local ESX = exports["es_extended"]:getSharedObject()
local cooldowns = {}
local rewards = {} -- rewardID => { amount = x, player = src }

RegisterNetEvent('sg_storerobbery:robberyStarted', function(shopIndex, coords)
    local src = source
    local shop = Config.Shops[shopIndex]

    if cooldowns[shopIndex] and os.time() < cooldowns[shopIndex] then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Store Robbery',
            description = 'Tenhle obchod byl nedávno přepaden!',
        })
        return
    end

    cooldowns[shopIndex] = os.time() + Config.Cooldown

    if Config.Dispatch == 'linden' then
        --Dispatch
        local data = {
            displayCode = '10-68',
            description = 'Vykradaní Obchodu',
            isImportant = 0,
            recipientList = {'police', 'sheriff'},
            length = '10000',
            infoM = 'fa-info-circle',
            info = 'Vykradaní Obchodu'
        }
    
        -- Get the player's current coordinates
        local playerPed = GetPlayerPed(source)
        local coords = GetEntityCoords(playerPed)
    
        -- Define the dispatch data
        local dispatchData = {
            dispatchData = data,
            caller = 'Alarm',
            coords = coords
        }
    
        -- Trigger the event with the dispatch data
        TriggerEvent('wf-alerts:svNotify', dispatchData)

    end

    local rewardID = tostring(math.random(100000, 999999)) .. "_" .. src
    local reward = math.random(25000,25000)

    rewards[rewardID] = {
        amount = reward,
        player = src
    }

    TriggerClientEvent('sg_storerobbery:startTimer', src, Config.RobberyTime, rewardID)
end)

lib.callback.register('sg_storerobbery:claimReward', function(source, rewardID)
    local src = source
    local rewardData = rewards[rewardID]

    -- ✅ Security check
    if not rewardData then
        local src = source

        --print(('Cheater detected (no reward): %s | rewardID: %s'):format(GetPlayerName(src), rewardID))
        --print('cheater')
        --exports['sg_logs']:Log("Hráč použil Zakazanej trigger sg_storerobbery:claimReward'", "cheater", src)
        exports["sg_bans"]:banPlayer(source, "Cheating detected / sg_storerobbery:claimReward")
        --exports['sg_screenshot-basic']:screenshot(source)
        return false
    end

    if rewardData.player ~= src then
        print(('Cheater detected (wrong player): %s | rewardID: %s'):format(GetPlayerName(src), rewardID))
        print('cheater')
        return false
    end

    local amount = rewardData.amount

    -- ✅ Odstraníme po jednom použití
    rewards[rewardID] = nil

    if Config.Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then xPlayer.addAccountMoney(Config.Items, amount) end
    elseif Config.Framework == 'QB' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then Player.Functions.AddMoney(Config.Items, amount) end
    end

    return amount
end)