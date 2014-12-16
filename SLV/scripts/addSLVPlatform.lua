#! /bin/lua
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
    usage();
    return;
  end
  if tablelength(cmdArg) > 2 then
    for i = 1, tablelength(cmdArg), 1 do
      if cmdArg[i] ~= nil then
	listArgs[i] = cmdArg[i];
      end
    end
    if tablelength(listArgs) > 3 then
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
    print("Usage: ./lua addSLVPlatform.lua <platform label> <root filesystem version> <(optional) platform only>");
end

function findNAS(version)
  if string.find(version, "()NAS()") ~= nil then
    return true;
  else
    return false;
  end
end

function setPlatform(platform)
  print("Switching platforms: " .. platform);
  -- Update symlink to point to new folder
  result = os.execute("sudo rm -f /home/sgp1000/build");
  if result == nil then
    print("/home/sgp1000/build does not exist, Creating...");
  end
  result = os.execute("ln -s /home/sgp1000/" .. platform .. " /home/sgp1000/build");
  if result == nil then
    print("Cannot create symlink to /home/sgp1000/" .. platform);
    return result;
  end
  return result;
end

function copyBIOS()
  print(" -- copying BIOS...")
  os.execute("rsync -rl --exclude=.svn /home/sgp1000/EGMPlatforms/bios /home/sgp1000/build");
end

function copyRFS(rfs)
  print(" -- copying root filesystem " .. rfs);
  os.execute("rsync -rl --exclude=.svn /home/sgp1000/" .. rfs .. "/ /home/sgp1000/build/");
end

function copyPlatform(rfs, srcPlatform, srcOnly)
  copyRFS(rfs);

  if srcOnly == false then
    print(" -- Platform contains rfs information");
    os.execute("rsync -rl --exclude=.svn /home/sgp1000/EGMPlatforms/" .. srcPlatform .. "/ /home/sgp1000/build");
  else
    print(" -- Platform is clean");
    os.execute("mkdir /home/sgp1000/build/images/platform/P5/" .. stripVersion(srcPlatform));
    os.execute("rsync -rl --exclude=.svn /home/sgp1000/EGMPlatforms/" .. srcPlatform .. "/ /home/sgp1000/build/images/platform/P5/" .. stripVersion(srcPlatform));
  end
end

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then 
    io.close(f);
    print("file_exists: " .. name .. " found.");
    return true;
  else 
    print("file_exists: " .. name .. " not found.");
  end
  return false;
end

local function directory_exists( sPath )
  if type( sPath ) ~= "string" then return false end

  local response = os.execute( "cd " .. sPath )
  if response == 0 or response == true then
    return true
  end
  return false
end

function stripVersion(rawName)
    index = string.find(rawName, "()-()") - 1;
    return string.sub(rawName, 0, index);
end

if evalCmdLine(arg) ~= nil then
    print(" -- begin")
  name = arg[1];
  rfsName = arg[2];
  platOnly = arg[3];
  platformSourceOnly = 0;
  if rfsName == nil then
    rfsName = "A2RFS002";
  end
  print("Installing platform " .. name .. " using BRF system " .. rfsName);
  source = "/home/sgp1000/EGMPlatforms/".. name .. "/images";
  imagesExists = directory_exists(source);
  --print("file_exists returned : ");
  --print(imagesExists);
  if imagesExists then
    -- /images exists so NOT platform only
    sourceOnly = false;
    --print("/home/sgp1000/EGMPlatforms/".. name .. "/images found");
  elseif platOnly ~= nil then
    sourceOnly = true;
  end
  
  if name ~= nil then
    os.execute("sudo rm -rf /home/sgp1000/" .. stripVersion(name) .. "_Debug");
    os.execute("mkdir /home/sgp1000/" .. stripVersion(name) .. "_Debug");
    os.execute("sudo rm -rf /home/sgp1000/" .. stripVersion(name) .. "_Release");
    os.execute("mkdir /home/sgp1000/" .. stripVersion(name) .. "_Release");
    os.execute("sudo rm -rf /home/sgp1000/" .. stripVersion(name) .. "_Show");
    os.execute("mkdir /home/sgp1000/" .. stripVersion(name) .. "_Show");
    
    if sourceOnly then
      print(" -- Platform is source only.");
    end

    plat = stripVersion(name) .. "_Debug";
    print(" -- Setting platform " .. plat);
    setPlatform(plat);
    --copyBIOS();
    copyPlatform(rfsName, name, sourceOnly);

    plat = stripVersion(name) .. "_Release";
    print(" -- Setting platform " .. plat);
    setPlatform(plat);
    --copyBIOS();
    copyPlatform(rfsName, name, sourceOnly);

    plat = stripVersion(name) .. "_Show";
    print(" -- Setting platform " .. plat);
    setPlatform(plat);
    --copyBIOS();
    copyPlatform(rfsName, name, sourceOnly);
  end
  print(" -- end")
end
