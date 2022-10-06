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
        -- print("not enough money")
    end
end)

RegisterServerEvent("just_apartments:changeLease")
AddEventHandler("just_apartments:changeLease", function(data)
    local lastPayment = MySQL.update.await('UPDATE owned_apartments SET renew = @renew WHERE id = @id', {['@id'] = data.id, ['@renew'] = tonumber(data.renew)})
end)

RegisterServerEvent("just_apartments:getOwnedApartments")
AddEventHandler("just_apartments:getOwnedApartments", function(apartment, coords)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local id = MySQL.scalar.await('SELECT id FROM owned_apartments WHERE owner = @owner AND apartment = @apartment', { ['@owner'] = xPlayer.identifier, ['@apartment'] = apartment })
    local expired = MySQL.scalar.await('SELECT expired FROM owned_apartments WHERE id = @id', {['@id'] = id})
    local renewDate = MySQL.scalar.await('SELECT renewDate FROM owned_apartments WHERE id = @id', {['@id'] = id})
    local price = MySQL.scalar.await('SELECT Price FROM apartments WHERE name = @name', { ['@name'] = apartment })
    if id ~= nil and expired == 0 then
        local renew = MySQL.scalar.await('SELECT renew FROM owned_apartments WHERE id = @id', {['@id'] = id})
        local data = {coords = coords, id = id, price = price, renewDate = renewDate, renew = renew}
        TriggerClientEvent('just_apartments:entranceMenu', _source, data)
    else
        local id = false
        local data = {coords = coords, id = id, price = price, renewDate = renewDate}
        TriggerClientEvent('just_apartments:entranceMenu', _source, data)
    end
end)

RegisterServerEvent("just_apartments:checkApptOwnership")
AddEventHandler("just_apartments:checkApptOwnership", function(apartment, type, appt_id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source

	local id = MySQL.scalar.await('SELECT id FROM owned_apartments WHERE owner = @owner AND apartment = @apartment', {['@owner'] = xPlayer.identifier,['@apartment'] = apartment})
    if id ~= nil then
        if type == "Wardrobe" then
            TriggerClientEvent('just_apartments:enteredWardrobe', _source)
        elseif type == "Stash" then
            TriggerClientEvent('just_apartments:enteredStash', _source, id, apartment)
        end
    else
        local id2 = MySQL.scalar.await('SELECT id FROM apartment_keys WHERE appt_id = @appt_id AND player = @player', {['@appt_id'] = appt_id,['@player'] = xPlayer.identifier})
        if id2 ~= nil then
            -- exports.xng_parsingtable:ParsingTable_sv(id2)
            if type == "Wardrobe" then
                TriggerClientEvent('just_apartments:enteredWardrobe', _source)
            elseif type == "Stash" then
                TriggerClientEvent('just_apartments:enteredStash', _source, appt_id, apartment)
            end
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
                -- TriggerClientEvent("swt_notifications:Icon",v2 , 'Someones at the door',"top-right",5000,"blue-10","white",true,"mdi-doorbell")
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

RegisterServerEvent("just_apartments:getPlayersAtDoor")
AddEventHandler("just_apartments:getPlayersAtDoor", function(coords, name, id, exit)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if id == nil then 
        TriggerClientEvent('just_apartments:exitMenu', _source, coords)
    else
        local id2 = MySQL.scalar.await('SELECT id FROM apartment_keys WHERE appt_id = @appt_id AND player = @player', {['@appt_id'] = id,['@player'] = xPlayer.identifier})

        if id2 ~= nil then
            TriggerClientEvent('just_apartments:exitMenu', _source, coords, playersAtDoor[name..id], exit)
        else
            MySQL.query('SELECT * FROM apartment_keys WHERE appt_id = @appt_id',{
                ['@appt_id'] = id
            }, function(keyholders)
                TriggerClientEvent('just_apartments:exitMenu', _source, coords, playersAtDoor[name..id], exit, keyholders)
            end)
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
        -- TriggerClientEvent("swt_notifications:Icon", _source , 'Key given',"top-right",5000,"blue-10","white",true,"mdi-key-variant")
        -- TriggerClientEvent("swt_notifications:Icon", data.target , 'Key recieved',"top-right",5000,"blue-10","white",true,"mdi-key-variant")
    else
        TriggerClientEvent("just_apartments:notification", _source , 'Person already has keys', nil, "error")
        -- TriggerClientEvent("swt_notifications:Icon", _source , 'Person already has keys',"top-right",5000,"red","white",true,"mdi-alert-circle-outline")
    end
end)

RegisterServerEvent("just_apartments:getAppartmentsWithKeys")
AddEventHandler("just_apartments:getAppartmentsWithKeys", function(data, currentApartment)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.query('SELECT * FROM apartment_keys WHERE appt_name = @appt_name AND player = @player',{
        ['@appt_name'] = currentApartment,
        ['@player'] = xPlayer.identifier
    }, function(apartments)
        -- exports.xng_parsingtable:ParsingTable_sv(apartments)
        TriggerClientEvent('just_apartments:keyEntryMenu', _source, apartments, data)
    end)
end)

RegisterServerEvent("just_apartments:removeApartmentKeys")
AddEventHandler("just_apartments:removeApartmentKeys", function(data)
    local id = data.id
    MySQL.update('DELETE FROM apartment_keys WHERE id = @id', {['@id'] = id}, function(affectedRows)
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