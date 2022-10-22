ESX             = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local instances = {}
 
RegisterServerEvent("instance:set")
AddEventHandler("instance:set", function(set)
    print('[INSTANCES] Instances looked like this: ', json.encode(instances))
    local src = source
    -- TriggerClientEvent('DoTheBigRefreshYmaps', src)
    local instanceSource = 0
    if set then
        if set == 0 then
            for k,v in pairs(instances) do
                for k2,v2 in pairs(v) do
                    if v2 == src then
                        table.remove(v, k2)
                        if #v == 0 then
                            instances[k] = nil
                        end
                    end
                end
            end
        end
        instanceSource = set
    else
        instanceSource = math.random(1, 1000)
        while instances[instanceSource] and #instances[instanceSource] >= 1 do
            instanceSource = math.random(1, 1000)
            Citizen.Wait(1)
        end
    end
    print(instanceSource)
    if instanceSource ~= 0 then
        if not instances[instanceSource] then
            instances[instanceSource] = {}
        end
        table.insert(instances[instanceSource], src)
    end
    SetPlayerRoutingBucket(src, instanceSource)
    print('[INSTANCES] Instances now looks like this: ', json.encode(instances))
end)
 
Namedinstances = {}

RegisterServerEvent("instance:setNamed")
AddEventHandler("instance:setNamed", function(setName)
    print('[INSTANCES] Named Instances looked like this: ', json.encode(Namedinstances))
    local src = source
    local instanceSource = nil
 
    if setName == 0 then
            for k,v in pairs(Namedinstances) do
                for k2,v2 in pairs(v.people) do
                    if v2 == src then
                        table.remove(v.people, k2)
                    end
                end
                if #v.people == 0 then
                    Namedinstances[k] = nil
                end
            end
        instanceSource = setName
    else
        for k,v in pairs(Namedinstances) do
            if v.name == setName then
                instanceSource = k
            end
        end
        if instanceSource == nil then
            instanceSource = math.random(1, 1000)
 
            while Namedinstances[instanceSource] and #Namedinstances[instanceSource] >= 1 do
                instanceSource = math.random(1, 1000)
                Citizen.Wait(1)
            end
        end
    end
    if instanceSource ~= 0 then
        if not Namedinstances[instanceSource] then
            Namedinstances[instanceSource] = {name = setName, people = {}}
        end
        table.insert(Namedinstances[instanceSource].people, src)
    end
    SetPlayerRoutingBucket(src, instanceSource)
    print('[INSTANCES] Named Instances now look like this: ', json.encode(Namedinstances))
end)

local playersAtDoor = {}

RegisterServerEvent("just_apartments:purchaseApartment")
AddEventHandler("just_apartments:purchaseApartment", function(apartment, currentApartmentLabel)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local Price = MySQL.scalar.await('SELECT Price FROM apartments WHERE Name = @Name', {['@Name'] = apartment})
    local rentLength = MySQL.scalar.await('SELECT rentLength FROM apartments WHERE Name = @Name', {['@Name'] = apartment})
    local balance

    if Config.usePEFCL then
        balance = exports.pefcl:getDefaultAccountBalance(_source)
        balance = balance.data
    else
        balance = xPlayer.getAccount('bank').money
    end

    if Price <= balance then
        local t = os.time()
        local date = os.date("%Y%m%d",t)
        local d = rentLength
        local renewDate = t + d * 24 * 60 * 60
        local oldLease = MySQL.scalar.await('SELECT id FROM owned_apartments WHERE apartment = @apartment AND owner = @owner', {['@apartment'] = apartment, ['@owner'] = xPlayer.identifier})
        if oldLease ~= nil then
            local lastPayment = MySQL.update.await('UPDATE owned_apartments SET lastPayment = @lastPayment WHERE id = @id', {['@id'] = oldLease, ['@lastPayment'] = tonumber(date)})
            local renewDateChange = MySQL.update.await('UPDATE owned_apartments SET renewDate = @renewDate WHERE id = @id', {['@id'] = oldLease, ['@renewDate'] = os.date("%Y%m%d",renewDate)})
            local lastPayment = MySQL.update.await('UPDATE owned_apartments SET renew = @renew WHERE id = @id', {['@id'] = oldLease, ['@renew'] = tonumber(1)})
            local renewDateChange = MySQL.update.await('UPDATE owned_apartments SET expired = @expired WHERE id = @id', {['@id'] = oldLease, ['@expired'] = tonumber(0)})
            if Config.usePEFCL then
                exports.pefcl:removeBankBalance(_source, { amount = Price, message = (currentApartmentLabel.." lease renewal") })
            else 
                xPlayer.removeAccountMoney('bank', Price)
            end
        else
            MySQL.insert('INSERT INTO `owned_apartments` (`owner`, `lastPayment`, `renewDate`, `apartment`) VALUES (@owner, @lastPayment, @renewDate, @apartment)', {
                ['@apartment'] = apartment,
                ['@lastPayment'] = os.date("%Y%m%d",t),
                ['@renewDate'] = os.date("%Y%m%d",renewDate),
                ['@owner'] = xPlayer.identifier
            })
            if Config.UseOxInventory then
                MySQL.scalar('SELECT id FROM owned_apartments WHERE apartment = @apartment AND owner = @owner', {['@apartment'] = apartment, ['@owner'] = xPlayer.identifier}, function(id)
                    if id then
                        exports.ox_inventory:RegisterStash((apartment..id.."Stash"), (apartment.." Stash - "..id), 50, 100000, id)
                    end
                end)
            end
            if Config.usePEFCL then
                exports.pefcl:removeBankBalance(_source, { amount = Price, message = ("Apartment lease at "..currentApartmentLabel) })
            else 
                xPlayer.removeAccountMoney('bank', Price)
            end
        end
    else
        TriggerClientEvent("just_apartments:notification", _source , 'Not enough money', nil, "error")
    end
end)

RegisterServerEvent("just_apartments:changeLease")
AddEventHandler("just_apartments:changeLease", function(data)
    local lastPayment = MySQL.update.await('UPDATE owned_apartments SET renew = @renew WHERE id = @id', {['@id'] = data.id, ['@renew'] = tonumber(data.renew)})
end)

lib.callback.register('just_apartments:getOwnedApartments', function(source, apartment, coords)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local id = MySQL.scalar.await('SELECT id FROM owned_apartments WHERE owner = @owner AND apartment = @apartment', { ['@owner'] = xPlayer.identifier, ['@apartment'] = apartment })
    local expired = MySQL.scalar.await('SELECT expired FROM owned_apartments WHERE id = @id', {['@id'] = id})
    local renewDate = MySQL.scalar.await('SELECT renewDate FROM owned_apartments WHERE id = @id', {['@id'] = id})
    local price = MySQL.scalar.await('SELECT Price FROM apartments WHERE name = @name', { ['@name'] = apartment })
    if id ~= nil and expired == 0 then
        local renew = MySQL.scalar.await('SELECT renew FROM owned_apartments WHERE id = @id', {['@id'] = id})
        local data = {coords = coords, id = id, price = price, renewDate = renewDate, renew = renew}
        return data
    else
        local id = false
        local data = {coords = coords, id = id, price = price, renewDate = renewDate}
        return data
    end
end)

lib.callback.register('just_apartments:checkApptOwnership', function(source, apartment, appt_id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source

	local id = MySQL.scalar.await('SELECT id FROM owned_apartments WHERE owner = @owner AND apartment = @apartment', {['@owner'] = xPlayer.identifier,['@apartment'] = apartment})
    if id ~= nil then
        return true
    else
        local id2 = MySQL.scalar.await('SELECT id FROM apartment_keys WHERE appt_id = @appt_id AND player = @player', {['@appt_id'] = appt_id,['@player'] = xPlayer.identifier})
        if id2 ~= nil then
            -- exports.xng_parsingtable:ParsingTable_sv(id2)
            return true
        end
    end
end)

RegisterServerEvent("just_apartments:alertOwner")
AddEventHandler("just_apartments:alertOwner", function(data)
    local _source = source
    if not playersAtDoor[data.apartment..data.id] then
        playersAtDoor[data.apartment..data.id] = {
            name = data.apartment..data.id,
            people = {}
        }
    end
    table.insert(playersAtDoor[data.apartment..data.id].people, _source)
    -- exports.xng_parsingtable:ParsingTable_sv(playersAtDoor)
    for k,v in pairs(Namedinstances) do
        -- exports.xng_parsingtable:ParsingTable_sv(Namedinstances)
        if v.name == (data.apartment..data.id) then
            for k2,v2 in pairs(Namedinstances[k].people) do
                TriggerClientEvent("just_apartments:notification", _source , 'Someones at the door', "Go buzz them in", "info")
            end
        end
    end
end)

RegisterServerEvent("just_apartments:getBuildingApartments")
AddEventHandler("just_apartments:getBuildingApartments", function(data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.query('SELECT * FROM owned_apartments WHERE apartment = @apartment',{
        ['@apartment'] = data.currentApartment
    }, function(apartments)
        TriggerClientEvent('just_apartments:ringMenu', _source, apartments, data, xPlayer.identifier)
    end)
end)

lib.callback.register('just_apartments:getPlayersAtDoor', function(source, coords, name, id, exit)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if id == nil then
        TriggerClientEvent('just_apartments:exitMenu', _source, coords)
    else
        local id2 = MySQL.scalar.await('SELECT id FROM apartment_keys WHERE appt_id = @appt_id AND player = @player', {['@appt_id'] = id,['@player'] = xPlayer.identifier})
        if id2 ~= nil then
            return coords, playersAtDoor[name..id], exit
        else
            local keyholders = MySQL.query.await('SELECT * FROM apartment_keys WHERE appt_id = @appt_id', {['@appt_id'] = id})
            return coords, playersAtDoor[name..id], exit, keyholders
        end
    end
end)

RegisterServerEvent("just_apartments:bringPlayerIn")
AddEventHandler("just_apartments:bringPlayerIn", function(data)
    local _source = source
    -- exports.xng_parsingtable:ParsingTable_sv(data)
    for k,v in pairs(playersAtDoor) do
        for k2,v2 in pairs(v.people) do
            if v2 == data.player then
                table.remove(v.people, k2)
            end
        end
        if #v.people == 0 then
            playersAtDoor[k] = nil
        end
    end
    -- exports.xng_parsingtable:ParsingTable_sv(data)
    TriggerClientEvent('just_apartments:enterExitApartment', data.player, data)
end)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'just_apartments' or resourceName == GetCurrentResourceName() then
        MySQL.query('SELECT * FROM owned_apartments ', function(apartments)
            for i=1, #apartments, 1 do
                local todaysDate = tonumber(os.date("%Y%m%d",os.time()))
                if todaysDate > apartments[i].renewDate then
                    if apartments[i].renew then
                        local Price = MySQL.scalar.await('SELECT Price FROM apartments WHERE Name = @Name', {['@Name'] = apartments[i].apartment})
                        local rentLength = MySQL.scalar.await('SELECT rentLength FROM apartments WHERE Name = @Name', {['@Name'] = apartments[i].apartment})
                        local balance
                        if Config.usePEFCL then
                            balance = exports.pefcl:getTotalBankBalanceByIdentifier(source, apartments[i].owner)
                            balance = balance.data
                        else 
                            local accounts = MySQL.scalar.await('SELECT accounts FROM users WHERE identifier = @identifier', {['@identifier'] = apartments[i].owner})
                            accounts = json.decode(accounts)
                            balance = accounts.bank
                        end

                        if Price <= balance then 
                            local t = os.time()
                            local date = os.date("%Y%m%d",t)
                            local d = rentLength
                            local renewDate = t + d * 24 * 60 * 60
                            local lastPayment = MySQL.update.await('UPDATE owned_apartments SET lastPayment = @lastPayment WHERE id = @id', {['@id'] = apartments[i].id, ['@lastPayment'] = tonumber(date)})
                            local renewDateChange = MySQL.update.await('UPDATE owned_apartments SET renewDate = @renewDate WHERE id = @id', {['@id'] = apartments[i].id, ['@renewDate'] = os.date("%Y%m%d",renewDate)})
                            if lastPayment ~= nil and renewDateChange ~= nil then
                                if Config.usePEFCL then
                                    exports.pefcl:removeBankBalanceByIdentifier(source, { identifier = apartments[i].owner, amount = Price, message = apartments[i].apartment.." apartment lease renewal" })
                                else 
                                    accounts.bank = balance - Price
                                    MySQL.update.await('UPDATE users SET accounts = @accounts WHERE identifier = @identifier', {['@identifier'] = apartments[i].owner, ['@accounts'] = json.encode(accounts)})
                                end
                            end
                        else 
                            MySQL.update('UPDATE owned_apartments SET expired = @expired WHERE id = @id', {
                                ['@id'] = apartments[i].id,
                                ['@expired'] = 1
                            }, function(id)
                            end)
                        end
                    else
                        MySQL.update('UPDATE owned_apartments SET expired = @expired WHERE id = @id', {
                            ['@id'] = apartments[i].id,
                            ['@expired'] = 1
                        }, function(id)
                        end)
                    end
                end
            end    
        end)
    end
end)

----------
-- Keys --
----------

RegisterServerEvent("just_apartments:giveKeys")
AddEventHandler("just_apartments:giveKeys", function(data)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(data.target)
    local hasKeys = MySQL.scalar.await('SELECT id FROM apartment_keys WHERE appt_id = @appt_id AND player = @player', {['@appt_id'] = data.appt_id, ['@player'] = xTarget.identifier})
    -- exports.xng_parsingtable:ParsingTable_sv(xTarget)
    if hasKeys == nil then
        MySQL.insert('INSERT INTO `apartment_keys` (`appt_id`, `appt_name`, `player`, `player_name`, `appt_owner`) VALUES (@appt_id, @appt_name, @player, @player_name, @appt_owner)', {
            ['@appt_id'] = data.appt_id,
            ['@appt_name'] = data.appt_name,
            ['@player'] = xTarget.identifier,
            ['@player_name'] = xTarget.name,
            ['@appt_owner'] = xPlayer.identifier
        })
        TriggerClientEvent("just_apartments:notification", _source , 'Key given', nil, "success")
        TriggerClientEvent("just_apartments:notification", data.target , 'Key recieved', nil, "success")
    else
        TriggerClientEvent("just_apartments:notification", _source , 'Person already has keys', nil, "error")
    end
end)

lib.callback.register('just_apartments:getAppartmentsWithKeys', function(source, currentApartment)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.query('SELECT * FROM apartment_keys WHERE appt_name = @appt_name AND player = @player',{
        ['@appt_name'] = currentApartment,
        ['@player'] = xPlayer.identifier
    }, function(apartments)
        exports.xng_parsingtable:ParsingTable_sv(apartments)
        return apartments
    end)
end)

RegisterServerEvent("just_apartments:removeApartmentKeys")
AddEventHandler("just_apartments:removeApartmentKeys", function(data)
    MySQL.update('DELETE FROM apartment_keys WHERE id = @id', {['@id'] = data.id}, function(affectedRows)
        if affectedRows then
            print(affectedRows)
        end
    end)
end)

-----------
-- Stash --
-----------

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() and Config.UseOxInventory then
        exports.ox_inventory:RegisterStash("AltaStreetAppts0Stash", "Alta Street Apartments", 25, 100000, true)
        MySQL.query('SELECT * FROM owned_apartments ', function(apartments)
            for i=1, #apartments, 1 do
                exports.ox_inventory:RegisterStash((apartments[i].apartment..apartments[i].id.."Stash"), (apartments[i].apartment.." Stash - "..apartments[i].id), 50, 100000, apartments[i].id)
            end
        end)
    end
end)

-------------------------
-- Save Last Apartment --
-------------------------

function Split(s, delimiter)
    if s ~= nil then
        result = {};
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match);
        end
        return result;
    end
end

RegisterServerEvent("just_apartments:updateLastApartment")
AddEventHandler("just_apartments:updateLastApartment", function(last_property)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.update('UPDATE users SET last_property = @last_property WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@last_property'] = last_property
    }, function(id)
    end)
end)

RegisterServerEvent("just_apartments:getLastApartment")
AddEventHandler("just_apartments:getLastApartment", function()
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer ~= nil then
        local last_property = MySQL.scalar.await('SELECT last_property FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
        local apartment_id = Split(last_property, " ")
        if apartment_id ~= nil then
            TriggerClientEvent('just_apartments:spawnInProperty', _source, apartment_id[1], apartment_id[2])
        end
    end
end)

------------
-- Garage --
------------

lib.callback.register('just_apartments:GetVehicles', function(source, garage)
    local vehicles = {}
    local results = MySQL.Sync.fetchAll("SELECT `plate`, `vehicle`, `stored`, `garage`, `job` FROM `owned_vehicles` WHERE `garage` = @garage", {
        ['@garage'] = garage
    })
    if results[1] ~= nil then
        for i = 1, #results do
            local result = results[i]
            local veh = json.decode(result.vehicle)
            vehicles[#vehicles+1] = {plate = result.plate, vehicle = veh, stored = result.stored, garage = result.garage}
        end
        return vehicles
    end
end)

RegisterServerEvent("just_apartments:SpawnVehicle")
AddEventHandler("just_apartments:SpawnVehicle", function(model, plate, coords, heading)
    if type(model) == 'string' then model = GetHashKey(model) end
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = GetAllVehicles()
    plate = ESX.Math.Trim(plate)
    for i = 1, #vehicles do
        if ESX.Math.Trim(GetVehicleNumberPlateText(vehicles[i])) == plate then
            if GetVehiclePetrolTankHealth(vehicle) > 0 and GetVehicleBodyHealth(vehicle) > 0 then
            return xPlayer.showNotification(Locale('vehicle_already_exists')) end
        end
    end
    MySQL.Async.fetchAll('SELECT vehicle, plate, garage FROM `owned_vehicles` WHERE plate = @plate', {['@plate'] = ESX.Math.Trim(plate)}, function(result)
        if result[1] then
            CreateThread(function()
                local entity = Citizen.InvokeNative(`CREATE_AUTOMOBILE`, model, coords.x, coords.y, coords.z, coords.h)
                SetEntityHeading(entity, coords.h)
                local ped = GetPedInVehicleSeat(entity, -1)
                if ped > 0 then
                    for i = -1, 6 do
                        ped = GetPedInVehicleSeat(entity, i)
                        local popType = GetEntityPopulationType(ped)
                        if popType <= 5 or popType >= 1 then
                            DeleteEntity(ped)
                        end
                    end
                end
                local playerPed = GetPlayerPed(xPlayer.source)
                local timer = GetGameTimer()
                while GetVehiclePedIsIn(playerPed) ~= entity do
                    Wait(10)
                    SetPedIntoVehicle(playerPed, entity, -1)
                    if timer - GetGameTimer() > 15000 then
                        break
                    end
                end
                local ent = Entity(entity)
                ent.state.vehicleData = result[1]
            end)
        end
    end)
end)

RegisterServerEvent("just_apartments:SaveVehicle")
AddEventHandler("just_apartments:SaveVehicle", function(vehicle, plate, ent, garage)
    MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle, `garage` = @garage, `last_garage` = @garage, `stored` = @stored WHERE `plate` = @plate', {
        ['@vehicle'] = json.encode(vehicle),
        ['@plate'] = ESX.Math.Trim(plate),
        ['@stored'] = 1,
        ['@garage'] = garage
    })
    local ent = NetworkGetEntityFromNetworkId(ent)
    DeleteEntity(ent)
end)

lib.callback.register('just_apartments:CheckOwnership', function(source, plate)
    local result = MySQL.scalar.await('SELECT vehicle FROM owned_vehicles WHERE plate = ?', {plate})
    if result ~= nil then
        return true
    else
        -- Player tried to cheat
        TriggerClientEvent("just_apartments:notification", source, "Wait this is a local's vehicle", nil, "error")
        return false
    end
end)

lib.callback.register('just_apartments:garageCheck', function(source, apartment)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local ownedapartments = MySQL.Sync.fetchAll('SELECT id, apartment, expired FROM owned_apartments WHERE owner = @owner AND apartment = @apartment AND expired = @expired', {['@owner'] = xPlayer.identifier, ['@apartment'] = apartment, ['@expired'] = 0})
    if ownedapartments ~= nil then
        return ownedapartments
    end
end)

lib.callback.register('just_apartments:keyCheck', function(source, apartment)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local keyedApartments = MySQL.Sync.fetchAll('SELECT * FROM apartment_keys WHERE appt_name = @appt_name AND player = @player', {['@appt_name'] = apartment,['@player'] = xPlayer.identifier})
    if keyedApartments ~= nil then
        return keyedApartments
    end
end)