script_name('[SAMP-RP] Police Detector')
script_description('показывает сколько полицейских/солдатов находится рядом и видят ли они вас')
script_author('YoungDaggerD')
script_version('1.0')

local policeSkins = {[265] = true, [266] = true, [267] = true, [280] = true, [281] = true, [282] = true, [283] = true, [284] = true, [288] = true, [302] = true, [303] = true, [304] = true, [305] = true, [306] = true, [309] = true, [310] = true, [311] = true}
local policeCounter = 0
local swatSkins = {[285] = true}
local swatCounter = 0
local fbiSkins = {[163] = true, [164] = true, [165] = true, [166] = true, [286] = true}
local fbiCounter = 0
local soldierSkins = {[287] = true}
local soldierCounter = 0

local font = renderCreateFont('Tahoma', 10, 13)
local font1 = renderCreateFont('Tahoma', 9, 13)
local detectedFont = renderCreateFont('Tahoma', 14, 13)
local active = true
local w, h = getScreenResolution()

function isVisible(myPosX, myPosY, myPosZ, posX, posY, posZ)
	if isLineOfSightClear(myPosX, myPosY, myPosZ, posX, posY, posZ, true) then
		renderFontDrawText(detectedFont, '{AB1126}Вас видят!!!', w/1.200, h/1.62, 0xFFFFFFFF)
	end
end

function main()
	repeat wait(0) until isSampAvailable() 
	sampRegisterChatCommand('pd',function()
		active = not active
		printString('Police Detector: '..(active and '~g~activated' or '~r~disabled'), 1500)
	end)
	while true do
		wait(0)
		if active then
			policeCounter = 0
			swatCounter = 0
			fbiCounter = 0
			soldierCounter = 0

			for i = 0, sampGetMaxPlayerId(true) do
				local result, ped = sampGetCharHandleBySampPlayerId(i)
				if result then
					local myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
					local posX, posY, posZ = getCharCoordinates(ped)
					local distance = getDistanceBetweenCoords3d(myPosX, myPosY, myPosZ, posX, posY, posZ)

					if distance <= 301.0 then
						local playerSkinId = getCharModel(ped)
						if policeSkins[playerSkinId] then
							policeCounter = policeCounter + 1
							isVisible(myPosX, myPosY, myPosZ, posX, posY, posZ)
						end
						if swatSkins[playerSkinId] then
							swatCounter = swatCounter + 1
							isVisible(myPosX, myPosY, myPosZ, posX, posY, posZ)
						end
						if fbiSkins[playerSkinId] then
							fbiCounter = fbiCounter + 1
							isVisible(myPosX, myPosY, myPosZ, posX, posY, posZ)
						end
						if soldierSkins[playerSkinId] then
							soldierCounter = soldierCounter + 1
							isVisible(myPosX, myPosY, myPosZ, posX, posY, posZ)
						end
					end
				end
			end
			if not isPauseMenuActive() and fbiCounter ~= 0 or policeCounter ~= 0 or swatCounter ~= 0 or soldierCounter ~= 0 then
				renderFontDrawText(font, '{207E9E}Копы: {FFFFFF}'..policeCounter..'{0F426B}\nСпецназ: {FFFFFF}'..swatCounter..'{092730}\nФБР: {FFFFFF}'..fbiCounter..'{138054}\nСолдаты: {FFFFFF}'..soldierCounter, w/1.200, h/1.850, 0xFFFFFFFF)
			elseif not isPauseMenuActive() then
				renderFontDrawText(font1, 'Возле вас нет силовиков.', w/1.255, h/1.850, 0xFFFFFFFF)
			end
		end
	end
end