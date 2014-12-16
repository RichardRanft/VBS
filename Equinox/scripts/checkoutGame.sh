if [ $# -lt 5 ]; then
        echo "Usage: sh checkoutGame.sh <Game Version> <\"Game Name\"> <Game Folder> <Label> <View>" >&2
        exit 1
fi
if [ -f "/home/sgp1000/build/images/games/$1/sources/$3/.config" ]; then 
	echo "Game already checked out!";
	exit 1
fi

function change_special_characters
{
    echo "$(echo $1 | sed 's/%/%25/g;s/\//%2f/g;s/:/%3a/g;s/@/%40/g;s/</%3c/g;s/>/%3e/g;s/ /%20/g')"
}

game_name="$(change_special_characters "$2")"

echo "Removing old files..."
sudo rm -rf /home/sgp1000/build/images/games/$1
mkdir /home/sgp1000/build/images/games/$1
mkdir /home/sgp1000/build/images/games/$1/sources
mkdir /home/sgp1000/build/images/games/$1/sources/$3
cd /home/sgp1000/build/images/games/$1/sources/$3
if [ "$4" != "x" ]; then
  echo "Checking out $2 view $5 at label $4 to project folder /home/sgp1000/build/images/games/$1/sources/$3"
  stcmd co -p "richardr:7w34034G354q634@starteam.australia.shufflemaster.com:49210/PC4G $game_name/$5" -fp "/home/sgp1000/build/images/games/$1/sources/$3" -eol "on" -is -o -cfgl "$4"
else
  echo "Checking out $2 at label $4 to project folder /home/sgp1000/build/images/games/$1/sources/$3"
  stcmd co -p "richardr:7w34034G354q634@starteam.australia.shufflemaster.com:49210/PC4G $game_name/$5" -fp "/home/sgp1000/build/images/games/$1/sources/$3" -eol "on" -is -o
fi
cd /home/sgp1000
