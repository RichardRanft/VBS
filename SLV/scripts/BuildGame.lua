#!/bin/lua 
 -- Language: Lua

-- debug output options
DEBUG = true;           -- generally only prints function entry with parameters.
DEBUGCMD = true;        -- prints actual strings sent to console commands.
DEBUGLOG = true;        -- true to send to log file, false to log to console.
DEBUGTIMESTAMP = true;  -- true to add timestamps before each log message.
LOGOUTPUT = {};

-- build defaults

ARGNAMES = {};
ARGNAMES[1] = "platform             "; -- platform version
ARGNAMES[2] = "target               "; -- debug, show, deploy or release
ARGNAMES[3] = "revision             "; -- revision number
ARGNAMES[4] = "version              "; -- game version
ARGNAMES[5] = "folder               "; -- source folder name
ARGNAMES[6] = "name                 "; -- game name
ARGNAMES[7] = "product number       "; -- product number
ARGNAMES[8] = "market               "; -- market
ARGNAMES[9] = "repository folder    "; -- location under /svn/EGMGameSoftware/SLV

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

function loadParamFile(filename)
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
    local logFile = io.open("/mnt/hgfs/buildOutput/" .. fileName, "r");
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

function setupVMScripts()
	logPrint(" -- setupVMScripts()");

    program = "sh " .. ShareRoot .. "buildScripts/setupVM";
    local command = program;
    result = executeCmd(command);

    return result, "setup VM scripts";
end

function compileGame(Platform, Target, Revision, Version, Folder, Name, ProdNum, Market, RepoFolder)
    -- vm compile step
    local result = 0;
    if DEBUG == true then
		local infostring = Platform .. ", " .. Target .. ", " .. Revision .. ", " .. Version .. ", " .. Folder;
		if ProdNum ~= nil then
			infostring = infostring .. ", " .. prodNum;
		end
		if Market ~= nil then
			infostring = infostring  .. ", " .. Market;
		end
		if RepoFolder ~= nil then
			infostring = infostring  .. ", " .. RepoFolder;
		end
        logPrint(" -- compileGame(" .. infostring .. ")");
    else
        logPrint(" -- compileGame()");
    end
	local program = "";
	local args = "";

	if string.find(Target, "()Release()") ~= nil or string.find(Target, "()release()") ~= nil then
		-- Full release build
		program = "sh " .. ShareRoot .. "buildScripts/BuildSLVProduction";
		args = Version .. " " .. Folder .. " " .. Name .. " " .. ProdNum .. " " .. Platform .. " " .. Market .. " " .. RepoFolder .. " " .. Revision;
	elseif string.find(Target, "()Deploy()") ~= nil or string.find(Target, "()deploy()") ~= nil then
		-- Release build, no document package
		program = "sh " .. ShareRoot .. "buildScripts/BuildSLVDeploy";
		args = Version .. " " .. Folder .. " " .. Platform .. " " .. Revision;
	elseif string.find(Target, "()Debug()") ~= nil or string.find(Target, "()debug()") ~= nil then
		-- Debug build
		program = "sh " .. ShareRoot .. "buildScripts/BuildSLVDebugRev";
		args = Version .. " " .. Revision .. " " .. Platform;
	else
		-- Show build
		program = "sh " .. ShareRoot .. "buildScripts/BuildSLVShow";
		args = Version .. " " .. Platform;
	end

    local command = program .. " " .. args;
    result = executeCmd(command);

    return result, "compileGame";
end

-- Game build function

function buildGame(Platform, Target, Revision, Version, Folder, Name, ProdNum, Market, RepoFolder)
    -- construct vm command
    local result = 0;
    local msg = "";
    if Platform == nil then
        logPrint(" -- buildGame() - Platform is nil!");
        return 1;
    end
    if Target == nil then
        logPrint(" -- buildGame() - Target is nil!");
        return 1;
    end
    if Version == nil then
        logPrint(" -- buildGame() - Version is nil!");
        return 1;
    end
    if Folder == nil then
        logPrint(" -- buildGame() - Folder is nil!");
        return 1;
    end
	if string.find(Target, "()Release()") ~= nil or string.find(Target, "()release()") ~= nil then
		if Name == nil then
			logPrint(" -- buildGame() - Name is nil!");
			return 1;
		end
		if ProdNum == nil then
			logPrint(" -- buildGame() - ProdNum is nil!");
			return 1;
		end
		if Market == nil then
			logPrint(" -- buildGame() - Market is nil!");
			return 1;
		end
		if RepoFolder == nil then
			logPrint(" -- buildGame() - RepoFolder is nil!");
			return 1;
		end
	end

    result, msg = setupVMScripts();
    checkResult(result, msg);
    if result ~= 0 then
        abort(" --- game build failed - unable to set up VM scripts.", result);
    end

    result, msg = compileGame(Platform, Target, Revision, Version, Folder, Name, ProdNum, Market, RepoFolder);
    checkResult(result, msg);
    result = checkLogFile(Name .. "_build.log");
    if result ~= 0 then
        abort(" --- game build failed!", result);
    end

    logPrint(" -- Build complete");

    return result;
end

function usage()
    logPrint("Usage: ./(lua )BuildGame.lua <platform> <target> <revision> <version> <folder> <game name> <product number> <market> <repository folder>\n");
    logPrint(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    logPrint(" -- <platform>          the platform to build against.");
    logPrint(" -- <target>            the build target (debug, show, deploy or release).");
    logPrint(" -- <revision>          the Subversion revision number.");
    logPrint(" -- <version>           the game version.");
    logPrint(" -- <folder>            the game source folder name.");
	logPrint(" -- <game name>         the game name.");
    logPrint(" -- <product number>    the game product number.");
    logPrint(" -- <market> the target the target market - NorthAmerica, LatinAmerica, and NewYork are currently supported.");
    logPrint(" -- <repository folder> the repository folder containing the game source.");
end

-------------------------------------------------------------------------------
-- execution

if DEBUGLOG == true then
    logFile = io.open("/mnt/hgfs/buildOutput/buildGame.log", "w+");
end

-- read our build parameters
inArgs = loadParamFile();

-- parse and execute
if evalCmdLine(inArgs, 5, 9) ~= nil then
    platform = inArgs[1];
    target = inArgs[2];
    revision = inArgs[3];
    version = inArgs[4];
    folder = inArgs[5];
	name = inArgs[6];
    prodNum = inArgs[7];
    market = inArgs[8];
    repoFolder = inArgs[9];

    if DEBUG == true then
        logPrint(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        logPrint(" -- DEBUGCMD active");
    end

    result = buildGame(platform, target, revision, version, folder, name, prodNum, market, repoFolder);

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
