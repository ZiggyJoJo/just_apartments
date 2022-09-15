local atDoor
local atExit
local state = nil
local Instanced = false
local InWardrobe = false
local AtStash = false
local allMyOutfits   = {}
local currentApartment = nil
local currentApartmentLabel = nil
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

local function Blips(coords, type, label, job, blipOptions)
    if job then return end
    if blip == false then return end
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, blipOptions?.sprite or 357)
    SetBlipScale(blip, blipOptions?.scale or 0.8)
    SetBlipColour(blip, blipOptions?.colour ~= nil and blipOptions.colour or type == 'car' and Config.BlipColors.Car or type == 'boat' and Config.BlipColors.Boat or Config.BlipColors.Aircraft)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Apartment")
    EndTextCommandSetBlipName(blip)
end

for k, v in pairs(Config.Apartments) do
    exports["bt-polyzone"]:AddBoxZone(v.zone.name.."Entrance", vector3(v.entrance.x, v.entrance.y, v.entrance.z), 3, 3, {
        name = v.zone.name.."Entrance",
        heading = v.entrance.h,
        debugPoly = false,
        minZ = (v.entrance.z - 1),
        maxZ = (v.entrance.z + 1.5),
        }
    )
    if v.wardrobe ~= nil then
        exports["bt-polyzone"]:AddBoxZone(v.zone.name.."Wardrobe", vector3(v.wardrobe.x, v.wardrobe.y, v.wardrobe.z), 3, 3, {
            name = v.zone.name.."Wardrobe",
            heading = v.wardrobe.h,
            debugPoly = false,
            minZ = (v.wardrobe.z - 1),
            maxZ = (v.wardrobe.z + 1.5),
            }
        )
    end
    if v.stash ~= nil then
        exports["bt-polyzone"]:AddBoxZone(v.zone.name.."Stash", vector3(v.stash.x, v.stash.y, v.stash.z), 3, 3, {
            name = v.zone.name.."Stash",
            heading = v.stash.h,
            debugPoly = false,
            minZ = (v.stash.z - 1),
            maxZ = (v.stash.z + 1.5),
            }
        )
    end
    exports["bt-polyzone"]:AddBoxZone(v.zone.name.."Exit", vector3(v.exit.x, v.exit.y, v.exit.z), 3, 3, {
        name = v.zone.name.."Exit",
        heading = v.exit.h,
        debugPoly = false,
        minZ = (v.exit.z - 1),
        maxZ = (v.exit.z + 1.5),
        }
    )

    if v.blip ~= false then
        Blips(vector3(v.entrance.x, v.entrance.y, v.entrance.z), v.type, v.label, v.job, v.blip)
    end
end

RegisterNetEvent('bt-polyzone:enter')
AddEventHandler('bt-polyzone:enter', function(name)
    for k, v in pairs(Config.Apartments) do
        if v.zone.name.."Entrance" == name then
            currentApartment = v.zone.name
            currentApartmentLabel = v.label
            atDoor = true 
            if currentApartment == 'AltaStreetAppts' then 
                lib.showTextUI("[E] Apartments", {icon = "fa-solid fa-building"})
                TriggerEvent('just_apartments:enterExitApartment', v.exit, "Entering")
            else 
                TriggerServerEvent('just_apartments:getOwnedApartments', v.zone.name, v.exit)
            end
            break
        end
    end
    if Config.BrpFivemAppearance then
        for k, v in pairs(Config.Apartments) do
            if v.zone.name.."Wardrobe" == name then
                if currentApartment == "AltaStreetAppts" then
                    TriggerEvent('just_apartments:enteredWardrobe')
                else
                    TriggerServerEvent('just_apartments:checkApptOwnership', v.zone.name, "Wardrobe", currentApartmentID)
                end
                break
            end
        end
    end
    if Config.UseOxInventory then
        for k, v in pairs(Config.Apartments) do
            if v.zone.name.."Stash" == name then
                AtStash = true
                if currentApartment == "AltaStreetAppts" then
                    TriggerEvent('just_apartments:useStash', 0, "AltaStreetAppts")
                else
                    TriggerServerEvent('just_apartments:checkApptOwnership', v.zone.name, "Stash", currentApartmentID)
                end
                break
            end
        end
    end
    for k, v in pairs(Config.Apartments) do
        if v.zone.name.."Exit" == name then
            currentApartment = v.zone.name
            currentApartmentLabel = v.label
            atExit = true 
            if v.seperateExitPoint == true then 
                if currentApartment == 'AltaStreetAppts' then 
                    lib.showTextUI("[E] Exit Apartment", {icon = "fa-solid fa-door-open"})
                    TriggerEvent('just_apartments:enterExitApartment', v.exitPoint, "Exiting")
                else
                    TriggerServerEvent('just_apartments:getPlayersAtDoor', v.exitPoint, v.zone.name, currentApartmentID, v.exit)
                end
            else 
                TriggerServerEvent('just_apartments:getPlayersAtDoor', v.entrance, v.zone.name, currentApartmentID, v.exit)
            end
            break
        end
    end
end)

RegisterNetEvent('bt-polyzone:exit')
AddEventHandler('bt-polyzone:exit', function(name)
    for k, v in pairs(Config.Apartments) do
        if v.zone.name.."Entrance" == name then
            atDoor = false
            lib.hideTextUI()
            break
        end
    end
    if Config.BrpFivemAppearance then
        for k, v in pairs(Config.Apartments) do
            if v.zone.name.."Wardrobe" == name then
                InWardrobe = false
                lib.hideTextUI()
                break
            end
        end
    end
    if Config.UseOxInventory then
        for k, v in pairs(Config.Apartments) do
            if v.zone.name.."Stash" == name then
                AtStash = false
                lib.hideTextUI()
                break
            end
        end
    end
    for k, v in pairs(Config.Apartments) do
        if v.zone.name.."Exit" == name then
            atExit = false
            lib.hideTextUI()
            break
        end
    end
end)

RegisterNetEvent('just_apartments:enteredWardrobe')
AddEventHandler('just_apartments:enteredWardrobe', function ()
    InWardrobe = true
    lib.showTextUI("[E] Wardrobe", {icon = "fa-solid fa-shirt"})
    TriggerEvent('just_apartments:useWardrobe')
end)

RegisterNetEvent('just_apartments:useWardrobe')
AddEventHandler('just_apartments:useWardrobe', function ()
    while InWardrobe do
		Citizen.Wait(0)
		if IsControlPressed(1, 38) then
            Citizen.Wait(500)
            TriggerEvent('fivem-appearance:useWardrobe')
		end
	end
end)

RegisterNetEvent('just_apartments:entranceMenu')
AddEventHandler('just_apartments:entranceMenu', function (data)
    Citizen.CreateThread(function ()
        lib.showTextUI("[E] Apartments", {icon = "fa-solid fa-building"})
        while atDoor or atExit do
            if (IsControlJustReleased(0, 54) or IsControlJustReleased(0, 175)) then
                TriggerServerEvent('just_apartments:getAppartmentsWithKeys', data, currentApartment)
            end
            Citizen.Wait(0)
        end 
    end)
end)

RegisterNetEvent('just_apartments:keyEntryMenu')
AddEventHandler('just_apartments:keyEntryMenu', function (apartments, data)
    local data = data 
    local options = {}
    TriggerEvent('just_apartments:leaseMenu', data)
    if not data.id then
        options = {
            {
                title = "Purchase "..currentApartmentLabel.." Apartment",
                description = "$"..data.price,
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
                    coords = data.coords,
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
                    coords = data.coords,
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
                    event = 'just_apartments:keyEntry',
                    args = {
                        apartments = apartments,
                        data = data
                    },
                })
            end
        end
    end
    Citizen.Wait(100)
    lib.registerContext({
        id = 'just_apartments:keyEntryMenu',
        title = currentApartmentLabel,
        options = options
    })
	Citizen.Wait(100)
    lib.showContext('just_apartments:keyEntryMenu')
end)

RegisterNetEvent('just_apartments:keyEntry')
AddEventHandler('just_apartments:keyEntry', function (args)
    local apartments = args.apartments
    local data = args.data 

    local options = {}

    for i=1, #apartments, 1 do
        if apartments[i].owner ~= identifier then
            table.insert(options,  {
                title = "Appt: "..apartments[i].appt_id,
                event = "Enter",
                event = 'just_apartments:enterExitApartment',
                args = {
                    coords = data.coords,
                    enteringExiting = "Entering",
                    id = apartments[i].appt_id
                }
            })
        end
	end
    Citizen.Wait(100)
    lib.registerContext({
        id = 'just_apartments:keyEntry',
        title = currentApartmentLabel.." Appts",
        menu = "just_apartments:keyEntryMenu",
        options = options
    })
	Citizen.Wait(100)
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
        title = currentApartmentLabel.." Appts",
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

    Citizen.Wait(100)
    if data.renew == 1 then
        lib.registerContext({
            id = 'just_apartments:leaseMenu',
            title =  "Change Lease",
            menu = "just_apartments:keyEntryMenu",
            options = {{             
                title = "Cancel Lease",
                description = "Renews: "..string.sub(data.renewDate,5,6).."/"..string.sub(data.renewDate,7,8).."/"..string.sub(data.renewDate,1,4).." For $"..data.price,
                event = 'just_apartments:changeLease',
                args = {
                    renew = 0,
                    id = data.id
                }
            }}
        })
    else 
        lib.registerContext({
            id = 'just_apartments:leaseMenu',
            title =  "Change Lease",
            menu = "just_apartments:keyEntryMenu",
            options = {{           
                title = "Resume Lease $"..data.price,
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
    atDoor = false 
    Citizen.Wait(500)
    atDoor = true 
    TriggerServerEvent('just_apartments:getOwnedApartments', currentApartment.currentApartment, currentApartment.exit)
end)

RegisterNetEvent('just_apartments:exitMenu')
AddEventHandler('just_apartments:exitMenu', function (coords, playersAtDoor, exitDoor, keyholders)
    local playersAtDoor = playersAtDoor
    Citizen.CreateThread(function ()
        local coords = coords 
        lib.showTextUI("[E] Door", {icon = "fa-solid fa-door-open"})
        while atDoor or atExit do
            if (IsControlJustReleased(0, 54) or IsControlJustReleased(0, 175)) then
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
            end
            Citizen.Wait(0)
        end 
    end)
end)

RegisterNetEvent('just_apartments:keyholderMenu')
AddEventHandler('just_apartments:keyholderMenu', function (data)
    local playersAtDoor = playersAtDoor
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
	Citizen.CreateThread(function ()
        local coords = coords 
        local player = PlayerPedId()
        while atDoor or atExit do
            if currentApartment == 'AltaStreetAppts' then
                if (IsControlJustReleased(0, 54) or IsControlJustReleased(0, 175)) then
                    TriggerEvent("mythic_progbar:client:progress", {
                        name = "just_apartments_use",
                        duration = 5000,
                        label = enteringExiting.." Apartment",
                        useWhileDead = false,
                        canCancel = true,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        },
                        -- animation = {
                        --     animDict = "missheistdockssetup1clipboard@idle_a",
                        --     anim = "idle_a",
                        --     flags = 561,
                        -- },
                    }, function(status)
                        if not status then
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
                                currentApartmentLabel = nil
                                currentApartmentID = nil
                                TriggerServerEvent('just_apartments:updateLastApartment', nil)
                            end
                            atDoor = false 
                            atExit = false
                            SetEntityCoords(player, coords.x, coords.y, coords.z)
                            SetEntityHeading(player, coords.h)
                        end
                    end)
                end
            else 
                atDoor = false
                atExit = false
                TriggerEvent("mythic_progbar:client:progress", {
                    name = "just_apartments_use",
                    duration = 5000,
                    label = coords.enteringExiting.." Apartment",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    -- animation = {
                    --     animDict = "missheistdockssetup1clipboard@idle_a",
                    --     anim = "idle_a",
                    --     flags = 561,
                    -- },
                }, function(status)
                    if not status then
                        PlaySoundFrontend(-1, "CLOSED", "MP_PROPERTIES_ELEVATOR_DOORS", 1);
                        Citizen.Wait(500)
                        PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 0)
                        Citizen.Wait(500)
                        PlaySoundFrontend(-1, "OPENED", "MP_PROPERTIES_ELEVATOR_DOORS", 1);

                        if coords.enteringExiting == "Entering" then 
                            TriggerServerEvent('instance:setNamed', currentApartment..coords.id)
                            TriggerServerEvent('just_apartments:updateLastApartment', currentApartment.." "..coords.id)
                            currentApartmentID = coords.id
                        elseif coords.enteringExiting == "Exiting" then 
                            if state == "Viewing" then  
                                TriggerServerEvent('instance:set', 0)
                                TriggerServerEvent('just_apartments:updateLastApartment', nil)
                            else 
                                TriggerServerEvent('instance:setNamed', 0)
                                TriggerServerEvent('just_apartments:updateLastApartment', nil)
                            end
                            state = nil
                            currentApartment = nil
                            currentApartmentLabel = nil
                            currentApartmentID = nil
                        elseif coords.enteringExiting == "Viewing" then 
                            state = "Viewing"
                            TriggerServerEvent('instance:set')
                        end
                        atDoor = false 
                        atExit = false
                        SetEntityCoords(player, coords.coords.x, coords.coords.y, coords.coords.z)
                        SetEntityHeading(player, coords.coords.h)
                    end
                end)
            end
            Citizen.Wait(0)
        end
	end)
end)

----------
-- Keys --
----------

RegisterCommand('giveApptKey', function()
	TriggerEvent('just_apartments:givePlayerKeys')
end, false)

RegisterNetEvent('just_apartments:givePlayerKeys')
AddEventHandler('just_apartments:givePlayerKeys', function ()
	local playerPed = PlayerPedId()
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