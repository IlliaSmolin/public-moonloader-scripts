local memory = require 'memory'
local sampev = require 'samp.events'
local ffi = require 'ffi'
local imgui = require 'imgui'
local sW, sH = getScreenResolution()
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local currentVehicle = nil

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()

local config = ({
    others = {
        Coup = false,
        Bang = false,
        Turn = false,
        Jump = true,
        Fexit = true,
        ExplosionInvert = false
    }, 
    settings = {
        Key = '0x4D',
        Command = 'vehm'
    },
	mfunc = {
		QuickDoors = false,
		SimplifiedDl = false,
        WheelFix = false,
        CutSpeedHack = false,
        AntiJamMotor = false,
        RepairCar = true,
        NitroMode = true,
        HydraulMode = false,
        ByeFuel = true,
        FireTroll = false,
        AntiFallOfBike = false,
        AntiEjectVehicle = false,
        WheelGM = true,
        GodMVeh = true,
        TankMode = false,
        CruiseControl = true,
        CutBrake = false,
        Springboard = true,
        RidOnWater = false,
        NoCollision = true,
        FloodComp = false,
        VehTwist = false,
        NumEdit = 'bu3ka3'
	}
})

local status = inicfg.load(config, 'MyVehicleMenu.ini')
if not doesFileExist('moonloader/config/MyVehicleMenu.ini') then inicfg.save(config, 'MyVehicleMenu.ini') end

local window = imgui.ImBool(false)
local platew = imgui.ImBool(false)
local infow = imgui.ImBool(false)
local c = imgui.ImBool(status.others.Coup)
local b = imgui.ImBool(status.others.Bang)
local t = imgui.ImBool(status.others.Turn)
local j = imgui.ImBool(status.others.Jump)
local f = imgui.ImBool(status.others.Fexit)
local expv = imgui.ImBool(status.others.ExplosionInvert)
local quick = imgui.ImBool(status.mfunc.QuickDoors)
local dl = imgui.ImBool(status.mfunc.SimplifiedDl)
local wf = imgui.ImBool(status.mfunc.WheelFix)
local sh = imgui.ImBool(status.mfunc.CutSpeedHack)
local antijm = imgui.ImBool(status.mfunc.AntiJamMotor)
local repair = imgui.ImBool(status.mfunc.RepairCar)
local nitro = imgui.ImBool(status.mfunc.NitroMode)
local hydr = imgui.ImBool(status.mfunc.HydraulMode)
local bfl = imgui.ImBool(status.mfunc.ByeFuel)
local ftrl = imgui.ImBool(status.mfunc.FireTroll)
local afb = imgui.ImBool(status.mfunc.AntiFallOfBike)
local aej = imgui.ImBool(status.mfunc.AntiEjectVehicle)
local whelgm = imgui.ImBool(status.mfunc.WheelGM)
local godm = imgui.ImBool(status.mfunc.GodMVeh)
local tmode = imgui.ImBool(status.mfunc.TankMode)
local cb = imgui.ImBool(status.mfunc.CutBrake)
local crs = imgui.ImBool(status.mfunc.CruiseControl)
local spb = imgui.ImBool(status.mfunc.Springboard)
local rw = imgui.ImBool(status.mfunc.RidOnWater)
local ncls = imgui.ImBool(status.mfunc.NoCollision)
local vtwist = imgui.ImBool(status.mfunc.VehTwist)
local flcomp = imgui.ImBool(status.mfunc.FloodComp)
local platet = imgui.ImBuffer(tostring(status.mfunc.NumEdit), 256)
local key = imgui.ImBuffer(''.. status.settings.Key, 256)
local command = imgui.ImBuffer(''.. status.settings.Command, 256)
local platec = imgui.ImFloat4(0.45, 0.55, 0.60, 1.00)

function samp_create_sync_data(sync_type, copy_from_player)
    local sampfuncs = require 'sampfuncs'
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function main()
    troll = false
    сruise = false
    rage = false
    timer = 0
    local address = sampGetBase() + 0xD83A8
    plate = ffi.cast('void(__thiscall*)(void*this, const char* text)', sampGetBase() + 0xB1BF0)
    sampRegisterChatCommand(status.settings.Command, function() window.v = not window.v imgui.Process = window.v end)
    while true do wait(0)
    if isKeyJustPressed(status.settings.Key) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then 
        window.v = not window.v 
        imgui.Process = window.v 
    end
    if quick.v then 
        if isKeyJustPressed(0x4C) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat('/lock')
        end
    end
    if dl.v then
        local protect = memory.unprotect(address, 0x87) 
        ffi.copy(ffi.cast('void*', address), '[id: %d, type: %d subtype: %d Health: %.1f]', 0x87) 
        memory.protect(address, protect) 
    else
        local protect = memory.unprotect(address, 0x87) 
        ffi.copy(ffi.cast('void*', address), '[id: %d, type: %d subtype: %d Health: %.1f preloaded: %u]\nDistance: %.2fm\nPassengerSeats: %u\ncPos: %.3f,%.3f,%.3f\nsPos: %.3f,%.3f,%.3f', 0x87) 
        memory.protect(address, protect)
    end
    if wf.v and isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
            if isKeyJustPressed(0x58) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            for tire = 0, 3 do
            fixCarTire(veh, tire)
            end
        end
    end
    if sh.v and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        local speed = getCarSpeed(veh)
        if speed >= 20 and not isCarInAirProper(veh) and isKeyDown(0x12) then
            setCarForwardSpeed(veh, speed + 7.8)
            wait(100)
        end	  
    end
    if antijm.v and isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        if isCarVisiblyDamaged(veh) then
            setCarEngineBroken(veh, false)
        end
    end
    if repair.v and isCharInAnyCar(PLAYER_PED) then
        if isKeyJustPressed(0x50) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            local _, id = sampGetVehicleIdByCarHandle(veh)
            local data = samp_create_sync_data('vehicle', true)
            if _ then
                data.vehicleId = id
                data.position.x, data.position.y, data.position.z = getCarCoordinates(veh)
                data.vehicleHealth = 1000
                data.send()
                setCarHealth(veh, 1000)
                fixCar(veh)
            end
        end
    end
    if nitro.v and isCharInAnyCar(PLAYER_PED) and isKeyJustPressed(0x4E) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        giveNonPlayerCarNitro(veh)
    end
    if hydr.v and isCharInAnyCar(PLAYER_PED) then
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            setCarHydraulics(veh, true)
    else
        if isCharInAnyCar(PLAYER_PED) then
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            setCarHydraulics(veh, false)
        end
    end
    if bfl.v and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        setCarEngineBroken(veh, false)
    end
    if ftrl.v then
        if isKeyJustPressed(0x4F) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        troll = not troll
        end
        if troll then
            if not isCharInAnyCar(PLAYER_PED) then
                troll = false
            else
                local veh = storeCarCharIsInNoSave(PLAYER_PED)
                local one, two = math.modf(localClock())
                if math.fmod(one, 2) == 0 and two < 0.1 then
                setCarHealth(veh, 1000.0)
                else
                setCarHealth(veh, 1.0)
                end
            end
        end
    end
    if vtwist.v and isKeyJustPressed(0x65) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        rage = not rage
    end
    if rage then
        if not isCharInAnyCar(PLAYER_PED) then
            rage = false
            else
            timer = timer + 20
			if timer >= 360 then timer = 0 end
			local veh = storeCarCharIsInNoSave(PLAYER_PED)
			local vx, vy, vz = getCarSpeedVector(veh)
			local camx, camy, camz = getActiveCameraCoordinates()
			local targetx, targety, targetz = getActiveCameraPointAt()
			local heading = getHeadingFromVector2d(targetx - camx, targety - camy)
			applyForceToCar(veh, (math.sin(-math.rad(timer)) / 2) - (vx / 50), (math.cos(-math.rad(timer)) / 2) - (vy / 50), 0.0, 0.0, 0.0, 0.0)
			setCarRotationVelocity(veh, 0.0, 0.0, 20.0)
        end
    end
    if afb.v and isCharInAnyCar(PLAYER_PED) then
        setCharCanBeKnockedOffBike(PLAYER_PED, true)
    else
        if isCharInAnyCar(PLAYER_PED) then
            setCharCanBeKnockedOffBike(PLAYER_PED, false)
        end
    end
    if whelgm.v and isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        setCanBurstCarTires(veh, false)
    end
	if godm.v and isCharInAnyCar(PLAYER_PED) and isKeyDown(0x10) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
		setCarProofs(veh, true, true, true, true, true)
    end
    if tmode.v and isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        setCarHeavy(veh, true)
    else
        if isCharInAnyCar(PLAYER_PED) then
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            setCarHeavy(veh, false)
        end
    end
    if crs.v and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        if isKeyJustPressed(0x43) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then cruise = not cruise end
        if cruise then
			printString("Cruise mod", 1)
            local veh = storeCarCharIsInNoSave(PLAYER_PED)
            setCarCruiseSpeed(veh, 60.0)
            setGameKeyState(16, 255)
        end  
    end 
    if cb.v and isCharInAnyCar(PLAYER_PED) and isKeyJustPressed(0x4A) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        repeat
            local speed = getCarSpeed(veh)
            setCarForwardSpeed(veh, speed - 0.5)
            wait(0)
        until speed > 0
    end
    if spb.v and isCharInAnyCar(PLAYER_PED) and isKeyJustPressed(0x4B) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        local vle = getCarHeading(veh)
        local ofX, ofY, ofZ = getOffsetFromCarInWorldCoords(veh, 0.0, 14.5, -1.3)
        local object = createObject(1634, ofX, ofY, ofZ) 
        local ole = getObjectHeading(object)
        setObjectHeading(object, vle)
        wait(3500)
        deleteObject(object)
    end
    if rw.v and isCharInAnyCar(PLAYER_PED) and isKeyDown(0xDB) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        memory.write(9867602, 1, 4)
    else
        memory.write(9867602, 0, 4)
    end
    if ncls.v and isCharInAnyCar(PLAYER_PED) and isKeyDown(0x4E) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local vehHandle = nil
        vehHandle = getNearestVehicle(300)
        if vehHandle ~= nil and currentVehicle == nil then
            setCarCollision(vehHandle, false)
            currentVehicle = vehHandle   
        end                                                                                                                   
        elseif currentVehicle ~= nil then
        if isVehicleExist(currentVehicle) then
            setCarCollision(currentVehicle, true)
            currentVehicle = nil    
        end
    end
    if flcomp.v and isCharInAnyCar(PLAYER_PED) and not isCharOnAnyBike(PLAYER_PED) then
        local v = storeCarCharIsInNoSave(PLAYER_PED)
		for i = 0, 5 do fixCarDoor(v, i) end
		for i = 0, 6 do fixCarPanel(v, i) end
		wait(50)
		for i = 0, 5 do popCarDoor(v, i, true) end
        for i = 0, 6 do popCarPanel(v, i, true) end
    end
    if c.v and isKeyDown(0x2E) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        addToCarRotationVelocity(veh, 0.0, 0.1, 0.0)
    end
    if b.v and isKeyJustPressed(0x72) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        setCarHealth(veh, 200)
    end
    if j.v and isKeyJustPressed(0x42) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local cVecX, cVecY, cVecZ = getCarSpeedVector(storeCarCharIsInNoSave(PLAYER_PED))
        if cVecZ < 7.0 then applyForceToCar(storeCarCharIsInNoSave(PLAYER_PED), 0.0, 0.0, 0.1, 0.0, 0.0, 0.0) 
        end
    end
    if t.v and isKeyJustPressed(0x08) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
		local cVecX, cVecY, cVecZ = getCarSpeedVector(storeCarCharIsInNoSave(PLAYER_PED))
		applyForceToCar(storeCarCharIsInNoSave(PLAYER_PED), -cVecX / 25, -cVecY / 25, -cVecZ / 25, 0.0, 0.0, 0.0)
		local x, y, z, w = getVehicleQuaternion(storeCarCharIsInNoSave(PLAYER_PED))
		local matrix = {convertQuaternionToMatrix(w, x, y, z)}
		matrix[1] = -matrix[1]
		matrix[2] = -matrix[2]
		matrix[4] = -matrix[4]
		matrix[5] = -matrix[5]
		matrix[7] = -matrix[7]
		matrix[8] = -matrix[8]
		local w, x, y, z = convertMatrixToQuaternion(matrix[1], matrix[2], matrix[3], matrix[4], matrix[5], matrix[6], matrix[7], matrix[8], matrix[9])
        setVehicleQuaternion(storeCarCharIsInNoSave(PLAYER_PED), x, y, z, w)
        setCarForwardSpeed(storeCarCharIsInNoSave(PLAYER_PED), 0.0)
    end
    if f.v and isKeyJustPressed(0xBB) and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
		local posX, posY, posZ = getCarCoordinates(storeCarCharIsInNoSave(PLAYER_PED))
		warpCharFromCarToCoord(PLAYER_PED, posX, posY, posZ)
    end
    if expv.v and isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        if isCarUpsidedown(veh) then
            setCarHealth(veh, 1000)
        end
    end
    if isCharInAnyCar(PLAYER_PED) then
        local add1 = memory.read(5993075, 4, false)
        local vspeed = memory.read(12045148, 4, false)
        vspeed = 1.7
        vsp = 0.9
        memory.write(add1, vsp, 4, false) 
        end
    end
end

function sampev.onSetVehicleHealth(vehicleId, health)
    if antijm.v and repair.v and godm.v then
        return false
    end
end

function sampev.onSendExitVehicle(vehicleId)
    if aej.v then
        return false
    end
end

function imgui.OnDrawFrame()
    if infow.v then
    imgui.ShowCursor = false
    imgui.SetNextWindowPos(imgui.ImVec2(sW / 2, sH / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(180, 98), imgui.Cond.FirstUseEver)
    imgui.Begin('1ff', infow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    if isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        local vhp = getCarHealth(veh)
        local gid = getCarModel(veh)
        local nmodel = getNameOfVehicleModel(gid)
        local cs = getCarSpeed(veh)
        cs = math.round(cs, 1)
        cs = cs * 4.0
        local result, sid = sampGetVehicleIdByCarHandle(veh)
        imgui.Text(u8'GameID транспорта: '..gid)
        imgui.Text(u8'ServerID транспорта: '..sid)
        imgui.Text(u8'Health: '..vhp)  
        imgui.Text(u8'Speed: '..cs)
    else
		infow.v = false 
        sampAddChatMessage('{D34A4F}MyVehicleMenu - {FFFFFF}You are not in the car', 0xD34A4F) 
    end
    imgui.End()
    end
    imgui.ShowCursor = false
    if platew.v then
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(sW / 2, sH / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(400, 100), imgui.Cond.FirstUseEver)
    imgui.Begin('MyVehicleMenu | NumEdit', platew, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    imgui.ColorEdit4('##сolor', platec)
    imgui.InputText(u8'Номерной текст', platet)
    if imgui.Button(u8'Записать', imgui.ImVec2(-1, 0)) then
    status.mfunc.NumEdit = platet.v
    if isCharInAnyCar(PLAYER_PED) then
    local veh = storeCarCharIsInNoSave(PLAYER_PED)
    local result, id = sampGetVehicleIdByCarHandle(veh)
    local vehpool = sampGetVehiclePoolPtr()
        if getStructElement(vehpool, 0x3074 + id * 4, 1) == 1 then 
            plate(ffi.cast('void*', getStructElement(vehpool, 0x1134 + id * 4, 4)), ffi.cast('char*', (tostring(status.mfunc.NumEdit))))
        end
    end
    inicfg.save(config, 'MyVehicleMenu.ini')
    end
    imgui.End()
    end
    imgui.ShowCursor = false
    if window.v then
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(sW / 2, sH / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 390), imgui.Cond.FirstUseEver)
    imgui.Begin('MyVehicleMenu v1.0.8 + edited by YoungDaggedD', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    imgui.Columns(3, 'nullptr', false)
    imgui.SetColumnWidth(-1, 150)
    imgui.Checkbox('QuickDoors', quick)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Позволяет Вам быстро открывать/закрывать двери транспорта. [НЕОБХОДИМО НАЖИМАТЬ НА L, НАХОДЯСЬ РЯДОМ С АВТОМОБИЛЕМ]')
    imgui.Checkbox('SimplifiedDl', dl)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Убирает из /dl всю лишнюю информацию. Оставляет: ServerID & GameID транспорта, HP автомобиля. [ВКЛЮЧИТЕ ЭТУ ФУНКЦИЮ И ВВЕДИТЕ /DL]')
    imgui.Checkbox('WheelFix', wf) 
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Чинит колёса автомобиля, в котором вы сидите. [НАЖМИТЕ X В АВТОМОБИЛЕ]')
    imgui.Checkbox('FireTroll', ftrl)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Заставляет ваш транспорт гореть, взорвётся, как вы из него выйдите. [НУЖНО БЫТЬ ВОДИТЕЛЕМ, НУЖНО НАЖАТЬ НА O для поджога]')
    imgui.Checkbox('WheelGM', whelgm)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Не даёт никому пробить ваши колёса, пока функция включена')
    imgui.Checkbox('CruiseControl', crs)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Круиз-Контроль для вашего автомобиля [НАЖАТЬ C]')
    imgui.Checkbox('Springboard', spb)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Трамплин для пересечения каких-либо препятствий [НАЖАТЬ НА K]')
    imgui.Checkbox('NoCollision', ncls)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Функция для уборки коллизии у ближайших автомобилей [ЗАЖАТЬ N]')
    imgui.NextColumn()
    imgui.SetColumnWidth(-1, 150)
    imgui.Checkbox('CutSpeedHack', sh)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Уже настроенный СпидХак, который даёт некоторое преимущество в скорости вашего автомобиля. [НЕОБХОДИМО ЗАЖИМАТЬ ALT, СИДЯ В АВТО; АВТОМОБИЛИ И МОТОЦИКЛЫ НЕ ПОДЛЕТАЮТ]')
    imgui.Checkbox('AntiJamMotor', antijm)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Исправляет фичу серверов, связанную с нанесением урона автомобилю, когда двигатель глушится')
    imgui.Checkbox('RepairCar', repair)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Чинит ваш автомобиль полностью. [НЕОБХОДИМО НАЖАТЬ НА P, СИДЯ В АВТОМОБИЛЕ]')
    imgui.Checkbox('AntiFallOfBike', afb)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Не даёт Вам упасть с мотоцикла')
    imgui.Checkbox('GodMVeh', godm)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Обычный GodMode для всего автомобиля [ЗАЖАТЬ LSHIFT]')
    imgui.Checkbox('NumEdit', platew)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Редактирует номер вашего автомобиля')
    imgui.Checkbox('InfoInW', infow)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Нужная информация об автомобиле в одном окне')
    imgui.Checkbox('VehTwist', vtwist)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Функция, крутящая ваш автомобиль с бешеной скоростью [АКТИВАЦИЯ НА NUM5]')
    imgui.NextColumn()
    imgui.SetColumnWidth(-1, 150)
    imgui.Checkbox('NitroMode', nitro)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Добавляет в автомобиль одноразовый нитроускоритель [НЕОБХОДИМО НАЖАТЬ НА N]')
    imgui.Checkbox('HydraulMode', hydr)
    imgui.SameLine(nil, 5)
	imgui.TextQuestion(u8'Устанавливает вашему автомобилю гидравлику')
    imgui.Checkbox('ByeFuel', bfl)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Позволяет вам забыть о заправке вашего автомобиля')
    imgui.Checkbox('AntiEjectVehicle', aej)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Не даёт другому человеку выкинуть вас из автомобиля')
    imgui.Checkbox('TankMode', tmode)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Делает ваш автомобиль опасным на дороге (тяжёлым)')
    imgui.Checkbox('CutBrake', cb)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Позволяет вам автоматически плавно затормозить [НАЖАТЬ J]')
    imgui.Checkbox('RidOnWater', rw)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Зажимная езда автомобиля по воде [ЗАЖАТЬ "["]')
    imgui.Checkbox('FloodComp', flcomp)
    imgui.SameLine(nil, 5)
    imgui.TextQuestion(u8'Функция для флуда компонентами автомобиля [НЕ ВИЗУАЛЬНО]')
    imgui.Columns(1)
    if imgui.CollapsingHeader(u8'Дополнительные функции') then
        imgui.Columns(2, 'gggzz', false)
        imgui.SetColumnWidth(-1, 200)
        imgui.Checkbox(u8'Переворот автомобиля', c)
        imgui.SameLine(nil, 5)
        imgui.TextQuestion(u8'Плавно перевернёт автомобиль, зажмите клавишу Delete')
        imgui.Checkbox(u8'Взрыв автомобиля', b)
        imgui.SameLine(nil, 5)
        imgui.TextQuestion(u8'Если автомобиль нужно срочно взорвать или вам нужно срочно взорваться, то нажмите F3')
        imgui.Checkbox(u8'Разворот на 180 градусов', t)
        imgui.SameLine(nil, 5)
        imgui.TextQuestion(u8'Если требуется развернуть автомобиль, то нажмите на Backspace')
        imgui.NextColumn()
        imgui.SetColumnWidth(-1, 250)
        imgui.Checkbox(u8'Прыжок автомобиля', j)
        imgui.SameLine(nil, 5)
        imgui.TextQuestion(u8'Если требуется перепрыгнуть воду или препятствие, то нажмите на B')
        imgui.Checkbox(u8'Быстрый выход с автомобиля', f)
        imgui.SameLine(nil, 5)
        imgui.TextQuestion(u8'Если требуется быстро выйти из автомобиля, то нажмите на =')
        imgui.Checkbox(u8'ExplosionInvert', expv)
        imgui.SameLine(nil, 5)
        imgui.TextQuestion(u8'Функция, благодаря которой ваш автомобиль при перевороте не взорвётся')
        imgui.Columns(1)
    end
    imgui.InputText(u8'Клавиша', key)
    imgui.InputText(u8'Команда', command)
    if imgui.Button(u8'Сохранить изменения', imgui.ImVec2(-1, 0)) then
        status.mfunc.QuickDoors = quick.v
        status.mfunc.SimplifiedDl = dl.v
        status.mfunc.WheelFix = wf.v
        status.mfunc.CutSpeedHack = sh.v
        status.mfunc.AntiJamMotor = antijm.v
        status.mfunc.RepairCar = repair.v
        status.mfunc.NitroMode = nitro.v
        status.mfunc.HydraulMode = hydr.v
        status.mfunc.ByeFuel = bfl.v
        status.mfunc.FireTroll = ftrl.v
        status.mfunc.AntiFallOfBike = afb.v
        status.mfunc.AntiEjectVehicle = aej.v
        status.mfunc.WheelGM = whelgm.v
        status.mfunc.GodMVeh = godm.v
        status.mfunc.TankMode = tmode.v
        status.mfunc.CruiseControl = crs.v
        status.mfunc.CutBrake = cb.v
        status.mfunc.Springboard = spb.v
        status.mfunc.RidOnWater = rw.v
        status.mfunc.NoCollision = ncls.v
        status.mfunc.FloodComp = flcomp.v
        status.mfunc.VehTwist = vtwist.v
        status.others.Coup = c.v
        status.others.Bang = b.v
        status.others.Turn = t.v
        status.others.Jump = j.v
        status.others.Fexit = f.v
        status.others.ExplosionInvert = expv.v
        status.settings.Key = key.v
        status.settings.Command = command.v
        inicfg.save(config, 'MyVehicleMenu.ini')
        printStringNow('~g~Changes Saved Successfully', 1500)
    end
    imgui.End()   
    end
end

function imgui.TextQuestion(text)
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function math.round(num, idp) -- округление
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function getNearestVehicle(radius)
    if not sampIsLocalPlayerSpawned() then return end
    local pVehicle = getLocalVehicle()
    local pCoords = {getCharCoordinates(PLAYER_PED)}
    local vehicles = getAllVehicles()
    table.sort(vehicles, function(a, b)
        local aX, aY, aZ = getCarCoordinates(a)
        local bX, bY, bZ = getCarCoordinates(b)
        return getDistanceBetweenCoords3d(aX, aY, aZ, unpack(pCoords)) < getDistanceBetweenCoords3d(bX, bY, bZ, unpack(pCoords))
    end)
    for i = #vehicles, 1, -1 do
        if vehicles[i] == pVehicle then
            table.remove(vehicles, i)
        elseif radius ~= nil then
            local x, y, z = getCarCoordinates(vehicles[i])
            if getDistanceBetweenCoords3d(x, y, z, unpack(pCoords)) > radius then
                table.remove(vehicles, i)
            end
        end
    end
    return vehicles[1]
end

function getLocalVehicle()
    return isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or nil
end

function isVehicleExist(vHandle)
    if not sampIsLocalPlayerSpawned() then return false end
    return hasValue(getAllVehicles(), vHandle)
end

function hasValue(tab, val)
    for _, v in ipairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end