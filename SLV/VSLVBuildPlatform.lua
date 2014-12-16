#!/bin/lua 
 -- Language: Lua

DEBUG = true;
DEBUGCMD = false;
VMNAME = "/home/sgp1000/vmware/SLVBuildEnv/SHFL-SUSE-12.3-64-bit.100GB.vmx";
VMSTARTED = false;
ShareRoot = "/mnt/hgfs/"

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function list_iter(t)
    local i = 0
    local n = tablelength(t)
    return function ()
        i = i + 1
        if i <= n then return t[i] end
    end
end

function evalCmdLine(cmdArg, minArgs, maxArgs)
    local listArgs = {};
    if tablelength(cmdArg) < minArgs then
        print("Too few arguments");
        for i = 1, tablelength(arg), 1 do
            print(cmdArg[i]);
        end
        usage();
        return;
    end
    if tablelength(cmdArg) >= minArgs then
        for i = 1, tablelength(cmdArg), 1 do
            if cmdArg[i] ~= nil then
                listArgs[i] = cmdArg[i];
            end
        end
        if tablelength(listArgs) > maxArgs then
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

function dumpOutput(fileHandle, message)
    -- dump command output to console
    if message ~= nil then
        print(" -- " .. message);
    end
    local result = 0;
    local errorFound = false;
    for line in fileHandle:lines() do
        if line ~= nil then
            if string.find(line, "()Error()") ~= nil then
                errorFound = true;
                result = 2;
            end
            print(" --- " .. line);
        end
    end
    return result;
end

function checkError(fileHandle)
    -- dump command output to console
    if message ~= nil then
        print(" -- " .. message);
    end
    local result = 0;
    local errorFound = false;
    for line in fileHandle:lines() do
        if line ~= nil then
            if string.find(line, "()Error()") ~= nil then
                errorFound = true;
                result = 2;
            end
            if errorFound == true then
                print(" --- " .. line);
                abort(" --- " .. line, result);
            end
        end
    end
    return result;
end

function abort(reason, code)
	print(reason);
        if VMSTARTED == true then
            stopVM();
        end
	os.exit(code, true);
end

function wait(seconds)
    if seconds == nil then
        print(" -- wait() - seconds is nil");
        return 29;
    end
    if DEBUG == true then
        print(" -- wait() : " .. seconds);
    end
    os.execute("sleep " .. tonumber(seconds));
    return 0;
end

function setScriptLink(Platform)
    local result = 0;
    if Platform == nil then
        abort(" -- setScriptLink() - Platform is nil!", 2);
    end
    if DEBUG == true then
        print(" -- setScriptLink(" .. Platform .. ")");
    end

    command = "sh /home/sgp1000/VBS/SLV/scripts/setup " .. Platform .. "_Debug";
    result = os.execute(command);
    if result == nil then
        print(" --- Error: setScriptLink()");
    end

    return result;
end

-- VMWare wrapper functions

function startVM()
    -- vm start step
    local result = 0;
    command = "vmrun -T ws start " .. VMNAME .. " nogui";
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- startVM() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "startVM()");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing startVM() - " .. exitCode .. " : " .. exitSignal);
    end
    VMSTARTED = true;
    return result;
end

function stopVM()
    -- vm start step
    local result = 0;
    command = "vmrun -T ws stop " .. VMNAME .. " soft";
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- stopVM() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "stopVM()");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing stopVM() - " .. exitCode .. " : " .. exitSignal);
    end
    VMSTARTED = false;
    return result;
end

function runScriptInVM(interpreter, scriptText)
    -- runs script in guest
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password runScriptInGuest " .. VMNAME .. " " .. interpreter .. " " .. scriptText;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- runScriptInVM() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "runScriptInVM(" .. interpreter .. ", " .. scriptText .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing runScriptInVM() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function runProgramInVM(program, args)
    -- runs script in guest
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password runProgramInGuest " .. VMNAME .. " " .. program .. " " .. args;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- runProgramInVM() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "runProgramInVM(" .. program .. ", " .. args .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing runScriptInVM() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function createFolderInVM(path)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password createDirectoryInGuest " .. VMNAME .. " " .. path;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- createFolderInVM() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "createFolderInVM(" .. path .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing createFolderInVM() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function removeFolderInVM(path)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password deleteDirectoryInGuest " .. VMNAME .. " " .. path;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- removeFolderInVM() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "removeFolderInVM(" .. path .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing removeFolderInVM() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function addSharedFolder(pathOnGuest, pathOnHost)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password addSharedFolder " .. VMNAME .. " " .. pathOnGuest .. " " .. pathOnHost;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- addSharedFolder() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "addSharedFolder(" .. pathOnGuest .. ", " .. pathOnHost .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile)
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing addSharedFolder() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function removeSharedFolder(pathOnGuest)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password removeSharedFolder " .. VMNAME .. " " .. pathOnGuest;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- removeSharedFolder() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "addSharedFolder(" .. pathOnGuest .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing removeSharedFolder() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function copyFileToGuest(pathOnHost, pathOnGuest)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password copyFileFromHostToGuest " .. VMNAME .. " " .. pathOnHost .. " " .. pathOnGuest;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- copyFileToGuest() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "copyFileToGuest(" .. pathOnHost .. ", " .. pathOnGuest .. ")");
            if DEBUGCMD == true then
            print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing copyFileToGuest() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function copyFileToHost(pathOnGuest, pathOnHost)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password copyFileFromGuestToHost " .. VMNAME .. " " .. pathOnGuest .. " " .. pathOnHost;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- copyFileToHost() - unable to execute vmrun command!", 1);
    else
        if DEBUG == true then
            result = dumpOutput(infile, "copyFileToHost(" .. pathOnGuest .. ", " .. pathOnHost .. ")");
            if DEBUGCMD == true then
            print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing copyFileToHost() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function listDirectoryInGuest(pathOnGuest)
    local result = 0;
    command = "vmrun -T ws -gu sgp1000 -gp password listDirectoryInGuest " .. VMNAME .. " " .. pathOnGuest;
    infile = io.popen(command, "r");
    if infile == nil then
        abort(" -- listDirectoryInGuest() - unable to execute vmrun command!", 1);
    else
        for line in infile:lines() do
            if line ~= nil then
                print(" --- " .. line);
            end
        end
        if DEBUG == true then
            result = dumpOutput(infile, "listDirectoryInGuest(" .. pathOnGuest .. ")");
            if DEBUGCMD == true then
                print(" -- " .. command);
            end
        else
            result = checkError(infile);
        end
    end
    exitCode, exitSignal = infile:close();
    if tonumber(exitCode) ~= nil then
        print(" --- error executing listDirectoryInGuest() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

-- build scripts

function compile(Platform)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compile(" .. Platform .. ")");
    end
    program = ShareRoot .. "buildScripts/BuildSLVPlatform";
    args = Platform;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result;
end

function compileShow(Platform)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compileShow(" .. Platform .. ")");
    end
    program = ShareRoot .. "buildScripts/BuildSLVPlatform";
    args = Platform;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result;
end

function compileDebug(Platform, Revision)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compileDebug(" .. Platform .. ", " .. Revision .. ")");
    end
    program = ShareRoot .. "buildScripts/BuildSLVPlatformDebugRev";
    args = Platform .. " Debug " .. Revision;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result;
end

function publishGame(targetIP, gameName)
    -- vm publish game step
    local result = 0;
    if targetIP == nil then
        abort(" --- publishGame() - targetIP is nil!");
    end
    if gameName == nil then
        abort(" --- publishGame() - gameName is nil!");
    end
    if DEBUG == true then
        print(" -- publishGame(" .. targetIP .. ", " .. gameName .. ")");
    end
    program = ShareRoot .. "buildScripts/publishToIP";
    args = targetIP .. " " .. gameName;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result;
end

-- Game build function

function buildPlatform(Target, Platform, Revision)
    -- construct vm command
    local result = 0;
    if Target == nil then
        print(" -- buildPlatform() - Target is nil!");
        abort(" --- Target must be debug, release, or show", 1);
    end
    if Platform == nil then
        print(" -- buildPlatform() - Platform is nil!");
        abort(" --- Platform cannot be nil", 1);
    end
    if Target == "debug" and Revision == nil then
        print(" -- buildPlatform() - Revision is nil!");
        abort(" --- debug build target requires a software revision number.");
    end
    if Revision ~= nil then
        print(" -- building " .. Platform .. ", " .. Target .. " at revision " .. Revision);
    else
        print(" -- building " .. Platform .. ", " .. Target);
    end

    -- Set up link to build scripts folder
    setScriptLink();

    -- Shut down in case it was left running
    stopVM();

    -- Start the VM
    result = startVM();

    if result ~= 0 then
        abort(" --- VM failed to start", result);
    end

    -- Give it time to fire up
    wait(45);

    if Target == "debug" then
        -- build debug
        result = compileDebug(Platform, Revision);
    elseif Target == "show" then
        -- build show
        result = compileShow(Platform);
    else
        -- build release
        result = compile(Platform);
    end

    if result ~= 0 then
        abort(" --- compile step failed", result);
    end

    result = stopVM();

    return result;
end

function usage()
    print("Usage: ./(lua )VSLVBuildPlatform.lua <release path> <game name> <gamecore> <sandbox> <(optional)VM name> <(optional) deployment address>\n");
    print(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    print(" -- <target>     the build target - debug, release, or show.");
    print(" -- <platform>   the platform name.");
    print(" -- <revision>   software revision - required for debug builds, ignored for others.");
end

-- execution
if evalCmdLine(arg, 2, 3) ~= nil then
    target = arg[1];
    platform = arg[2];
    if target == "debug" and arg[3] == nil then
        usage()
        abort(" -- debug builds require a revision number.", 1);
    end
    revision = arg[3];
    if DEBUG == true then
        print(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        print(" -- DEBUGCMD active");
    end
    result = buildPlatform(target, platform, revision);
    os.exit(result);
end
