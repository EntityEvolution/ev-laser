RegisterNetEvent('driver:requestEffect', function(playerId)
    if playerId ~= source then
        if type(playerId) == "number" then
            TriggerClientEvent('driver:getEffect', playerId)
        end
    end
end)