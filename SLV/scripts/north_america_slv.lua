-- Language: Lua

north_america_slv = {};

function north_america_slv.createDocPacket(buildVersion, sourceFolder, gameName, partNum, platform, slv, svnSource)
    print(" -- north_america_slv.createDocPacket() called");
	local ver = north_america_slv.cleanSpaces(buildVersion);
	local src = north_america_slv.cleanSpaces(sourceFolder);
	local game = north_america_slv.cleanSpaces(gameName);
	local part = north_america_slv.cleanSpaces(partNum);
	local plat = north_america_slv.cleanSpaces(platform);
	north_america_slv.Name = game;
    north_america_slv.Version = ver;
    north_america_slv.Platform = platform;
    north_america_slv.PartNum = partNum;
    -- This is the location of the game source code
    north_america_slv.Source = "/home/sgp1000/build/images/platform/P5/" .. platform .. "/games/egm/" .. buildVersion .. "/" .. sourceFolder;
    -- This is the location of the game disk image
    north_america_slv.GameRoot = "/home/sgp1000/build/images/platform/P5/".. platform .. "/games/egm/" .. buildVersion;
    north_america_slv.PC5SigsName20 = buildVersion .. "_" .. platform .. "_pc5_SBAL2004.catbin";
    north_america_slv.PC5SigsName21 = buildVersion .. "_" .. platform .. "_pc5_SBAL2105.catbin";
    north_america_slv.SVNSourcePath = svnSource;
    print(" -- Name     : " .. north_america_slv.Name);
    print(" -- Version  : " .. north_america_slv.Version);
    print(" -- Source   : " .. north_america_slv.Source);
    print(" -- PartNum  : " .. north_america_slv.PartNum);
    print(" -- Platform : " .. north_america_slv.Platform);
    print(" -- SVN path : " .. north_america_slv.SVNSourcePath);

    -- set up the package marshaling folders
    north_america_slv.createPacketTreeBase()

    north_america_slv.createTargetTree();

    -- Source folders
    north_america_slv.setupSourceFolders();

    -- begin copying documentation
    north_america_slv.copySource();

    north_america_slv.copySupportScripts();

    print(" -- Document packet complete.");
    return true;
end

function north_america_slv.cleanSpaces(input)
	return string.gsub(input, " ", "_");
end

function north_america_slv.copyDir(sourceDir, targetDir, filter, recurse)
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

function north_america_slv.file_exists(name)
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

function north_america_slv.directory_exists( sPath )
  if type( sPath ) ~= "string" then return false end

  local response = os.execute( "cd " .. sPath )
  if response == 0 or response == true then
    return true
  end
  return false
end

function north_america_slv.getGameImage()
    --char& gameVersion, char& documentDir
    imageSrcPath = "/home/sgp1000/ReleaseImages/" .. north_america_slv.Version .. "-namerica_deploy.img.gz";
    
    imageDestPath = north_america_slv.targetDir .. "images/" .. north_america_slv.Version .. "-namerica_deploy.img.gz\"";

    if north_america_slv.copyFile(imageSrcPath, imageDestPath) ~= 1 then
        return false;
    end

    return true;
end

function north_america_slv.copySupportScripts()
    print(" -- setting up source install scripts");
    os.execute("cp -r /home/sgp1000/EGMTools/SLVBuildInstaller/Game/*" .. north_america_slv.targetDir .. "/install/");
    print(" -- source install scripts complete");
end

function north_america_slv.packCurrentRevision(Version)
    --char& workingFolder, char& version
  print(" -- Beginning source archive creation...");
  
  workingFolder = north_america_slv.getWorkingFolder();
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

function north_america_slv.createTargetTree()
  -- Target folders
  -- set up target documentation folder
  print(" -- Creating target document folders....");

  north_america_slv.targetDocRoot = north_america_slv.targetDir .. "/docs/";
  os.execute("mkdir " .. north_america_slv.targetDocRoot);

  -- set up target documentation/art folder
  north_america_slv.targetArtRoot = north_america_slv.targetDocRoot .. "Artwork/";
  os.execute("mkdir " .. north_america_slv.targetArtRoot);

  -- set up target documentation/art/help folder
  north_america_slv.targetArtHelp = north_america_slv.targetArtRoot .. "Help_Screen/";
  os.execute("mkdir " .. north_america_slv.targetArtHelp);

  -- set up target documentation/art/panel folder
  north_america_slv.targetArtPanel = north_america_slv.targetArtRoot .. "Topper/";
  os.execute("mkdir " .. north_america_slv.targetArtPanel);

  -- set up target documentation/art/topbox folder
  north_america_slv.targetArtTopbox = north_america_slv.targetArtRoot .. "Topbox/";
  os.execute("mkdir " .. north_america_slv.targetArtTopbox);

  -- set up target documentation/calculations folder
  north_america_slv.targetCalcFolder = north_america_slv.targetDocRoot .. "Calculations/";
  os.execute("mkdir " .. north_america_slv.targetCalcFolder);

  -- set up target documentation/build_logs folder
  north_america_slv.targetLogsFolder = north_america_slv.targetDocRoot .. "build_logs/";
  os.execute("mkdir " .. north_america_slv.targetLogsFolder);

  -- set up target documentation/profile folder
  -- north_america_slv.targetProfileFolder = north_america_slv.targetDir .. "\"Par Sheets/\"";
  -- os.execute("mkdir " .. north_america_slv.targetProfileFolder);

  -- set up target documentation/specifications folder
  north_america_slv.targetSpecFolder = north_america_slv.targetDocRoot .. "Game_Specification/";
  os.execute("mkdir " .. north_america_slv.targetSpecFolder);

  -- set up target game image tarball folder
  north_america_slv.targetGameFolder = north_america_slv.targetDir .. "/images/";
  os.execute("mkdir " .. north_america_slv.targetGameFolder);

  -- set up target game source tarball folder
  north_america_slv.targetSourceFolder = north_america_slv.targetDir .. "/install/tgz";
  os.execute("mkdir -p " .. north_america_slv.targetSourceFolder);
  
  print(" -- Target document folders ready.");
  return true;
end

function north_america_slv.createPacketTreeBase()
	print(" -- Creating target document root....");

	if north_america_slv.directory_exists("/home/sgp1000/Release/EGM/SLV/NorthAmerica") ~= true then
		os.execute("mkdir -p /home/sgp1000/Release/EGM/SLV/NorthAmerica");
	end

	north_america_slv.targetDir = "/home/sgp1000/Release/EGM/SLV/NorthAmerica/" .. north_america_slv.Name .. "_" .. north_america_slv.Version .. "_" .. north_america_slv.PartNum .. "/";

	print(" -- Cleaning " .. north_america_slv.targetDir);

	os.execute("sudo rm -rf " .. north_america_slv.targetDir);

	-- Target folders
	os.execute("mkdir " .. north_america_slv.targetDir);

	print(" -- Target document folders root ready.");
	return file_exists(north_america_slv.targetDir);
end

function north_america_slv.syncFolder(source, target)
    cmd = "rsync -r " .. source .. "/ " .. target;
    print(" -- " .. cmd);
    os.execute(cmd);
end

function north_america_slv.copyFile(source, target)
    cmd = "cp " .. source .. " " .. target;
    os.execute(cmd);
    return 1;
end

function north_america_slv.setupSourceFolders()
	-- set up source game document root folder
	print(" -- Locating source folders....");
	if directory_exists(north_america_slv.Source) ~= true then
		north_america_slv.abort(" -- " .. north_america_slv.Name .. " source folder does not exist.  Exiting.", 99);
	end

	north_america_slv.docRoot = north_america_slv.Source .. "/documents/";

	-- set up source calcs folder
	north_america_slv.docSrcCalcs = north_america_slv.docRoot .. "calcs";
	if directory_exists(north_america_slv.docSrcCalcs) ~= true then
		north_america_slv.docSrcCalcs = north_america_slv.docRoot .. "Calcs";
		if directory_exists(north_america_slv.docSrcCalcs) ~= true then
			north_america_slv.abort(" -- Source calculations folder does not exist.  Exiting.", 99);
		end
	end

	-- set up source misc folder
	north_america_slv.docSrcMisc = north_america_slv.docRoot .. "misc";
	if directory_exists(north_america_slv.docSrcMisc) ~= true then
		north_america_slv.docSrcMisc = north_america_slv.docRoot .. "Misc";
		if directory_exists(north_america_slv.docSrcMisc) ~= true then
			north_america_slv.abort(" -- Source misc folder does not exist.  Exiting.", 99);
		end
	end

	-- set up source specs folder
	north_america_slv.docSrcSpecs = north_america_slv.docRoot .. "specs";
	if directory_exists(north_america_slv.docSrcSpecs) ~= true then
		north_america_slv.docSrcSpecs = north_america_slv.docRoot .. "Specs";
		if directory_exists(north_america_slv.docSrcSpecs) ~= true then
			north_america_slv.abort(" -- Source specification folder does not exist.  Exiting.", 99);
		end
	end

	-- set up source pars folder
	north_america_slv.docSrcPars = north_america_slv.docRoot .. "pars";
	if directory_exists(north_america_slv.docSrcPars) ~= true then
		north_america_slv.docSrcPars = north_america_slv.docRoot .. "Pars";
		if directory_exists(north_america_slv.docSrcPars) ~= true then
			north_america_slv.noPars = true;
			print(" -- Source par sheet folder does not exist.");
		end
	end

	-- set up source help screen image folder
	north_america_slv.helpScreenFolder = north_america_slv.Source .. "/resource_widescreen/help/english";
	if directory_exists(north_america_slv.helpScreenFolder) ~= true then
		-- in case the help/english folder is not there
		north_america_slv.helpScreenFolder = north_america_slv.Source .. "/resource_widescreen/help";
		if directory_exists(north_america_slv.helpScreenFolder) ~= true then
			north_america_slv.abort(" -- Source help images folder does not exist.  Exiting.", 99);
		end
	end

	-- topbox images
	north_america_slv.topboxFolder = north_america_slv.Source .. "/topbox/resource/";
	if directory_exists(north_america_slv.topboxFolder) ~= true then
		-- in case the help/english folder is not there
		north_america_slv.topboxFolder = north_america_slv.Source .. "/topbox_widescreen/resource/";
		if directory_exists(north_america_slv.topboxFolder) ~= true then
			north_america_slv.abort(" -- Source topbox images folder does not exist.  Exiting.", 99);
		end
	end

	-- set up source game images root folder
	north_america_slv.imgRoot = "/home/sgp1000/build/images/platform/P5/" .. north_america_slv.Platform .. "/images/namerica_debug/";

	-- set up source game images root folder
	north_america_slv.gameImgRoot = north_america_slv.imgRoot .. "/" .. north_america_slv.Version .. "-namerica_deploy.img.gz";

	-- set up source platform images root folder
	north_america_slv.platformImgName = "/home/sgp1000/build/pc5.disk.img.gz";
end

function north_america_slv.copySource()
	print(" -- Beginning document copy....");
	if Revised == true then
		north_america_slv.packCurrentRevision();
	end

	-- Game par sheets
	if north_america_slv.noPars ~= true then
		filter = "*.pdf";
		north_america_slv.copyDir(north_america_slv.docSrcPars, north_america_slv.targetProfileFolder, filter);
		-- remove pars from the source folder after copy so that they're not included
		-- in the zipped source archive
		os.execute("sudo rm -rf " .. north_america_slv.docSrcPars);
	end
    -- collect the .sigs and .bin files
    north_america_slv.copySigs();

	-- create game source tarball
	north_america_slv.zipSource();

	-- copy game image
	if north_america_slv.getGameImage() ~= true then
		north_america_slv.abort("Game image is not available.", 13);
	end

	-- copy help screens and symbols
	filter = "*rule*";
	north_america_slv.copyDir(north_america_slv.helpScreenFolder, north_america_slv.targetArtHelp, filter, true);

	filter = "*feature*";
	north_america_slv.copyDir(north_america_slv.helpScreenFolder, north_america_slv.targetArtHelp, filter, true);

	filter = "*symbol*";
	north_america_slv.copyDir(north_america_slv.helpScreenFolder, north_america_slv.targetArtHelp, filter, true);

	-- copy top box art
	filter = "*.png";
	north_america_slv.copyDir(north_america_slv.topboxFolder, north_america_slv.targetArtTopbox, filter, true);

	filter = "*.avi";
	north_america_slv.copyDir(north_america_slv.topboxFolder, north_america_slv.targetArtTopbox, filter, true);

	-- Game specs
	filter = "*pecs*.doc*";
	north_america_slv.copyDir(north_america_slv.docSrcSpecs, north_america_slv.targetSpecFolder, filter);

	-- build logs
	filter = "*.build.txt";
	local logDir = "/home/sgp1000/ProductionBuildLogs/" .. north_america_slv.Version .. "/";
	local logName = "/" .. north_america_slv.Version .. ".make.txt";
	north_america_slv.copyDir(logDir, north_america_slv.targetLogsFolder .. logName, filter);

	-- Or maybe this is the game specs file...
	filter = "*detail*.doc*";
	north_america_slv.copyDir(north_america_slv.docSrcSpecs, north_america_slv.targetSpecFolder, filter);

	-- Calcs, should recurse but keep an eye on it....
	filter = "*.xl*";
	north_america_slv.syncFolder(north_america_slv.docSrcCalcs, north_america_slv.targetCalcFolder);

	-- The text file for signatures.
	north_america_slv.sigTxtFile = north_america_slv.targetDir .. north_america_slv.Version .. ".txt";
	north_america_slv.createInfoFile(north_america_slv.sigTxtFile);

	-- The revision document.  This should be in <game>/documents
	north_america_slv.docRevisions = north_america_slv.Source .. "/documents/revision.txt";

	if file_exists(north_america_slv.docRevisions) == true then
		north_america_slv.copyFile(north_america_slv.docRevisions, north_america_slv.targetDocRoot);
	end
end

function north_america_slv.copySigs()
	print(" -- Copying .sigs files....");
	cmd = "cp /home/sgp1000/build/pc5_SBAL2004.sigs " .. north_america_slv.targetDir .. "/" .. north_america_slv.PC5SigsName20;
	os.execute(cmd);
	cmd = "cp /home/sgp1000/build/pc5_SBAL2105.sigs " .. north_america_slv.targetDir .. "/" .. north_america_slv.PC5SigsName21;
	os.execute(cmd);
	print(" -- Copy complete.");
end

function north_america_slv.zipSource()
    -- check out clean copy
	print(" -- Performing clean source checkout...");
    os.execute("svn co http://egm-dev.ad.agi/svn/EGMGameSoftware/SLV/" .. north_america_slv.SVNSourcePath .. " " .. north_america_slv.Version);
    print(" -- Source checkout complete.");

    print(" -- removing archive artifacts...");
    os.execute("sudo rm -rf " .. north_america_slv.GameRoot .. "/.svn");
    os.execute("sudo rm -rf " .. north_america_slv.Version .. "/.svn");

    targetFile = north_america_slv.targetSourceFolder .. "build." .. north_america_slv.Version .. ".tgz";
    print(" -- Begin zipping source to:");
    print(" --- " .. targetFile);
    -- run gzip on sourceDir
    -- $5 - platform
    -- $1 - version
    -- /home/sgp1000/$5_Release/images/platform/P5/$5/games/egm/$1/images/namerica_deploy/$1-namerica_deploy.img.gz
    cdCmd = "cd /home/sgp1000";
    tarCmd = cdCmd .. "; sudo tar --format=gnu -czf " .. targetFile .. " " .. north_america_slv.Version;
    os.execute(tarCmd);
	print(" -- Source tarball created.");

	print(" -- Removing local copy of source...");
    os.execute("sudo rm -rf " .. north_america_slv.Version);
    print(" -- Source archive complete.");
    return true;
end

function north_america_slv.getWorkingFolder()
	return os.getenv("PWD");
end

function north_america_slv.createInfoFile(fileName)
	print(" -- Creating signature file " .. fileName .. "....");
	cmd = "cp /dev/null " .. fileName;
	os.execute(cmd);
	return file_exists(fileName);
end

function north_america_slv.abort(reason, code)
	cmd = "rm -rf " .. north_america_slv.targetDir;
	os.execute(cmd);
	print(reason);
	os.exit(code, true);
end

return north_america_slv;