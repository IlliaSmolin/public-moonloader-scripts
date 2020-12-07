script_name('Mech Bot')
script_version("v0.3")
script_description('Automatically proposes /repair and /refill for each driver id in the radius')
script_author('YoungDaggerD')

local samp = require 'lib.samp.events'

local active = false
local floodTimeout = 1000
local smsTimeout = 2000
local nextServeTimeout = 8000
local nearbyDriverIds = {}
local timedOutIds = {}
local timedOutSmsIds = {}
local distance = 7.5
local selfId = nil
local id = nil

function samp.onServerMessage(color, text) --catch users with active requests
  lua_thread.create(function()
    if text:find('Игрок уже получил предложение') then
      local currId = id
      wait(smsTimeout)

      if not hasValue(timedOutSmsIds, currId) then
        if tableLength(timedOutSmsIds) >= 3 then
          table.remove(timedOutSmsIds, 1)
        end
        sampSendChat('/sms '..currId..' отмени активные предложения заправки/починки', 0xFFFFFF)
        table.insert(timedOutSmsIds, currId)
        wait(nextServeTimeout)
        servePlayer(currId)
      end
    end
  end)
end

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
  timedOutSmsIds = {}
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
			local res, id = sampGetPlayerIdByCharHandle(driver)
			if res and id ~= selfId then
				table.insert(nearbyDriverIds, id)
			end
		end
	end
end

function servePlayer(id)
  sendWithTimeOut("/repair "..id)
  sendWithTimeOut("/refill "..id)
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand('mb', activation)
	while true do
		wait(floodTimeout)

		if active then
			findNearbyDrivers()
      for k,v in ipairs(nearbyDriverIds) do
        if not hasValue(timedOutIds, v) then
          if tableLength(timedOutIds) >= 3 then
            table.remove(timedOutIds, 1)
          end
          id = v
          servePlayer(id)
          table.insert(timedOutIds, id)
        end
      end
		end
	end
end
