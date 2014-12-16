#! /bin/lua
-- Language: Lua

if (arg[1]) then
  print("Switching platforms: " .. arg[1]);
  -- Update symlink to point to new folder
  result = os.execute("rm -f /home/sgp1000/build");
  if result == nil then 
    print("/home/sgp1000/build does not exist or cannot be removed");
    os.exit(1);
  end
  result = os.execute("ln -s /home/sgp1000/" .. arg[1] .. " /home/sgp1000/build");
  if result == nil then
    print("Cannot create symlink to /home/sgp1000/" .. arg[1]);
    os.exit(1);
  end
  os.exit(result);
end
