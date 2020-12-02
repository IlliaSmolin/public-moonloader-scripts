script_name('Hot-Dog Bot')
script_version("v0.2")
script_description('Automatically proposes /selleat for each id in the selling radius')
script_author('YoungDaggerD')

local active = false
local floodTimeout = 1000
local nearbyPlayerIds = {}
local timedOutIds = {}
local distance = 7.8

function hasValue (tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

function activation()
	active = not active
	timedOutIds = {}
	printString('Hot-Dog Bot: '..(active and '~g~activated' or '~r~disabled'), 1500)
end

function findNearbyPlayers()
	nearbyPlayerIds = {}
	local charsTable = getAllChars()
	table.remove(charsTable, 1)

	for k,v in ipairs(charsTable) do
		local posX, posY, posZ = getCharCoordinates(v)
		local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
		if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= distance then
			res, id = sampGetPlayerIdByCharHandle(v)
			if res then
				table.insert(nearbyPlayerIds, id)
			end
		end
	end
end

function feedPlayers()
	for k,v in ipairs(nearbyPlayerIds) do
		if not hasValue(timedOutIds, v) then
			sampSendChat("/selleat "..v)
			table.insert(timedOutIds, v)
			wait(floodTimeout)
		end
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
			feedPlayers()
		end
	end
end
