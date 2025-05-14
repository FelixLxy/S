-- Server-Skript f�r Bootsvermietung

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local rentedBoats = {}  -- Tabelle f�r gemietete Boote

ESX.RegisterServerCallback('boatrental:callback:removeMoney', function(source, cb, boatType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = 0

    if boatType == 'seashark' then
        price = 100
    elseif boatType == 'suntrap' then
        price = 200
    elseif boatType == 'jetmax' then
        price = 300
    elseif boatType == 'toro' then
        price = 400
    elseif boatType == 'dinghy4' then
        price = 500
    elseif boatType == 'marquis' then
        price = 600
    elseif boatType == 'tug' then
        price = 800
    elseif boatType == 'predator' or boatType == 'dinghy3' or boatType == 'seashark2' then
        price = 0
    end

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        cb(true)
    else
        TriggerClientEvent('esx:showNotification', source, 'You do not have enough money to rent this boat.')
        cb(false)
    end
end)

RegisterNetEvent('boatrental:SpawnServerside')
AddEventHandler('boatrental:SpawnServerside', function(boatModel, coords, heading)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicle = nil

    -- �berpr�fen, ob das Boot und die Koordinaten g�ltig sind
    if boatModel and coords then
        local model = GetHashKey(boatModel)
        
        -- Modell anfordern und warten, bis es geladen ist
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(500)
        end

        -- Boot an den angegebenen Koordinaten und mit der angegebenen Richtung spawnen
        vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleNumberPlateText(vehicle, 'BOAT'..math.random(1000, 9999))  -- Zufallskennzeichen

        -- Spieler ins Fahrzeug setzen
        TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)

        -- Event an den Client senden, um das Fahrzeug im Netzwerk zu synchronisieren
        TriggerClientEvent('rlo_boatrental:cartoclient', source, NetworkGetNetworkIdFromEntity(vehicle))
    end
end)

-- Event zum L�schen des Bootes, wenn der Spieler es zur�ckgibt
RegisterNetEvent('boatrental:deleteBoat')
AddEventHandler('boatrental:deleteBoat', function(boat)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicle = NetToVeh(boat)

    -- �berpr�fen, ob das Boot existiert und es l�schen
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
        TriggerClientEvent('rlo_boatrental:boatReturned', source)  -- Client benachrichtigen, dass das Boot zur�ckgegeben wurde
    end
end)

RegisterNetEvent('boatrental:trackRentedBoats')
AddEventHandler('boatrental:trackRentedBoats', function(boatId)
    local xPlayer = ESX.GetPlayerFromId(source)

    rentedBoats[source] = boatId
end)

RegisterNetEvent('boatrental:returnBoat')
AddEventHandler('boatrental:returnBoat', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Boot aus der Tabelle der gemieteten Boote entfernen
    rentedBoats[source] = nil
    TriggerClientEvent('boatrental:boatReturned', source)  -- Client benachrichtigen, dass das Boot erfolgreich zur�ckgegeben wurde
end)

RegisterNetEvent('boatrental:cartoclient')
AddEventHandler('boatrental:cartoclient', function(mycar)
    Wait(1)

    while not NetworkDoesEntityExistWithNetworkId(mycar) do
        Wait(10)
    end

    local vehicle = NetToEnt(mycar)
    local PlayerPed = PlayerPedId()

    while not DoesEntityExist(vehicle) do
        Wait(10)
    end

    SetVehRadioStation(vehicle, "OFF")
    SetVehicleUndriveable(vehicle, false)
    Wait(50)

    TaskWarpPedIntoVehicle(PlayerPed, vehicle, -1)

    Wait(100)
    jobPlate = GetVehicleNumberPlateText(vehicle)
end)

