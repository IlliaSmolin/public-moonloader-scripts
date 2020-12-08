script_name("Mech job helper")
script_description("repair and refill other drivers with a click")
script_version("v1.0")
script_authors("YoungDaggerD")

local distance = 7.5

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	local font = renderCreateFont("Tahoma", 12, 5)
	while true do
		wait(0)
		if not isPauseMenuActive() and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() then
			if wasKeyPressed(86) then
				local ur, selfId = sampGetPlayerIdByCharHandle(PLAYER_PED)
				while isKeyDown(86) do
					wait(0)
					sampToggleCursor(1)
					
					local vehTable = getAllVehicles()

					for k,v in ipairs(vehTable) do
						local posX, posY, posZ = getCarCoordinates(v)
						local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
						driver = getDriverOfCar(v)
						res, id = sampGetPlayerIdByCharHandle(driver)
						if res then
							local wPosX, wPosY = convert3DCoordsToScreen(posX, posY, posZ)
							local sPosX, sPosY = convert3DCoordsToScreen(pPosX, pPosY, pPosZ)

							if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= distance then
								if id == selfId then
									if drawClickableText(font, "repair myself", sPosX + 25, sPosY - 10, 0xFFFFFFFF, 0xFFFF0000) then
										repair(id)
									end
								else
									if drawClickableText(font, "refill", wPosX + 25, wPosY - 40, 0xFFFFFFFF, 0xFFFF0000) then
										refill(id)
									end
									if drawClickableText(font, "repair", wPosX + 25, wPosY - 10, 0xFFFFFFFF, 0xFFFF0000) then
										repair(id)
									end
								end
							end
						end
					end
				end
				if wasKeyReleased(86) then sampSetCursorMode(0) end
			end
		end
	end
end

function repair(id)
	sampSendChat("/repair "..id)
end

function refill(id)
	sampSendChat("/refill "..id)
end

function drawClickableText(font, text, posX, posY, color, colorA)
	renderFontDrawText(font, text, posX, posY, color)
	local textLenght = renderGetFontDrawTextLength(font, text)
	local textHeight = renderGetFontDrawHeight(font)
	local curX, curY = getCursorPos()
	if curX >= posX and curX <= posX + textLenght and curY >= posY and curY <= posY + textHeight then
		renderFontDrawText(font, text, posX, posY, colorA)
		if wasKeyPressed(1) then
			return true
		end
	end
end