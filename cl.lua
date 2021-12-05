local EFFECT_TIME = 1000 -- Every second an effect will occur.
local STOP_VEHICLE = 8 -- Chances to stop a vehicle.

---Returns direction of camera
---@param rotation number
---@return table
local function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

---Returns if the raycast was hit, the entity, and the coords of entity
---@param distance number
---@return boolean
---@return table
---@return number
local function RayCastGamePlayCamera(distance)
	local cameraRotation, cameraCoord = GetGameplayCamRot(), GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = {
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end

---Sets vehicle to halt
---@param entity number
local function haltEnt(entity)
    if not IsVehicleBeingHalted(entity) then
        BringVehicleToHalt(entity, 10.0, 10.0, false)
        Wait(10000)
        StopBringVehicleToHalt(entity)
    end
end

CreateThread(function()
    local sleep = 0
    while true do
        if IsFlashLightOn(PlayerPedId()) then
            sleep = EFFECT_TIME
            local hit, coords, entity = RayCastGamePlayCamera(5.0)
            if hit and IsEntityAVehicle(entity) then
                if DoesEntityExist(entity) then
                    local driver = GetPedInVehicleSeat(entity, -1)
                    if IsPedAPlayer(driver) then
                        TriggerServerEvent('driver:requestEffect', GetPlayerServerId(NetworkGetEntityOwner(driver)))
                    else
                        if math.random(1, 10) >= STOP_VEHICLE then
                            haltEnt(entity)
                        else
                            local ranTire = math.random(0, 5)
                            if not IsVehicleTyreBurst(entity, ranTire, true) then
                                SetVehicleTyreBurst(entity, ranTire, true, 1)
                            end
                        end
                    end
                end
            end
        else
            if sleep ~= 1000 then
                sleep = 1500
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('driver:getEffect', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle > 0 then
        if math.random(1, 10) >= STOP_VEHICLE then
            haltEnt(vehicle)
        else
            local ranTire = math.random(0, 5)
            if not IsVehicleTyreBurst(vehicle, ranTire, true) then
                SetVehicleTyreBurst(vehicle, ranTire, true, 1)
            end
        end
    end
end)