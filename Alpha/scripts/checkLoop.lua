#! /bin/lua
-- Language: Lua

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function evalCmdLine(cmdArg)
    local listArgs = {};
    local argCount = 0;
    if tablelength(cmdArg) < 0 then
        print("Too few arguments");
        for i = 1, tablelength(arg), 1 do
            print(cmdArg[i]);
        end
        usage();
        return;
    end
    if tablelength(cmdArg) > 0 then
        for i = 1, tablelength(cmdArg), 1 do
            if cmdArg[i] ~= nil then
                listArgs[i] = cmdArg[i];
            end
        end
        if tablelength(listArgs) > 0 then
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

function usage()
    print("Usage: ./lua checkLoop.lua");
end

function checkLoopNames()
    -- noting that this works because Lua supports returning multiple values from
    -- a single function call.  io.open() returns three values - a file handle if
    -- successful or nil if it fails, an error message and an error code returned
    -- from the operating system.
    infile,openMsg = io.open("/dev/loop01", "r");
    print(" -- checking /dev/loop01 ... ");
    if infile ~= nil or string.find(openMsg, "()Permission()") ~= nil then
        -- If the user is root infile will be opened as a valid file handle so
        -- we'll close it.
        -- If the user is not root then "Permission denied" will be returned and we'll 
        -- fall through to the else clause.  The print statements are more for debugging
        -- than for any functional purpose.
        print(" -- /dev/loop01 is present");
        if infile ~= nil then
            print(" -- closing /dev/loop01");
            infile:close();
        else
            print(" -- /dev/loop01 closed");
        end
        return true;
    end
    return false;
end

function createLoop01()
    -- where we might erroneously report that the /dev/loop01 file/link does
    -- not exist.  Fortunately, the call to ln will fail if it actually does
    -- exist.
    print(" -- /dev/loop01 is not present.  Creating symlink and updating /etc/init.d/boot.local");
    os.execute("sudo ln -s /dev/loop1 /dev/loop01");
end

function updatebootlocal()
    local textLines = {};
    infile = io.open("/etc/init.d/boot.local", "r");
    i = 0;
    -- read the original contents of our boot.local file and add a little bit
    -- of script to recreate our symlink on boot if needed.
    print(" -- original /etc/init.d/boot.local contents");
    for line in infile:lines() do
        if line ~= nil and line ~= "" and (string.find(line, "()/dev/loop01()") == nil ) then
            -- don't add it if we don't need it
            print(" -- /etc/init.d/boot.local already contains loop01 setup script");
            return true;
        end
        textLines[i] = line;
        print(textLines[i]);
        i = i + 1;
    end
    textLines[i] = "if [ ! -e /dev/loop01 ]; then";
    textLines[i + 1] = "  ln -s /dev/loop1 /dev/loop01";
    textLines[i + 2] = "fi";
    outFile = io.open("/home/sgp1000/temp.boot.local", "w");
    if outFile ~= nil then
        -- write to our temp file in /home/sgp1000 to avoid having to fiddle
        -- with permissions.
        print(" -- writing new boot.local");
        for j = 0, tablelength(textLines) - 1 do
            print(textLines[j]);
            outFile:write(textLines[j] .. "\n");
            outFile:flush();
        end
        outFile:close();
        -- and deal with the permission issue by just copying it using sudo
        success, exitcode = os.execute("sudo cp -f /home/sgp1000/temp.boot.local /etc/init.d/boot.local");
        if success ~= true then
            print(" -- unable to copy new boot.local file to /etc/init.d/boot.local");
            success, exitcode = os.execute("rm /home/sgp1000/temp.boot.local");
            if success ~= true then
                print(" -- unable to delele temp boot.local file");
                return exitcode;
            end
            return exitcode;
        end
        return false;
    else
        print(" -- could not create temp file");
        return false;
    end
end

-- expecting parameter:
-- none
if evalCmdLine(arg) ~= nil then
    if checkLoopNames() == true then
        if updatebootlocal() == true then
            return 0;
        end
        return 0;
    else
        createLoop01();
    end
    if updatebootlocal() == true then
        return 0;
    end
    return 1;
end