#!/bin/bash
    #view=$(echo $view | sed 's/\//%2f/g')

starteam_checkout_command="stcmd co"
server_addr="starteam.australia.shufflemaster.com"
port_pc4_platform="49209"
port_pc4_game="49210"

server_sel="G"
port=
server=

view=
sub_view=
label_opt="-cfgl"
label=

path=
path_opt="-fp"

misc_opt="-is -o"


#$starteam_checkout_command -p gamedev:GameDev1@starteam.australia.shufflemaster.com:49210/"PC4G Hey Presto%2fMagic Master"/"NSW - Hey Presto Maximillions Gold (Statewide Link)" -cfgl "HMGNSW1A-00" -is -o -fp /home/francisp/dev/CROWN/W4CRA03/games/egm/hey_presto


function to_lower_case
{
    echo "$(echo $1 |tr '[A-Z]' '[a-z]')"
}

function change_special_characters
{
    echo "$(echo $1 | sed 's/%/%25/g;s/\//%2f/g;s/:/%3a/g;s/@/%40/g;s/</%3c/g;s/>/%3e/g;s/ /%20/g')"
}

function change_special_characters_back
{
    echo "$(echo $1 | sed 's/%25/%/g;s/%2f/\//g;s/%3a/:/g;s/%40/@/g;s/%3c/</g;s/%3e/>/g;s/%20/ /g')"
}

function config_server 
{
    server=$server_addr
    echo " -- Server Addr is : $server"
    read -e -i "$server_sel" -p "Platform or Game (p/g)? " input
    server_sel="${input:-$name}"
    server_sel=$(to_lower_case $server_sel)

    case $server_sel in
        p) port=$port_pc4_platform;;
        g) port=$port_pc4_game;;
        *) echo "Default [Game]. Proceeding...";\
           server_sel="g";\
           port=$port_pc4_game;;
    esac

    echo " -- Server : $server:$port"
}

function config_view
{
    if [ "$server_sel" == "g" ]
    then
        if [ "$view" == "" ]
        then
        view="PC4G "
    fi
    fi

    read -e -i "$(change_special_characters_back "$view")" -p "View Name ? " input
    view="${input:-$name}"

    echo " -- View Name : "$(change_special_characters_back "$view")""
    view="$(change_special_characters "$view")"
}

function add_sub_view 
{
    echo -n "Sub View Name ? "
    read sub_branch
    if [ "$sub_branch" != "" ]
    then
        echo " -- Sub View : $sub_branch"
        sub_branch="$(change_special_characters "$sub_branch")"
        sub_view="$sub_view/$sub_branch"
    else
        echo "No Sub View added."
    fi
}

function config_sub_view
{
    sub_view=""
    while :
    do
        echo -n "Sub View Present (y/[n])? "
        read sel
        sel=$(to_lower_case $sel)
        case $sel in
            y) add_sub_view;;
            n) return;;
            *) return;;
        esac
    done

    echo " -- Sub View : "$(change_special_characters_back "$sub_view")""
}

function config_label
{
    echo -n "Label (default:current) ? "
    read lc_label
    if [ "$lc_label" != "" ]
    then
        echo " -- Label : $lc_label"
        label="$label_opt $lc_label"
    else
        label=""
        echo "No Label given. using Current Configuration"
    fi
}

function config_path
{
    local lc_path="${PWD}/"
    read -e -i "$lc_path" -p "Check out Path : " input
    lc_path="${input:-$name}"
    path="$lc_path"
}


function config_misc_opts
{
    read -e -i "$misc_opt" -p "Misc Options : " input
    $misc_opt="${input:-$misc_opt}"
}

function check_out
{
    local ans="y"

    echo -n "Command :"
    echo "$starteam_checkout_command -p gamedev:GameDev1@$server:$port/$view$sub_view $label $path_opt $path $misc_opt" ;
    
    if [ -d "$path" ]
    then
        ans="n"
        read -e -i "$ans" -p "Path $path already exists. Is it OK [y/N]? " input
        ans="${input:-$name}"
        ans="$(to_lower_case "$ans")"
    fi
    
    if [ "$ans" == "y" ]
    then
        $starteam_checkout_command -p gamedev:GameDev1@$server:$port/$view$sub_view $label $path_opt $path $misc_opt;
    fi
}


function display_config
{
    local label_temp="current"
    while :
    do
        echo "------------- Options ---------------"
        echo "[] Server         : $server"
        echo "[2] Port           : $port"
        echo "[3] View Name      : "$(change_special_characters_back "$view")""
        echo "[4] Sub View       : "$(change_special_characters_back "$sub_view")""

        if [ "$label" != "" ]
        then
            label_temp="$label"
        fi

        echo "[5] Label          : $label_temp"
        echo "[6] Misc Options   : $misc_opt"
        echo "[7] Path           : $path"
        echo "[C] Checkout"
        echo "[Q] Exit"
        echo "-------------------------------------"
        echo -n "Enter : "
        read choice
        choice="$(to_lower_case "$choice")"
        case $choice in
            #1);;
            2)config_server;;
            3)config_view;;
            4)config_sub_view;;
            5)config_label;;
            6)config_misc_opts;;
            7)config_path;;
            c)check_out;;
            q)exit 0;;
            *) echo "Invalid Option!";;
        esac
    done
}

config_server
config_view
config_sub_view
config_label
config_path

display_config

 
