#!/bin/lua 
 -- Language: Lua

-- debug output options
DEBUG = true;           -- generally only prints function entry with parameters.
DEBUGCMD = true;        -- prints actual strings sent to console commands.
DEBUGLOG = true;        -- true to send to log file, false to log to console.
DEBUGTIMESTAMP = true;  -- true to add timestamps before each log message.
LOGOUTPUT = {};

-- build defaults
VMPATH = "/home/sgp1000/vmware/AlphaBuildEnv/";
VMNAME = "SB_5.00.00.002.vmx";
ShareRoot = "/mnt/hgfs/"
SANDBOX = ""
GAME = ""

ARGNAMES = {};
ARGNAMES[1] = "reserved             ";
ARGNAMES[2] = "game name            ";
ARGNAMES[3] = "game core            ";
ARGNAMES[4] = "sandbox              ";
ARGNAMES[5] = "VM name              ";
ARGNAMES[6] = "deployment address   ";

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
        logPrint("Too few arguments");
        for i = 1, tablelength(arg), 1 do
            logPrint(cmdArg[i]);
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
            logPrint("Too many arguments");
            for i = 1, tablelength(listArgs), 1 do
                logPrint(listArgs[i]);
            end
            usage();
            return;
        end
    end
    return 0;
end

function loadParamFile()
    local buildParams = io.open("/mnt/hgfs/buildScripts/buildParams.ini", "r");
    if buildParams == nil then
        abort(" --- Error: unable to open buildParams.ini file!");
    end
    local params = {};
    local i = 1;
    for line in buildParams:lines() do
        if line ~= nil then
            params[i] = line;
            logPrint(" -- parsed " .. ARGNAMES[i] .. params[i]);
            i = i + 1;
        end
    end

    local command = "rm -f /mnt/hgfs/buildScripts/buildParams.ini";
    executeCmd(command);

    return params;
end

function logPrint(message)
    if message == nil then
        message = " --- nil message";
    end
    if DEBUGLOG == true then
        if DEBUGTIMESTAMP == true then
            LOGOUTPUT[tablelength(LOGOUTPUT) + 1] = " --- " .. os.date() .. " " .. message .. "\n";
            if logFile ~= nil then
                logFile:write(LOGOUTPUT[tablelength(LOGOUTPUT)]);
            end
        else
            LOGOUTPUT[tablelength(LOGOUTPUT) + 1] = " --- " .. message .. "\n";
            if logFile ~= nil then
                logFile:write(LOGOUTPUT[tablelength(LOGOUTPUT)]);
            end
        end
    else
        if DEBUGTIMESTAMP == true then
            print(" --- " .. os.date() .. " ");
        end
        print(message);
    end
end

function dumpLog()
    local logdump =  io.open("/mnt/hgfs/buildOutput/BootBuildGame.log", "w+");
    for i = 1, tablelength(LOGOUTPUT) do
        logdump:write(LOGOUTPUT[i]);
    end
    logdump:flush();
    logdump:close();
end

function checkLogFile(fileName)
    local logFile = io.open("/gamedev/" .. fileName, "r");
    local result = 0;
    if logFile == nil then
        abort(" --- Error: unable to open log " .. fileName, 1);
    end
    for line in logFile:lines() do
        if line ~= nil then
            -- Ok, look for "error" except when it says "0 errors" for shit's sake....
            if string.find(line, "()0 errors()") == nil and string.find(line, "()Error()") ~= nil then
                result = 2;
            end
        end
    end

    return result;
end

function dumpOutput(fileHandle, message)
    -- dump command output to console
    if message ~= nil then
        logPrint(" -- " .. message);
    end
    local result = 0;
    local errorFound = false;
    for line in fileHandle:lines() do
        if line ~= nil then
            if string.find(line, "()Error()") ~= nil or string.find(line, "()failed()") ~= nil then
                errorFound = true;
                result = 2;
            end
            if string.find(line, "()%c()") == nil then
                logPrint(" --- " .. line);
            end
        end
    end
    return result;
end

function checkError(fileHandle)
    -- dump error output to console
    local result = 0;
    local errorFound = false;
    for line in fileHandle:lines() do
        if line ~= nil then
            if string.find(line, "()Error()") ~= nil or string.find(line, "()failed()") ~= nil then
                errorFound = true;
                result = 2;
                break;
            end
        end
    end
    if errorFound == true then
        logPrint(" --- " .. line);
        abort(" --- " .. line, result);
    end
    return result;
end

function checkResult(result, message)
    if result ~= true and result ~= 0 then
        if message == nil then
            message = " -- unknown message: nil";
        end
        -- clean up and copy logs
        clean(SANDBOX, GAME);
        abort(" --- " .. message .. " step failed", result);
    end
end

function abort(reason, code)
    logPrint(reason);
    -- bailing early, better clean house a little...
    clean(SANDBOX, GAME);
    if DEBUGLOG == true and logFile ~= nil then
        logFile:flush();
        logFile:close();
    end

    os.exit(false, true);
end

function executeCmd(command)
    if DEBUGCMD == true then
        logPrint(command);
    end
    local handle = io.popen(command);
    local result = 0;
    if handle ~= nil then
        if DEBUGCMD == true then
            result = dumpOutput(handle, command);
        else
            result = checkError(handle);
        end
    end
    return result;
end

function getFileList(path)
    if path == nil then
        path = "./"
    end
    if DEBUG == true then
        logPrint(" -- getFileList(" .. path .. ")");
    end
    local command = "ls " .. path .. "*.srm.img";
    if DEBUGCMD == true then
        logPrint(command);
    end
    local handle = io.popen(command);
    local result = 0;
    local fileList = {};
    local i = 1;
    if handle ~= nil then
        for line in handle:lines() do
            if line ~= nil then
                if DEBUG == true then
                    logPrint(" -- " .. line);
                end
                fileList[i] = line;
                i = i + 1;
            end
        end
    end
    return fileList;
end

function wait(seconds)
    if seconds == nil then
        logPrint(" -- wait() - seconds is nil");
        return 29;
    end
    if DEBUG == true then
        logPrint(" -- wait() : " .. seconds);
    end
    os.execute("sleep " .. tonumber(seconds));
    return 0;
end

-- build scripts

function setupVMScripts(Sandbox, GameCore, Game, RepoPath, Clean)
    -- vm compile step
    local result = 0;
    local refresh = false;
    if NoRefresh ~= nil then
        refresh = NoRefresh;
    end
    if DEBUG == true then
        logPrint(" -- setupVMScripts(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        logPrint(" -- setupVMScripts()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/setupVM";
    if refresh then
        args = Sandbox .. " " .. GameCore .. " " .. Game .. " 1";
    else
        args = Sandbox .. " " .. GameCore .. " " .. Game;
    end
    if Clean == true then
        args = args .. " 1";
    end
    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "setup VM scripts";
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
        logPrint(" -- copyGame(" .. Sandbox .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        logPrint(" -- copyGame()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/copyGame";
    if refresh then
        args = Sandbox .. " " .. Game .. " 1";
    else
        args = Sandbox .. " " .. Game;
    end
    local command = program .. " " .. args;
    result = executeCmd(command);

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
        logPrint(" -- copyGameCore(" .. GameCore .. ", " .. Game .. ", " .. tostring(refresh) .. ")");
    else
        logPrint(" -- copyGameCore()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/copyGameCore";
    if refresh then
        args = GameCore .. " " .. Game .. " 1";
    else
        args = GameCore .. " " .. Game;
    end
    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "copy game core";
end

function compileGraphics(Sandbox, GameCore, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        logPrint(" -- compileGraphics(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ")");
    else
        logPrint(" -- compileGraphics()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/buildGraphics";
    args = Sandbox .. " " .. GameCore .. " " .. Game;
    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "compile graphics";
end

function compileInstall(Sandbox, GameCore, Game, Path)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        logPrint(" -- compileInstall(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ", " .. Path .. ")");
    else
        logPrint(" -- compileInstall()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/buildInstall";
    args = Sandbox .. " " .. GameCore .. " " .. Game .. " " .. Path;
    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "compile install";
end

function compileAllGames(Sandbox, GameCore, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        logPrint(" -- compileAllGames(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ")");
    else
        logPrint(" -- compileAllGames()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/buildAllGames";
    args = Sandbox .. " " .. GameCore .. " " .. Game;
    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "compile all games";
end

function compileAllSRMS(Sandbox, GameCore, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        logPrint(" -- compileAllSRMS(" .. Sandbox .. ", " .. GameCore .. ", " .. Game .. ")");
    else
        logPrint(" -- compileAllSRMS()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/buildAllSRMS";
    args = Sandbox .. " " .. GameCore .. " " .. Game;
    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "compile compile all srms";
end

function clean(Sandbox, Game)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
        logPrint(" -- clean(" .. Sandbox .. ", " .. Game .. ")");
    else
        logPrint(" -- clean()");
    end
    program = "sh " .. ShareRoot .. "buildScripts/clean";
    args = Game .. " " .. Sandbox;
    local command = program .. " " .. args;

    result = executeCmd(command);

    return result;
end

-- Game build function

function buildGame(Path, Name, GameCore, Sandbox, VMName, VMPath, Target)
    -- construct vm command
    local result = 0;
    local msg = "";
    if Path == nil then
        logPrint(" -- buildGame() - Path is nil!");
        return 1;
    end
    if Name == nil then
        logPrint(" -- buildGame() - Name is nil!");
        return 1;
    end
    if GameCore == nil then
        logPrint(" -- buildGame() - GameCore is nil!");
        return 1;
    end
    if Sandbox == nil then
        logPrint(" -- buildGame() - Sandbox is nil!");
        return 1;
    end
    if VMPath == nil or VMPath == "" then
        logPrint(" -- buildGame() - VMPath is nil, using " .. VMPATH);
    else
        VMPATH = VMPath;
    end
    if VMName == nil or VMName == "" then
        logPrint(" -- buildGame() - VMName is nil, using " .. VMNAME);
    else
        VMNAME = VMPATH .. VMName;
        logPrint(" -- buildGame() - Using virtual machine " .. VMNAME);
    end
    if Target == nil or Target == "" then
        logPrint(" -- buildGame() - Target is nil, will not deploy game");
    else
        logPrint(" -- buildGame() - Deploy to ".. Target);
    end
    logPrint(" -- building " .. Name .. " in " .. Sandbox .. " using VM " .. VMNAME);

    SANDBOX = Sandbox;
    GAME = Name;

    -- set up guest side scripts and logs
    result, msg = setupVMScripts(Sandbox, GameCore, Name, Path, true);
    checkResult(result, msg);

    -- copy game core
    result, msg = copyGameCore(GameCore, Name, "1");
    checkResult(result, msg);

    -- copy game
    result, msg = copyGame(Sandbox, Name);
    checkResult(result, msg);

    -- Compile the game
    result, msg = compileInstall(Sandbox, GameCore, Name, Path);
    checkResult(result, msg);
    result = checkLogFile(Name .. "_install.log");
    if result ~= 0 then
        abort(" --- install build failed!", result);
    end

    result, msg = compileGraphics(Sandbox, GameCore, Name);
    checkResult(result, msg);
    result = checkLogFile(Name .. "_graphics.log");
    if result ~= 0 then
        abort(" --- graphics build failed!", result);
    end

    result, msg = compileAllGames(Sandbox, GameCore, Name);
    checkResult(result, msg);
    result = checkLogFile(Name .. "_allgames.log");
    if result ~= 0 then
        abort(" --- game build failed!", result);
    end

    result, msg = compileAllSRMS(Sandbox, GameCore, Name);
    checkResult(result, msg);
    result = checkLogFile(Name .. "_allsrms.log");
    if result ~= 0 then
        abort(" --- image build failed!", result);
    end

    clean(Sandbox, Name);

    logPrint(" -- Build complete");

    return result;
end

function usage()
    logPrint("Usage: ./(lua )BootBuildGame.lua <release path> <game name> <gamecore> <sandbox> <(optional)VM name> <(optional)VM path> <(optional) deployment address>\n");
    logPrint(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    logPrint(" -- <friendly name>      the name of the folder under Menu to run updateTranslationFiles.sh, or a hyphen (-) to skip.");
    logPrint(" -- <game name>          the game name.");
    logPrint(" -- <gamecore>           the gamecore CVS tag (core label).");
    logPrint(" -- <sandbox>            the target sandbox environment.");
    logPrint(" -- <VM name>            the target build environment.  Defaults to " .. VMNAME);
    logPrint(" -- <VM path>            path to the target build environment.  Defaults to " .. VMPATH);
    logPrint(" -- <deployment address> the target IP address to deploy the game to.");
end

-------------------------------------------------------------------------------
-- execution

if DEBUGLOG == true then
    logFile = io.open("/mnt/hgfs/buildOutput/buildSystem.log", "w+");
end

-- read our build parameters
inArgs = loadParamFile();

-- parse and execute
if evalCmdLine(inArgs, 4, 6) ~= nil then
    path = inArgs[1];
    name = inArgs[2];
    gamecore = inArgs[3];
    sandbox = inArgs[4];
    vmname = inArgs[5];
    vmpath = inArgs[6];
    target = inArgs[7];

    if DEBUG == true then
        logPrint(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        logPrint(" -- DEBUGCMD active");
    end

    result = buildGame(path, name, gamecore, sandbox, vmname, vmpath, target);

    -- if we're logging to file, flush and close
    if DEBUGLOG == true then
        dumpLog();
    end
    if logFile ~= nil then
        logFile:flush();
        logFile:close();
    end

    os.exit(result);
end
