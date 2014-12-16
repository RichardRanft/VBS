#!/bin/lua 

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function list_iter(t)
    local i = 0
    local n = tablelength(t)
    return function ()
        i = i + 1
        if i <= n then return t[i] end
    end
end

function evalCmdLine(cmdArg)
    local listArgs = {};
    if tablelength(cmdArg) < 6 then
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
        if tablelength(listArgs) > 8 then
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

function parseRevisionText(path, CurrVersion, PrevVersion)
    -- Open the revision text file and load it into a table.  Only load text blocks
    -- that pertain to the PrevVersion or later, up to the CurrVersion.
    textLines = {};
    if path == nil then 
        print(" -- parseRevisionText path argument is empty");
        return textLines;
    end
    if CurrVersion == nil then 
        print(" -- parseRevisionText CurrVersion argument is empty");
        return textLines;
    end
    if PrevVersion == nil then 
        print(" -- parseRevisionText PrevVersion argument is empty");
        return textLines;
    end
    filePath = path .. "/Documentation/revision.txt";
    infile = io.open(filePath, "r");
    if infile == nil then
        filePath = path .. "/Documentation/Revision.txt";
        infile = io.open(filePath, "r");
    end
    if infile == nil then
        filePath = path .. "/Documentation/revision";
        infile = io.open(filePath, "r");
    end
    if infile == nil then
        filePath = path .. "/Documentation/Revision";
        infile = io.open(filePath, "r");
    end
    i = 1;
    if infile ~= nil then
        --print(" -- opened " .. path);
        for line in infile:lines() do
            if line ~= nil then
                -- Parse for previous version.  If the line's stated previous version
                -- is not the same as the one we're looking for we can stop parsing.
                if string.find(line, "()Previous version: ()") ~= nil then
                    previous = string.gsub(line, "()Previous version: ()", "");
                    if compareOrdinal(previous, PrevVersion) >= 0 and previous ~= "N/A" then
                        return textLines;
                    end
                else
                    textLines[i] = line .. "\n";
                    i = i + 1;
                end
            end
        end
        print(" -- Parsed " .. filePath);
    else
        print(" -- No version of revision.txt found....");
    end

    return textLines;
end

function getGameHMAC(path, version)
    HMAC = "";
    if path == nil then 
        print(" -- getGameHMAC path argument is empty");
        return HMAC;
    end
    if version == nil then 
        print(" -- getGameHMAC version argument is empty");
        return HMAC;
    end
    path = path .. "/".. version .. ".txt";
    infile = io.open(path, "r");
    i = 1;
    if infile ~= nil then
        --print(" -- opened " .. path);
        for line in infile:lines() do
            if line ~= nil then
                if string.find(line, "()HMACsha1 with 0 key is: ()") ~= nil and line ~= lastLine then
                    HMAC = string.gsub(line, "()HMACsha1 with 0 key is: ()", "");
                end
            end
        end
    else
        print("File " .. path .. " does not exist...");
    end

    return HMAC;
end

function getGameSHA1(path, version)
    SHA1 = "";
    if path == nil then 
        print(" -- getGameSHA1 path argument is empty");
        return SHA1;
    end
    if version == nil then 
        print(" -- getGameSHA1 version argument is empty");
        return SHA1;
    end
    path = path .. "/".. version .. ".txt";
    infile = io.open(path, "r");
    i = 1;
    if infile ~= nil then
        --print(" -- opened " .. path);
        for line in infile:lines() do
            if line ~= nil then
                if string.find(line, "()sha1 generated: ()") ~= nil and line ~= lastLine then
                    SHA1 = string.gsub(line, "()sha1 generated: ()", "");
                end
            end
        end
    else
        print("File " .. path .. " does not exist...");
    end

    return SHA1;
end

function getGameSigs(path, version)
    HMAC = "";
    SHA1 = "";
    if path == nil then 
        print(" -- getGameSigs path argument is empty");
        return HMAC;
    end
    if version == nil then 
        print(" -- getGameSigs version argument is empty");
        return HMAC;
    end
    path = path .. "/".. version .. ".txt";
    infile = io.open(path, "r");
    i = 1;
    if infile ~= nil then
        --print(" -- opened " .. path);
        for line in infile:lines() do
            if line ~= nil then
                if string.find(line, "()HMACsha1 with 0 key is: ()") ~= nil and line ~= lastLine then
                    HMAC = string.gsub(line, "()HMACsha1 with 0 key is: ()", "");
                elseif string.find(line, "()sha1 generated: ()") ~= nil and line ~= lastLine then
                    SHA1 = string.gsub(line, "()sha1 generated: ()", "");
                end
            end
        end
    else
        print("File " .. path .. " does not exist...");
    end

    return HMAC, SHA1;
end

function createRevisionDoc(Path, Name, CurVersion, PrevVersion, Platform, SLV)
    -- find the revision.txt file and use it to create a revision doc that is
    -- compatible with a mod doc.
    -- for PC4 games, this is located in <version>/sources/<folder>/documentation
    -- Name     : north_america.Name
    -- Version  : north_america.Version
    -- Source   : north_america.Source
    -- PartNum  : north_america.PartNum
    -- Platform : north_america.Platform
    HMAC, SHA1 = getGameSigs(Path, CurVersion);
    --print(Path);
    --print(Name);
    --print(CurVersion);
    --print(PrevVersion);
    --print(Platform);
    --print(HMAC);
    --print(SHA1);
    --print(SLV);
    
    -- Set up document header.
    local revText = {};
    local NewLine = "\n";
    revText[1] =    "GAME: " .. Name .. NewLine .. NewLine;
    if SLV == nil then
        revText[2] =    "MACHINE: EGM Equinox" .. NewLine .. NewLine;
    else
        revText[2] =    "MACHINE: EGM V22/V32/Wave SL-V" .. NewLine .. NewLine;
    end
    revText[3] =    "CURRENT VERSION: " .. NewLine .. CurVersion .. NewLine .. NewLine;
    revText[4] =    "PREVIOUS VERSION: " .. NewLine .. PrevVersion .. NewLine .. NewLine;
    revText[5] =    "JURISDICTION: " .. NewLine .. "NGCB" .. NewLine .. NewLine;
    revText[6] =    "SOFTWARE COMPATIBILITY" .. NewLine;
    revText[7] =    "Kernel:   " .. Platform .. NewLine;
    if SLV == nil then
        revText[8] =    "BIOS:     SBGEN024" .. NewLine;
        revText[9] =    "RAMCLEAR: RCUSA06C" .. NewLine .. NewLine;
        revText[10] =   "HMACSHA1: " .. HMAC .. NewLine;
        revText[11] =   "SHA1    : " .. SHA1 .. NewLine .. NewLine;
        revText[12] =   "CHANGE OVERVIEW: " .. NewLine .. NewLine;
    else
        revText[8] =    "BIOS:     SBAL2004" .. NewLine;
        revText[9] =    "BIOS:     SBAL2105" .. NewLine;
        revText[10] =   "BIOS:     SBSLV003" .. NewLine;
        revText[11] =   "RAMCLEAR: A2INCL02" .. NewLine .. NewLine;
        revText[12] =   "HMACSHA1: " .. HMAC .. NewLine;
        revText[13] =   "SHA1    : " .. SHA1 .. NewLine .. NewLine;
        revText[14] =   "CHANGE OVERVIEW: " .. NewLine .. NewLine;
    end
    print(" -- Created header");
    -- Get and parse the revision.txt file
    inputLines = parseRevisionText(Path, CurVersion, PrevVersion);
    -- Wrap lines for moddoc
    wrappedTextLines = wrapText(inputLines);
    -- Add revision contents to header text
    print(" -- Wrapped revision lines");
    outputLines = prepareDocument(revText, wrappedTextLines);
    -- Write moddoc to text file
    print(" -- Mod document prepared - writing to file");
    outpath = Path .. "/Documentation";
    writeOutput(outpath, "moddoc", outputLines);
    print(" -- Mod document complete.");
end

function prepareDocument(headerList, bodyList)
    moddoc = {};
    i = 1;
    for element in list_iter(headerList) do
        moddoc[i] = element;
        i = i + 1;
    end
    for element in list_iter(bodyList) do
        moddoc[i] = element;
        i = i + 1;
    end
    
    return moddoc;
end

function writeOutput(path, outfileName, lineList)
    diffText = {};
    diffLine = 0;
    for curLine = 1, tablelength(lineList), 1 do
        diffLine = diffLine + 1;
        diffText[diffLine] = lineList[curLine];
    end
    filename = path .. "/" .. outfileName .. ".txt";
    
    outfile, openMsg = io.open(filename, "w");
    if outfile ~= nil then
        for element in list_iter(diffText) do
            outfile:write(element)
        end
        outfile:close();
    else
        print(" -- unable to open " .. filename .. " - " .. openMsg);
    end
end

function wrapText(textList)
    -- take a table of lines, break it into a table of words, then reassemble
    -- the table of words into a table of lines 70 or fewer characters in length.
    -- I took the lazy way out - I wrap trailing words but don't combine them with
    -- later lines.
    wrappedList = {};
    lineCount = 1;

    if textList == nil then
        return wrappedList;
    end
    for element in list_iter(textList) do
        print(element);
        string.gsub(element, "()\n()", "");
        if string.len(element) > 68 then
            print(" -- ");
            wordList = {};
            wordCount = 1;
            wordsInLine = 1;
            tempLine = "";
            for w in string.gmatch(element, "%S+") do
                wordList[wordCount] = w;
                wordCount = wordCount + 1;
                tempLen = string.len(tempLine);
                wordLen = string.len(w) + 1;
                if (tempLen + wordLen) <= 69 then
                    if tempLine == "" then
                        tempLine = tempLine .. w;
                    else
                        tempLine = tempLine .. " " .. w;
                    end
                    wordsInLine = wordsInLine + 1;
                end
            end
            wrappedList[lineCount] = tempLine .. "\n";
            lineCount = lineCount + 1;
            tempLine = "";
            while wordsInLine < wordCount do
                tempLen = string.len(tempLine);
                wordLen = string.len(wordList[wordsInLine]) + 1;
                if (tempLen + wordLen) <= 69 then
                    if tempLine == "" then
                        tempLine = tempLine .. wordList[wordsInLine];
                    else
                        tempLine = tempLine .. " " .. wordList[wordsInLine];
                    end
                    wordsInLine = wordsInLine + 1;
                end
            end
            wrappedList[lineCount] = tempLine .. "\n";
            lineCount = lineCount + 1;
        else
            wrappedList[lineCount] = element;
            lineCount = lineCount + 1;
        end
    end
    --for element in list_iter(wrappedList) do
        --print(element);
    --end
    
    return wrappedList;
end

function compareOrdinal(first, second)
    -- returns 0 if strings are the same, 
    -- -1 if first is ordinally less than second, or
    -- 1 if first is ordinally greater than second.
    index = 1;
    for w in string.gmatch(element, "%w") do
        fByteVal = string.byte(first,index);
        sByteVal = string.byte(second, index);
        if fByteVal < sByteVal then
            return -1;
        end
        if fByteVal > sByteVal then
            return 1;
        end
        index = index + 1;
    end
    return 0;
end

function usage()
    print("Usage: ./lua createModDoc.lua <release path> <game name> <current version> <previous version> <platform> (optional)<SLV>");
end

if evalCmdLine(arg) ~= nil then
    path = arg[1];
    name = arg[2];
    curr = arg[3];
    prev = arg[4];
    plat = arg[5];
    slv = arg[6];
    createRevisionDoc(path, name, curr, prev, plat, slv);
end
