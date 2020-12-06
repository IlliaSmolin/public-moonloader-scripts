script_name('норм езда с пробитыми шинами')
script_version('1.0')
script_version_number(1)
script_author('KepchiK')
script_dependencies('SAMPFUNCS ^5.3')

local ffi = require 'ffi'

ffi.cdef [[
    int __stdcall VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
]]

activated = ffi.new('int[1]', 1)

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand('fw', cmdFunc)
	local hookType = 'unsigned int(__thiscall *)(void *, int)'
	installCallHook(hookType, 0x6A55FE, GetWheelStatus)
	installCallHook(hookType, 0x6A5ACC, GetWheelStatus)
	OrigGetWheelStatus = ffi.cast(hookType, 0x6C21B0)
	wait(-1)
end

function cmdFunc(arg)
	if activated[0] == 0 then
		printString('fix wheels: ~g~activated', 1000)
		activated[0] = 1
	else
		printString('fix wheels: ~r~deactivated', 1000)
		activated[0] = 0
	end
end

function GetWheelStatus(this, wheel)
	if activated[0] == 1 then
		return 0
	end
	return OrigGetWheelStatus(this, wheel)
end

function installCallHook(hookType, installAddr, hookFunc)
    local hookAddr = ffi.cast('void*', installAddr)
    local hookArray = ffi.new('uint8_t[?]', 5, 0x90)
    hookArray[0] = 0xE8
    ffi.cast('uint32_t*', hookArray + 1)[0] = tonumber(ffi.cast('intptr_t', ffi.cast('void*', ffi.cast(hookType, hookFunc)))) - installAddr - 5
	local oldProtect = ffi.new('unsigned long[1]')
	ffi.C.VirtualProtect(hookAddr, 5, 0x40, oldProtect)
	ffi.copy(hookAddr, hookArray , 5)
	ffi.C.VirtualProtect(hookAddr, 5, oldProtect[0], oldProtect)
end