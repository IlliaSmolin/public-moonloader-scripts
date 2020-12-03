script_name("WH")
script_description("Wall hack with info about enemies' health, shots to die from deagle, and with anti-screenshot mode")
script_version("v1.4")
script_authors("YoungDaggerD")

require 'lib.moonloader'
local font = renderCreateFont('Arial',8,5)
local active = false

function activation()
	active = not active
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	while true do
		wait(0)
		
		if wasKeyPressed(VK_Z) and not sampIsChatInputActive() and not sampIsDialogActive() then
			activation()
		end
		
		if active then
			if wasKeyPressed(VK_F8) then
			 activation()
			 wait(1000)
			 activation()
			end
			
			--'+' symbol on main char as an indicator
			local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
			local sPosX, sPosY = convert3DCoordsToScreen(pPosX, pPosY, pPosZ)
			renderFontDrawText(font, '{00FF00}+', sPosX, sPosY, -1)

			local charsTable = getAllChars()
			table.remove(charsTable, 1)

			for k,v in ipairs(charsTable) do 
				local posX, posY, posZ = getCharCoordinates(v)
				if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= 100.0 then
					local wPosX, wPosY = convert3DCoordsToScreen(posX, posY, posZ)
					res, id = sampGetPlayerIdByCharHandle(v)
					hp = sampGetPlayerHealth(id)
					armor = sampGetPlayerArmor(id)
					globalHealth = hp + armor
					if res then
						renderDrawBoxWithBorder(wPosX - 35, wPosY - 40, 65, 95, 0x00FFFFFF, 1, 0xFF00FF00)
						renderFontDrawText(font, '{FF0000}'..math.ceil((globalHealth)/47), wPosX + 10, wPosY + 20, -1)
						renderFontDrawText(font, globalHealth, wPosX, wPosY + 35, -1)
					end
				end
			end
		end
	end
end