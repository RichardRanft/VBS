#!/bin/lua 
 -- Language: Lua

DEBUG = true;
DEBUGCMD = false;
VMNAME = "/home/sgp1000/vmware/AlphaBuildEnv/SB_5.00.00.002.vmx";
VMSTARTED = false;
ShareRoot = "/mnt/hgfs/"
SANDBOX = ""
GAME = ""

-- Utilities

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

function cleanLocal()
    -- remake /home/sgp1000/buildSource
    local result = 0;
    if DEBUG == true then
        print(" -- cleanLocal()");
    end
    command = "sudo rm -rf /home/sgp1000/buildSource";
    result = os.execute(command);
    if result == 0 then
        print(" --- Error: cleanLocal() unable to remove /home/sgp1000/buildSource");
    end
    command = "mkdir /home/sgp1000/buildSource";
    os.execute(command);
    if result == 0 then
        print(" --- Error: cleanLocal() unable to create /home/sgp1000/buildSource");
    end

    return result;
end

function setScriptLink()
    local result = 0;
    if DEBUG == true then
        print(" -- setScriptLink()");
    end

    command = "sh /home/sgp1000/VBS/Alpha/scripts/setup";
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
    command = "vmrun -T ws -gu root -gp ballytech runScriptInGuest " .. VMNAME .. " " .. interpreter .. " " .. scriptText;
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
    command = "vmrun -T ws -gu root -gp ballytech runProgramInGuest " .. VMNAME .. " " .. program .. " " .. args;
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
        print(" --- error executing runProgramInVM() - " .. exitCode .. " : " .. exitSignal);
    end
    return result;
end

function createFolderInVM(path)
    local result = 0;
    command = "vmrun -T ws -gu root -gp ballytech createDirectoryInGuest " .. VMNAME .. " " .. path;
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
    command = "vmrun -T ws -gu root -gp ballytech deleteDirectoryInGuest " .. VMNAME .. " " .. path;
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
    command = "vmrun -T ws -gu root -gp ballytech addSharedFolder " .. VMNAME .. " " .. pathOnGuest .. " " .. pathOnHost;
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
    command = "vmrun -T ws -gu root -gp ballytech removeSharedFolder " .. VMNAME .. " " .. pathOnGuest;
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
    command = "vmrun -T ws -gu root -gp ballytech copyFileFromHostToGuest " .. VMNAME .. " " .. pathOnHost .. " " .. pathOnGuest;
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
    command = "vmrun -T ws -gu root -gp ballytech copyFileFromGuestToHost " .. VMNAME .. " " .. pathOnGuest .. " " .. pathOnHost;
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
    command = "vmrun -T ws -gu root -gp ballytech listDirectoryInGuest " .. VMNAME .. " " .. pathOnGuest;
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

function dumbwait()
    program = ShareRoot .. "buildScripts/dumbwait";
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. "\"");
end

function setupVMScripts(Sandbox, GameCore, Game, RepoPath)
    -- vm compile step
    local result = 0;
    local refresh = false;
    if NoRefresh ~= nil then
        refresh = NoRefresh;
    end
    if DEBUG == true then
        print(" -- setupVMScripts(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        print(" -- setupVMScripts()");
    end
    program = ShareRoot .. "buildScripts/setupVM";
    if refresh then
        args = Sandbox .. " " .. GameCore .. " " .. Game .. " 1";
    else
        args = Sandbox .. " " .. GameCore .. " " .. Game;
    end
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "setup VM scripts";
end

function exportGameCore(Sandbox, GameCore, Game, NoRefresh)
    -- vm compile step
    local result = 0;
    local refresh = false;
    if NoRefresh ~= nil then
        refresh = NoRefresh;
    end
    if DEBUG == true then
        print(" -- exportGameCore(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        print(" -- exportGameCore()");
    end
    program = ShareRoot .. "buildScripts/exportGameCore";
    if refresh then
        args = Sandbox .. " " .. GameCore .. " " .. Game .. " 1";
    else
        args = Sandbox .. " " .. GameCore .. " " .. Game;
    end
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "export game core";
end

function exportGame(Sandbox, Game, Repository, NoRefresh)
    -- vm compile step
    local result = 0;
    local refresh = false;
    if NoRefresh ~= nil then
        refresh = NoRefresh;
    end
    if refresh == nil then
        refresh = false;
    end
    if DEBUG == true then
        print(" -- exportGame(" .. Sandbox .. ", " .. Game .. ", " .. Repository .. ", " .. tostring(refresh) .. ")");
    else
        print(" -- exportGame()");
    end
    program = ShareRoot .. "buildScripts/exportGame";
    if refresh then
        args = Sandbox .. " " .. Game .. " " .. Repository .. " 1";
    else
        args = Sandbox .. " " .. Game .. " " .. Repository;
    end
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "export game";
end

function copyGame(Sandbox, Game, NoRefresh)
    -- vm compile step
    local result = 0;
    local refresh = false;
    if NoRefresh ~= nil then
        refresh = NoRefresh;
    end
    if refresh == nil then
        refresh = false;
    end
    if DEBUG == true then
        print(" -- copyGame(" .. Sandbox .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        print(" -- copyGame()");
    end
    program = ShareRoot .. "buildScripts/copyGame";
    if refresh then
        args = Sandbox .. " " .. Game .. " 1";
    else
        args = Sandbox .. " " .. Game;
    end
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "copy game";
end

function copyGameCore(GameCore, Game, NoRefresh)
    -- vm compile step
    local result = 0;
    local refresh = false;
    if NoRefresh ~= nil then
        refresh = NoRefresh;
    end
    if refresh == nil then
        refresh = false;
    end
    if DEBUG == true then
        print(" -- copyGameCore(" .. GameCore .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        print(" -- copyGameCore()");
    end
    program = ShareRoot .. "buildScripts/copyGameCore";
    if refresh then
        args = GameCore .. " " .. Game .. " 1";
    else
        args = GameCore .. " " .. Game;
    end
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "copy game core";
end

function compile(Sandbox, GameCore, Game, RepoPath)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compile(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ", " .. RepoPath .. ")");
    else
        print(" -- compile()");
    end
    program = ShareRoot .. "buildScripts/buildgame";
    args = Sandbox .. " " .. GameCore .. " " .. Game .. " " .. RepoPath;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "compile";
end

function compileGraphics(Sandbox, GameCore, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compileGraphics(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ")");
    else
        print(" -- compileGraphics()");
    end
    program = ShareRoot .. "buildScripts/buildGraphics";
    args = Sandbox .. " " .. GameCore .. " " .. Game;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "compile graphics";
end

function compileInstall(Sandbox, GameCore, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compileInstall(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ")");
    else
        print(" -- compileInstall()");
    end
    program = ShareRoot .. "buildScripts/buildInstall";
    args = Sandbox .. " " .. GameCore .. " " .. Game;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "compile install";
end

function compileAllGames(Sandbox, GameCore, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- compileAllGames(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ")");
    else
        print(" -- compileAllGames()");
    end
    program = ShareRoot .. "buildScripts/buildAllGames";
    args = Sandbox .. " " .. GameCore .. " " .. Game;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "compile game";
end

function publishGame(Sandbox, targetIP, gameName)
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
    else
        print(" -- publishGame()");
    end
    program = ShareRoot .. "buildScripts/publish";
    args = targetIP .. " " .. gameName .. " " .. Sandbox;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result, "publish game";
end

function clean(Sandbox, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        print(" -- clean(" .. Sandbox .. ", " .. Game .. ")");
    else
        print(" -- clean()");
    end
    program = ShareRoot .. "buildScripts/clean";
    args = Game .. " " .. Sandbox;
    result = runScriptInVM("\"/bin/sh\"", "\"" .. program .. " " .. args .. "\"");

    return result;
end

function checkResult(result, message)
    if result ~= 0 then
        if message == nil then
            message = "unknown";
        end
        -- clean up and copy logs
        clean(SANDBOX, GAME);
        abort(" --- " .. message .. " step failed", result);
    end
end

-- Game build function

function buildGame(Path, Name, GameCore, Sandbox, VMName, Target)
    -- construct vm command
    local result = 0;
    local msg = "";
    if Path == nil then
        print(" -- buildGame() - Path is nil!");
        return 1;
    end
    if Name == nil then
        print(" -- buildGame() - Name is nil!");
        return 1;
    end
    if GameCore == nil then
        print(" -- buildGame() - GameCore is nil!");
        return 1;
    end
    if Sandbox == nil then
        print(" -- buildGame() - Sandbox is nil!");
        return 1;
    end
    if VMName == nil or VMName == "" then
        print(" -- buildGame() - VMName is nil, using " .. VMNAME);
    else
        VMNAME = VMName;
    end
    if Target == nil or Target == "" then
        print(" -- buildGame() - Target is nil, will not deploy game");
    end
    print(" -- building " .. Name .. " in " .. Sandbox .. " using VM " .. VMNAME);

    SANDBOX = Sandbox;
    GAME = Name;

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

    -- set up guest side scripts and logs
    result, msg = setupVMScripts(Sandbox, GameCore, Name, Path);
    checkResult(result, msg);

    -- copy game core
    result, msg = copyGameCore(GameCore, Name, "1");
    checkResult(result, msg);

    -- copy game
    result, msg = copyGame(Sandbox, Name);
    checkResult(result, msg);

    -- Compile the game
    result, msg = compileInstall(Sandbox, GameCore, Name);
    checkResult(result, msg);

    result, msg = compileGraphics(Sandbox, GameCore, Name);
    checkResult(result, msg);

    result, msg = compileAllGames(Sandbox, GameCore, Name);
    checkResult(result, msg);

    -- publish to EGM
    if Target ~= nil then
        result, msg = publishGame(Sandbox, Target, gameName);
        checkResult(result, msg);
    end

    clean(Sandbox, Name);

    -- Shut down
    result = stopVM();

    return result;
end

function usage()
    print("Usage: ./(lua )VAlphaBuildGame.lua <release path> <game name> <gamecore> <sandbox> <(optional)VM name> <(optional) deployment address>\n");
    print(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    print(" -- <release path>       the path to the source code to build.");
    print(" -- <game name>          the game name.");
    print(" -- <gamecore>           the gamecore CVS tag (core label).");
    print(" -- <sandbox>            the target sandbox environment.");
    print(" -- <VM name>            the target build environment.  Defaults to " .. VMNAME);
    print(" -- <deployment address> the target IP address to deploy the game to.");
end

-- execution
if evalCmdLine(arg, 4, 6) ~= nil then
    path = arg[1];
    name = arg[2];
    gamecore = arg[3];
    sandbox = arg[4];
    vmname = arg[5];
    target = arg[6];
    if DEBUG == true then
        print(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        print(" -- DEBUGCMD active");
    end
    result = buildGame(path, name, gamecore, sandbox, vmname, target);
    os.exit(result);
end
