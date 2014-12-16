#!/bin/lua 
 -- Language: Lua

-- debug output options
DEBUG = true;           -- generally only prints function entry with parameters.
DEBUGCMD = true;        -- prints actual strings sent to console commands.
DEBUGLOG = true;        -- true to send to log file, false to log to console.
DEBUGTIMESTAMP = true;  -- true to add timestamps before each log message.
LOGOUTPUT = {};

-- build defaults
ShareRoot = "/mnt/hgfs/";
ReleaseRoot = "/mnt/RELEASE/";

-- build parameters
paramFile = "/mnt/hgfs/buildScripts/sandboxParams.ini";
-- primary log file - updated during run
logFileName = "/mnt/hgfs/buildOutput/configSystem.log";
-- same output as the primary log, but dumped at end of run
logDumpFile = "/mnt/hgfs/buildOutput/BootSetupSandbox.log"
-- path to shell script logs
logPath = "/gamedev/";

ARGNAMES = {};
ARGNAMES[1] = "sandbox           ";
ARGNAMES[2] = "operating system  ";
ARGNAMES[3] = "media services    ";
ARGNAMES[4] = "build tool        ";
ARGNAMES[5] = "license manager   ";

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
    local buildParams = io.open(paramFile, "r");
    if buildParams == nil then
        abort(" --- Error: unable to open sandboxParams.ini file!");
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

    --local command = "rm -f /mnt/hgfs/buildScripts/sandboxParams.ini";
    --executeCmd(command);

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
    local logdump =  io.open(logDumpFile, "w+");
    for i = 1, tablelength(LOGOUTPUT) do
        logdump:write(LOGOUTPUT[i]);
    end
    logdump:flush();
    logdump:close();
end

function checkLogFile(fileName)
    local logFile = io.open(logPath .. fileName, "r");
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
        --clean(SANDBOX, GAME);
        abort(" --- " .. message .. " step failed", result);
    end
end

function abort(reason, code)
    logPrint(reason);
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

function parseModulePath(moduleName)
    local wordList = {};
    local wordCount = 0;
    for w in string.gmatch(moduleName, "%P+") do
        wordCount = wordCount + 1;
        wordList[wordCount] = w;
    end

    return wordList, wordCount;
end

function getModuleName(modulePathTable, LM)
    local name = "";
    if LM == true then
        -- make MODULE_NAME-X.XX.XX
        name = string.upper(modulePathTable[1]) .. "_" .. string.upper(modulePathTable[2]);
        name = name .. "-" .. modulePathTable[3] .. "." .. modulePathTable[4] .. "." .. modulePathTable[5];
    else
        -- make MODULENAME-X.XX.XX
        name = string.upper(modulePathTable[1]);
        name = name .. "-" .. modulePathTable[2] .. "." .. modulePathTable[3] .. "." .. modulePathTable[4];
    end
    return name;
end

-- build scripts

function installSB(Sandbox)
    local result = 0;
    if DEBUG == true then
        logPrint(" -- installSB(" .. Sandbox .. ")");
    else
        logPrint(" -- installSB()");
    end
    
    program = "sh " .. ShareRoot .. "buildScripts/installSB";
    local sbInfo = parseModulePath(Sandbox);
    name = getModuleName(sbInfo);
    args = name .. " " .. sbInfo[5];
    local command = program .. " " .. args;
    if DEBUGCMD == true then
        logPrint(" -- " .. command);
    end
    result = executeCmd(command);

    return result, "install sandbox";
end

function installOS(OperatingSys, Sandbox)
    local result = 0;
    if DEBUG == true then
        logPrint(" -- installOS(" .. OperatingSys .. ", " .. Sandbox .. ")");
    else
        logPrint(" -- installOS()");
    end
    
    program = "sh " .. ShareRoot .. "buildScripts/installOS";
    local osInfo = parseModulePath(OperatingSys);
    name = getModuleName(osInfo);
    args = name .. " " .. osInfo[5] .. " " .. Sandbox;
    local command = program .. " " .. args;
    if DEBUGCMD == true then
        logPrint(" -- " .. command);
    end
    result = executeCmd(command);

    return result, "install operating system";
end

function installMS(MediaService, Sandbox)
    local result = 0;
    if DEBUG == true then
        logPrint(" -- installMS(" .. MediaService .. ", " .. Sandbox .. ")");
    else
        logPrint(" -- installMS()");
    end
    
    program = "sh " .. ShareRoot .. "buildScripts/installMS";
    local msInfo = parseModulePath(MediaService);
    name = getModuleName(msInfo);
    args = name .. " " .. msInfo[5] .. " " .. Sandbox;
    local command = program .. " " .. args;
    if DEBUGCMD == true then
        logPrint(" -- " .. command);
    end
    result = executeCmd(command);

    return result, "install media services";
end

function installBT(BuildTool, Sandbox)
    local result = 0;
    if DEBUG == true then
        logPrint(" -- installBT(" .. BuildTool .. ", " .. Sandbox .. ")");
    else
        logPrint(" -- installBT()");
    end
    
    program = "sh " .. ShareRoot .. "buildScripts/installBT";
    local btInfo = parseModulePath(BuildTool);
    name = getModuleName(btInfo);
    args = name .. " " .. btInfo[5] .. " " .. Sandbox;
    local command = program .. " " .. args;
    if DEBUGCMD == true then
        logPrint(" -- " .. command);
    end
    result = executeCmd(command);

    return result, "install build tool";
end

function installLM(LicenseMan, Sandbox)
    local result = 0;
    if DEBUG == true then
        logPrint(" -- installLM(" .. LicenseMan .. ", " .. Sandbox .. ")");
    else
        logPrint(" -- installLM()");
    end
    
    program = "sh " .. ShareRoot .. "buildScripts/installLM";
    local lmInfo = parseModulePath(LicenseMan);
    name = getModuleName(lmInfo, true);
    args = name .. " " .. lmInfo[5] .. " " .. Sandbox;
    local command = program .. " " .. args;
    if DEBUGCMD == true then
        logPrint(" -- " .. command);
    end
    result = executeCmd(command);

    return result, "install license manager";
end

-- sandbox build function

function buildSandbox(SandBox, OperatingSys, MediaServices, BuildTool, LicenseMan)
    -- construct vm command
    local result = 0;
    local msg = "";
    if SandBox == nil then
        logPrint(" -- buildSandbox() - SandBox is nil!");
        return 1;
    end
    if OperatingSys == nil then
        logPrint(" -- buildSandbox() - OperatingSys is nil!");
        return 1;
    end
    if MediaServices == nil then
        logPrint(" -- buildSandbox() - MediaServices is nil!");
        return 1;
    end
    if BuildTool == nil then
        logPrint(" -- buildSandbox() - BuildTool is nil!");
        return 1;
    end
    if LicenseMan == nil then
        logPrint(" -- buildSandbox() - LicenseMan is nil!");
        return 1;
    end
    logPrint(" -- installing " .. SandBox);
    logPrint(" --- OS : " .. OperatingSys);
    logPrint(" --- MS : " .. MediaServices);
    logPrint(" --- BT : " .. BuildTool);
    logPrint(" --- LM : " .. LicenseMan);

    result, msg = installSB(SandBox);
    checkResult(result, msg);
    result = checkLogFile(SandBox .. "_sandbox.log");
    if result ~= 0 then
        abort(" --- sandbox install failed!", result);
    end

    result, msg = installOS(OperatingSys, SandBox);
    checkResult(result, msg);
    result = checkLogFile(SandBox .. "_os.log");
    if result ~= 0 then
        abort(" --- operating system install failed!", result);
    end

    result, msg = installMS(MediaServices, SandBox);
    checkResult(result, msg);
    result = checkLogFile(SandBox .. "_ms.log");
    if result ~= 0 then
        abort(" --- media services install failed!", result);
    end

    result, msg = installBT(BuildTool, SandBox);
    checkResult(result, msg);
    result = checkLogFile(SandBox .. "_bt.log");
    if result ~= 0 then
        abort(" --- build tool install failed!", result);
    end

    result, msg = installLM(LicenseMan, SandBox);
    checkResult(result, msg);
    result = checkLogFile(SandBox .. "_lm.log");
    if result ~= 0 then
        abort(" --- license manager install failed!", result);
    end

    logPrint(" -- Sandbox complete");

    return result;
end

function usage()
    logPrint("Usage: ./(lua )BootSetupSandbox.lua <sandbox> <operating system> <media services> <build tool> <license manager>\n");
    logPrint(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    logPrint(" -- <sandbox>             Sandbox version");
    logPrint(" -- <operating system>    Operating system version");
    logPrint(" -- <media services>      Media services version");
    logPrint(" -- <build tool>          Build tool version");
    logPrint(" -- <license manager>     License manager version");
end

-------------------------------------------------------------------------------
-- execution

if DEBUGLOG == true then
    logFile = io.open(logFileName, "w+");
end

-- read our build parameters
inArgs = loadParamFile();

-- parse and execute
if evalCmdLine(inArgs, 5, 5) ~= nil then
    SB = inArgs[1];
    OS = inArgs[2];
    MS = inArgs[3];
    BT = inArgs[4];
    LM = inArgs[5];

    if DEBUG == true then
        logPrint(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        logPrint(" -- DEBUGCMD active");
    end

    result = buildSandbox(SB, OS, MS, BT, LM);

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
