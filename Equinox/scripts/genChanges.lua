-- Language: Lua

-- open the first changes.txt file
-- look for two lines with different revisions - this is going to start
-- a file listing with changes
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function list_iter (t)
  local i = 0
  local n = tablelength(t)
  return function ()
    i = i + 1
    if i <= n then return t[i] end
  end
end

textLines = {};
i = 0;
infile = io.open("/home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.c.txt", "r");
lastLine = "";
if infile ~= nil then
  for line in infile:lines() do
    if line ~= nil and line ~= "" and (string.find(line, "()Revisions are()") == nil ) and line ~= lastLine then
      if string.find(line, "()Revision:()") ~= nil and line ~= lastLine then
	i = i + 1;
	textLines[i] = line;
      elseif string.find(string.sub(line, 0, 2), "%+") or string.find(string.sub(line, 0, 2), "%-") then
	i = i + 1;
	textLines[i] = line;
      end
    end
    lastLine = line;
  end
else
  print("File /home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.c.txt does not exist...");
end

infile = io.open("/home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.cpp.txt", "r");
if infile ~= nil then
  for line in infile:lines() do
    if line ~= nil and line ~= "" and (string.find(line, "()Revisions are()") == nil ) and line ~= lastLine then
      if string.find(line, "()Revision:()") ~= nil and line ~= lastLine then
	i = i + 1;
	textLines[i] = line;
      elseif string.find(string.sub(line, 0, 2), "%+") or string.find(string.sub(line, 0, 2), "%-") then
	i = i + 1;
	textLines[i] = line;
      end
    end
    lastLine = line;
  end
else
  print("File /home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.cpp.txt does not exist...");
end

infile = io.open("/home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.h.txt", "r");
if infile ~= nil then
  for line in infile:lines() do
    if line ~= nil and line ~= "" and  (string.find(line, "()Revisions are()") == nil ) and line ~= lastLine then
      if string.find(line, "()Revision:()") ~= nil and line ~= lastLine then
	i = i + 1;
	textLines[i] = line;
      elseif string.find(string.sub(line, 0, 2), "%+") or string.find(string.sub(line, 0, 2), "%-") then
	i = i + 1;
	textLines[i] = line;
      end
    end
    lastLine = line;
  end
else
  print("File /home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.h.txt does not exist...");
end

diffText = {};
diffLine = 0;
for curLine = 1, tablelength(textLines), 1 do
  if textLines[curLine + 1] ~= nil and textLines[curLine + 1] == "-------------------------------------------------------------------------------" then
    diffLine = diffLine + 1;
    diffText[diffLine] = textLines[curLine];
  elseif string.find(string.sub(textLines[curLine], 0, 2), "%+") or string.find(string.sub(textLines[curLine], 0, 2), "%-") then
    diffLine = diffLine + 1;
    diffText[diffLine] = textLines[curLine];
  end
end

outfile = io.open("/home/sgp1000/DiffFiles/" .. arg[1] .. ".diff.txt", "w");

for element in list_iter(diffText) do
  outfile:write(element .. "\n")
end

outfile:close();
