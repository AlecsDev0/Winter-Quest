local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface("vRP","WinterQuest")

RegisterNetEvent('wquest:insertUserData', function()
    local src = source
    local uid = vRP.getUserId({src})

    local userCount = exports.oxmysql:executeSync("SELECT * FROM winter_users WHERE user_id = ?", { uid })

    local embed = {
        {
            ["color"] = 0x5affe7,
            ["title"] = "Winter Quest",
            ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** s-a inregistrat / intrat in cursa la Winter Quest",
        }
    }
    PerformHttpRequest('https://discord.com/api/webhooks/1316844262725517394/pkATABS7A7Kh-VsyNUyq4wAfvOavKtzz-R8H12voL-DXcurZuxPZUQ4aZOChbnznojHc', function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})

    if userCount and #userCount > 0 then return end

    local query = [[
        INSERT INTO `winter_users` 
        (`id`, `user_id`, `status`, `candy`, `bmwm5touring`, `mkcdodgeb`, `ugcthdeer`) 
        VALUES 
        (NULL, ?, ?, ?, ?, ?, ?)
    ]]
    
    exports.oxmysql:execute(query, { uid, 'Standard', 0, 0,0,0 })
end)

RegisterNetEvent('wquest:openUI', function()
    local src = source
    local uid = vRP.getUserId({src})

    local masini = exports.oxmysql:executeSync("SELECT * FROM winter_cars")
    local userDataRaw = exports.oxmysql:executeSync("SELECT * FROM winter_users WHERE user_id = ?", {uid})
    local userData = userDataRaw[1]

    TriggerClientEvent('openUI', src, json.encode(masini), json.encode(userData))
end)


RegisterNetEvent('wquest:giveUserCar', function(data)
    local src = source
    local uid = vRP.getUserId({src})
    local carDataHash = data.hash
    local firstQuery = exports.oxmysql:executeSync("SELECT ?? FROM winter_users WHERE user_id = ?", { data.hash, uid })
    
    if firstQuery and firstQuery[1] and firstQuery[1][data.hash] == 0 then

        local embed = {
            {
                ["color"] = 0x5affe7,
                ["title"] = "Winter Quest",
                ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** a cumparat masina **"..data.name.."** ",
            }
        }
        PerformHttpRequest('https://discord.com/api/webhooks/1316845178979618846/04fUUpYBkN_Gu-9KpWwOkOvQ7jvBYqu1k0RpuaeIKMVsiYee4kNVAqObs3LnMDxlppji', function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
    

        exports.oxmysql:executeSync('INSERT INTO vrp_user_vehicles(user_id,vehicle,vehicle_plate) VALUES (@user_id,@vehicle,@vehicle_plate)', {
            ['@user_id'] = uid,
            ['@vehicle'] = carDataHash,
            ['@vehicle_plate'] = 'WQUEST',
        })

        exports.oxmysql:executeSync('UPDATE winter_users SET candy = candy - ? WHERE user_id = ?', { data.price, uid })
        exports.oxmysql:executeSync('UPDATE winter_users SET ?? = ? WHERE user_id = ?', { carDataHash, 1, uid })
        exports.oxmysql:executeSync('UPDATE winter_cars SET stock = stock - 1 WHERE hash = ?', { carDataHash })
        
    elseif firstQuery and firstQuery[1] and firstQuery[1][data.hash] == 1 then
        TriggerClientEvent('notify', src, 'Ai cumparat deja masina <span> '..data.name..'</span> ')
    end
end)

function RequestConfirmation(src, title, msg, callback)
    local requestId = tostring(math.random(1000, 9999))
    local eventHandler

    eventHandler = RegisterNetEvent('Interface:Response', function(receivedId, response)
        if receivedId == requestId then
            callback(response)
            RemoveEventHandler(eventHandler)
        end
    end)

    TriggerClientEvent('Interface:GetRequest', src, title, msg, requestId)
end

local premiumPrice = 500

RegisterNetEvent('wquest:setUserPremium',function()
    local src = source
    local uid = vRP.getUserId({src})
    local diamante = vRP.getdonationCoins({uid})
    if diamante >= premiumPrice then
        RequestConfirmation(src, 'Confirmare', 'Doresti sa achizitionezi statutul <span>Premium</span> pentru suma de <span>500 ATX Coins</span>?', function(response)
            if response == 'Y' then
                vRP.tryPaymentDonationCoins({uid,premiumPrice})
                exports.oxmysql:executeSync('UPDATE winter_users SET status = ? WHERE user_id = ?', { 'Premium',uid })
                exports.oxmysql:executeSync("SELECT ?? FROM winter_users WHERE user_id = ?", { 'bmwm5touring', uid })

                exports.oxmysql:executeSync('INSERT INTO vrp_user_vehicles(user_id,vehicle,vehicle_plate) VALUES (@user_id,@vehicle,@vehicle_plate)', {
                    ['@user_id'] = uid,
                    ['@vehicle'] = 'bmwm5touring',
                    ['@vehicle_plate'] = 'WQUEST',
                })

                local embed = {
                    {
                        ["color"] = 0x5affe7,
                        ["title"] = "Winter Quest",
                        ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** a cumparat masina Premium ",
                    }
                }
                PerformHttpRequest('https://discord.com/api/webhooks/1316845575009996870/weu5IQb0HeNgGzs_iOMjkujYYr6pQg-8J1XaXv2ob7k_HcsxQcec-aYMAyXapTfR0Tqf', function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
          

                TriggerClientEvent('notify', src, 'Ai cumparat statutul <span>Premium</span> si ai primit <span>BMW M5 G90 Touring</span>')
            end
            if response == 'N' then
                TriggerClientEvent('notify', src, 'Ai anultat tranzactia statutului <span>Premium</span>')
            end
        end)
    else
        TriggerClientEvent('notify', src, 'Nu ai <span>500 ATX Coins</span>')
    end
end)

RegisterNetEvent('wquest:claimDailyGift', function(hash,name)
    local src = source
    local uid = vRP.getUserId({src})
    if uid then
        local userDataRaw = exports.oxmysql:executeSync("SELECT dailyGift FROM winter_users WHERE user_id = ?", {uid})
        
        if not userDataRaw or #userDataRaw == 0 then
            TriggerClientEvent('notify', src, 'Trebuie mai intai sa incepi <span>event-ul</span>')
            return
        else
            local currentTime = os.date("*t", os.time())
            local currentTimestamp = os.time(currentTime)

            local timeout = 60 * 60 * 24

            local lastClaimTimestamp = userDataRaw[1].dailyGift

            if (currentTimestamp - lastClaimTimestamp) >= timeout then
                local embed = {
                    {
                        ["color"] = 0x5affe7,
                        ["title"] = "Winter Quest",
                        ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** a primit din Daily Gift **"..name.."** ",
                    }
                }
                PerformHttpRequest('https://discord.com/api/webhooks/1316846047061872640/c50Ruw4BMnQ4v_6Lw9SMM-WkgamEKaA-aNsyHhLaAkgwaZ9LKAZjx89mMkpL0ftFt2KX', function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
          
                TriggerClientEvent("chatMessage",-1,"^6 [ Winter Quest ]^0 Jucatorul "..GetPlayerName(src).."["..uid.."] a primit din Daily Gift ^6"..name.." ^0")
                TriggerClientEvent('notify', src, 'Ai primit <span>'..name..'</span> din <span>Daily Gift</span>')
                exports.oxmysql:executeSync("UPDATE winter_users SET dailyGift = ? WHERE user_id = ?", {currentTimestamp, uid})
            else
                local remainingTime = timeout - (currentTimestamp - lastClaimTimestamp)
                local remainingHours = math.floor(remainingTime / 3600)
                local remainingMinutes = math.floor((remainingTime % 3600) / 60)
                TriggerClientEvent('notify', src, 'Poti deschide cadoul in <span>'..remainingHours..' ore</span> si <span>'..remainingMinutes..' minute</span>')
            end
        end
    end
end)

RegisterNetEvent('wquest:claimPaidGift',function(hash,name)
    local src = source
    local uid = vRP.getUserId({src})
    local actualDCoins = vRP.getdonationCoins({uid})
    if uid then
        exports.oxmysql:executeSync("UPDATE winter_users SET candy = candy - ? WHERE user_id = ?", {20, uid})
        local embed = {
            {
                ["color"] = 0x5affe7,
                ["title"] = "Winter Quest",
                ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** a primit din Candy Gift **"..name.."** ",
            }
        }
        PerformHttpRequest('https://discord.com/api/webhooks/1316846387203145748/brptTJtvBWf8WHGL-0tfY26cv0AiZJhOmL9DRgUHoofEm5WB8PhctszsK5Xdq2dE4pOQ', function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
  
        if hash == 'money' then
            vRP.giveMoney({uid,tonumber(name)})
            TriggerClientEvent('wq:notify', src, 'Ai primit <span>'..vRP.formatMoney({tonumber(name)})..'$</span> din <span>Paid Gift</span>')
            TriggerClientEvent("chatMessage",-1,"^6 [ Winter Quest ]^0 Jucatorul "..GetPlayerName(src).."["..uid.."] a primit din Candy Gift ^6"..vRP.formatMoney({tonumber(name)}).."$ ^0")
            return
        end
        if hash == 'atxcoins' then
            vRP.setdonationCoins({uid,actualDCoins + tonumber(name)})
            TriggerClientEvent('wq:notify', src, 'Ai primit <span>'..name..'Astrix Coins</span> din <span>Paid Gift</span>')
            TriggerClientEvent("chatMessage",-1,"^6 [ Winter Quest ]^0 Jucatorul "..GetPlayerName(src).."["..uid.."] a primit din Candy Gift ^6"..vRP.formatMoney({tonumber(name)}).." Astrix Coins ^0")
            return
        end

        -- give inventory item
        TriggerClientEvent('wq:notify', src, 'Ai primit <span>'..name..'</span> din <span>Paid Gift</span>')
        TriggerClientEvent("chatMessage",-1,"^6 [ Winter Quest ]^0 Jucatorul "..GetPlayerName(src).."["..uid.."] a primit din Candy Gift ^6"..name.." ^0")
    end
end)

RegisterNetEvent('wquest:updateCandy',function(number)
    local src = source
    local uid = vRP.getUserId({src})
    exports.oxmysql:executeSync('UPDATE winter_users SET candy = candy + ? WHERE user_id = ?', { tonumber(3), uid })
end)

RegisterNetEvent('wquest:payUser', function()
    local src = source
    local uid = vRP.getUserId({src})

    local currentHour = tonumber(os.date("%H"))
    local oraDeInceput = 16
    local oraDeTermint = 23
    local candyLuate = 0
    local embed;
    if currentHour >= oraDeInceput and currentHour <= oraDeTermint then
        local userCount = exports.oxmysql:executeSync("SELECT status FROM winter_users WHERE user_id = ?", { uid })
        local status = userCount[1].status
        local money = math.random(100, 500)
        local actualMoney = money / 100 * 25
        local sansaCandy

        TriggerClientEvent('startColinda',src)
        Wait(20000)

        if status == 'Standard' then
            sansaCandy = 5
            vRP.giveMoney({uid, math.floor(money)})
            TriggerClientEvent('wq:notify', src, 'Ai primit <span>' .. math.floor(money) .. '$</span> pentru colinda')
            if math.random(1, 100) <= sansaCandy then
                candyLuate = 1
                TriggerEvent('wquest:updateCandy',src,1)
                -- give item candy
            end

            embed = {
                {
                    ["color"] = 0x5affe7,
                    ["title"] = "Winter Quest",
                    ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** a colindat si a primit suma de **"..math.floor(money).."$** si **"..candyLuate.." Candy**",
                }
            }

        else
            sansaCandy = 15
            local updatedMoney = math.floor(money + actualMoney)
            vRP.giveMoney({uid, updatedMoney})
            TriggerClientEvent('wq:notify', src, 'Ai primit <span>' .. updatedMoney .. '$</span> pentru colinda')

            if math.random(1, 100) <= sansaCandy then
                candyLuate = 3
                -- give item candy
                TriggerEvent('wquest:updateCandy',src,3)
            end

            embed = {
                {
                    ["color"] = 0x5affe7,
                    ["title"] = "Winter Quest",
                    ["description"] = "Jucatorul **"..GetPlayerName(src).."["..uid.."]** a colindat si a primit suma de **"..updatedMoney.."$** si **"..candyLuate.." Candy**",
                }
            }
        end
    else
        TriggerClientEvent('wq:notify', src, 'Job-ul este disponibil doar intre orele 8:00 și 11:00')
    end

    PerformHttpRequest('https://discord.com/api/webhooks/1317498978731954206/148uCpBc9LaZHpt2H4OqwCHlT0472U0NqNvzCQyMJ-ccVdplazlaDKzFwNwhbSNhXolo', function(err, text, headers) end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end)