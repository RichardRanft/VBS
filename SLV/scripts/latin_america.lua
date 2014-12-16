-- Language: Lua

latin_america = {};

function latin_america.createDocPacket(buildVersion, sourceFolder, gameName, partNum, platform)
  print(" -- latin_america.createDocPacket() called");
  latin_america.Name = gameName;
  latin_america.Version = buildVersion;
  latin_america.Source = "/home/sgp1000/build/images/games/" .. latin_america.Version .. "/sources/" .. sourceFolder;
  latin_america.PartNum = partNum;
  latin_america.GameRoot = "/home/sgp1000/build/images/games/" .. latin_america.Version;
  latin_america.Platform = platform;
  latin_america.PC4SigsName = latin_america.Version .. "_" .. latin_america.Platform .. "_pc4.sigs";
  print(" -- Name     : " .. latin_america.Name);
  print(" -- Version  : " .. latin_america.Version);
  print(" -- Source   : " .. latin_america.Source);
  print(" -- PartNum  : " .. latin_america.PartNum);
  print(" -- Platform : " .. latin_america.Platform);

  -- set up the package marshaling folders
  latin_america.createPacketTreeBase()

  latin_america.createTargetTree();
  
  -- Source folders
  latin_america.setupSourceFolders();

  -- begin copying documentation
  print(" -- Beginning document copy....");
  if Revised == true then
    latin_america.packCurrentRevision();
  end

  latin_america.zipSource();

  if latin_america.getGameImage() ~= true then
    latin_america.abort("Game image is not available.", 13);
  end
  
  latin_america.copyFiles();

  -- The text file for signatures.
  latin_america.sigTxtFile = latin_america.targetDir .. latin_america.Version .. ".txt";
  latin_america.createInfoFile(latin_america.sigTxtFile);

  -- The revision document.  This should be in <game>/documents and should be
  -- copied to the root target folder
  -- set up source specs folder
  latin_america.docRevisions = latin_america.Source .. "/documents/revision.txt";

  if file_exists(latin_america.docRevisions) == true then
    latin_america.copyFile(latin_america.docRevisions, latin_america.targetDir);
  else
    latin_america.docRevisions = latin_america.Source .. "/documents/Revision.txt";

    if file_exists(latin_america.docRevisions) == true then
      latin_america.copyFile(latin_america.docRevisions, latin_america.targetDir);
    end
  end

  print(" -- Document packet complete.");
  return true;
end

function latin_america.file_exists(name)
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

function latin_america.getGameImage()
    --char& gameVersion, char& documentDir
    imageSrcPath = "/home/sgp1000/ReleaseImages/" .. latin_america.Version .. ".img.gz";
    
    imageDestPath = latin_america.targetDir .. "\"Game Image/" .. latin_america.Version .. ".img.gz\"";

    if latin_america.copyFile(imageSrcPath, imageDestPath) ~= 1 then
        return false;
    end

    return true;
end

function latin_america.packCurrentRevision(Version)
    --char& workingFolder, char& version
  print(" -- Beginning source archive creation...");
  
  workingFolder = latin_america.getWorkingFolder();
  prepCmd = "sudo cp " .. workingFolder .. "/*.gz ../*";
  os.execute(prepCmd);
  clearCmd = "sudo rm " .. workingFolder .. "/*.gz";
  os.execute(clearCmd);
  tarCmd = "sudo tar -czf --directory /home/sgp1000/build/images/games/ " .. targetFile .. " " .. latin_america.Version;
  os.execute(tarCmd);
  restoreCmd = "sudo cp " .. workingFolder .. "../*.gz " .. workingFolder;
  os.execute(restoreCmd);

  print(" -- Source archive " .. Version .. "_source.tar.gz created.");
  return true;
end

function latin_america.createTargetTree()
  -- Target folders
  -- set up target documentation folder
  print(" -- Creating target document folders....");

  latin_america.targetDocRoot = latin_america.targetDir .. "/Documentation/";
  os.execute("mkdir " .. latin_america.targetDocRoot);
  --if file_exists(latin_america.targetDocRoot) ~= true then
    --return false;
  --end

  -- set up target documentation/art folder
  latin_america.targetArtRoot = latin_america.targetDocRoot .. "Artwork/";
  os.execute("mkdir " .. latin_america.targetArtRoot);

  -- set up target documentation/art/help folder
  latin_america.targetArtHelp = latin_america.targetArtRoot .. "\"Help Screen/\"";
  os.execute("mkdir " .. latin_america.targetArtHelp);

  -- set up target documentation/art/help/esp folder
  latin_america.targetArtEspHelp = latin_america.targetArtHelp .. "/esp";
  os.execute("mkdir " .. latin_america.targetArtEspHelp);

  -- set up target documentation/art/panel folder
  latin_america.targetArtPanel = latin_america.targetArtRoot .. "Panel/";
  os.execute("mkdir " .. latin_america.targetArtPanel);

  -- set up target documentation/art/topbox folder
  latin_america.targetArtTopbox = latin_america.targetArtRoot .. "\"Top box/\"";
  os.execute("mkdir " .. latin_america.targetArtTopbox);

  -- set up target documentation/calculations folder
  latin_america.targetCalcFolder = latin_america.targetDocRoot .. "Calculations/";
  os.execute("mkdir " .. latin_america.targetCalcFolder);

  -- set up target documentation/profile folder
  latin_america.targetProfileFolder = latin_america.targetDocRoot .. "\"Game Profile/\"";
  os.execute("mkdir " .. latin_america.targetProfileFolder);

  -- set up target documentation/specifications folder
  latin_america.targetSpecFolder = latin_america.targetDocRoot .. "\"Game Specification/\"";
  os.execute("mkdir " .. latin_america.targetSpecFolder);

  -- set up target game image tarball folder
  latin_america.targetGameFolder = latin_america.targetDir .. "\"/Game Image/\"";
  os.execute("mkdir " .. latin_america.targetGameFolder);

  -- set up target game source tarball folder
  latin_america.targetSourceFolder = latin_america.targetDir .. "\"/Game Source/\"";
  os.execute("mkdir " .. latin_america.targetSourceFolder);
  
  print(" -- Target document folders ready.");
  return true;
end

function latin_america.createPacketTreeBase()
  print(" -- Creating target document root....");

  if file_exists("/home/sgp1000/Release") ~= true then
    os.execute("mkdir /home/sgp1000/Release");
  end
  if file_exists("/home/sgp1000/Release/EGM") ~= true then
    os.execute("mkdir /home/sgp1000/Release/EGM");
  end
  if file_exists("/home/sgp1000/Release/EGM/PC4") ~= true then
    os.execute("mkdir /home/sgp1000/Release/EGM/PC4");
  end
  if file_exists("/home/sgp1000/Release/EGM/PC4/LatinAmerica") ~= true then
    os.execute("mkdir /home/sgp1000/Release/EGM/PC4/LatinAmerica");
  end
  latin_america.targetDir = "\"/home/sgp1000/Release/EGM/PC4/LatinAmerica/" .. latin_america.Name .. " " .. latin_america.Version .. " " .. latin_america.PartNum .. "/\"";
  print(" -- Cleaning " .. latin_america.targetDir);
  os.execute("sudo rm -rf " .. latin_america.targetDir);
  -- Target folders
  os.execute("mkdir " .. latin_america.targetDir);

  print(" -- Target document folders root ready.");
  return file_exists(latin_america.targetDir);
end

function latin_america.copyDir(sourceDir, targetDir, filter, recurse)
    valid = true;
    if sourceDir == nil then
        print(" --- copyDir : sourceDir is invalid");
        if targetDir ~= nil then
            print(" ---- targetDir : " .. targetDir);
        end
        valid = false;
    end
    if targetDir == nil then
        print(" --- copyDir : targetDir is invalid");
        if sourceDir ~= nil then
            print(" ---- sourceDir : " .. targetDir);
        end
        valid = false
    end
    if valid == false then
        return;
    end
    if recurse == true then
        if filter ~= nil and filter ~= "" then
              cmd = "cp -r " .. sourceDir .. "/".. filter .. " " .. targetDir;
        else
              cmd = "cp -r " .. sourceDir .. "/ " .. targetDir;
        end
    else
        if filter ~= nil and filter ~= "" then
              cmd = "cp " .. sourceDir .. "/".. filter .. " " .. targetDir;
        else
              cmd = "cp " .. sourceDir .. "/ " .. targetDir;
        end
    end
    print(" -- " .. cmd);
    os.execute(cmd);
end

function latin_america.copyFile(source, target)
    cmd = "cp " .. source .. " " .. target;
    os.execute(cmd);
    return 1;
end

function latin_america.setupSourceFolders()
  print(" -- Set up source folders....");

  -- set up source game document root folder
  if file_exists(latin_america.Source) ~= true then
    latin_america.abort(" -- " .. latin_america.Name .. " source folder does not exist.  Exiting.", 99);
  end
  
  latin_america.docRoot = latin_america.Source .. "/documents/";

  -- set up source calcs folder
  latin_america.docSrcCalcs = latin_america.docRoot .. "calcs";
  if file_exists(latin_america.docSrcCalcs) ~= true then
    latin_america.docSrcCalcs = latin_america.docRoot .. "Calcs";
    if file_exists(latin_america.docSrcCalcs) ~= true then
      latin_america.abort(" -- Source calculations folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source misc folder
  latin_america.docSrcMisc = latin_america.docRoot .. "misc";
  if file_exists(latin_america.docSrcMisc) ~= true then
    latin_america.docSrcMisc = latin_america.docRoot .. "Misc";
    if file_exists(latin_america.docSrcMisc) ~= true then
      latin_america.abort(" -- Source misc folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source specs folder
  latin_america.docSrcSpecs = latin_america.docRoot .. "specs";
  if file_exists(latin_america.docSrcSpecs) ~= true then
    latin_america.docSrcSpecs = latin_america.docRoot .. "Specs";
    if file_exists(latin_america.docSrcSpecs) ~= true then
      latin_america.abort(" -- Source specifications folder does not exist.  Exiting.", 99);
    end
  end
  
  -- set up source help screen image folder
  latin_america.helpScreenFolder = latin_america.Source .. "/resource_widescreen/help/english";
  if file_exists(latin_america.helpScreenFolder) ~= true then
    -- in case the help/english folder is not there
    latin_america.helpScreenFolder = latin_america.Source .. "/resource_widescreen/help";
    if file_exists(latin_america.helpScreenFolder) ~= true then
      latin_america.abort(" -- Source help images folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source Spanish help screen image folder
  latin_america.espHelpScreenFolder = latin_america.Source .. "/resource_widescreen/help/esp";
  if file_exists(latin_america.espHelpScreenFolder) ~= true then
    -- in case the help/english folder is not there
    latin_america.espHelpScreenFolder = latin_america.Source .. "/resource_widescreen/help";
    if file_exists(latin_america.espHelpScreenFolder) ~= true then
      latin_america.abort(" -- Source help images folder does not exist.  Exiting.", 99);
    end
  end

  -- topbox images
  latin_america.topboxFolder = latin_america.Source .. "/topbox/resource/";
  if file_exists(latin_america.topboxFolder) ~= true then
    -- in case the help/english folder is not there
    latin_america.topboxFolder = latin_america.Source .. "/topbox_widescreen/resource/";
    if file_exists(latin_america.topboxFolder) ~= true then
      latin_america.abort(" -- Source topbox images folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source game images root folder
  latin_america.imgRoot = "/home/sgp1000/build/images/";

  -- set up source game images root folder
  latin_america.gameImgRoot = latin_america.imgRoot .. "games/" .. latin_america.Version .. "/" .. latin_america.Version .. ".img.gz";

  -- set up source platform images root folder
  latin_america.platformImgName = latin_america.gameImgRoot .. "P4.disk.img.gz";

  print(" -- Source folders complete.");
end

function latin_america.copyFiles()
  print(" -- Begin file copy....");
  filter = "*rule*";
  latin_america.copyDir(latin_america.helpScreenFolder, latin_america.targetArtHelp, filter, true);

  filter = "*feature*";
  latin_america.copyDir(latin_america.helpScreenFolder, latin_america.targetArtHelp, filter, true);

  filter = "*rule*";
  latin_america.copyDir(latin_america.espHelpScreenFolder, latin_america.targetArtEspHelp, filter, true);

  filter = "*feature*";
  latin_america.copyDir(latin_america.espHelpScreenFolder, latin_america.targetArtEspHelp, filter, true);

  filter = "*.png";
  latin_america.copyDir(latin_america.topboxFolder, latin_america.targetArtTopbox, filter, true);

  filter = "*.avi";
  latin_america.copyDir(latin_america.topboxFolder, latin_america.targetArtTopbox, filter, true);

  -- Game specs
  filter = "*pecs*.doc";
  latin_america.copyDir(latin_america.docSrcSpecs, latin_america.targetSpecFolder, filter);

  -- Or maybe this is the game specs file...
  filter = "*detail*.doc";
  latin_america.copyDir(latin_america.docSrcSpecs, latin_america.targetSpecFolder, filter);

  -- Game profile
  filter = "*rofile*.doc";
  latin_america.copyDir(latin_america.docSrcSpecs, latin_america.targetProfileFolder, filter);

  -- Calcs, should recurse but keep an eye on it....
  filter = "*.xl*";
  latin_america.copyDir(latin_america.docSrcCalcs, latin_america.targetCalcFolder, filter, true);
  print(" -- Files copied.");
end

function latin_america.zipSource()
  workDir = latin_america.getWorkingFolder();
  os.execute("cd " .. latin_america.GameRoot);

  -- make clean
  print(" -- " .. latin_america.GameRoot .. ": Cleaning source files...");
  os.execute("sudo make -s -C " .. latin_america.GameRoot .. " -f Makefile clean");
  print(" -- Sources clean.");

  print(" -- removing archive artifacts...");
  os.execute("sudo rm -rf " .. latin_america.GameRoot .. "/sources/.svn");
  os.execute("sudo rm -rf " .. latin_america.Source .. "/.svn");

  targetFile = latin_america.targetSourceFolder .. latin_america.Version .. "_source.tar.gz";
  print(" -- Begin zipping source to:");
  print(" --- " .. targetFile);
  -- run gzip on sourceDir
  tarCmd = "cd /home/sgp1000/build/images/games/; sudo tar --format=gnu -czf " .. targetFile .. " " .. latin_america.Version;
  --sprintf(tarCmd, "sudo tar cvzf \"%s%s_source.tar.gz\" /home/sgp1000/build/images/games/%s/*", &targetDir, &build, &build);
  os.execute(tarCmd);

  os.execute("cd " .. workDir);
  print(" -- Source archive complete.");
  return true;
end

function latin_america.getWorkingFolder()
  return os.getenv("PWD");
end

function latin_america.createInfoFile(fileName)
  print(" -- Creating signature file " .. fileName .. "....");
  cmd = "cp /dev/null " .. fileName;
  os.execute(cmd);
  return file_exists(fileName);
end

function latin_america.abort(reason, code)
  cmd = "rm -rf " .. latin_america.targetDir;
  os.execute(cmd);
  print(reason);
  os.exit(code, true);
end

return latin_america;