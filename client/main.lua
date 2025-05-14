--------- BLIPS ---------
BlipList = {}
AddEventHandler('onResourceStop', function(resource) 
    if resource == GetCurrentResourceName() then 
        clearBlips() 
    end 
end)

CreateThread(function()
    Wait(20)
    createBlips()
end)

createBlips = function()
    for i=1, #Zones do
        local blip = AddBlipForCoord(Zones[i])
        SetBlipSprite (blip, 410)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, 0.4)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Bootsvermietung')
        EndTextCommandSetBlipName(blip)
        table.insert(BlipList, blip)
    end
end

clearBlips = function() 
    for k, v in pairs(BlipList) do 
        RemoveBlip(v) 
    end 
    BlipList = {} 
end
--------- BLIPS ENDE ---------


function MessageUpLeftCorner(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end


CreateThread(function()
    while true do
        Wait(0)
        local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, nil, true

        for k, v in pairs(Zones) do
            local distance = #(playerCoords - v)
            if distance <= 25 then
                letSleep = false
                DrawMarker(35, v, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.6, 0, 153, 255, 255, 0, 1, 0, 0)
                if distance <= 1.40 then
                    isInMarker, currentZone = true, k
                    if not menuOpen then
                       MessageUpLeftCorner("Press ~INPUT_CONTEXT~ to rent a boat")
                        if IsControlJustPressed(0, 51) then
                            OpenBoatsMenu(SpawnZones[k].x, SpawnZones[k].y, SpawnZones[k].z)
                        end
                    end
                end
            end
        end

        if letSleep then
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(playerPed), false, nil, true
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        for k,v in pairs(DeleteZones) do
            local distance = #(playerCoords - v)
            if distance <= 50 then
                letSleep = false
                DrawMarker(1, v, 0, 0, 0, 0, 0, 0, 4.5, 4.5, 1.5, 0, 153, 255, 255, 0, 1, 0, 0)
                if distance <= 2.40 then
                    isInMarker, currentZone = true, k
                    if not menuOpen and vehicle ~= 0 then
                      MessageUpLeftCorner("Press ~INPUT_CONTEXT~ return your boat")
                        if IsControlJustPressed(0, 51) then
                            DeleteEntity(vehicle)
                            SetEntityCoords(playerPed, DeleteZones[k], false, false, false, false) -- FIXED Teleport
                        end
                    end
                end
            end
        end

        if letSleep then
            Wait(1000)
        end
    end
end)

function SpawnBikeRental(modelname)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    ESX.Game.SpawnVehicle(modelname, coords, 90.0, function(vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        haverentbike = true
        veh = vehicle
        jobPlate = GetVehicleNumberPlateText(veh)
        Wait(3000)
        exports['rlo_autokeys']:GiveJobKeys(jobPlate, veh, true)
    end)
end

-- Boot Mieten Men 
function OpenBoatsMenu(x, y, z)
    local ped = PlayerPedId()
    PlayerData = ESX.GetPlayerData()
    local elements = {}
    
    table.insert(elements, {label = '<span>Jetski</span> <span style="color:green;">100$</span>', value = 'seashark'})
    table.insert(elements, {label = '<span>Motorboot</span> <span style="color:green;">200$</span>', value = 'suntrap'})
    table.insert(elements, {label = '<span>Speedboot</span> <span style="color:green;">300$</span>', value = 'jetmax'})
    table.insert(elements, {label = '<span>Luxusspeedboot</span> <span style="color:green;">400$</span>', value = 'toro'}) 
    table.insert(elements, {label = '<span>Schlauchboot</span> <span style="color:green;">500$</span>', value = 'dinghy4'})
    table.insert(elements, {label = '<span>Segelboot</span> <span style="color:green;">600$</span>', value = 'marquis'}) 
    table.insert(elements, {label = '<span>Schlepper</span> <span style="color:green;">800$</span>', value = 'tug'})
        
    if PlayerData.job.name == 'police' then
        table.insert(elements, {label = '<span style="color:green;">Polizeiboot</span>', value = 'predator'})
    end
    if PlayerData.job.name == 'fire' then
        table.insert(elements, {label = '<span style="color:green;">Feuerwehrboot</span>', value = 'dinghy3'})
        table.insert(elements, {label = '<span style="color:green;">Lifeguard Jetski</span>', value = 'seashark2'})
    end
    if PlayerData.job.name == 'ambulance' then
        table.insert(elements, {label = '<span style="color:green;">Medicboot</span>', value = 'dinghy3'})
        table.insert(elements, {label = '<span style="color:green;">Lifeguard Jetski</span>', value = 'seashark2'})
    end
    
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'client', {
        css      = 'garage',
        title    = 'Boot rent',
        align    = 'top-left',
        elements = elements,
    }, function(data, menu)
        ESX.UI.Menu.CloseAll()
        ESX.TriggerServerCallback('boatrental:callback:removeMoney', function(paid)
            if paid then 
                SpawnBoatClientSide(data.current.value, x, y, z, 90.0)  -- Setzt den Spawnpunkt und die Rotation
            end
        end, data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end


function SpawnBoatClientSide(modelname, x, y, z, heading)
    ESX.Game.SpawnVehicle(modelname, vector3(x, y, z), heading, function(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)  -- Spieler ins Boot setzen
        SetEntityAsMissionEntity(vehicle, true, true)
        local plate = GetVehicleNumberPlateText(vehicle)

        Citizen.Wait(3000)

        --TriggerEvent('stealVehicleKeys') -- Event f r Fahrzeugschl ssel

        --if vehicle and DoesEntityExist(vehicle) then
        --    Entity(vehicle).state.fuel = 100.0
        --    SetVehicleFuelLevel(vehicle, 100.0)
        -- end

        local vehicleId = NetworkGetNetworkIdFromEntity(vehicle)
    end)
end

