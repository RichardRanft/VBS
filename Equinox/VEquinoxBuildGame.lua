#!/bin/lua 
 -- Language: Lua

DEBUG = true;
DEBUGCMD = false;
VMNAME = "/home/sgp1000/vmware/OpenSUSE_12_2_32bit/OpenSUSE_12_2_32bit.vmx";
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

function setScriptLink()
    local result = 0;
    if DEBUG == true then
        print(" -- setScriptLink()");
    end

    command = "sh /home/sgp1000/VBS/Equinox/scripts/setup";
    result = os.execute(command);
    if result ~= 0 then
        print(" --- Error: setScriptLink()");
    end

    return result;
end

function checkBuildParams(Version, Folder, Name, Project, Platform, Market, Build, Revision, VMName)
    if Version == nil then
        print(" -- buildGame() - Version is nil!");
        return 1;
    end
    if Folder == nil then
        print(" -- buildGame() - Folder is nil!");
        return 1;
    end
    if Name == nil then
        print(" -- buildGame() - Name is nil!");
        return 1;
    end
    if Project == nil then
        print(" -- buildGame() - Project is nil!");
        return 1;
    end
    if Platform == nil then
        print(" -- buildGame() - Platform is nil!");
        return 1;
    end
    if Market == nil then
        print(" -- buildGame() - Market is nil!");
        return 1;
    end
    if Build == nil then
        print(" -- buildGame() - Build is nil!");
        return 1;
    end
    if Revision == nil then
        print(" -- buildGame() - revision is nil, using 0");
        Revision = "0";
    end
    if VMName == nil or VMName == "" then
        print(" -- buildGame() - VMName is nil, using " .. VMNAME);
    else
        VMNAME = VMName;
    end
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

function compile(Version, Folder, Name, Project, Platform, Market, Build, Revision)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compile(" .. Version .. ", " .. Folder .. ", " .. Name .. ", " .. Project .. ", " .. Platform .. ", " .. Market .. ", " .. Build .. ", " .. Revision .. ")");
    end
    if Build == "release" then
        -- Build full release package, including documentation
        program = ShareRoot .. "buildScripts/BuildProduction";
        args = Version .. " " ..  Folder .. " " ..  Name .. " " ..  Project .. " " ..  Platform .. " " ..  Market;
        result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");
    elseif Build == "deploy" then
        -- Build release version, no package
        program = ShareRoot .. "buildScripts/buildgame";
        args = Platform .. " " .. GameCore .. " " .. Game;
        result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");
    elseif Build == "debug" then
        -- Build debug version
        program = ShareRoot .. "buildScripts/buildgame";
        args = Platform .. " " .. GameCore .. " " .. Game;
        result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");
    elseif Build == "show" then
        -- Build show version
        program = ShareRoot .. "buildScripts/buildgame";
        args = Platform .. " " .. GameCore .. " " .. Game;
        result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");
    else
        print(" --- Error: " .. Build .. " is not a valid configuration.  Must be release, deploy, debug, or show");
    end

    return result;
end

-- Game build function

function buildGame(Version, Folder, Name, Project, Platform, Market, Build, Revision, VMName)
    -- construct vm command
    local result = 0;

    checkBuildParams(Version, Folder, Name, Project, Platform, Market, Build, Revision, VMName);

    print(" -- building " .. Name .. ", " .. Revision .. " using VM " .. VMNAME);

    setScriptLink();

    stopVM();

    wait(10);

    result = startVM();

    wait(30);

    if result ~= 0 then
        abort(" --- VM failed to start", result);
    end

    result = compile(Version, Folder, Name, Project, Platform, Market, Build, Revision);

    if result ~= 0 then
        abort(" --- compile step failed", result);
    end

    result = stopVM();

    return result;
end

function usage()
    print("Usage: ./(lua )VEquinoxBuildGame.lua <release path> <game name> <gamecore> <platform> <(optional)VM name> <(optional) deployment address>\n");
    print(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    print(" -- <version>        the game version number - RFPNAM1A.");
    print(" -- <game folder>    the game folder - river_queen.");
    print(" -- <game name>      the game name - \"River Queen\".");
    print(" -- <project>        the project number - 14E000.");
    print(" -- <platform>       the target platform - W4NAS07S.");
    print(" -- <market>         the target market - NorthAmerica.");
    print(" -- <build>          the build type - Must be release, deploy, debug, or show.");
    print(" -- <revision>       the software revision number.  Defaults to 0.");
    print(" -- <VM name>        the target build environment.  Defaults to " .. VMNAME);
end

-- ./BuildProduction RFPNAM1A river_queen "River Queen" 14E000 W4NAS07L NorthAmerica

-- execution
if evalCmdLine(arg, 7, 9) ~= nil then
    version = arg[1];
    folder = arg[2];
    name = arg[3];
    project = arg[4];
    platform = arg[5];
    market = arg[6];
    build = arg[7];
    revision = arg[8];
    vmname = arg[9];
    if DEBUG == true then
        print(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        print(" -- DEBUGCMD active");
    end
    result = buildGame(version, folder, name, project, platform, market, build, vmname);
    os.exit(result);
end
