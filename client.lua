local function startRobbery(shopIndex)
    local shop = Config.Shops[shopIndex]

    TriggerEvent('ox_lib:notify', {
        type = 'inform',
        title = 'Store Robbery',
        description = 'Loupež probíhá...',
    })

    TriggerServerEvent('sg_storerobbery:robberyStarted', shopIndex, shop.coords)
end

RegisterNetEvent('sg_storerobbery:startTimer', function(seconds, rewardID)
    local success = lib.progressCircle({
        duration = seconds * 1000,
        label = 'Probíhá loupež...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true
        }
    })

    if not success then
        lib.notify({
            title = 'Loupež zrušena',
            description = 'Loupež byla přerušena a nebyla dokončena.',
            type = 'error'
        })
        return
    end

    local result = lib.callback.await('sg_storerobbery:claimReward', false, rewardID)
    if result and type(result) == "number" then
        lib.notify({
            title = 'Loupež úspěšná',
            description = 'Získal jsi $' .. result,
            type = 'success'
        })
    else
        lib.notify({
            title = 'Chyba',
            description = 'Nepodařilo se získat odměnu.',
            type = 'error'
        })
    end
end)

-- ox_target bez NPC
CreateThread(function()
    for k, shop in pairs(Config.Shops) do
        exports.ox_target:addBoxZone({
            coords = shop.coords,
            size = vec3(1.5, 1.5, 2.0),
            rotation = 0,
            debug = false,
            options = {
                {
                    label = 'Vykrást obchod',
                    icon = 'fas fa-mask',
                    onSelect = function()
                        startRobbery(k)
                    end
                }
            }
        })
    end
end)
