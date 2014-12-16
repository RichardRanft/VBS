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
ARGNAMES[1] = "type                 "; -- game or platform

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
	-- Read buildParams.ini file and use the data to configure the build
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

-- build scripts

function compile(Type)
    local result = 0;
    local refresh = false;
    if DEBUG == true then
        logPrint(" -- compile(" .. Type .. ")");
    else
        logPrint(" -- compile()");
    end
	if Type == "game" then
		program = "lua " .. ShareRoot .. "buildScripts/buildGame.lua";
	else
		program = "lua " .. ShareRoot .. "buildScripts/buildPlatform.lua";
	end
    local command = program;
    result = executeCmd(command);

    return result, "compile";
end

-- Game build function

function build(Type)
    -- construct vm command
    local result = 0;
    local msg = "";
    if Type == nil then
        logPrint(" -- build() - Type is nil!");
        return 1;
    end

    -- Compile
    result, msg = compile(Type);
    checkResult(result, msg);
    result = checkLogFile(Name .. ".build.txt");
    if result ~= 0 then
        abort(" --- build failed!", result);
    end

    logPrint(" -- Build complete");

    return result;
end

function usage()
    logPrint("Usage: ./(lua )BootBuildGame.lua <type>\n");
    logPrint(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    logPrint(" -- <type>      the build type - platform or game");
end

-------------------------------------------------------------------------------
-- execution

if DEBUGLOG == true then
    logFile = io.open("/mnt/hgfs/buildOutput/buildSystem.log", "w+");
end

-- read our build parameters
inArgs = loadParamFile();

-- parse and execute
if evalCmdLine(inArgs, 1, 1) ~= nil then
    buildtype = inArgs[1];

    if DEBUG == true then
        logPrint(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        logPrint(" -- DEBUGCMD active");
    end

    result = build(buildtype);

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
