local spot
local ownedGarage
local keyedGarages
local state = nil
local visible = false
local passedCheck = false
local checkOwnership = true
local AtStash = false
local currentApartment = nil
local currentApartmentID = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    spot = nil
    ownedGarage = nil
    keyedGarages = nil
    state = nil
    visible = false
    passedCheck = false
    AtStash = false
    currentApartment = nil
    currentApartmentID = nil
end)

local function Blips(coords, type, label, job, blipOptions)
    if job then return end
    if blip == false then return end
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, blipOptions.sprite or 357)
    SetBlipScale(blip, blipOptions.scale or 0.8)
    SetBlipColour(blip, blipOptions.colour ~= nil and blipOptions.colour or type == 'car' and Config.BlipColors.Car or type == 'boat' and Config.BlipColors.Boat or Config.BlipColors.Aircraft)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Apartment")
    EndTextCommandSetBlipName(blip)
end

function comma_value(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function Split(s, delimiter)
    if s ~= nil then
        result = {};
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match);
        end
        return result;
    end
end

function onEnter(self)
    local apartment = Split(self.name, " ")
    currentApartment = apartment[1]
    if self.type == "garage" then

    elseif self.type == "entrance" then
        
    elseif self.type == "wardrobe" then

    elseif self.type == "stash" then

    elseif self.type == "exit" then

    end
end

function onExit(self)
    checkOwnership = true
    lib.hideTextUI()
    Citizen.Wait(100)
    visible = false
    passedCheck = false
	if self.type == "garage" then
		currentApartment = nil
    elseif self.type == "entrance" then
    elseif self.type == "wardrobe" then

    elseif self.type == "stash" then

    elseif self.type == "exit" then

	end
end

function insideZone(self)
    if self.type == "garage" then
        local ped = PlayerPedId()
        local inVehicle = GetVehiclePedIsIn(ped, false)
        local apartment = Split(self.name, " ")
        currentApartment = apartment[1]
        spot = apartment[3]
        if passedCheck then
            if not visible then
                if inVehicle ~= 0 then
                    visible = true
                    lib.showTextUI("[E] Store Vehicle", {icon = "fa-solid fa-car"})
                else
                    visible = true
                    lib.showTextUI("[E] Open Garage", {icon = "fa-solid fa-car"})
                end
            end
            if IsControlJustReleased(0, 54) then
                if inVehicle ~= 0 then
                    TriggerEvent('just_apartments:viewGarages', currentApartment, 'just_apartments:StoreVehicle', inVehicle, false)
                    passedCheck = false
                else
                    TriggerEvent('just_apartments:viewGarages', currentApartment, 'just_apartments:GetOwnedVehicles', nil, true)
                    passedCheck = false
                end
            end
        else
            ownedGarage = lib.callback.await('just_apartments:garageCheck', false, currentApartment)
            keyedGarages = lib.callback.await('just_apartments:keyCheck', false, currentApartment)
            if ownedGarage ~= nil then
                for i=1, #ownedGarage, 1 do
                    if ownedGarage[i].apartment == currentApartment then
                        passedCheck = true
                        break
                    end
                end
            end
            if keyedGarages ~= nil then
                for i=1, #keyedGarages, 1 do
                    if keyedGarages[i].appt_name == currentApartment then
                        passedCheck = true
                        break
                    end
                end
            end
        end
    elseif self.type == "entrance" then
        if not visible then
            visible = true
            lib.showTextUI("[E] Apartments", {icon = "fa-solid fa-building"})
        end
        if IsControlJustReleased(0, 54) then
            if currentApartment == 'AltaStreetAppts' then 
                TriggerEvent('just_apartments:enterExitApartment', Config.Apartments[currentApartment].exit, "Entering")
            else
                lib.callback('just_apartments:getOwnedApartments', false, function(data)
                    local apartments = lib.callback.await('just_apartments:keyCheck', false, currentApartment)
                    -- print(apartments, data)
                    -- if apartments ~= nil then
                    --     exports.xng_parsingtable:ParsingTable_cl(apartments)
                    -- end
                    -- exports.xng_parsingtable:ParsingTable_cl(data)
                    TriggerEvent('just_apartments:keyEntryMenu', apartments, data)
                end, currentApartment, self.tpCoords)
            end
        end
    elseif self.type == "wardrobe" then
        if Config.BrpFivemAppearance or Config.ox_appearance then
            if currentApartment == "AltaStreetAppts" then
                if not visible then
                    visible = true
                    lib.showTextUI("[E] Wardrobe", {icon = "fa-solid fa-shirt"})
                end
                if IsControlJustReleased(0, 54) then
                    if Config.BrpFivemAppearance then
                        TriggerEvent('fivem-appearance:useWardrobe')
                    elseif Config.ox_appearance then
                        TriggerEvent('ox_appearance:wardrobe')
                    end                end
            else
                if checkOwnership then
                    passedCheck = lib.callback.await('just_apartments:checkApptOwnership', false, currentApartment, currentApartmentID)
                end
                if passedCheck then
                    checkOwnership = false
                    if not visible then
                        visible = true
                        lib.showTextUI("[E] Wardrobe", {icon = "fa-solid fa-shirt"})
                    end
                    if IsControlJustReleased(0, 54) then
                        if Config.BrpFivemAppearance then
                            TriggerEvent('fivem-appearance:useWardrobe')
                        elseif Config.ox_appearance then
                            TriggerEvent('ox_appearance:wardrobe')
                        end
                    end
                end
            end
        end
    elseif self.type == "stash" then
        if Config.UseOxInventory then
            if currentApartment == "AltaStreetAppts" then
                if not visible then
                    visible = true
                    lib.showTextUI("[E] Stash", {icon = "fa-solid fa-box-open"})
                end
                if IsControlJustReleased(0, 54) then
                    exports.ox_inventory:openInventory('stash', {id = ("AltaStreetAppts".."0".."Stash"), owner = 0})
                end
            else
                if checkOwnership then
                    passedCheck = lib.callback.await('just_apartments:checkApptOwnership', false, currentApartment, currentApartmentID)
                end
                if passedCheck then
                    checkOwnership = false
                    if not visible then
                        visible = true
                        lib.showTextUI("[E] Stash", {icon = "fa-solid fa-box-open"})
                    end
                    if IsControlJustReleased(0, 54) then
                        exports.ox_inventory:openInventory('stash', {id = (currentApartment..currentApartmentID.."Stash"), owner = currentApartmentID})
                    end
                end
            end
        end
    elseif self.type == "exit" then
        if not visible then
            visible = true
            lib.showTextUI("[E] Exit Apartment", {icon = "fa-solid fa-door-open"})
        end
        if IsControlJustReleased(0, 54) then
            if Config.Apartments[currentApartment].seperateExitPoint == true then

                if currentApartment == 'AltaStreetAppts' then
                    TriggerEvent('just_apartments:enterExitApartment', Config.Apartments[currentApartment].exitPoint, "Exiting")
                else
                    lib.callback('just_apartments:getPlayersAtDoor', false, function(coords, playersAtDoor, exit, keyholders)
                        -- print(coords, playersAtDoor, exit, keyholders)
                        TriggerEvent('just_apartments:exitMenu', coords, playersAtDoor, exit, keyholders)
                    end, Config.Apartments[currentApartment].exitPoint, currentApartment, currentApartmentID, Config.Apartments[currentApartment].exit)
                end
            else
                lib.callback('just_apartments:getPlayersAtDoor', false, function(coords, playersAtDoor, exit, keyholders)
                    TriggerEvent('just_apartments:exitMenu', coords, playersAtDoor, exit, keyholders)
                end, Config.Apartments[currentApartment].exitPoint, currentApartment, currentApartmentID, Config.Apartments[currentApartment].exit)
            end
        end
    end
end

for k, v in pairs(Config.Apartments) do
    lib.zones.box({
        coords = vec3(v.entrance.x, v.entrance.y, v.entrance.z),
        size = vec3(3, 3, 3),
        rotation = v.entrance.h,
        debug = false,
        inside = insideZone,
        onEnter = onEnter,
        onExit = onExit,
        name = k.." Entrance",
        tpCoords = v.exit,
        type = "entrance",
    })
    if v.wardrobe ~= nil then
        lib.zones.box({
            coords = vec3(v.wardrobe.x, v.wardrobe.y, v.wardrobe.z),
            size = vec3(v.wardrobe.w, v.wardrobe.l, 4),
            rotation = v.wardrobe.h,
            debug = false,
            inside = insideZone,
            onEnter = onEnter,
            onExit = onExit,
            name = v.zone.name.." Wardrobe",
            type = "wardrobe",
        })
    end
    if v.stash ~= nil then
        lib.zones.box({
            coords = vec3(v.stash.x, v.stash.y, v.stash.z),
            size = vec3(3, 5.4, 4),
            rotation = v.stash.h,
            debug = false,
            inside = insideZone,
            onEnter = onEnter,
            onExit = onExit,
            name = v.zone.name.." Stash",
            type = "stash",
        })
    end
    lib.zones.box({
        coords = vec3(v.exit.x, v.exit.y, v.exit.z),
        size = vec3(3, 3, 3),
        rotation = v.exit.h,
        debug = false,
        inside = insideZone,
        onEnter = onEnter,
        onExit = onExit,
        name = v.zone.name.." Exit",
        tpCoords = v.entrance,
        type = "exit",
    })
	if v.parking ~= nil and Config.useGarages then
		for k2, v2 in pairs(v.parking) do
			lib.zones.box({
				coords = vec3(v2.x, v2.y, v2.z),
				size = vec3(3, 5.4, 4),
				rotation = v2.h,
				debug = false,
				inside = insideZone,
				onEnter = onEnter,
				onExit = onExit,
				name = k.." parking "..k2,
				type = "garage",
			})
		end
	end

    if v.blip ~= false then
        Blips(vector3(v.entrance.x, v.entrance.y, v.entrance.z), v.type, v.label, v.job, v.blip)
    end
end

RegisterNetEvent('just_apartments:keyEntryMenu')
AddEventHandler('just_apartments:keyEntryMenu', function (apartments, data)
    local data = data
    local options = {}
    TriggerEvent('just_apartments:leaseMenu', data)
    if not data.id then
        options = {
            {
                title = "Purchase "..Config.Apartments[currentApartment].label.." Apartment",
                description = "$"..comma_value(data.price),
                event = 'just_apartments:purchaseApartment',
                args = {
                    currentApartment = currentApartment,
                    coords = data.coords,
                    id = data.id
                }
            },
            {
                title = "Preview Appartment",
                description = "OOOOOO This is nice",
                event = 'just_apartments:enterExitApartment',
                args = {
                    coords = data.coords,
                    enteringExiting = "Viewing"
                }
            },
            {
                title = "Ring Apartment",
                description = "Let Me In Now",
                arrow = true,
                serverEvent = 'just_apartments:getBuildingApartments',
                args = {
                    currentApartment = currentApartment,
                    coords = data.coords,
                    id = data.id,
                    ring = true
                }
            },
        }
    else
        options = {
            {
                title = "Appt: "..data.id,
                description = "Enter",
                event = 'just_apartments:enterExitApartment',
                args = {
                    coords = Config.Apartments[currentApartment].exit,
                    enteringExiting = "Entering",
                    id = data.id
                }
            },
            {
                title = "Change Lease",
                description = "Should I Stay Or Should I Go Now",
                menu = 'just_apartments:leaseMenu',
            },
            {
                title = "Ring Apartment",
                description = "Let Me In Now",
                arrow = true,
                serverEvent = 'just_apartments:getBuildingApartments',
                args = {
                    currentApartment = currentApartment,
                    coords = Config.Apartments[currentApartment].exit,
                    id = data.id,
                    ring = true
                }
            },
        }
    end

    if apartments ~= nil then
        for i=1, #apartments, 1 do
            if apartments[i].id ~= nil then
                table.insert(options,  {
                    title = "Shared Apartments",
                    description = "It's Not Mine But It's Still Nice",
                    arrow = true,
                    event = 'just_apartments:keyEntry',
                    args = {
                        apartments = apartments,
                        data = data
                    },
                })
            end
        end
    end
    lib.registerContext({
        id = 'just_apartments:keyEntryMenu',
        title = Config.Apartments[currentApartment].label,
        options = options
    })
    lib.showContext('just_apartments:keyEntryMenu')
end)

RegisterNetEvent('just_apartments:keyEntry')
AddEventHandler('just_apartments:keyEntry', function (args)
    -- exports.xng_parsingtable:ParsingTable_cl(args)

    local apartments = args.apartments
    local data = args.data
    local options = {}
    for i=1, #apartments, 1 do
        table.insert(options,  {
            title = "Appt: "..apartments[i].appt_id,
            description = "Enter",
            event = 'just_apartments:enterExitApartment',
            args = {
                coords = data.coords,
                enteringExiting = "Entering",
                id = apartments[i].appt_id
            }
        })
	end
    lib.registerContext({
        id = 'just_apartments:keyEntry',
        title = Config.Apartments[currentApartment].label.." Appts",
        menu = "just_apartments:keyEntryMenu",
        options = options
    })
    lib.showContext('just_apartments:keyEntry')
end)

----------
-- Ring --
----------


RegisterNetEvent('just_apartments:ringMenu')
AddEventHandler('just_apartments:ringMenu', function (apartments, data, identifier)
    local data = data
    local options = {}
    for i=1, #apartments, 1 do
        if apartments[i].owner ~= identifier then
            table.insert(options,  {
                title = "Ring Appt: "..apartments[i].id,
                event = 'just_apartments:ringAppartment',
                args = {
                    coords = data.coords,
                    enteringExiting = "Entering",
                    id = apartments[i].id,
                    apartment = apartments[i].apartment
                }
            })
        end
	end
    Citizen.Wait(100)
    lib.registerContext({
        id = 'just_apartments:ringMenu',
        title = Config.Apartments[currentApartment].label.." Appts",
        menu = "just_apartments:keyEntryMenu",
        options = options
    })
	Citizen.Wait(100)
    lib.showContext('just_apartments:ringMenu')
end)

RegisterNetEvent('just_apartments:ringAppartment')
AddEventHandler('just_apartments:ringAppartment', function (data)
    TriggerServerEvent('just_apartments:alertOwner', data)
end)

-----------
-- Lease --
-----------

RegisterNetEvent('just_apartments:leaseMenu')
AddEventHandler('just_apartments:leaseMenu', function (data)
    local data = data
    if data.renew == 1 then
        lib.registerContext({
            id = 'just_apartments:leaseMenu',
            title =  "Change Lease",
            menu = "just_apartments:keyEntryMenu",
            options = {{
                title = "Cancel Lease",
                description = "Renews: "..string.sub(data.renewDate,5,6).."/"..string.sub(data.renewDate,7,8).."/"..string.sub(data.renewDate,1,4).." For $"..comma_value(data.price),
                event = 'just_apartments:changeLease',
                args = {
                    renew = 0,
                    id = data.id
                }
            }}
        })
    elseif data.renewDate ~= nil then
        lib.registerContext({
            id = 'just_apartments:leaseMenu',
            title =  "Change Lease",
            menu = "just_apartments:keyEntryMenu",
            options = {{
                title = "Resume Lease $"..comma_value(data.price),
                description = "Lease Ends: "..string.sub(data.renewDate,5,6).."/"..string.sub(data.renewDate,7,8).."/"..string.sub(data.renewDate,1,4),
                event = 'just_apartments:changeLease',
                args = {
                    renew = 1,
                    id = data.id
                }
            }}
        })
    end
end)

RegisterNetEvent('just_apartments:changeLease')
AddEventHandler('just_apartments:changeLease', function (data)
    TriggerServerEvent('just_apartments:changeLease', data)
end)

RegisterNetEvent('just_apartments:purchaseApartment')
AddEventHandler('just_apartments:purchaseApartment', function (currentApartment)
    TriggerServerEvent('just_apartments:purchaseApartment', currentApartment.currentApartment)
    Citizen.Wait(250)
    TriggerServerEvent('just_apartments:getOwnedApartments', currentApartment.currentApartment, currentApartment.exit)
end)

RegisterNetEvent('just_apartments:exitMenu')
AddEventHandler('just_apartments:exitMenu', function (coords, playersAtDoor, exitDoor, keyholders)
    local playersAtDoor = playersAtDoor

    local options = {
        {
            title = "Exit Apartment",
            description = "Go Out Into The World",
            event = 'just_apartments:enterExitApartment',
            args = {
                coords = coords,
                enteringExiting = "Exiting"
            }
        },
    }

    if keyholders ~= nil then
        if #keyholders > 0 then
            table.insert(options,  {
                title = "Manage Keyholders",
                description = "Who's Got Keys",
                arrow = true,
                event = 'just_apartments:keyholderMenu',
                args = {
                    keyholders = keyholders
                }
            })
        end
    end
    if playersAtDoor ~= nil then
        for i=1, #playersAtDoor.people, 1 do 
            table.insert(options,  {
                title = "Let In: "..playersAtDoor.people[i],
                description = "It's Always Nice To Have Company",
                arrow = true,
                event = 'just_apartments:letPlayerIn',
                args = {
                    coords = exitDoor,
                    enteringExiting = "Entering",
                    playersAtDoor = playersAtDoor,
                    player = playersAtDoor.people[i],
                    id = currentApartmentID
                }
            })
        end
    end

    Citizen.Wait(100)
    lib.registerContext({
        id = 'just_apartments:exitMenu',
        title = "Elevator",
        options = options
    })
    Citizen.Wait(100)
    lib.showContext('just_apartments:exitMenu')
end)

RegisterNetEvent('just_apartments:keyholderMenu')
AddEventHandler('just_apartments:keyholderMenu', function (data)
    local keyholders = data.keyholders
    local options = {}

    if keyholders ~= nil then
        for i=1, #keyholders, 1 do 
            table.insert(options,  {
                title = "Name: "..keyholders[i].player_name,
                description = "Remove Key",
                event = 'just_apartments:removeApartmentKeys',
                args = {
                    id = keyholders[i].id
                }
            })
        end
    end

    Citizen.Wait(100)
    lib.registerContext({
        id = 'just_apartments:keyholderMenu',
        title = "Keyholders",
        menu = "just_apartments:exitMenu",
        options = options
    })
    Citizen.Wait(100)
    lib.showContext('just_apartments:keyholderMenu')
end)

RegisterNetEvent('just_apartments:removeApartmentKeys')
AddEventHandler('just_apartments:removeApartmentKeys', function (data)
    local id = data.id
    TriggerServerEvent('just_apartments:removeApartmentKeys', id)
end)

RegisterNetEvent('just_apartments:letPlayerIn')
AddEventHandler('just_apartments:letPlayerIn', function (data)
    TriggerServerEvent('just_apartments:bringPlayerIn', data)
end)

RegisterNetEvent('just_apartments:enterExitApartment')
AddEventHandler('just_apartments:enterExitApartment', function (coords, enteringExiting)
    -- exports.xng_parsingtable:ParsingTable_cl(coords)
    if coords.id ~= nil then
        currentApartmentID = coords.id
    end
    local coords = coords
    local player = PlayerPedId()
    if currentApartment == 'AltaStreetAppts' then
        if IsControlJustReleased(0, 54) then
            if lib.progressBar({
                duration = 5000,
                label = enteringExiting.." Apartment",
                useWhileDead = false,
                canCancel = true,
                disable  = {
                    move = true,
                },
            }) then
                PlaySoundFrontend(-1, "CLOSED", "MP_PROPERTIES_ELEVATOR_DOORS", 1);
                Citizen.Wait(500)
                PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 0)
                Citizen.Wait(500)
                PlaySoundFrontend(-1, "OPENED", "MP_PROPERTIES_ELEVATOR_DOORS", 1);

                if enteringExiting == "Entering" then
                    TriggerServerEvent('instance:set')
                    TriggerServerEvent('just_apartments:updateLastApartment', 'AltaStreetAppts')
                else
                    TriggerServerEvent('instance:set', 0)
                    currentApartment = nil
                    currentApartmentID = nil
                    TriggerServerEvent('just_apartments:updateLastApartment', nil)
                end
                SetEntityCoords(player, coords.x, coords.y, coords.z)
                SetEntityHeading(player, coords.h)
                lib.hideTextUI()
            end
        end
    else
        if lib.progressBar({
            duration = 5000,
            label = coords.enteringExiting.." Apartment",
            useWhileDead = false,
            canCancel = true,
            disable  = {
                move = true,
            },
        }) then
            PlaySoundFrontend(-1, "CLOSED", "MP_PROPERTIES_ELEVATOR_DOORS", 1);
            Citizen.Wait(500)
            PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 0)
            Citizen.Wait(500)
            PlaySoundFrontend(-1, "OPENED", "MP_PROPERTIES_ELEVATOR_DOORS", 1);

            if coords.enteringExiting == "Entering" then
                TriggerServerEvent('instance:setNamed', currentApartment..coords.id)
                TriggerServerEvent('just_apartments:updateLastApartment', currentApartment.." "..coords.id)
                currentApartmentID = coords.id
                SetEntityCoords(player, coords.coords.x, coords.coords.y, coords.coords.z)
                SetEntityHeading(player, coords.coords.h)
            elseif coords.enteringExiting == "Exiting" then
                if state == "Viewing" then
                    TriggerServerEvent('instance:set', 0)
                    TriggerServerEvent('just_apartments:updateLastApartment', nil)
                    SetEntityCoords(player, Config.Apartments[currentApartment].entrance.x, Config.Apartments[currentApartment].entrance.y, Config.Apartments[currentApartment].entrance.z)
                    SetEntityHeading(player, Config.Apartments[currentApartment].entrance.h)
                else
                    TriggerServerEvent('instance:setNamed', 0)
                    TriggerServerEvent('just_apartments:updateLastApartment', nil)
                    SetEntityCoords(player, coords.coords.x, coords.coords.y, coords.coords.z)
                    SetEntityHeading(player, coords.coords.h)
                end
                state = nil
                currentApartment = nil
                currentApartmentID = nil
            elseif coords.enteringExiting == "Viewing" then
                state = "Viewing"
                TriggerServerEvent('instance:set')
                SetEntityCoords(player, coords.coords.x, coords.coords.y, coords.coords.z)
                SetEntityHeading(player, coords.coords.h)
            end
            lib.hideTextUI()
        end
    end
end)

----------
-- Keys --
----------

TriggerEvent('chat:addSuggestion', '/giveapptkey', 'Give closest person keys')
RegisterCommand('giveapptkey', function()
	TriggerEvent('just_apartments:givePlayerKeys')
end, false)

RegisterNetEvent('just_apartments:givePlayerKeys')
AddEventHandler('just_apartments:givePlayerKeys', function ()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 4.0 then
        local data = { target = GetPlayerServerId(closestPlayer), appt_id = currentApartmentID, appt_name = currentApartment }
        -- exports.xng_parsingtable:ParsingTable_cl(data)
		TriggerServerEvent('just_apartments:giveKeys', data)
	end
end)

RegisterNetEvent('just_apartments:removePlayerKeys')
AddEventHandler('just_apartments:removePlayerKeys', function ()
	TriggerServerEvent('just_apartments:removeKeys', data)
end)

RegisterNetEvent('just_apartments:notification')
AddEventHandler('just_apartments:notification', function (Notificationtitle, Notificationdescription, Notificationtype)
	lib.notify({
        title = Notificationtitle,
        description = Notificationdescription,
        status = Notificationtype
    })
end)

-----------
-- Stash --
-----------

RegisterNetEvent('just_apartments:enteredStash')
AddEventHandler('just_apartments:enteredStash', function (ApptID, apartment)
    local ApptID = ApptID
    local apartment = apartment
    AtStash = true
    TriggerEvent('just_apartments:useStash', ApptID, apartment)
end)

RegisterNetEvent('just_apartments:useStash')
AddEventHandler('just_apartments:useStash', function (ApptID, apartment)
    local ApptID = ApptID
    local apartment = apartment
    lib.showTextUI("[E] Stash", {icon = "fa-solid fa-box-open"})
    while AtStash do
		Citizen.Wait(0)
		if IsControlPressed(1, 38) then
            Citizen.Wait(100)
            exports.ox_inventory:openInventory('stash', {id = (apartment..ApptID.."Stash"), owner = ApptID})
		end
	end
end)

-----------
-- Relog --
-----------

AddEventHandler('onClientResourceStart', function(resource)
    TriggerServerEvent('just_apartments:getLastApartment')
end)

RegisterNetEvent('just_apartments:spawnInProperty')
AddEventHandler('just_apartments:spawnInProperty', function (property, ApptID)
    currentApartment = property
    if currentApartment == "AltaStreetAppts" then 
        TriggerServerEvent('instance:set')
    else 
        TriggerServerEvent('instance:setNamed', property..ApptID)
        currentApartmentID = ApptID
    end
end)

------------
-- Garage --
------------

RegisterNetEvent('just_apartments:viewGarages')
AddEventHandler('just_apartments:viewGarages', function (currentApartment, event, vehicle, arrow)
    local options = {}
    if ownedGarage ~= nil then
        for i = 1, #ownedGarage do
            local data = ownedGarage[i]
            table.insert(options, {
                title = "Appt: "..data.id.." Garage",
                event = event,
                arrow = arrow,
                args = {id = data.id, name = data.apartment, vehicle = vehicle},
            })
        end
    end
    if keyedGarages ~= nil then
        for i = 1, #keyedGarages do
            local data = keyedGarages[i]
            table.insert(options, {
                title = "Appt: "..data.appt_id.." Garage",
                event = event,
                arrow = arrow,
                args = {id = data.appt_id, name = data.appt_name, vehicle = vehicle},
            })
        end
    end
    lib.registerContext({
        id = 'just_apartments:apptGarageMenu',
		title = Config.Apartments[currentApartment].label.." Garage",
        options = options
    })
    lib.showContext('just_apartments:apptGarageMenu')
end)

RegisterNetEvent('just_apartments:GetOwnedVehicles')
AddEventHandler('just_apartments:GetOwnedVehicles', function (data)
    local vehicles = lib.callback.await('just_apartments:GetVehicles', false, data.name.."appt"..data.id)
    local options = {}
    if not vehicles then
        lib.registerContext({
            id = 'just_apartments:GarageMenu',
            menu = 'just_apartments:apptGarageMenu',
            title = Config.Apartments[currentApartment].label.." Garage",
            options = {{title = "No vehicles parked"}}
        })
        return lib.showContext('just_apartments:GarageMenu')
    else
        for i = 1, #vehicles do
            local data = vehicles[i]
            local vehicleMake = GetLabelText(GetMakeNameFromVehicleModel(data.vehicle.model))
            local vehicleModel = GetLabelText(GetDisplayNameFromVehicleModel(data.vehicle.model))
            local vehicleTitle = vehicleMake .. ' ' .. vehicleModel
            local stored = data.stored
            print(vehicleTitle, data.plate, stored)
            if stored then
                table.insert(options, {
                    title = vehicleTitle,
                    event = 'just_apartments:VehicleMenu',
                    arrow = true,
                    args = {name = vehicleTitle, plate = data.plate, model = vehicleModel, vehicle = data.vehicle},
                    metadata = {
                        {label = 'Plate', value = data.plate},
                    }
                })
            end
        end
        lib.registerContext({
            id = 'just_apartments:GarageMenu',
            menu = 'just_apartments:apptGarageMenu',
            title = Config.Apartments[currentApartment].label.." Garage",
            options = options
        })
    end
    lib.showContext('just_apartments:GarageMenu')
end)

RegisterNetEvent('just_apartments:VehicleMenu')
AddEventHandler('just_apartments:VehicleMenu', function (data)
    lib.registerContext({
        id = 'just_apartments:VehicleMenu',
        title = data.name,
        menu = 'just_apartments:GarageMenu',
        options = {
            {
				title = 'Take out vehicle',
                event = 'just_apartments:RequestVehicle',
                args = {
                    vehicle = data.vehicle,
                    type = 'garage'
                }
            }
        }
    })

    lib.showContext('just_apartments:VehicleMenu')
end)

local function spawnVehicle(data, spawn)
    lib.requestModel(data.vehicle.model)
    TriggerServerEvent('just_apartments:SpawnVehicle', data.vehicle.model, data.vehicle.plate, spawn)
	lib.hideTextUI()
	Citizen.Wait(250)
	visible = false
end

RegisterNetEvent('just_apartments:RequestVehicle')
AddEventHandler('just_apartments:RequestVehicle', function (data)
	local spawn = Config.Apartments[currentApartment].parking[spot]
	if ESX.Game.IsSpawnPointClear(vector3(spawn.x, spawn.y, spawn.z), 1.0) then
		return spawnVehicle(data, spawn)
	end
end)

RegisterNetEvent('just_apartments:StoreVehicle')
AddEventHandler('just_apartments:StoreVehicle', function (data)
    local vehicle = data.vehicle
    local vehPlate = GetVehicleNumberPlateText(vehicle)
    local vehProps = lib.getVehicleProperties(vehicle)
    local isOwned = lib.callback.await('just_apartments:CheckOwnership', false, vehPlate)
	if isOwned and currentApartment ~= nil then
		TriggerServerEvent('just_apartments:SaveVehicle', vehProps, vehPlate, VehToNet(vehicle), data.name.."appt"..data.id)
		lib.hideTextUI()
		Citizen.Wait(250)
		visible = false
	end
end)