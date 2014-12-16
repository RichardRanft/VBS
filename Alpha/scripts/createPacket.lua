#! /bin/lua
-- Language: Lua
require"north_america";
require"new_york";
require"latin_america";
require"north_america_slv";

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function evalCmdLine(cmdArg)
  local listArgs = {};
  if tablelength(cmdArg) < 6 then
    print("Too few arguments");
    for i = 1, tablelength(arg), 1 do
      print(cmdArg[i]);
    end
    usage();
    return;
  end
  if tablelength(cmdArg) > 2 then
    for i = 1, tablelength(cmdArg), 1 do
      if cmdArg[i] ~= nil then
	listArgs[i] = cmdArg[i];
      end
    end
    if tablelength(listArgs) > 8 then
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
    print("Usage: ./lua createPacket.lua <build version> <source folder> <game name> <part number> <market> <platform> (optional)<SLV>");
    print("Current markets:");
    print("  north_america");
    print("  new_york");
    print("  latin_america");
    print("  north_america_slv");
end

function openpackage (ns)
  for n,v in pairs(ns) do
    if _G[n] ~= nil then
      error("name clash: " .. n .. " is already defined")
    end
    _G[n] = v
  end
  return true;
end
    
function createPacket(buildVersion, sourceFolder, gameName, partNum, Market, Platform, SLV, SVNSourcePath)
    print("Creating packet for market: " .. Market)
    if SLV ~= nil then
        print(" -- SLV packet");
        if Market == "north_america_slv" then
          packageOpened = openpackage(north_america_slv);
        end        
    else
        if Market == "north_america" then
          packageOpened = openpackage(north_america);
        end
        if Market == "new_york" then
          packageOpened = openpackage(new_york);
        end
        if Market == "latin_america" then
          packageOpened = openpackage(latin_america);
        end
        if packageOpened ~= true or packageOpened == nil or Market == nil then
            if packageOpened ~= true or packageOpened == nil then
                print(" -- failed to open package " .. Market);
            end
            if Market == nil then
                print(" -- Market argument is nil");
            end
            usage();
            return 2;
        end
    end
    if createDocPacket == nil then
        print(" -- createDocPacket function undefined - fix your scripts");
        usage();
        return 3;
    end
    result = createDocPacket(buildVersion, sourceFolder, gameName, partNum, Platform, SLV, SVNSourcePath);
    if result == true then
        return 0;
    end
    return 1;
end

if evalCmdLine(arg) ~= nil then
    version = arg[1];
    source = arg[2];
    name = arg[3];
    part = arg[4];
    mkt = arg[5];
    platform = arg[6];
    slv = arg[7];
    svnPath = arg[8];
    print(" -- Game Version  : " .. version);
    print(" -- Game Folder   : " .. source);
    print(" -- Game Name     : " .. name);
    print(" -- Game PartNo   : " .. part);
    print(" -- Game Market   : " .. mkt);
    print(" -- Game Platform : " .. platform);
    if slv ~= nil then
        print(" -- SLV           : " .. slv);
        print(" -- svnPath       : " .. svnPath);
    end
    return createPacket(version, source, name, part, mkt, platform, slv, svnPath);
end