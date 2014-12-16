-- Language: Lua

new_york = {};

function new_york.createDocPacket(buildVersion, sourceFolder, gameName, partNum, platform)
  print(" -- new_york.createDocPacket() called");
  new_york.Name = gameName;
  new_york.Version = buildVersion;
  new_york.Source = "/home/sgp1000/build/images/games/" .. new_york.Version .. "/sources/" .. sourceFolder;
  new_york.PartNum = partNum;
  new_york.GameRoot = "/home/sgp1000/build/images/games/" .. new_york.Version;
  new_york.Platform = platform;
  new_york.PC4SigsName = new_york.Version .. "_" .. new_york.Platform .. "_pc4.sigs";
  print(" -- Name     : " .. new_york.Name);
  print(" -- Version  : " .. new_york.Version);
  print(" -- Source   : " .. new_york.Source);
  print(" -- PartNum  : " .. new_york.PartNum);
  print(" -- Platform : " .. new_york.Platform);

  -- set up the package marshaling folders
  new_york.createPacketTreeBase();

  -- Target folders
  new_york.createTargetTree();

  -- Source folders
  new_york.setupSourceFolders();

  -- begin copying documentation
  new_york.copySource();

  -- The text file for signatures.
  new_york.sigTxtFile = new_york.targetDir .. new_york.Version .. ".txt";
  new_york.createInfoFile(new_york.sigTxtFile);

  -- The revision document.  This should be in <game>/documents and should be
  -- copied to the root target folder
  -- set up source specs folder
  new_york.docRevisions = new_york.Source .. "/documents/revision.txt";

  if file_exists(new_york.docRevisions) == true then
    new_york.copyFile(new_york.docRevisions, new_york.targetDir);
  else
    new_york.docRevisions = new_york.Source .. "/documents/Revision.txt";

    if file_exists(new_york.docRevisions) == true then
      new_york.copyFile(new_york.docRevisions, new_york.targetDir);
    end
  end

  new_york.zipXLDF()
  
  new_york.zipSource();

  print(" -- Document packet complete.");
  return true;
end

function new_york.file_exists(name)
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

function new_york.copyDir(sourceDir, targetDir, filter, recurse)
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
    source = string.gsub(sourceDir, "()//()", "/");
    target = string.gsub(sourceDir, "()//()", "/");
    if recurse == true then
        if filter ~= nil and filter ~= "" then
              cmd = "cp -r " .. source .. "/".. filter .. " " .. target;
        else
              cmd = "cp -r " .. source .. "/ " .. target;
        end
    else
        if filter ~= nil and filter ~= "" then
              cmd = "cp " .. source .. "/".. filter .. " " .. target;
        else
              cmd = "cp " .. source .. "/ " .. target;
        end
    end
    os.execute(cmd);
end

function new_york.copyFile(source, target)
    cmd = "cp " .. source .. " " .. target;
    os.execute(cmd);
    return 1;
end

function new_york.getGameImage()
    imageSrcPath = "/home/sgp1000/ReleaseImages/" .. new_york.Version .. ".img.gz";
    
    imageDestPath = new_york.targetDir .. "/Software/\"Game Image/" .. new_york.Version .. ".img.gz\"";

    if new_york.copyFile(imageSrcPath, imageDestPath) ~= 1 then
        return false;
    end

    return true;
end

function new_york.packCurrentRevision(Version)
  --char& workingFolder, char& version
  print(" -- Beginning source archive creation...");
  
  workingFolder = new_york.getWorkingFolder();
  prepCmd = "sudo cp " .. workingFolder .. "/*.gz ../*";
  os.execute(prepCmd);
  clearCmd = "sudo rm " .. workingFolder .. "/*.gz";
  os.execute(clearCmd);
  tarCmd = "sudo tar cvzf \"".. workingFolder .. "../" .. Version .. "_source.tar.gz\" " .. workingFolder .. "/*";
  os.execute(tarCmd);
  restoreCmd = "sudo cp " .. workingFolder .. "../*.gz " .. workingFolder;
  os.execute(restoreCmd);
  
  print(" -- Source archive " .. Version .. "_source.tar.gz created.");
  return true;
end

function new_york.createTargetTree()
  -- Target folders
  -- set up target documentation folder
  print(" -- Creating target document folders....");

  new_york.targetDocRoot = new_york.targetDir .. "/Documentation/";
  os.execute("mkdir " .. new_york.targetDocRoot);
  --if file_exists(new_york.targetDocRoot) ~= true then
      --return false;
  --end

  -- set up target documentation/art folder
  new_york.targetArtRoot = new_york.targetDocRoot .. "Artwork/";
  os.execute("mkdir " .. new_york.targetArtRoot);

  -- set up target documentation/art/help folder
  new_york.targetArtHelp = new_york.targetArtRoot .. "\"Help Screen/\"";
  os.execute("mkdir " .. new_york.targetArtHelp);

  -- set up target documentation/art/panel folder
  new_york.targetArtPanel = new_york.targetArtRoot .. "Panel/";
  os.execute("mkdir " .. new_york.targetArtPanel);

  -- set up target documentation/art/topbox folder
  new_york.targetArtTopbox = new_york.targetArtRoot .. "Topbox/";
  os.execute("mkdir " .. new_york.targetArtTopbox);

  -- set up target documentation/art/panel/digits folder
  new_york.targetArtDigits = new_york.targetArtRoot .. "Topbox/Digits";
  os.execute("mkdir " .. new_york.targetArtDigits);

  -- set up target documentation/art/panel/videos folder
  new_york.targetArtVideo = new_york.targetArtRoot .. "Topbox/Videos";
  os.execute("mkdir " .. new_york.targetArtVideo);

  -- set up target documentation/calculations folder
  new_york.targetCalcFolder = new_york.targetDocRoot .. "\"Game Calcs/\"";
  os.execute("mkdir " .. new_york.targetCalcFolder);

  -- set up target documentation/specifications folder
  new_york.targetSpecFolder = new_york.targetDocRoot .. "\"Game Specs/\"";
  os.execute("mkdir " .. new_york.targetSpecFolder);

  -- set up target documentation/submission documents folder
  new_york.targetSubDocsFolder = new_york.targetDocRoot .. "\"Submission Documents/\"";
  os.execute("mkdir " .. new_york.targetSubDocsFolder);

  -- set up target documentation/submission documents/game play package folder
  new_york.targetGameplayFolder = new_york.targetSubDocsFolder .. "\"Game Play Package/\"";
  os.execute("mkdir " .. new_york.targetGameplayFolder);

  -- set up target documentation/submission documents/ny par sheet folder
  new_york.targetParSheetFolder = new_york.targetSubDocsFolder .. "\"NY Par Sheet/\"";
  os.execute("mkdir " .. new_york.targetParSheetFolder);

  -- set up target documentation/submission documents/NYS Software Form folder
  --new_york.targetSoftwareFormFolder = new_york.targetSubDocsFolder .. "\"NYS Software Form/\"";
  --os.execute("mkdir " .. new_york.targetSoftwareFormFolder);

  -- set up target documentation/submission documents/VGM Form folder
  --new_york.targetVGMFormFolder = new_york.targetSubDocsFolder .. "\"VGM Form/\"";
  --os.execute("mkdir " .. new_york.targetVGMFormFolder);

  -- set up target software folder
  new_york.targetSoftwareFolder = new_york.targetDir .. "/Software/";
  os.execute("mkdir " .. new_york.targetSoftwareFolder);

  -- set up target game image folder
  new_york.targetImageFolder = new_york.targetSoftwareFolder .. "\"/Game Image/\"";
  os.execute("mkdir " .. new_york.targetImageFolder);

  -- set up target game labels folder
  new_york.targetLabelsFolder = new_york.targetSoftwareFolder .. "\"/Game Labels/\"";
  os.execute("mkdir " .. new_york.targetLabelsFolder);
  
  -- set up target game source folder
  new_york.targetSourceFolder = new_york.targetSoftwareFolder .. "\"/Game Source Code/\"";
  os.execute("mkdir " .. new_york.targetSourceFolder);
  
  -- set up target game video folder
  new_york.targetVideoFolder = new_york.targetSoftwareFolder .. "\"/Game Video/\"";
  os.execute("mkdir " .. new_york.targetVideoFolder);
  
  -- set up target game XADF folder
  new_york.targetXADFFolder = new_york.targetSoftwareFolder .. "\"/XADF & BIN Files/\"";
  os.execute("mkdir " .. new_york.targetXADFFolder);
  
  -- set up target game XLDF folder
  new_york.targetXLDFFolder = new_york.targetSoftwareFolder .. "\"/XLDF Files/\"";
  os.execute("mkdir " .. new_york.targetXLDFFolder);
  
  print(" -- Target document folders ready.");
  return true;
end

function new_york.createPacketTreeBase()
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
  if file_exists("/home/sgp1000/Release/EGM/PC4/NewYork") ~= true then
    os.execute("mkdir /home/sgp1000/Release/EGM/PC4/NewYork");
  end
  new_york.targetDir = "\"/home/sgp1000/Release/EGM/PC4/NewYork/" .. new_york.Name .. " " .. new_york.Version .. " " .. new_york.PartNum .. "/\"";
  print(" -- Cleaning " .. new_york.targetDir);
  os.execute("sudo rm -rf " .. new_york.targetDir);
  -- Target folders
  os.execute("mkdir " .. new_york.targetDir);

  print(" -- Target document folders root ready.");
  return file_exists(new_york.targetDir);
end

function new_york.setupSourceFolders()
  -- set up source game document root folder
  print(" -- Locating source folders....");
  if file_exists(new_york.Source) ~= true then
    new_york.abort(" -- " .. new_york.Name .. " source folder does not exist.  Exiting.", 99);
  end
  new_york.docRoot = new_york.Source .. "/documents/";

  -- set up source calcs folder
  new_york.docSrcCalcs = new_york.docRoot .. "calcs";
  if file_exists(new_york.docSrcCalcs) ~= true then
    new_york.docSrcCalcs = new_york.docRoot .. "Calcs";
    if file_exists(new_york.docSrcCalcs) ~= true then
      new_york.abort(" -- Source calculations folder does not exist.  Exiting.", 99);
    end
  end
  new_york.docSrcCalcs = new_york.docSrcCalcs .. "/";

  -- set up source misc folder
  new_york.docSrcMisc = new_york.docRoot .. "misc";
  if file_exists(new_york.docSrcMisc) ~= true then
    new_york.docSrcMisc = new_york.docRoot .. "Misc";
    if file_exists(new_york.docSrcMisc) ~= true then
      new_york.abort(" -- Source misc folder does not exist.  Exiting.", 99);
    end
  end
  new_york.docSrcMisc = new_york.docSrcMisc .. "/";

  -- set up source specs folder
  new_york.docSrcSpecs = new_york.docRoot .. "specs";
  if file_exists(new_york.docSrcSpecs) ~= true then
    new_york.docSrcSpecs = new_york.docRoot .. "Specs";
    if file_exists(new_york.docSrcSpecs) ~= true then
      print(" -- Warning: Source specifications folder does not exist.");
    end
  end
  new_york.docSrcSpecs = new_york.docSrcSpecs .. "/";
  
  -- set up source help screen image folder
  new_york.helpScreenFolder = new_york.Source .. "/resource_widescreen/help/english";
  if file_exists(new_york.helpScreenFolder) ~= true then
    -- in case the help/english folder is not there
    new_york.helpScreenFolder = new_york.Source .. "/resource_widescreen/help";
    if file_exists(new_york.helpScreenFolder) ~= true then
      new_york.abort(" -- Source help images folder does not exist.  Exiting.", 99);
    end
  end
  new_york.helpScreenFolder = new_york.helpScreenFolder .. "/";

  -- topbox images
  new_york.topboxFolder = new_york.Source .. "/topbox/resource/";
  if file_exists(new_york.topboxFolder) ~= true then
    -- in case the help/english folder is not there
    new_york.topboxFolder = new_york.Source .. "/topbox_widescreen/resource/";
    if file_exists(new_york.topboxFolder) ~= true then
      new_york.abort(" -- Source topbox images folder does not exist.  Exiting.", 99);
    end
  end

  -- xldf files
  new_york.xldfFolder = new_york.Source .. "/xldf/";
  if file_exists(new_york.xldfFolder) ~= true then
    new_york.abort(" -- Source xldf folder does not exist.  Exiting.", 99);
  end

  -- set up source game images root folder
  new_york.imgRoot = "/home/sgp1000/build/images/";

  -- set up source game images root folder
  new_york.gameImgRoot = new_york.imgRoot .. "games/" .. new_york.Version .. "/" .. new_york.Version .. ".img.gz";

  -- set up source platform images root folder
  new_york.platformImgName = new_york.gameImgRoot .. "P4.disk.img.gz";
end

function new_york.copySource()
  print(" -- Beginning document copy....");
  if Revised == true then
    new_york.packCurrentRevision();
  end

  if new_york.getGameImage() ~= true then
    new_york.abort("Game image is not available.", 13);
  end
  
  filter = "*rule*";
  new_york.copyDir(new_york.helpScreenFolder, new_york.targetArtHelp, filter, true);

  filter = "*feature*";
  new_york.copyDir(new_york.helpScreenFolder, new_york.targetArtHelp, filter, true);

  filter = "*.png";
  new_york.copyDir(new_york.topboxFolder, new_york.targetArtTopbox, filter, true);

  filter = "*.avi";
  new_york.copyDir(new_york.topboxFolder, new_york.targetArtTopbox .. "/videos/", filter, true);

  -- Game specs
  filter = "*pecs*.doc";
  new_york.copyDir(new_york.docSrcSpecs, new_york.targetSpecFolder, filter);

  -- Or maybe this is the game specs file...
  filter = "*detail*.doc";
  new_york.copyDir(new_york.docSrcSpecs, new_york.targetSpecFolder, filter);

  -- Calcs, should recurse but keep an eye on it....
  filter = "*.xl*";
  new_york.copyDir(new_york.docSrcCalcs, new_york.targetCalcFolder, filter, true);

  -- Par sheet
  filter = "*.pdf";
  new_york.copyDir(new_york.docSrcMisc, new_york.targetParSheetFolder, filter, true);
  print(" -- Document copy complete.");
end

function new_york.copySigs()
  print(" -- Copying .bin and .sigs files....");
  cmd = "cp " .. new_york.GameRoot .. "/" .. new_york.Version .. ".sigs " .. new_york.targetXADFFolder .. "/" .. new_york.Version .. ".sigs";
  os.execute(cmd);
  cmd = "cp " .. new_york.GameRoot .. "/diskend.sigs " .. new_york.targetXADFFolder .. "/" .. new_york.Version .. "_diskend.sigs";
  os.execute(cmd);
  cmd = "cp " .. new_york.GameRoot .. "/pc4.sigs " .. new_york.targetXADFFolder .. "/" .. new_york.PC4SigsName;
  os.execute(cmd);
  cmd = "cp " .. new_york.GameRoot .. "/pc4hmac.bin " .. new_york.targetXADFFolder .. "/" .. new_york.Version .. "_pc4hmac.bin";
  os.execute(cmd);
  cmd = "cp " .. new_york.GameRoot .. "/sha1.bin " .. new_york.targetXADFFolder .. "/" .. new_york.Version .. "_sha1.bin";
  os.execute(cmd);
  cmd = "cp " .. new_york.GameRoot .. "/table.bin " .. new_york.targetXADFFolder .. "/" .. new_york.Version .. "_table.bin";
  os.execute(cmd);
  print(" -- Copy complete.");
end

function new_york.zipXLDF()
  workDir = new_york.getWorkingFolder();
  os.execute("cd " .. new_york.GameRoot);

  targetFile = new_york.targetXLDFFolder .. "/" .. new_york.Version .. "_XLDF.tar.gz";
  print(" -- Begin zipping XLDF files to:");
  print(" --- " .. targetFile);
  -- run gzip on sourceDir
  tarCmd = "cd " .. new_york.Source .. "; sudo tar --format=gnu -czf " .. targetFile .. " xldf/*";
  --sprintf(tarCmd, "sudo tar cvzf \"%s%s_source.tar.gz\" /home/sgp1000/build/images/games/%s/*", &targetDir, &build, &build);
  os.execute(tarCmd);

  os.execute("cd " .. workDir);
  print(" -- XLDF archive complete.");
  return true;
end

function new_york.zipSource()
  -- collect the .sigs and .bin files
  new_york.copySigs();

  workDir = new_york.getWorkingFolder();
  os.execute("cd " .. new_york.GameRoot);

  -- make clean
  print(" -- " .. new_york.GameRoot .. ": Cleaning source files...");
  os.execute("sudo make -s -C " .. new_york.GameRoot .. " -f Makefile clean");
  print(" -- Sources clean.");

  print(" -- removing archive artifacts...");
  os.execute("sudo rm -rf " .. new_york.GameRoot .. "/sources/.svn");
  os.execute("sudo rm -rf " .. new_york.Source .. "/.svn");

  targetFile = new_york.targetSourceFolder .. new_york.Version .. "_source.tar.gz";
  print(" -- Begin zipping source to:");
  print(" --- " .. targetFile);
  -- run gzip on sourceDir
  tarCmd = "cd /home/sgp1000/build/images/games/; sudo tar --format=gnu -czf " .. targetFile .. " " .. new_york.Version;
  --sprintf(tarCmd, "sudo tar cvzf \"%s%s_source.tar.gz\" /home/sgp1000/build/images/games/%s/*", &targetDir, &build, &build);
  os.execute(tarCmd);

  os.execute("cd " .. workDir);
  print(" -- Source archive complete.");
  return true;
end

function new_york.getWorkingFolder()
  return os.getenv("PWD");
end

function new_york.createInfoFile(fileName)
  print(" -- Creating signature file " .. fileName .. "....");
  cmd = "cp /dev/null " .. fileName;
  os.execute(cmd);
  return file_exists(fileName);
end

function new_york.abort(reason, code)
  cmd = "rm -rf " .. new_york.targetDir;
  os.execute(cmd);
  print(reason);
  os.exit(code, true);
end

return new_york;