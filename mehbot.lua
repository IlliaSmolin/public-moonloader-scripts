script_name('Mech Bot')
script_version("v1.0")
script_description('Automatically proposes /repair and /refill for each driver id in the radius')
script_author('YoungDaggerD')

local active = false
local floodTimeout = 1000
local nearbyDriverIds = {}
local timedOutIds = {}
local distance = 7.5
local selfId = nil

function hasValue(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function sendWithTimeOut(text)
	sampSendChat(text)
	wait(floodTimeout)
end

function activation()
	active = not active
	ur, selfId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	timedOutIds = {}
	printString('Mech Bot: '..(active and '~g~activated' or '~r~disabled'), 1500)
end

function findNearbyDrivers()
	nearbyDriverIds = {}
	local vehTable = getAllVehicles()

	for k,v in ipairs(vehTable) do
		local posX, posY, posZ = getCarCoordinates(v)
		local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
		if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= distance then
			driver = getDriverOfCar(v)
			res, id = sampGetPlayerIdByCharHandle(driver)
			if res and id ~= selfId then
				table.insert(nearbyDriverIds, id)
			end
		end
	end
end

function servePlayers()
	for k,v in ipairs(nearbyDriverIds) do
		if not hasValue(timedOutIds, v) then
			if tableLength(timedOutIds) >= 3 then
				timedOutIds = {}
			end
			sendWithTimeOut("/repair "..v)
			sendWithTimeOut("/refill "..v)
			table.insert(timedOutIds, v)
		end
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand('mb', activation)
	while true do
		wait(0)

		if active then
			findNearbyDrivers()
			servePlayers()
		end
	end
end
