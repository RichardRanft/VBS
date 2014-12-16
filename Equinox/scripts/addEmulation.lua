#! /bin/lua
-- Language: Lua

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function usage()
    print("Usage: ./lua addEmulation.lua <platform version> <(optional) subfolder");
end

function evalCmdLine(cmdArg)
    local listArgs = {};
    if tablelength(cmdArg) < 1 then
        print("Too few arguments");
        for i = 1, tablelength(arg), 1 do
            print(cmdArg[i]);
        end
        usage();
        return;
    end
    if tablelength(cmdArg) > 2 then
        for i = 1, tablelength(cmdArg), 1 do
            if cmdArg[i] ~= nil then
                listArgs[i] = cmdArg[i];
            end
        end
        if tablelength(listArgs) > 2 then
            print("Too many arguments");
            for i = 1, tablelength(listArgs), 1 do
                print(listArgs[i]);
            end
            usage();
            return;
        end
    end
    return 0;
end

function copyPlatform(srcPlatform, subfolder)
    if subfolder == nil or subfolder == "" then
        --print(" -- copyPlatform(" .. srcPlatform .. ", nil)");
        os.execute("sudo rm -rf /home/sgp1000/workspace/" .. srcPlatform);
        os.execute("rsync -r --exclude=.svn /home/sgp1000/EGMPlatforms/" .. srcPlatform .. "/* /home/sgp1000/workspace/" .. srcPlatform);
    else
        --print(" -- copyPlatform(" .. srcPlatform .. ", " .. subfolder .. ")");
        os.execute("sudo rm -rf /home/sgp1000/workspace/" .. subfolder .. "/" .. srcPlatform);
        os.execute("rsync -r --exclude=.svn /home/sgp1000/EGMPlatforms/" .. srcPlatform .. "/* /home/sgp1000/workspace/" .. subfolder .. "/" .. srcPlatform);
    end
end

function fix_ini(path)
    print("\n -- fixing egm_games.ini - setting path to /game\n");
    local textLines = {};
    i = 0;
    local scriptPath = path .. "/egm_games.ini";
    scriptFile = io.open(scriptPath, "r");
    for line in scriptFile:lines() do
        textLines[i] = string.gsub(line, "()rapid()", "game");
        i = i + 1;
    end
    scriptFile = io.open(scriptPath, "w+");
    for j = 0,i do
        if textLines[j] ~= nil then
            -- print(" -- " .. textLines[j]);
            scriptFile:write(textLines[j] .. "\n");
        end
    end
    scriptFile:close();
end

function fix_run_gc(path)
    print("\n -- fixing run_gc - setting to use ddd for debugging\n");
    local runGcLines = {};
    i = 0;
    runGc = path .. "/run_gc";
    runGcFile = io.open(runGc, "r");
    for line in runGcFile:lines() do
        if string.find(line, "()gdb()") ~= nil then
            runGcLines[i] = string.gsub(line, "()gdb()", "ddd");
            i = i + 1;
        else
            runGcLines[i] = line;
            i = i + 1;
        end
    end
    runGcFile = io.open(runGc, "w+");
    for j = 0,i do
        if runGcLines[j] ~= nil then
            -- print(" -- " .. runGcLines[j]);
            runGcFile:write(runGcLines[j] .. "\n");
        end
    end
    runGcFile:close();
end

function fix_run_gc_solo(path)
    print("\n -- fixing run_gc_solo - setting to use ddd for debugging\n");
    local runGcSoloLines = {};
    i = 0;
    runGcSolo = path .. "/run_gc_solo";
    runGcSoloFile = io.open(runGcSolo, "r");
    for line in runGcSoloFile:lines() do
        if string.find(line, "()gdb()") ~= nil then
            runGcSoloLines[i] = string.gsub(line, "()gdb()", "ddd");
            i = i + 1;
        else
            runGcSoloLines[i] = line;
            i = i + 1;
        end
    end
    runGcSoloFile = io.open(runGcSolo, "w+");
    for j = 0,i do
        if runGcSoloLines[j] ~= nil then
            -- print(" -- " .. runGcSoloLines[j]);
            runGcSoloFile:write(runGcSoloLines[j] .. "\n");
        end
    end
    runGcSoloFile:close();
end

function getOSVersion()
    releaseData = "";
    releaseFilePath = "/etc/os-release";
    releasefile = io.open(releaseFilePath, "r");
    for line in releasefile:lines() do
        if string.find(line, "()VERSION_ID=()") ~= nil then
            releaseData = string.gsub(line, "()VERSION_ID=()", "");
        end
    end
    -- clean quotation marks from the version id string
    temp = string.gsub(releaseData, "()\"()", "");
    -- and convert the remaining string to a number
    version = tonumber(temp);
    if version == nil then
        -- conversion failed - can't convert the remaining string to a valid number
        print(" -- OS Version is nil for some odd reason....");
        version = 0;
    else
        print(" -- OS Version: " .. version);
    end
    return version;
end

function fix_permissions(path)
    print(" -- fixing script executable permissions...");
    os.execute("chmod +x " .. path .. "/run_gc");
    os.execute("chmod +x " .. path .. "/run_gc_solo");
end

function fix_kernel_path()
    local osVersion = getOSVersion();
    -- Earlier versions of OpenSuSE didn't seem to need this fix, so bail if 
    -- our version is newer than 12.0
    if osVersion < 12 then
        return;
    end
    if file_exists("/usr/src/kernels/2.6.16-s915g5.i386") == true then
        print(" -- symlink /usr/src/kernels/2.6.16-s915g5.i386 to /usr/src/kernels/2.6.16-s915g5-i386 present.");
        return;
    end
    print(" -- adding symlink /usr/src/kernels/2.6.16-s915g5.i386 to /usr/src/kernels/2.6.16-s915g5-i386...");
    os.execute("sudo ln -s /usr/src/kernels/2.6.16-s915g5-i386 /usr/src/kernels/2.6.16-s915g5.i386");
end

function fix_io_proc_make(path)
    -- check our operating system.  If older than 12.0 then bail.
    local osVersion = getOSVersion();
    if osVersion < 12 then
    end
    print("\n -- checking io_proc/simulator/gui/Makefile for -lgobject-2.0 ...\n");
    local ioProcMakelines = {};
    i = 0;
    ioProcMake = path .. "/platform/src/io_proc/simulator/gui/Makefile";
    ioProcMakefile = io.open(ioProcMake, "r");
    for line in ioProcMakefile:lines() do
        if string.find(line, "()LIBS =()") ~= nil and string.find(line, "()-lgobject-2.0()") == nil then
            ioProcMakelines[i] = string.gsub(line, "()LIBS = ()", "LIBS = -lgobject-2.0 ");
            i = i + 1;
        else
            ioProcMakelines[i] = line;
            i = i + 1;
        end
    end
    ioProcMakefile = io.open(ioProcMake, "w+");
    for j = 0,i do
        if ioProcMakelines[j] ~= nil then
            -- print(" -- " .. ioProcMakelines[j]);
            ioProcMakefile:write(ioProcMakelines[j] .. "\n");
        end
    end
    ioProcMakefile:close();
    print("\n -- added -lgobject-2.0 to io_proc/simulator/gui/Makefile LIBS.\n");
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then 
        io.close(f);
        --print("file_exists: " .. name .. " found.");
        return true;
    else 
        --print("file_exists: " .. name .. " not found.");
    end
    return false;
end

if evalCmdLine(arg) ~= nil then
    os.setlocale("C");
    name = arg[1];
    folder = arg[2];
    print("Installing platform " .. name .. " for emulation");
    source = "/home/sgp1000/EGMPlatforms/".. name .. "/images";
    target = "/home/sgp1000/workspace/";

    if name ~= nil then
        if folder ~= nil then
            if file_exists("/home/sgp1000/workspace/" .. folder .. "/" .. name) then
                target = target .. folder .. "/" .. name;
                os.execute("sudo rm -rf /home/sgp1000/workspace/" .. folder .. "/" .. name);
            end
            os.execute("mkdir /home/sgp1000/workspace/" .. folder .. "/" .. name);
        else
            if file_exists("/home/sgp1000/workspace/" .. name) ~= true then
                target = target .. name;
                os.execute("sudo rm -rf /home/sgp1000/workspace/" .. name);
            end
            os.execute("mkdir /home/sgp1000/workspace/" .. name);
        end
        copyPlatform(name, folder);
        egmPath = "/home/sgp1000/workspace/";
        if folder ~= nil and folder ~= "" then
            egmPath = egmPath .. folder .. "/";
        end
        egmPath = egmPath .. name .. "/games/egm/";
        print(" -- EGM emulation path: " .. egmPath);
        fix_ini(egmPath);
        fix_run_gc(egmPath);
        fix_run_gc_solo(egmPath);
        fix_permissions(egmPath);
        fix_io_proc_make(target);
        fix_kernel_path();
    else
        print("No platform specified.  Exiting.");
    end
end
