#! /bin/lua
-- Language: Lua

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

function usage()
    print("Usage: ./lua addGameEmulation.lua <platform path> <game version>");
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

function split(text)
    local count = 1;
    local wordList = {};
    for w in string.gmatch(text, "[_%w]+") do -- underscore and all alphanumerics
        wordList[count] = w;
        count = count + 1;
    end
    return wordList;
end

function findGameFolder(pathTable, gameVer)
    for i = 1, tablelength(pathTable) do
	--print(pathTable[i]);
        if string.find(pathTable[i], "()"..gameVer.."()") ~= nil then
            return pathTable[i + 1];
        end
    end
    return "";
end

function getGameName(gameVersion)
    os.execute("ls -d /home/sgp1000/" .. gameVersion .. "/*/ > temp.lst");
    local folders = io.open("temp.lst", "r");
    if folders == nil then
        --print(" -- problem reading temp folder list file");
        os.exit(1);
    end
    local name = "";
    for line in folders:lines() do
        if line ~= nil and line ~= "" and string.find(line, "()build_system()") == nil then
            name = findGameFolder(split(line), gameVersion);
        end
    end
    return name;
end

function copyGame(gameVer, target)
    print(" -- copyGame(" .. gameVer .. ", " .. target .. ")");
    local gameName = getGameName(gameVer);
    if gameName == "" then
        print(" -- did not find valid game source folder");
        os.exit(1);
    end
    print(" -- copying to folder " .. target .. gameName);
    os.execute("sudo rm -rf " .. target .. gameName);
    os.execute("rsync -rlE --exclude=.svn /home/sgp1000/" .. gameVer .. "/" .. gameName .. " " .. target);
end

if evalCmdLine(arg, 2, 2) ~= nil then
    os.setlocale("C");
    if arg[1] == nil then
        usage();
    end;
    if arg[2] == nil then
        usage();
    end

    platformPath = arg[1];
    gameVer = arg[2];
    print("Installing " .. gameVer .. " for emulation in " .. platformPath);
    source = "/home/sgp1000/" .. gameVer;
    target = "/home/sgp1000/workspace/" .. platformPath .. "/games/egm/";
    print(" -- EGM emulation path: " .. target);

    copyGame(gameVer, target);

end
