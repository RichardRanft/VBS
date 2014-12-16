-- Language: Lua

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- This will add multiple platforms if they are listed on the command line.
function evalCmdLine(cmdArg)
  local listArgs = {};
  if tablelength(cmdArg) < 3 then
    print("Too few arguments");
    for i = 1, tablelength(arg), 1 do
      print(cmdArg[i]);
    end
    print("Usage: ./lua addPlatform.lua <platform version> <(optional) boot&root version> <target> <(optional) platform only>");
    return;
  end
  if tablelength(cmdArg) > 2 then
    for i = 1, tablelength(cmdArg), 1 do
      if cmdArg[i] ~= nil then
	listArgs[i] = cmdArg[i];
      end
    end
    if tablelength(listArgs) > 4 then
      print("Too many arguments");
      for i = 1, tablelength(listArgs), 1 do
	print(listArgs[i]);
      end
      print("Usage: ./lua addPlatform.lua <platform version> <(optional) boot&root version> <target> <(optional) platform only>");
      return;
    end
  end
  return 0;
end

function createPacket(mName, Version, PartNum, Folder, Market)
    print("Creating packet for market: " .. Market)
    packet = {}
    Market = packet;
    packet.createPacket();
end