script_name("GangSellButtons")
script_description("Sell guns and drugs fast")
script_version("v1.1")
script_authors("YoungDaggerD")

local gunDistance = 10.0
local drugDistance = 8.0
local reportDistance = 50.0

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	local font = renderCreateFont("Tahoma", 10, 5)
	while true do
		wait(0)
		if not isPauseMenuActive() and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() then
			if wasKeyPressed(66) then
				while isKeyDown(66) do
					wait(0)
					sampToggleCursor(1)
					
					local charsTable = getAllChars()

					for k,v in ipairs(charsTable) do
						local posX, posY, posZ = getCharCoordinates(v)
						local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
						res, id = sampGetPlayerIdByCharHandle(v)
						local wPosX, wPosY = convert3DCoordsToScreen(posX, posY, posZ)
						local sPosX, sPosY = convert3DCoordsToScreen(pPosX, pPosY, pPosZ)
						
						--get guns option only for player
						if drawClickableText(font, "get guns", sPosX + 25, sPosY - 75, 0xFFFFFFFF, 0xFFFF0000) and k == 1 then
							sampSendChat("/get guns")
						end

						--sell guns options
						if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= gunDistance then
							if drawClickableText(font, "sell deagle: 50", wPosX + 25, wPosY - 60, 0xFFFFFFFF, 0xFFFF0000) then
								sellGun(id, "deagle", 50)
							end
							if drawClickableText(font, "sell deagle: 100", wPosX + 25, wPosY - 45, 0xFFFFFFFF, 0xFFFF0000) then
								sellGun(id, "deagle", 100)
							end
							if drawClickableText(font, "sell m4: 50", wPosX + 25, wPosY - 30, 0xFFFFFFFF, 0xFFFF0000) then
								sellGun(id, "m4", 50)
							end
							if drawClickableText(font, "sell m4: 100", wPosX + 25, wPosY - 15, 0xFFFFFFFF, 0xFFFF0000) then
								sellGun(id, "m4", 100)
							end
						end

						--selldrugs options
						if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= drugDistance and k ~= 1 then
							if drawClickableText(font, "sell drugs: 50", wPosX + 25, wPosY, 0xFFFFFFFF, 0xFFFF0000) then
								sellDrugs(id, 50)
							end
							if drawClickableText(font, "sell drugs: 100", wPosX + 25, wPosY + 15, 0xFFFFFFFF, 0xFFFF0000) then
								sellDrugs(id, 100)
							end
						end

						--report option
						if getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ) <= reportDistance and k ~= 1 then
							if drawClickableText(font, "send report", wPosX + 25, wPosY + 30, 0xFFFFFFFF, 0xFFFF0000) then
								sendReport(id)
							end
						end
						
					end
				end
				if wasKeyReleased(66) then sampSetCursorMode(0) end
			end
		end
	end
end

function sellGun(id, gun, amount)
	local deaglePrice = 100
	local m4Price = 100
	if gun == "deagle" then
		price = amount * deaglePrice
	elseif gun == "m4" then
		price = amount * m4Price
	end

	sampSendChat("/sellgun "..gun.." "..amount.." "..price.." "..id)
end

function sellDrugs(id, amount)
	local drugPrice = 50
	sampSendChat("/selldrugs "..id.." "..amount.." "..amount * drugPrice)
end

function sendReport(id)
	sampSetChatInputEnabled(1)
	sampSetChatInputText("/report " .. id .. " ")
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