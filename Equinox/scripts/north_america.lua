-- Language: Lua

north_america = {};

function north_america.createDocPacket(buildVersion, sourceFolder, gameName, partNum, platform)
  print(" -- north_america.createDocPacket() called");
  north_america.Name = gameName;
  north_america.Version = buildVersion;
  north_america.Source = "/home/sgp1000/build/images/games/" .. north_america.Version .. "/sources/" .. sourceFolder;
  north_america.PartNum = partNum;
  north_america.GameRoot = "/home/sgp1000/build/images/games/" .. north_america.Version;
  north_america.Platform = platform;
  north_america.PC4SigsName = north_america.Version .. "_" .. north_america.Platform .. "_pc4.catbin";
  print(" -- Name     : " .. north_america.Name);
  print(" -- Version  : " .. north_america.Version);
  print(" -- Source   : " .. north_america.Source);
  print(" -- PartNum  : " .. north_america.PartNum);
  print(" -- Platform : " .. north_america.Platform);

  -- set up the package marshaling folders
  north_america.createPacketTreeBase()

  north_america.createTargetTree();
  
  -- Source folders
  north_america.setupSourceFolders();

  -- begin copying documentation
  north_america.copySource();

  print(" -- Document packet complete.");
  return true;
end

function north_america.copyDir(sourceDir, targetDir, filter, recurse)
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
	if directory_exists(sourceDir) ~= true then
		print(" --- copyDir : sourceDir does not exist.");
		valid = false;
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

function north_america.file_exists(name)
  local f=io.open(name,"r")
  if f ~= nil then 
    io.close(f);
    --print("file_exists: " .. name .. " found.");
    return true;
  else 
    --print("file_exists: " .. name .. " not found.");
  end
  return false;
end

function north_america.directory_exists( sPath )
  if type( sPath ) ~= "string" then return false end

  local response = os.execute( "cd " .. sPath )
  if response == 0 or response == true then
    return true
  end
  return false
end

function north_america.getGameImage()
    --char& gameVersion, char& documentDir
    imageSrcPath = "/home/sgp1000/ReleaseImages/" .. north_america.Version .. ".img.gz";
    
    imageDestPath = north_america.targetDir .. "\"Game Image/" .. north_america.Version .. ".img.gz\"";

    if north_america.copyFile(imageSrcPath, imageDestPath) ~= 1 then
        return false;
    end

    return true;
end

function north_america.packCurrentRevision(Version)
    --char& workingFolder, char& version
  print(" -- Beginning source archive creation...");
  
  workingFolder = north_america.getWorkingFolder();
  prepCmd = "sudo cp " .. workingFolder .. "/*.gz ../*";
  os.execute(prepCmd);
  clearCmd = "sudo rm " .. workingFolder .. "/*.gz";
  os.execute(clearCmd);
  tarCmd = "sudo tar cvzf \"".. workingFolder .. "../" .. Version .. "_source.tar.gz \" " .. workingFolder .. "/*";
  os.execute(tarCmd);
  restoreCmd = "sudo cp " .. workingFolder .. "../*.gz " .. workingFolder;
  os.execute(restoreCmd);

  print(" -- Source archive " .. Version .. "_source.tar.gz created.");
  return true;
end

function north_america.createTargetTree()
  -- Target folders
  -- set up target documentation folder
  print(" -- Creating target document folders....");

  north_america.targetDocRoot = north_america.targetDir .. "/Documentation/";
  os.execute("mkdir " .. north_america.targetDocRoot);
  --if file_exists(north_america.targetDocRoot) ~= true then
    --return false;
  --end

  -- set up target documentation/art folder
  north_america.targetArtRoot = north_america.targetDocRoot .. "Artwork/";
  os.execute("mkdir " .. north_america.targetArtRoot);

  -- set up target documentation/art/help folder
  north_america.targetArtHelp = north_america.targetArtRoot .. "\"Help Screen/\"";
  os.execute("mkdir " .. north_america.targetArtHelp);

  -- set up target documentation/art/panel folder
  north_america.targetArtPanel = north_america.targetArtRoot .. "Panel/";
  os.execute("mkdir " .. north_america.targetArtPanel);

  -- set up target documentation/art/topbox folder
  north_america.targetArtTopbox = north_america.targetArtRoot .. "\"Top box/\"";
  os.execute("mkdir " .. north_america.targetArtTopbox);

  -- set up target documentation/calculations folder
  north_america.targetCalcFolder = north_america.targetDocRoot .. "Calculations/";
  os.execute("mkdir " .. north_america.targetCalcFolder);

  -- set up target documentation/profile folder
  north_america.targetProfileFolder = north_america.targetDir .. "\"Par Sheets/\"";
  os.execute("mkdir " .. north_america.targetProfileFolder);

  -- set up target documentation/specifications folder
  north_america.targetSpecFolder = north_america.targetDocRoot .. "\"Game Specification/\"";
  os.execute("mkdir " .. north_america.targetSpecFolder);

  -- set up target game image tarball folder
  north_america.targetGameFolder = north_america.targetDir .. "\"/Game Image/\"";
  os.execute("mkdir " .. north_america.targetGameFolder);

  -- set up target game source tarball folder
  north_america.targetSourceFolder = north_america.targetDir .. "\"/Game Source/\"";
  os.execute("mkdir " .. north_america.targetSourceFolder);
  
  print(" -- Target document folders ready.");
  return true;
end

function north_america.createPacketTreeBase()
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
  if file_exists("/home/sgp1000/Release/EGM/PC4/NorthAmerica") ~= true then
    os.execute("mkdir /home/sgp1000/Release/EGM/PC4/NorthAmerica");
  end
  north_america.targetDir = "\"/home/sgp1000/Release/EGM/PC4/NorthAmerica/" .. north_america.Name .. " " .. north_america.Version .. " " .. north_america.PartNum .. "/\"";
  print(" -- Cleaning " .. north_america.targetDir);
  os.execute("sudo rm -rf " .. north_america.targetDir);
  -- Target folders
  os.execute("mkdir " .. north_america.targetDir);

  print(" -- Target document folders root ready.");
  return file_exists(north_america.targetDir);
end

function north_america.syncFolder(source, target)
    cmd = "rsync -r " .. source .. "/ " .. target;
    print(" -- " .. cmd);
    os.execute(cmd);
end

function north_america.copyFile(source, target)
    cmd = "cp " .. source .. " " .. target;
    os.execute(cmd);
    return 1;
end

function north_america.setupSourceFolders()
  -- set up source game document root folder
  print(" -- Locating source folders....");
  if directory_exists(north_america.Source) ~= true then
    north_america.abort(" -- " .. north_america.Name .. " source folder does not exist.  Exiting.", 99);
  end
  
  north_america.docRoot = north_america.Source .. "/documents/";

  -- set up source calcs folder
  north_america.docSrcCalcs = north_america.docRoot .. "calcs";
  if directory_exists(north_america.docSrcCalcs) ~= true then
    north_america.docSrcCalcs = north_america.docRoot .. "Calcs";
    if directory_exists(north_america.docSrcCalcs) ~= true then
      north_america.abort(" -- Source calculations folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source misc folder
  north_america.docSrcMisc = north_america.docRoot .. "misc";
  if directory_exists(north_america.docSrcMisc) ~= true then
    north_america.docSrcMisc = north_america.docRoot .. "Misc";
    if directory_exists(north_america.docSrcMisc) ~= true then
      north_america.abort(" -- Source misc folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source specs folder
  north_america.docSrcSpecs = north_america.docRoot .. "specs";
  if directory_exists(north_america.docSrcSpecs) ~= true then
    north_america.docSrcSpecs = north_america.docRoot .. "Specs";
    if directory_exists(north_america.docSrcSpecs) ~= true then
      north_america.abort(" -- Source specification folder does not exist.  Exiting.", 99);
    end
  end
  
  -- set up source pars folder
  north_america.docSrcPars = north_america.docRoot .. "pars";
  if directory_exists(north_america.docSrcPars) ~= true then
    north_america.docSrcPars = north_america.docRoot .. "Pars";
    if directory_exists(north_america.docSrcPars) ~= true then
      north_america.noPars = true;
      print(" -- Source par sheet folder does not exist.");
    end
  end
  
  -- set up source help screen image folder
  north_america.helpScreenFolder = north_america.Source .. "/resource_widescreen/help/english";
  if directory_exists(north_america.helpScreenFolder) ~= true then
    -- in case the help/english folder is not there
    north_america.helpScreenFolder = north_america.Source .. "/resource_widescreen/help";
    if directory_exists(north_america.helpScreenFolder) ~= true then
      north_america.abort(" -- Source help images folder does not exist.  Exiting.", 99);
    end
  end

  -- topbox images
  north_america.topboxFolder = north_america.Source .. "/topbox/resource/";
  if directory_exists(north_america.topboxFolder) ~= true then
    -- in case the help/english folder is not there
    north_america.topboxFolder = north_america.Source .. "/topbox_widescreen/resource/";
    if directory_exists(north_america.topboxFolder) ~= true then
      north_america.abort(" -- Source topbox images folder does not exist.  Exiting.", 99);
    end
  end

  -- set up source game images root folder
  north_america.imgRoot = "/home/sgp1000/build/images/";

  -- set up source game images root folder
  north_america.gameImgRoot = north_america.imgRoot .. "games/" .. north_america.Version .. "/" .. north_america.Version .. ".img.gz";

  -- set up source platform images root folder
  north_america.platformImgName = north_america.gameImgRoot .. "P4.disk.img.gz";
end

function north_america.copySource()
  print(" -- Beginning document copy....");
  if Revised == true then
    north_america.packCurrentRevision();
  end

  -- Game par sheets
  if north_america.noPars ~= true then
    filter = "*.pdf";
    north_america.copyDir(north_america.docSrcPars, north_america.targetProfileFolder, filter);
    -- remove pars from the source folder after copy so that they're not included
    -- in the zipped source archive
    os.execute("sudo rm -rf " .. north_america.docSrcPars);
  end

  north_america.zipSource();

  if north_america.getGameImage() ~= true then
    north_america.abort("Game image is not available.", 13);
  end
  
  filter = "*rule*";
  north_america.copyDir(north_america.helpScreenFolder, north_america.targetArtHelp, filter, true);

  filter = "*feature*";
  north_america.copyDir(north_america.helpScreenFolder, north_america.targetArtHelp, filter, true);

  filter = "*.png";
  north_america.copyDir(north_america.topboxFolder, north_america.targetArtTopbox, filter, true);

  filter = "*.avi";
  north_america.copyDir(north_america.topboxFolder, north_america.targetArtTopbox, filter, true);

  -- Game specs
  filter = "*pecs*.doc*";
  north_america.copyDir(north_america.docSrcSpecs, north_america.targetSpecFolder, filter);

  -- Or maybe this is the game specs file...
  filter = "*detail*.doc*";
  north_america.copyDir(north_america.docSrcSpecs, north_america.targetSpecFolder, filter);

  -- Calcs, should recurse but keep an eye on it....
  filter = "*.xl*";
  north_america.syncFolder(north_america.docSrcCalcs, north_america.targetCalcFolder);

  -- The text file for signatures.
  north_america.sigTxtFile = north_america.targetDir .. north_america.Version .. ".txt";
  north_america.createInfoFile(north_america.sigTxtFile);

    -- The revision document.  This should be in <game>/documents and should be
    -- copied to the root target folder
    -- set up source specs folder
    checkDoc = north_america.Source .. "/documents/revision.txt";
    revDocFound = false;
    if file_exists(checkDoc) == true then
        north_america.docRevisions = north_america.Source .. "/documents/revision.txt";
        revDocFound = true;
    end
    if revDocFound == false then
        checkDoc = north_america.Source .. "/documents/Revision.txt";
        if file_exists(checkDoc) == true then
            north_america.docRevisions = north_america.Source .. "/documents/Revision.txt";
            revDocFound = true;
        end
    end
    if revDocFound == false then
        checkDoc = north_america.Source .. "/documents/revision";
        if file_exists(checkDoc) == true then
            north_america.docRevisions = north_america.Source .. "/documents/revision";
            revDocFound = true;
        end
    end
    if revDocFound == false then
        checkDoc = north_america.Source .. "/documents/Revision";
        if file_exists(checkDoc) == true then
            north_america.docRevisions = north_america.Source .. "/documents/Revision";
            revDocFound = true;
        end
    end

    if revDocFound == true then
        north_america.copyFile(north_america.docRevisions, north_america.targetDocRoot);
        print(" -- " .. checkDoc .. " copied.");
    else
        print(" -- No version of revision.txt found....");
    end
end

function north_america.copySigs()
  print(" -- Copying .bin and .sigs files....");
  cmd = "cp " .. north_america.GameRoot .. "/" .. north_america.Version .. ".sigs " .. north_america.targetDir .. "/" .. north_america.Version .. ".sigs";
  os.execute(cmd);
  cmd = "cp " .. north_america.GameRoot .. "/diskend.sigs " .. north_america.targetDir .. "/" .. north_america.Version .. "_diskend.sigs";
  os.execute(cmd);
  cmd = "cp " .. north_america.GameRoot .. "/pc4.sigs " .. north_america.targetDir .. "/" .. north_america.PC4SigsName;
  os.execute(cmd);
  print(" -- Copy complete.");
end

function north_america.zipSource()
  -- collect the .sigs and .bin files
  north_america.copySigs();

  workDir = north_america.getWorkingFolder();
  os.execute("cd " .. north_america.GameRoot);

  -- make clean
  print(" -- " .. north_america.GameRoot .. ": Cleaning source files...");
  os.execute("sudo make -s -C " .. north_america.GameRoot .. " -f Makefile clean");
  print(" -- Sources clean.");

  print(" -- removing archive artifacts...");
  os.execute("sudo rm -rf " .. north_america.GameRoot .. "/sources/.svn");
  os.execute("sudo rm -rf " .. north_america.Source .. "/.svn");

  targetFile = north_america.targetSourceFolder .. north_america.Version .. "_source.tar.gz";
  print(" -- Begin zipping source to:");
  print(" --- " .. targetFile);
  -- run gzip on sourceDir
  tarCmd = "cd /home/sgp1000/build/images/games/; sudo tar --format=gnu -czf " .. targetFile .. " " .. north_america.Version;
  --sprintf(tarCmd, "sudo tar cvzf \"%s%s_source.tar.gz\" /home/sgp1000/build/images/games/%s/*", &targetDir, &build, &build);
  os.execute(tarCmd);

  os.execute("cd " .. workDir);
  print(" -- Source archive complete.");
  return true;
end

function north_america.getWorkingFolder()
  return os.getenv("PWD");
end

function north_america.createInfoFile(fileName)
  print(" -- Creating signature file " .. fileName .. "....");
  cmd = "cp /dev/null " .. fileName;
  os.execute(cmd);
  return file_exists(fileName);
end

function north_america.abort(reason, code)
  cmd = "rm -rf " .. north_america.targetDir;
  os.execute(cmd);
  print(reason);
  os.exit(code, true);
end

return north_america;