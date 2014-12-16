#!/usr/local/bin/lua
-- Language: Lua

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- This will add multiple platforms if they are listed on the command line.
function evalCmdLine(cmdArg)
  local listArgs = {};
  if tablelength(cmdArg) < 1 then
    print("Too few arguments");
    for i = 1, tablelength(arg), 1 do
      print(cmdArg[i]);
    end
    print("Usage: ./lua addBuild.lua <platform version> <build type> <(optional) boot&root version> <(optional) platform only>");
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
      print("Usage: ./lua addBuild.lua <platform version> <build type> <(optional) boot&root version> <(optional) platform only>");
      return;
    end
  end
  return 0;
end

function findNAS(version)
  if string.find(version, "()NAS()") ~= nil then
    return true;
  else
    return false;
  end
end

if evalCmdLine(arg) ~= nil then
  name = arg[1];
  type = arg[2];
  rfsName = arg[3];
  platOnly = arg[4];
  if rfsName == nil then
    rfsName = "EGM0062";
  end
  print("Installing platform " .. name .. "_" .. type .. " using BRF system " .. rfsName);
  if name ~= nil then
    os.execute("cp -f /home/sgp1000/" .. rfsName .. "/fix_perms.sh /home/sgp1000/");

    os.execute("sudo rm -rf " .. name .. "_" .. type);
    os.execute("mkdir " .. name .. "_" .. type);
    os.execute("cp -rf /home/sgp1000/EGMPlatforms/bios /home/sgp1000/" .. name .. "_" .. type);
    os.execute("cp -rf /home/sgp1000/" .. rfsName .. "/build/* /home/sgp1000/" .. name .. "_" .. type);
    if platOnly == nil then
      os.execute("cp -rf /home/sgp1000/EGMPlatforms/" .. name .. "/* /home/sgp1000/");
    else
      os.execute("mkdir /home/sgp1000/" .. name .. "_" .. type .. "/images/platform/P4/sources");
      os.execute("cp -rf /home/sgp1000/EGMPlatforms/" .. name .. "/* /home/sgp1000/" .. name .. "_" .. type .. "/images/platform/P4/sources");
    end
  end
end