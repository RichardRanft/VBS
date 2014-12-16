#!/bin/lua 
 -- Language: Lua

-- debug output options
DEBUG = true;           -- generally only prints function entry with parameters.
DEBUGCMD = true;        -- prints actual strings sent to console commands.
DEBUGLOG = true;        -- true to send to log file, false to log to console.
DEBUGTIMESTAMP = true;  -- true to add timestamps before each log missage.
LOGOUTPUT = {};

-- build defaults
ShareRoot = "/home/sgp1000/buildOutput/";
ScriptRoot = "/home/sgp1000/sharedScripts/";

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
    local logdump =  io.open(ShareRoot .. "PublishGame.log", "w+");
    for i = 1, tablelength(LOGOUTPUT) do
        logdump:write(LOGOUTPUT[i]);
    end
    logdump:flush();
    logdump:close();
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
            if string.find(line, "()Error()") ~= nil then
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
            if string.find(line, "()Error()") ~= nil then
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
    os.exit(code, true);
end

function executeCmd(command)
    if DEBUGCMD == true then
        logPrint(command);
    end
    local handle = io.popen(command);
    local result = 0;
    if handle ~= nil then
        if DEBUGCMD == true then
            dumpOutput(handle, command);
        else
            checkError(handle);
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

function publishGame(targetIP, ramClear)
    -- vm publish game step
    local result = 0;
    if targetIP == nil then
        abort(" --- publishGame() - targetIP is nil!");
    end
    if DEBUG == true then
        logPrint(" -- publishGame(" .. targetIP .. ")");
    else
        logPrint(" -- publishGame()");
    end

    local imageList = getFileList(ShareRoot);
    local images = "";
    if tablelength(imageList) > 0 then
        for i = 1, tablelength(imageList) do
            if i == 1 then
                images = imageList[i];
            else
                images = images .. " " .. imageList[i];
            end
        end
        if DEBUG == true then
            logPrint(" -- Images to install: " .. images);
        end
    else
        logPrint(" -- publishGame - image list is empty");
        return 1, "publish game";
    end

    program = "sh " .. ScriptRoot .. "publishToEGM";
    args = targetIP .. " " .. images;
    if ramClear ~= nil then
        args = args .. " 1";
    end
    local command = program .. " " .. args;

    result = executeCmd(command);

    return result, "publish game";
end

-- Game build function

function publish(Target)
    -- construct vm command
    local result = 0;
    local msg = "";
    if Target == nil or Target == "" then
        logPrint(" -- publish() - Target is nil, will not deploy game");
        return 1;
    else
        logPrint(" -- publish() - Deploy to ".. Target);
    end
    logPrint(" -- publishing to " .. Target);

    -- publish to EGM
    if Target ~= nil and Target ~= "" then
        result, msg = publishGame(Target);
        checkResult(result, msg);
    end

    logPrint(" -- Publish complete");

    return result;
end

function usage()
    logPrint("Usage: ./(lua )PublishGame.lua <deployment address>\n");
    logPrint(" - If Lua is present in /bin then the interpreter does not need to be invoked on the command line.\n");
    logPrint(" -- <deployment address> the target IP address to deploy the game to.");
end

-------------------------------------------------------------------------------
-- execution

if DEBUGLOG == true then
    logFile = io.open(ShareRoot .. "publish.log", "w+");
end

-- parse and execute
if evalCmdLine(arg, 1, 2) ~= nil then
    target = arg[1];
    ramclear = arg[2];

    if DEBUG == true then
        logPrint(" -- DEBUG active");
    end
    if DEBUGCMD == true then
        logPrint(" -- DEBUGCMD active");
    end

    result = publish(target, ramclear);

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
