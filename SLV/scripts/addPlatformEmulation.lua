#! /bin/lua
-- Language: Lua
-- script sources to be emitted directly to installation

RGC_SCRIPT_CONTENTS = {};
RGC_SCRIPT_CONTENTS[1] = "#! /bin/sh\n"
RGC_SCRIPT_CONTENTS[2] = "export PLATFORM_DIR=$PWD/../../\n"
RGC_SCRIPT_CONTENTS[3] = "export PLATFORM_SRC_DIR=$PLATFORM_DIR/platform/src\n"
RGC_SCRIPT_CONTENTS[4] = "\n"
RGC_SCRIPT_CONTENTS[5] = "export DEBUG=1\n"
RGC_SCRIPT_CONTENTS[6] = "export EGM_GAME=./egm_data.ini\n"
RGC_SCRIPT_CONTENTS[7] = "export EGM_DEF=./egm_def.ini\n"
RGC_SCRIPT_CONTENTS[8] = "export GTYPE_SCRIPT=./reel_data.ini\n"
RGC_SCRIPT_CONTENTS[9] = "export SDL_AUDIODRIVER=alsa\n"
RGC_SCRIPT_CONTENTS[10] = "export EGM_GAME_LIST=./egm_games.ini\n"
RGC_SCRIPT_CONTENTS[11] = "export EGM_OVER_DEF_DIR=$PWD\n"
RGC_SCRIPT_CONTENTS[12] = "export STARGAMES_LOCALE_PATH=$PWD/locale\n"
RGC_SCRIPT_CONTENTS[13] = "export LD_LIBRARY_PATH=$PWD:/usr/X11R6/lib64:/usr/X11R6/lib:$HOME/shufflemaster_packages/lib64:$PLATFORM_SRC_DIR/lib:$PWD/ats_lib:/usr/local/lib64\n"
RGC_SCRIPT_CONTENTS[14] = "export SCREEN_WIDTH=800\n"
RGC_SCRIPT_CONTENTS[15] = "export SCREEN_HEIGHT=600\n"
RGC_SCRIPT_CONTENTS[16] = "export SGPLOCALEDIR=$PWD/game/locale/\n"
RGC_SCRIPT_CONTENTS[17] = "export AUDIO_FREQUENCY=48000\n"
RGC_SCRIPT_CONTENTS[18] = "\n"
RGC_SCRIPT_CONTENTS[19] = "DEBUGGER=ddd\n"
RGC_SCRIPT_CONTENTS[20] = "VSYNC=0\n"
RGC_SCRIPT_CONTENTS[21] = "\n"
RGC_SCRIPT_CONTENTS[22] = "function usage()\n"
RGC_SCRIPT_CONTENTS[23] = "{\n"
RGC_SCRIPT_CONTENTS[24] = "    echo\n"
RGC_SCRIPT_CONTENTS[25] = "    echo \"USAGE:\"\n"
RGC_SCRIPT_CONTENTS[26] = "    echo \"    $0 [OPTIONS]\"\n"
RGC_SCRIPT_CONTENTS[27] = "    echo \"OPTIONS:\"\n"
RGC_SCRIPT_CONTENTS[28] = "    echo \"    -d/--debugger <debugger> : set debugger, default ddd\"\n"
RGC_SCRIPT_CONTENTS[29] = "    echo \"    -v/--vsync               : set sync on, default off\"\n"
RGC_SCRIPT_CONTENTS[30] = "    echo \"    -h/--help                : show this message\"\n"
RGC_SCRIPT_CONTENTS[31] = "    echo\n"
RGC_SCRIPT_CONTENTS[32] = "    exit 1\n"
RGC_SCRIPT_CONTENTS[33] = "}\n"
RGC_SCRIPT_CONTENTS[34] = "\n"
RGC_SCRIPT_CONTENTS[35] = "VSYNC=0\n"
RGC_SCRIPT_CONTENTS[36] = "while [ $# -gt 0 ]\n"
RGC_SCRIPT_CONTENTS[37] = "do\n"
RGC_SCRIPT_CONTENTS[38] = "    case \"$1\" in\n"
RGC_SCRIPT_CONTENTS[39] = "    \"-d\")\n"
RGC_SCRIPT_CONTENTS[40] = "        shift\n"
RGC_SCRIPT_CONTENTS[41] = "        if [ $# -gt 0 ]; then\n"
RGC_SCRIPT_CONTENTS[42] = "            DEBUGGER=$1\n"
RGC_SCRIPT_CONTENTS[43] = "        else\n"
RGC_SCRIPT_CONTENTS[44] = "            usage\n"
RGC_SCRIPT_CONTENTS[45] = "        fi\n"
RGC_SCRIPT_CONTENTS[46] = "        ;;\n"
RGC_SCRIPT_CONTENTS[47] = "    \"--debugger\")\n"
RGC_SCRIPT_CONTENTS[48] = "        shift\n"
RGC_SCRIPT_CONTENTS[49] = "        if [ $# -gt 0 ]; then\n"
RGC_SCRIPT_CONTENTS[50] = "            DEBUGGER=$1\n"
RGC_SCRIPT_CONTENTS[51] = "        else\n"
RGC_SCRIPT_CONTENTS[52] = "            usage\n"
RGC_SCRIPT_CONTENTS[53] = "        fi\n"
RGC_SCRIPT_CONTENTS[54] = "        ;;\n"
RGC_SCRIPT_CONTENTS[55] = "    \"-v\")\n"
RGC_SCRIPT_CONTENTS[56] = "        VSYNC=1\n"
RGC_SCRIPT_CONTENTS[57] = "        ;;\n"
RGC_SCRIPT_CONTENTS[58] = "    \"--vsync\")\n"
RGC_SCRIPT_CONTENTS[59] = "        VSYNC=1\n"
RGC_SCRIPT_CONTENTS[60] = "        ;;\n"
RGC_SCRIPT_CONTENTS[61] = "    *)\n"
RGC_SCRIPT_CONTENTS[62] = "        usage\n"
RGC_SCRIPT_CONTENTS[63] = "        ;;\n"
RGC_SCRIPT_CONTENTS[64] = "    esac\n"
RGC_SCRIPT_CONTENTS[65] = "    shift\n"
RGC_SCRIPT_CONTENTS[66] = "done\n"
RGC_SCRIPT_CONTENTS[67] = "if [ $VSYNC -eq 1 ]; then\n"
RGC_SCRIPT_CONTENTS[68] = "    export __GL_SYNC_TO_VBLANK=1\n"
RGC_SCRIPT_CONTENTS[69] = "fi\n"
RGC_SCRIPT_CONTENTS[70] = "__GNAME=`file game | awk '{print $5}'`\n"
RGC_SCRIPT_CONTENTS[71] = "\n"
RGC_SCRIPT_CONTENTS[72] = "echo\n"
RGC_SCRIPT_CONTENTS[73] = "echo \"Debugger       : $DEBUGGER\"\n"
RGC_SCRIPT_CONTENTS[74] = "echo \"DEBUG          : $DEBUG\"\n"
RGC_SCRIPT_CONTENTS[75] = "echo \"SDL_AUDIODRIVER: $SDL_AUDIODRIVER\"\n"
RGC_SCRIPT_CONTENTS[76] = "echo \"LD_LIBRARY_PATH: $LD_LIBRARY_PATH\"\n"
RGC_SCRIPT_CONTENTS[77] = "echo \"V-Sync         : $VSYNC\"\n"
RGC_SCRIPT_CONTENTS[78] = "echo \"GameName       : $__GNAME\"\n"
RGC_SCRIPT_CONTENTS[79] = "echo\n"
RGC_SCRIPT_CONTENTS[80] = "\n"
RGC_SCRIPT_CONTENTS[81] = "$DEBUGGER ./game_control\n"
RGC_SCRIPT_CONTENTS[82] = "exit 0\n"

CONFIG_CONTENTS = {};
CONFIG_CONTENTS[1] = "#"
CONFIG_CONTENTS[2] = "# Automatically generated make config: don't edit"
CONFIG_CONTENTS[3] = "#"
CONFIG_CONTENTS[4] = ""
CONFIG_CONTENTS[5] = "#"
CONFIG_CONTENTS[6] = "# General Settings"
CONFIG_CONTENTS[7] = "#"
CONFIG_CONTENTS[8] = "GAME_EGM=y"
CONFIG_CONTENTS[9] = "# GAME_ATS is not set"
CONFIG_CONTENTS[10] = "# GAME_MTGM_DISPLAY is not set"
CONFIG_CONTENTS[11] = "# GAME_RAPID_ITX is not set"
CONFIG_CONTENTS[12] = "GAME_BUILD_DEVEL=y"
CONFIG_CONTENTS[13] = "# GAME_BUILD_DEBUG_DEPLOY is not set"
CONFIG_CONTENTS[14] = "# GAME_BUILD_DEPLOY is not set"
CONFIG_CONTENTS[15] = "# GAME_BUILD_NO_WARNINGS is not set"
CONFIG_CONTENTS[16] = "GAME_BUILD_IGNORE_WARNINGS=y"
CONFIG_CONTENTS[17] = "KERNEL_SRC_DIR=\"/home/sgp1000/build/./rootfs/build//linux-3.6.1/\""
CONFIG_CONTENTS[18] = "KERNEL_OUT_DIR=\"/home/sgp1000/build/./rootfs/build//kernel-3.6.1/\""
CONFIG_CONTENTS[19] = "PLATFORM_FLASH_ID=\"Q4NWX01C\""
CONFIG_CONTENTS[20] = "PLATFORM_FLASH_CONFIG=\"CF2048\""
CONFIG_CONTENTS[21] = "# USE_SYSTEM_RTC is not set"
CONFIG_CONTENTS[22] = "# DISABLE_SOUND is not set"
CONFIG_CONTENTS[23] = "# DISABLE_LOAD_THREAD is not set"
CONFIG_CONTENTS[24] = "# RAM_CLEAR_NOT_ALLOWED_IN_PLATFORM is not set"
CONFIG_CONTENTS[25] = "# EXTERNAL_RAM_CLEAR is not set"
CONFIG_CONTENTS[26] = "# ENABLE_PSD_CHECK_ON_REAL_FILESYSTEM is not set"
CONFIG_CONTENTS[27] = "# ENABLE_THREAD_PRI is not set"
CONFIG_CONTENTS[28] = "# BUILD_TESTS is not set"
CONFIG_CONTENTS[29] = "# ALLOW_FORCED_ERRORS is not set"
CONFIG_CONTENTS[30] = "# BOARD_V3 is not set"
CONFIG_CONTENTS[31] = "# FPGA_V315 is not set"
CONFIG_CONTENTS[32] = "# PSDV_FUNCTION is not set"
CONFIG_CONTENTS[33] = "# ROM_SIGNATURE_ON_REAL_FILESYSTEM is not set"
CONFIG_CONTENTS[34] = "SIG_XOR_METHOD=y"
CONFIG_CONTENTS[35] = "# SIG_DAISY_CHAIN_METHOD is not set"
CONFIG_CONTENTS[36] = "SIGNATURE_FILE_PADDING=1"
CONFIG_CONTENTS[37] = "# SIGNATURE_FILE_TABCORP is not set"
CONFIG_CONTENTS[38] = "# PFAIL_TEST_MENU is not set"
CONFIG_CONTENTS[39] = "MULTILIB_64BIT=y"
CONFIG_CONTENTS[40] = "LOCAL_TOPBOX=y"
CONFIG_CONTENTS[41] = "# LOCAL_TOPBOX_QX40 is not set"
CONFIG_CONTENTS[42] = "# LOCAL_TOPBOX_ATL_MON_DETECT is not set"
CONFIG_CONTENTS[43] = "# TEST_COVERAGE is not set"
CONFIG_CONTENTS[44] = "# SINGLE_ATT_ACC_KEY is not set"
CONFIG_CONTENTS[45] = "# ENCRYPT_SHA1 is not set"
CONFIG_CONTENTS[46] = "# TEN_DIGIT_METERING is not set"
CONFIG_CONTENTS[47] = "# DEMO_MODE is not set"
CONFIG_CONTENTS[48] = "# ENABLE_DOWNLOAD_FEATURE is not set"
CONFIG_CONTENTS[49] = "# WIDESCREEN_ENABLED is not set"
CONFIG_CONTENTS[50] = "# ENABLE_DATA_CAPTURE is not set"
CONFIG_CONTENTS[51] = "# CONCURRENT_GAMES_SUPPORT is not set"
CONFIG_CONTENTS[52] = "FFMPEG_2010=y"
CONFIG_CONTENTS[53] = "# CABINET_TEST_11K004 is not set"
CONFIG_CONTENTS[54] = "DRAW_MESSAGING_BOX=y"
CONFIG_CONTENTS[55] = "# DRAW_TICKETING_ANIM is not set"
CONFIG_CONTENTS[56] = "# USE_TTY_DRIVER_PLUGINS is not set"
CONFIG_CONTENTS[57] = "# ENABLE_SERIAL_CONSOLE is not set"
CONFIG_CONTENTS[58] = ""
CONFIG_CONTENTS[59] = "#"
CONFIG_CONTENTS[60] = "# IO Process Settings"
CONFIG_CONTENTS[61] = "#"
CONFIG_CONTENTS[62] = "# IO_PROC_REAL is not set"
CONFIG_CONTENTS[63] = "IO_PROC_SIM_GUI=y"
CONFIG_CONTENTS[64] = "# IO_PROC_SIM_EGM_TERM is not set"
CONFIG_CONTENTS[65] = "# IO_PROC_SIM_KEYBOARD is not set"
CONFIG_CONTENTS[66] = "IO_PROC_SIM_NOTEVAL=y"
CONFIG_CONTENTS[67] = "# IO_PROC_NO_DIVERTER is not set"
CONFIG_CONTENTS[68] = ""
CONFIG_CONTENTS[69] = "#"
CONFIG_CONTENTS[70] = "# Note Validator Settings"
CONFIG_CONTENTS[71] = "#"
CONFIG_CONTENTS[72] = "NOTE_PROC_COMPORT=\"/dev/ttyXR1\""
CONFIG_CONTENTS[73] = ""
CONFIG_CONTENTS[74] = "#"
CONFIG_CONTENTS[75] = "# COMMS Settings"
CONFIG_CONTENTS[76] = "#"
CONFIG_CONTENTS[77] = "COMMS_ENABLED=y"
CONFIG_CONTENTS[78] = "# USE_VIRTUAL_CRAM is not set"
CONFIG_CONTENTS[79] = "# USE_PCI_SERIAL is not set"
CONFIG_CONTENTS[80] = "# COMMS_PROTOCOL_NOCOMMS is not set"
CONFIG_CONTENTS[81] = "# COMMS_PROTOCOL_QCOM is not set"
CONFIG_CONTENTS[82] = "# COMMS_PROTOCOL_SAS is not set"
CONFIG_CONTENTS[83] = "COMMS_SAS_TWO_PORT=y"
CONFIG_CONTENTS[84] = "COMMS_DONT_USE_SAS=y"
CONFIG_CONTENTS[85] = "# GLI11V20 is not set"
CONFIG_CONTENTS[86] = "# COMMS_PROTOCOL_XCOMMS is not set"
CONFIG_CONTENTS[87] = "# COMMS_PROTOCOL_ASP is not set"
CONFIG_CONTENTS[88] = "# COMMS_PROTOCOL_VLC is not set"
CONFIG_CONTENTS[89] = "# COMMS_PROTOCOL_SINFO is not set"
CONFIG_CONTENTS[90] = "# COMMS_PROTOCOL_G2S is not set"
CONFIG_CONTENTS[91] = "# COMMS_PROTOCOL_VLT is not set"
CONFIG_CONTENTS[92] = ""
CONFIG_CONTENTS[93] = "#"
CONFIG_CONTENTS[94] = "# Jurisdiction Settings"
CONFIG_CONTENTS[95] = "#"
CONFIG_CONTENTS[96] = "JUR_GAMBLESALLOWEDOPTION=y"
CONFIG_CONTENTS[97] = "# JUR_PROGRESSIVES_AGGREGATE_WIN_METERING is not set"
CONFIG_CONTENTS[98] = ""
CONFIG_CONTENTS[99] = "#"
CONFIG_CONTENTS[100] = "# NVRAM Settings"
CONFIG_CONTENTS[101] = "#"
CONFIG_CONTENTS[102] = "NVRAM_SIMULATOR=y"
CONFIG_CONTENTS[103] = "# NVRAM_FILES is not set"
CONFIG_CONTENTS[104] = "# NVRAM_PCI is not set"
CONFIG_CONTENTS[105] = "# NVRAM_QXT is not set"
CONFIG_CONTENTS[106] = "# NVRAM_TWO_COPY is not set"
CONFIG_CONTENTS[107] = ""
CONFIG_CONTENTS[108] = "#"
CONFIG_CONTENTS[109] = "# Game Process Settings"
CONFIG_CONTENTS[110] = "#"
CONFIG_CONTENTS[111] = "# GAME_SIM is not set"
CONFIG_CONTENTS[112] = ""
CONFIG_CONTENTS[113] = "#"
CONFIG_CONTENTS[114] = "# TouchScreen Settings"
CONFIG_CONTENTS[115] = "#"
CONFIG_CONTENTS[116] = "# USE_TOUCHSCREEN is not set"
CONFIG_CONTENTS[117] = "# USE_TOUCHPOLL_EVENT is not set"
CONFIG_CONTENTS[118] = ""
CONFIG_CONTENTS[119] = "#"
CONFIG_CONTENTS[120] = "# CardReader Settings"
CONFIG_CONTENTS[121] = "#"
CONFIG_CONTENTS[122] = "# USE_CARDREADER is not set"
CONFIG_CONTENTS[123] = "# USE_SERIAL_CARDREADER is not set"
CONFIG_CONTENTS[124] = ""
CONFIG_CONTENTS[125] = "#"
CONFIG_CONTENTS[126] = "# Lockout Board Settings"
CONFIG_CONTENTS[127] = "#"
CONFIG_CONTENTS[128] = "# USE_LOCKOUT_BOARD is not set"
CONFIG_CONTENTS[129] = ""
CONFIG_CONTENTS[130] = "#"
CONFIG_CONTENTS[131] = "# Printer Settings"
CONFIG_CONTENTS[132] = "#"
CONFIG_CONTENTS[133] = "PRN_PROC_COMPORT=\"/dev/ttySX2\""
CONFIG_CONTENTS[134] = ""
CONFIG_CONTENTS[135] = "#"
CONFIG_CONTENTS[136] = "# Mechanical Meter Settings"
CONFIG_CONTENTS[137] = "#"
CONFIG_CONTENTS[138] = "# USE_MECHMETER is not set"
CONFIG_CONTENTS[139] = ""
CONFIG_CONTENTS[140] = "#"
CONFIG_CONTENTS[141] = "# MTGM Display Settings"
CONFIG_CONTENTS[142] = "#"
CONFIG_CONTENTS[143] = "# USE_MTGM_DISPLAY_SIM is not set"
CONFIG_CONTENTS[144] = "# USE_MTGM_DISPLAY_TCP_COMMS is not set"
CONFIG_CONTENTS[145] = "ENABLE_MTGM_DISPLAY_SOUND=y"
CONFIG_CONTENTS[146] = ""
CONFIG_CONTENTS[147] = "#"
CONFIG_CONTENTS[148] = "# Developer Settings"
CONFIG_CONTENTS[149] = "#"
CONFIG_CONTENTS[150] = "# DEV_USE_INET_SOCKETS is not set"
CONFIG_CONTENTS[151] = "# DEV_SKIP_TEXTURING is not set"
CONFIG_CONTENTS[152] = "DEV_SHUFFLEMASTER_PACKAGES=y"
CONFIG_CONTENTS[153] = "# DEV_CONCURRENT_SELECTION is not set"
CONFIG_CONTENTS[154] = "DEV_QUICK_CONFIGURATION=y"
CONFIG_CONTENTS[155] = "# DEV_DROP_CONSOLE is not set"
CONFIG_CONTENTS[156] = "# DEV_SIMULATE_COMMS is not set"
CONFIG_CONTENTS[157] = "# DEV_GDB_EXPAND_MACROS is not set"
CONFIG_CONTENTS[158] = "# DEV_PRINT_METERS is not set"
CONFIG_CONTENTS[159] = "# DEV_RUN_LEGACY_GAME_ON_WS is not set"
CONFIG_CONTENTS[160] = "DEV_AUTOCONFIG_RAMCLEAR=y"
CONFIG_CONTENTS[161] = "# DEV_TEST_SDL_FONT_RENDERING is not set"
CONFIG_CONTENTS[162] = "DEV_LIB_DIRECTORY=\"/lib64\""
CONFIG_CONTENTS[163] = ""
CONFIG_CONTENTS[164] = "#"
CONFIG_CONTENTS[165] = "# Renderer Settings"
CONFIG_CONTENTS[166] = "#"
CONFIG_CONTENTS[167] = "FGLRX_ENABLED=y"
CONFIG_CONTENTS[168] = "# USE_GLX_VIDEO is not set"
CONFIG_CONTENTS[169] = "# USE_FULLSCREEN is not set"
CONFIG_CONTENTS[170] = ""
CONFIG_CONTENTS[171] = "#"
CONFIG_CONTENTS[172] = "# Markets"
CONFIG_CONTENTS[173] = "#"
CONFIG_CONTENTS[174] = "# MKT_tas is not set"
CONFIG_CONTENTS[175] = "# MKT_nzc is not set"
CONFIG_CONTENTS[176] = "# MKT_crown is not set"
CONFIG_CONTENTS[177] = "# MKT_ns6 is not set"
CONFIG_CONTENTS[178] = "# MKT_nsw is not set"
CONFIG_CONTENTS[179] = "# MKT_NY is not set"
CONFIG_CONTENTS[180] = "# MKT_nevada is not set"
CONFIG_CONTENTS[181] = "# MKT_rapid is not set"
CONFIG_CONTENTS[182] = "# MKT_wa is not set"
CONFIG_CONTENTS[183] = "MKT_north_america=y"
CONFIG_CONTENTS[184] = "# MKT_qld_cpp is not set"
CONFIG_CONTENTS[185] = "# MKT_nzl is not set"
CONFIG_CONTENTS[186] = "# MKT_sau is not set"
CONFIG_CONTENTS[187] = "# MKT_macau is not set"
CONFIG_CONTENTS[188] = "# MKT_tav is not set"
CONFIG_CONTENTS[189] = "# MKT_tat is not set"

--

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function usage()
    print("Usage: ./lua addPlatformEmulation.lua <platform version> <(optional) subfolder>");
end

function evalCmdLine(cmdArg, minArgs, maxArgs)
    local listArgs = {};
    if tablelength(cmdArg) < minArgs then
        logPrint("Too few arguments");
        for i = 1, tablelength(arg), 1 do
            logPrint(cmdArg[i]);
        end
        usage();
        return;
    end
    if tablelength(cmdArg) >= minArgs then
        for i = 1, tablelength(cmdArg), 1 do
            if cmdArg[i] ~= nil then
                listArgs[i] = cmdArg[i];
            end
        end
        if tablelength(listArgs) > maxArgs then
            logPrint("Too many arguments");
            for i = 1, tablelength(listArgs), 1 do
                logPrint(listArgs[i]);
            end
            usage();
            return;
        end
    end
    return 0;
end

function split(text, pattern)
    local count = 1;
    local wordList = {};
    if pattern == nil then
        pattern = "[_%w]+";
    end
    for w in string.gmatch(text, pattern) do -- underscore and all alphanumerics
        wordList[count] = w;
        --print(wordList[count]);
        count = count + 1;
    end
    return wordList;
end

function findInTable(srcTbl, pattern)
    for i = 1, tablelength(srcTbl) do
        if srcTbl[i] ~= nil then
            if string.find(srcTbl[i], "()" .. pattern .. "()") then
                return true;
            end
        end
    end
    return nil;
end

function copyPlatform(srcPlatform, subfolder)
    if subfolder == nil or subfolder == "" then
        --print(" -- copyPlatform(" .. srcPlatform .. ", nil)");
        os.execute("sudo rm -rf /home/sgp1000/workspace/" .. srcPlatform);
        os.execute("rsync -rlE --exclude=.svn /home/sgp1000/EGMPlatforms/" .. srcPlatform .. "/* /home/sgp1000/workspace/" .. srcPlatform);
    else
        --print(" -- copyPlatform(" .. srcPlatform .. ", " .. subfolder .. ")");
        os.execute("sudo rm -rf /home/sgp1000/workspace/" .. subfolder .. "/" .. srcPlatform);
        os.execute("rsync -rlE --exclude=.svn /home/sgp1000/EGMPlatforms/" .. srcPlatform .. "/* /home/sgp1000/workspace/" .. subfolder .. "/" .. srcPlatform);
    end
end

function create_ziyiz_link()
    print(" --- GOD DAMN IT ZIYIZ!  STOP HARDCODING THIS TO RUN IN YOUR HOME FOLDER!");
    local command = "sudo ln -s /home/sgp1000 /home/ziyiz";
    os.execute(command);
end

function create_rgc(path)
    print(" -- creating " .. path .. "rgc script");
    local fileHandle = io.open(path .. "rgc", "w+");
    if fileHandle == nil then
        print(" --- Error: could not create " .. path .. "rgc script");
        os.exit(1);
    end
    for i = 1, tablelength(RGC_SCRIPT_CONTENTS) do
        fileHandle:write(RGC_SCRIPT_CONTENTS[i]);
    end
    fileHandle:flush();
    fileHandle:close();
end

function create_sgp_config(cfgPath)
    print(" -- creating " .. cfgPath .. "/include/config/sgp_config.h");
    local command = "mkdir " .. cfgPath .. "/include/config";
    os.execute(command);
    outPath = cfgPath .. "/include/config/";
    gen_sgp_config(cfgPath, outPath, "[/#_%w%.%\"]+")
end

function gen_sgp_config(cfgPath, outPath, pattern)
    -- (pattern) can be any valid Lua string search pattern
    if pattern == nil then
        -- default to match alphanumerics and underscore inclusive
        pattern = "[_%w]+";
    end
    local cfgHandle = io.open(cfgPath .. ".config");
    if cfgHandle == nil then
        print(" --- Error: unable to open " .. path .. ".config");
        os.exit(1);
    end
    local configLines = {};
    local lCount = 1;
    -- read current .config file
    for line in cfgHandle:lines() do
        configLines[lCount] = line;
        lCount = lCount + 1;
    end
    cfgHandle:close();
    
    local mTBL = {};  -- .config line, split
    local cTBL = {};  -- current line
    local cTBLPos = 1;
    local lineLen = 0;
    local startComment = false;
    for i = 1, tablelength(configLines) do
        if configLines[i] ~= nil then
            mTBL = split(configLines[i], pattern);
            if mTBL[1] ~= nil then
                if string.find(mTBL[1], "#") ~= nil then
                    -- line is commented, emit #undef
                    -- if tablelength mTBL < 5 then probably not a setting so
                    lineLen = tablelength(mTBL);
                    if lineLen < 5 or i < 3 then
                        if lineLen == 1 then
                            if startComment == false then
                                startComment = true;
                                cTBL[cTBLPos] = "/*";
                                cTBLPos = cTBLPos + 1;
                            else
                                startComment = false;
                                cTBL[cTBLPos] = "*/";
                                cTBLPos = cTBLPos + 1;
                            end
                        else
                            cTBL[cTBLPos] = " *";
                            for j = 2, lineLen do
                                cTBL[cTBLPos] = cTBL[cTBLPos] .. " " .. mTBL[j];
                            end
                            cTBL[cTBLPos] = cTBL[cTBLPos];
                            cTBLPos = cTBLPos + 1;
                        end
                    else
                        -- probably not a comment, so go ahead and undef
                        cTBL[cTBLPos] = "#undef __" .. mTBL[2] .. "__";
                        cTBLPos = cTBLPos + 1;
                    end
                else
                    -- line is not commented, so define
                    if findInTable(mTBL, "y") ~= nil then
                        -- simple y/n
                        -- #define __GAME_EGM__ 1
                        cTBL[cTBLPos] = "#define __" .. mTBL[1] .. "__ 1";
                        cTBLPos = cTBLPos + 1;
                    else
                        -- value is a string
                        local tempLine = split(configLines[i], "[^=]");
                        cTBL[cTBLPos] = "#define __" .. mTBL[1] .. "__ ";
                        for j = string.len(mTBL[1]) + 1, tablelength(tempLine) do
                            cTBL[cTBLPos] = cTBL[cTBLPos] .. tempLine[j];
                        end
                        cTBLPos = cTBLPos + 1;
                    end
                end
            end
        end
    end

    cfgHandle = io.open(outPath .. "sgp_config.h", "w+")
    for i = 1, tablelength(cTBL) do
        cfgHandle:write(cTBL[i] .. "\n");
    end
    cfgHandle:flush();
    cfgHandle:close();
end

function create_config(path)
    print(" -- updating " .. path .. ".config");
    parse_config(path);
end

function parse_config(path, pattern)
    -- (pattern) can be any valid Lua string search pattern
    if pattern == nil then
        -- default to match alphanumerics and underscore inclusive
        pattern = "[_%w]+";
    end
    local cfgHandle = io.open(path .. ".config");
    if cfgHandle == nil then
        print(" --- Error: unable to open " .. path .. ".config");
        os.exit(1);
    end
    local configLines = {};
    local lCount = 1;
    -- read current .config file
    for line in cfgHandle:lines() do
        configLines[lCount] = line .. "";
        lCount = lCount + 1;
    end
    cfgHandle:close();
    
    local mTBL = {};  -- master line, split
    local cTBL = {};  -- current line, split
    local found = false;
    if tablelength(CONFIG_CONTENTS) > tablelength(configLines) then
        for i = 1, tablelength(CONFIG_CONTENTS) do
            if CONFIG_CONTENTS[i] ~= nil then
                mTBL = split(CONFIG_CONTENTS[i]);
                if mTBL[1] ~= nil then
                    for j = 1, tablelength(configLines) do
                        -- check each line in the current .config file and ensure existing
                        -- settings match master emulation settings
                        if configLines[j] ~= nil then
                            cTBL = split(configLines[j]);
                            if cTBL[1] ~= nil then
                                if string.find(cTBL[1], "()QXT()") ~= nil then
                                    configLines[j] = "# " .. cTBL[1] .. " is not set";
                                elseif mTBL[1] == cTBL[1] then
                                    configLines[j] = CONFIG_CONTENTS[i];
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        for i = 1, tablelength(configLines) do
            if configLines[i] ~= nil then
                cTBL = split(configLines[i]);
                if cTBL[1] ~= nil then
                    for j = 1, tablelength(CONFIG_CONTENTS) do
                        -- check each line in the current .config file and ensure existing
                        -- settings match master emulation settings
                        if CONFIG_CONTENTS[j] ~= nil then
                            mTBL = split(CONFIG_CONTENTS[j]);
                            if mTBL[1] ~= nil then
                                if string.find(cTBL[1], "()QXT()") ~= nil then
                                    configLines[i] = "# " .. cTBL[1] .. " is not set";
                                elseif mTBL[1] == cTBL[1] then
                                    configLines[i] = CONFIG_CONTENTS[j];
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, tablelength(CONFIG_CONTENTS) do
        if CONFIG_CONTENTS[i] ~= nil then
            if findInTable(configLines, CONFIG_CONTENTS[i]) == nil then
                -- since we don't want section comments, ensure that this line is either a define or
                -- an undefine.
                if string.find(CONFIG_CONTENTS[i], "()=()") or string.find(CONFIG_CONTENTS[i], "set") then
                    -- since it is not a comment and is an actual setting, add it.
                    table.insert(configLines, CONFIG_CONTENTS[i]);
                end
            end
        end
    end

    cfgHandle = io.open(path .. ".config", "w+")
    for i = 1, tablelength(configLines) do
        cfgHandle:write(configLines[i] .. "\n");
    end
    cfgHandle:flush();
    cfgHandle:close();
end

function fix_ini(path)
    print(" -- fixing egm_games.ini - setting path to /game");
    local textLines = {};
    local scriptPath = path .. "egm_games.ini";
    scriptFile = io.open(scriptPath, "w+");
    if scriptFile == nil then
        print(" --- file " .. scriptPath .. " not found.");
        return;
    end
    scriptFile:write("./game/conf/game_data.ini reels\n");
    scriptFile:close();
end

function fix_pkg_config(path)
    print(" -- fixing pkg-config");
    local rulesLines = {};
    i = 0;
    rules = path .. "/Rules.mak";
    rulesFile = io.open(rules, "r");
    for line in rulesFile:lines() do
        if string.find(line, "()/usr()") ~= nil then
            rulesLines[i] = string.gsub(line, "()/usr()", "/home/sgp1000/shufflemaster_packages");
            i = i + 1;
        else
            rulesLines[i] = line;
            i = i + 1;
        end
    end
    rulesFile = io.open(rules, "w+");
    for j = 0,i do
        if rulesLines[j] ~= nil then
            -- print(" -- " .. rulesLines[j]);
            rulesFile:write(rulesLines[j] .. "\n");
        end
    end
    rulesFile:close();
    local pkgList = getFileList("/home/sgp1000/shufflemaster_packages/lib64/pkgconfig/");
    for j = 0, tablelength(pkgList) do
        fix_pkg_file(pkgList[j]);
    end
    pkgList = getFileList("/home/sgp1000/shufflemaster_packages/lib/pkgconfig/");
    for j = 0, tablelength(pkgList) do
        fix_pkg_file(pkgList[j]);
    end
end

function fix_pkg_file(path)
    if path == nil then
        return;
    end
    print(" -- fixing " .. path .. " : ziyiz -> sgp1000");
    local rulesLines = {};
    i = 0;
    rules = path;
    rulesFile = io.open(rules, "r");
    for line in rulesFile:lines() do
        if string.find(line, "()ziyiz()") ~= nil then
            rulesLines[i] = string.gsub(line, "()ziyiz()", "sgp1000");
            i = i + 1;
        else
            rulesLines[i] = line;
            i = i + 1;
        end
    end
    rulesFile = io.open(rules, "w+");
    for j = 0,i do
        if rulesLines[j] ~= nil then
            -- print(" -- " .. rulesLines[j]);
            rulesFile:write(rulesLines[j] .. "\n");
        end
    end
    rulesFile:close();
end

function getFileList(path)
    if path == nil then
        path = "./"
    end
    local command = "ls " .. path .. "*.pc";
    local handle = io.popen(command);
    local result = 0;
    local fileList = {};
    local i = 1;
    if handle ~= nil then
        for line in handle:lines() do
            if line ~= nil then
                fileList[i] = line;
                i = i + 1;
            end
        end
    end
    return fileList;
end

function fix_egm_main(path)
    print(" -- fixing egm_main.c");
    local egmMainLines = {};
    i = 0;
    local egmMain = path .. "/game_proc/egm/egm_main.c";
    local egmMainFile = io.open(egmMain, "r");
    for line in egmMainFile:lines() do
        if string.find(line, "()egmInitSoundCard()") ~= nil then
            egmMainLines[i] = "#ifndef __DISABLE_SOUND__";
            i = i + 1;
            egmMainLines[i] = line;
            i = i + 1;
            egmMainLines[i] = "#endif";
            i = i + 1;
        elseif string.find(line, "()egmSoundCardUpdate()") ~= nil then
            egmMainLines[i] = "#ifndef __DISABLE_SOUND__";
            i = i + 1;
            egmMainLines[i] = line;
            i = i + 1;
            egmMainLines[i] = "#endif";
            i = i + 1;
        else
            egmMainLines[i] = line;
            i = i + 1;
        end
    end
    egmMainFile = io.open(egmMain, "w+");
    for j = 0,i do
        if egmMainLines[j] ~= nil then
            -- print(" -- " .. runGcLines[j]);
            egmMainFile:write(egmMainLines[j] .. "\n");
        end
    end
    egmMainFile:close();
end

function fix_run_gc(path)
    print(" -- fixing run_gc - setting to use ddd for debugging");
    local runGcLines = {};
    i = 0;
    runGc = path .. "/run_gc";
    runGcFile = io.open(runGc, "r");
    for line in runGcFile:lines() do
        if string.find(line, "()gdb()") ~= nil then
            runGcLines[i] = string.gsub(line, "()gdb()", "ddd");
            i = i + 1;
        else
            runGcLines[i] = line;
            i = i + 1;
        end
    end
    runGcFile = io.open(runGc, "w+");
    for j = 0,i do
        if runGcLines[j] ~= nil then
            -- print(" -- " .. runGcLines[j]);
            runGcFile:write(runGcLines[j] .. "\n");
        end
    end
    runGcFile:close();
end

function fix_run_gc_solo(path)
    print(" -- fixing run_gc_solo - setting to use ddd for debugging");
    local runGcSoloLines = {};
    i = 0;
    runGcSolo = path .. "/run_gc_solo";
    runGcSoloFile = io.open(runGcSolo, "r");
    for line in runGcSoloFile:lines() do
        if string.find(line, "()gdb()") ~= nil then
            runGcSoloLines[i] = string.gsub(line, "()gdb()", "ddd");
            i = i + 1;
        else
            runGcSoloLines[i] = line;
            i = i + 1;
        end
    end
    runGcSoloFile = io.open(runGcSolo, "w+");
    for j = 0,i do
        if runGcSoloLines[j] ~= nil then
            -- print(" -- " .. runGcSoloLines[j]);
            runGcSoloFile:write(runGcSoloLines[j] .. "\n");
        end
    end
    runGcSoloFile:close();
end

function fix_permissions(path)
    print(" -- fixing script executable permissions...");
    os.execute("chmod +x " .. path .. "/rgc");
    os.execute("chmod +x " .. path .. "/run_gc");
    os.execute("chmod +x " .. path .. "/run_gc_solo");
end

function fix_touch_proc_make(path)
    print(" -- checking platform/src/touch_proc/Makefile for -lpthread ...");
    local touchProcMakelines = {};
    i = 0;
    touchProcMake = path .. "/touch_proc/Makefile";
    touchProcMakefile = io.open(touchProcMake, "r");
    for line in touchProcMakefile:lines() do
        if string.find(line, "()-lusb()") ~= nil then
            if string.find(line, "()-lpthread()") == nil then
                touchProcMakelines[i] = string.gsub(line, "()-lusb()", "-lusb -lpthread");
            else
                touchProcMakelines[i] = line;
            end
            i = i + 1;
        else
            touchProcMakelines[i] = line;
            i = i + 1;
        end
    end
    touchProcMakefile = io.open(touchProcMake, "w+");
    for j = 0,i do
        if touchProcMakelines[j] ~= nil then
            -- print(" -- " .. touchProcMakelines[j]);
            touchProcMakefile:write(touchProcMakelines[j] .. "\n");
        end
    end
    touchProcMakefile:close();
    print(" -- added -lpthread to platform/src/touch_proc/Makefile.");
end

function fix_game_proc_make(path)
    -- check our operating system.  If older than 12.0 then bail.
    print(" -- checking platform/src/game_proc/egm/Makefile for -lGL ...");
    local gameProcMakelines = {};
    i = 0;
    gameProcMake = path .. "/game_proc/egm/Makefile";
    gameProcMakefile = io.open(gameProcMake, "r");
    for line in gameProcMakefile:lines() do
        if string.find(line, "()-lgmp -lusb()") ~= nil then
            if string.find(line, "()-lGL()") == nil then
                gameProcMakelines[i] = string.gsub(line, "()-lgmp -lusb()", "-lgmp -lusb -lGL");
            else
                gameProcMakelines[i] = line;
            end
            i = i + 1;
        else
            gameProcMakelines[i] = line;
            i = i + 1;
        end
    end
    gameProcMakefile = io.open(gameProcMake, "w+");
    for j = 0,i do
        if gameProcMakelines[j] ~= nil then
            -- print(" -- " .. gameProcMakelines[j]);
            gameProcMakefile:write(gameProcMakelines[j] .. "\n");
        end
    end
    gameProcMakefile:close();
    print(" -- added -lGL to platform/src/game_proc/egm/Makefile.");
end

function file_exists(name)
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

if evalCmdLine(arg, 1, 2) ~= nil then
    os.setlocale("C");
    local name = arg[1];
    local folder = arg[2];
    if folder == nil then
        folder = "north_america/"
    end
    print("Installing platform " .. name .. " for emulation");
    local source = "/home/sgp1000/EGMPlatforms/".. name .. "/images";
    local target = "/home/sgp1000/workspace/";
    local basePath = "/home/sgp1000/workspace/" .. folder .. "/" .. name .. "/";


    if name ~= nil then
        if folder ~= nil then
            if file_exists("/home/sgp1000/workspace/" .. folder .. "/" .. name) then
                target = target .. folder .. "/" .. name;
                os.execute("sudo rm -rf /home/sgp1000/workspace/" .. folder .. "/" .. name);
            end
            os.execute("mkdir -p /home/sgp1000/workspace/" .. folder .. "/" .. name);
        else
            if file_exists("/home/sgp1000/workspace/" .. name) ~= true then
                target = target .. name;
                os.execute("sudo rm -rf /home/sgp1000/workspace/" .. name);
            end
            os.execute("mkdir /home/sgp1000/workspace/" .. name);
        end
        copyPlatform(name, folder);
        if folder ~= nil and folder ~= "" then
            egmPath = basePath .. folder .. "/";
            platformPath = basePath .. folder .. "/"
        end

        egmPath = basePath .. "games/egm/";
        platformPath = basePath .. "platform/src/";

        print(" -- EGM emulation path: " .. egmPath);
        fix_ini(egmPath);
        fix_run_gc(egmPath);
        fix_run_gc_solo(egmPath);
        create_rgc(egmPath);
        fix_permissions(egmPath);

        fix_game_proc_make(platformPath);
        fix_touch_proc_make(platformPath);
        fix_egm_main(platformPath);
        fix_pkg_config(platformPath);
        create_config(platformPath);
        create_sgp_config(platformPath);
        create_ziyiz_link();
    else
        print("No platform specified.  Exiting.");
    end
end

