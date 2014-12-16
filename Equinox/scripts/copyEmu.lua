function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- This will add multiple platforms if they are listed on the command line.
function evalCmdLine(cmdArg)
  local listArgs = {};
  if tablelength(cmdArg) < 2 then
    print("Too few arguments");
    for i = 1, tablelength(arg), 1 do
      print(cmdArg[i]);
    end
    print("Usage: ./lua copyEmu.lua <game version> <platform version>");
    return;
  end
  if tablelength(cmdArg) > 2 then
    for i = 1, tablelength(cmdArg), 1 do
      if cmdArg[i] ~= nil then
	listArgs[i] = cmdArg[i];
      end
    end
    if tablelength(listArgs) > 2 then
      print("Too many arguments");
      for i = 1, tablelength(listArgs), 1 do
	print(listArgs[i]);
      end
      print("Usage: ./lua copyEmu.lua <game version> <platform version>");
      return;
    end
  end
  return 0;
end

if evalCmdLine(arg) ~= nil then
  name = arg[1];
  platform = arg[2];
  os.execute("cp -rf /home/sgp1000/EGMGames/" .. name .. "/sources/* /home/sgp1000/workspace/north_america/" .. platform .. "/games/egm");
end 
