require 'lib.moonloader'
local active = false
local floodTimeout = 1000
local playerIds = {}
local distance = 7.8

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function activation()
	active = not active
	printString('Hot-Dog Bot: '..(active and '~g~activated' or '~r~disabled'), 1500)
end

function findNearbyPlayers()
	playerIds = {}
	local charsTable = getAllChars()
	table.remove(charsTable, 1)

	for k,v in ipairs(charsTable) do
		local posX, posY, posZ = getCharCoordinates(v)
		local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
		if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= distance then
			res, id = sampGetPlayerIdByCharHandle(v)
			if res then
				table.insert(playerIds, id)
			end
		end
	end
end

function feedNearbies()
	for k,v in ipairs(playerIds) do
		sampSendChat("/selleat "..v)
		wait(floodTimeout)
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand('hb', activation)
	while true do
		wait(0)

		if active then
			findNearbyPlayers()

			if tablelength(playerIds) == 0 then
				wait(100)
			else
				feedNearbies()
				wait(5000)
			end
		end
	end
end
