RegisterNUICallback('closeUI',function()
    SendNUIMessage({
        type = 'closeUI'
    })
    SetNuiFocus(false,false)
end)

CreateThread(function()
    local commonCoords = vector3(352.68414306641,6631.2373046875,28.750249862671)
    local textui = false

    while true do
        local playerPed = PlayerPedId()
        local pedPos = GetEntityCoords(playerPed)

        local ticks = 2500
        local isNearLocation = false

        local distance = #(pedPos - commonCoords)

        if distance < 25 then
            ticks = 1500
            isNearLocation = true

            if distance < 5 then
                ticks = 1
                DrawMarker(2, commonCoords.x, commonCoords.y, commonCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 215, 60, 255, 50, false, true, 2, nil, nil, false)

                if not textui then
                    exports['neo-interface']:Open('E', 'Pentru a deschide', 'Meniul')
                    textui = true
                end

                if IsControlJustPressed(0, 38) then
                    exports['neo-interface']:Close()
                    TriggerServerEvent('wquest:openUI')
                end
            else
                if textui then
                    exports['neo-interface']:Close()
                    textui = false
                end
            end
        end

        if not isNearLocation and textui then
            exports['neo-interface']:Close()
            textui = false
        end

        Wait(ticks)
    end
end)

RegisterNUICallback('notify',function(data)
    TriggerEvent('Interface:Notify', 'error', 5, 'Eroare', data.text)
end)

RegisterNetEvent('wq:notify',function(data)
    TriggerEvent('Interface:Notify', 'info', 5, 'Winter Quest', data)
end)

RegisterNetEvent('notify',function(data)
    TriggerEvent('Interface:Notify', 'error', 5, 'Eroare', data)
end)

RegisterNetEvent('openUI', function(masini, userData)
    SendNUIMessage({
        type = 'openUI',
        cars = json.decode(masini),
        userData = json.decode(userData)
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("giveUserCar",function(data)
    TriggerServerEvent('wquest:giveUserCar',data)
end)

RegisterNUICallback('claimDailyGift',function(data)
    TriggerServerEvent('wquest:claimDailyGift',data.hash,data.name)
end)

RegisterNUICallback('giveUserPremiumStatus',function()
    TriggerServerEvent('wquest:setUserPremium')
end)

RegisterNUICallback('claimPaidGift',function(data)
    TriggerServerEvent('wquest:claimPaidGift',data.hash,data.name)
end)

local inJob = false
local textui = false
local blips = {}

RegisterNUICallback('startUserQuest', function()
    TriggerServerEvent('wquest:insertUserData')
    inJob = true
end)

CreateThread(function()
    for _, v in pairs(Config.Locations) do
        local jobCoords = vector3(v.x, v.y, v.z)
        local vehBlip = AddBlipForCoord(jobCoords.x, jobCoords.y, jobCoords.z)
        
        SetBlipSprite(vehBlip, 40)
        SetBlipColour(vehBlip, 4)
        SetBlipAsShortRange(vehBlip, true)
        SetBlipScale(vehBlip, 0.5)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Casa de colindat")
        EndTextCommandSetBlipName(vehBlip)
        table.insert(blips, vehBlip)
    end
end)

local inJob = false

RegisterNUICallback('startUserQuest', function()
    TriggerServerEvent('wquest:insertUserData')
    inJob = true
end)

local textui = false
local tick = 1000
local triggered = false
local cooldowns = {}

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local esteAproape = false
        local hasTextui = false
        tick = 1000

        for index, v in pairs(Config.Locations) do
            local dist = #(coords - vector3(v.x, v.y, v.z))

            if dist < 50.0 then
                DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 215, 60, 255, 50, false, true, 2, nil, nil, false)

                if dist < 10.0 then
                    esteAproape = true
                    tick = 1

                    local currentTime = GetGameTimer()
                    if not cooldowns[index] or (currentTime - cooldowns[index]) > 600000 then
                        if not hasTextui then
                            exports['neo-interface']:Open('E', 'Pentru a', 'Colinda')
                            hasTextui = true
                            textui = true
                        end

                        if IsControlJustPressed(0, 38) and not triggered and not IsPedSittingInAnyVehicle(ped) then
                            exports['neo-interface']:Close()
                            TriggerServerEvent('wquest:payUser')
                            triggered = true
                            cooldowns[index] = currentTime
                            Wait(20000)
                            triggered = false
                        end
                    else
                        if not hasTextui then
                            exports['neo-interface']:Open('E', 'Casa este deja', 'Colindata')
                            hasTextui = true
                            textui = true
                        end
                    end
                end
            end
        end

        if not esteAproape and textui then
            exports['neo-interface']:Close()
            textui = false
        end

        Wait(tick)
    end
end)

RegisterNetEvent('startColinda', function()
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    ExecuteCommand("e musician")
    TriggerEvent('Interface:ProgressBar', 20, 'Colinzi Casa')
    SendNUIMessage({ type = 'colinda' })
    
    Wait(20000)
    ExecuteCommand("e c")
    FreezeEntityPosition(ped, false)
end)