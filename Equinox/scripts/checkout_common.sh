#/bin/bash

#
# Checkout the current view of the base common code into the specified directory.
#
#       checkout_common.sh [-q | --quiet | -h | --help] [--log <log file>] -d <dest>
#
# Usage:
#       -q | --quiet            Quietly checkout, supress all output
#       -h | --help             Display the usage and exit
#       --log <log file>        Redirect all output to the specified log file
#	-d <dest>		Check-out into the given directory
#

# The default quiet level is off
quiet=0
debug=0

# Use stdout as default for all output
output="/dev/stdout"

# StarTeam user name and password stored here
credentials="/home/sgp1000/.stcmd_credentials"

# Directory to contain checked-out common code
dest_folder=""

# Log file and dest directory not specified yet
have_file=0
have_dest=0
got_file=0

#
# Echo the script usage to the terminal
#
myname=`basename "$0"`
usage ()
{
        echo "usage: ${myname} [-q | --quiet | -h | --help] [--log <log file>] -d <dest>"
        echo -e "\nCheckout the current view of the base common code into the specified directory.\n"
        echo "Options:"
        echo -e "\t-q | --quiet         Quietly build, supress all output"
        echo -e "\t-h | --help          Display the usage and exit"
        echo -e "\t--log <log file>     Redirect all output to the specified log file"
        echo -e "\t-d <name>            Fully-specified destination directory; do not use ./"
        echo "Example:"
        echo -e "\nQuietly check out into folder /tmp/dest, redirecting to logfile.txt"
        echo -e "\t${myname} -q --log logfile.txt -d /tmp/dest\n"
}


# Parse the command line for options
if [ $# -gt 0 ]; then
	count=0
        for i in "$@"; do

		let "count += 1"

                # Check for an option, begins with "-"
                if [ ${i:0:1} == "-" ]; then
                	if [ "$have_file" -ne 0 -a "$got_file" -ne 1 ]; then
				echo "${myname}: missing log file"
				exit 1
                	elif [ "$have_dest" -ne 0 ]; then
				echo "${myname}: missing dest directory"
				exit 1
                        elif [ "$i" == "--log" ]; then
                                have_file=$count
                        elif [ "$i" == "-d" ]; then
                                have_dest=$count
                        elif [ "$i" == "-q" -o "$i" == "--quiet" ]; then
                                quiet=1
                        elif [ "$i" == "-h" -o "$i" == "--help" ]; then
                                usage
                                exit 0
                        elif [ "$i" == "--debug" ]; then
				debug=1
                        else
                                echo "${myname}: unknown option $i"
                                exit 1
                        fi
		else
			# No leading "-" so this is not an option, must be one of:
			#
			#	<log file>
			#	<dest>
			#

			# The log file must immediately follow the --log option
			#
                	if [ $have_file -ne 0 -a `expr $have_file + 1` -eq $count ]; then
                        	# Must be the log file name
                        	output="$i"
                                got_file=1
			# The dest directory must immediately follow the -d option
			#
                	elif [ $have_dest -ne 0 -a `expr $have_dest + 1` -eq $count ]; then
                        	# Must be the dest directory
                        	dest_folder="$i"
                	else
                        	echo "${myname}: unknown option $i"
                        	exit 1
			fi

                fi
        done
else
	usage
	exit 0
fi

# Error out if dest directory name missing
if [ "${dest_folder}" == "" ]; then
        echo "${myname}: missing dest directory"
        exit 1
fi

# Error out if --log option given but file name missing
if [ "${have_file}" -ne 0 -a "${output}" == "/dev/stdout" ]; then
        echo "${myname}: missing damn log file"
        exit 1
fi

# If quiet and no log file specified, then redirect the output to /dev/null
[ "${quiet}" -eq 1 -a "${have_file}" -eq 0 ] && output="/dev/null"

if [ $debug -ne 0 ]; then
	echo "quiet:   $quiet"
	echo "output:  $output"
	echo "dest:    $dest_folder"
	echo
	exit 0
fi

# Make sure the credentials file exists
if [ ! -e "${credentials}" ]; then
	echo "${myname}: credentials file ${credentials} not found"
	exit 1
fi

# Extract the user name and password from the credentials file
#
user=`cat "${credentials}" | grep username | cut -d'=' -f2`
password=`cat "${credentials}" | grep password | cut -d'=' -f2`

if [ -z "${user}" ]; then
	echo "${myname}: missing user name"
	exit 1
elif [ -z "${password}" ]; then
	echo "${myname}: missing password"
	exit 1
fi

# Check out the current view of the base common code from PC4 Games Common.  Force all files to be checked out.
#
[ "${quiet}" -eq 0 ] && echo -e "\n\033[1;31mChecking out common code to ${dest_folder}\033[m\n"
stcmd co -p "${user}:${password}@starteam.australia.shufflemaster.com:49210/PC4 Games Common/code" -fp "${dest_folder}/code" -o -eol on -is >> "${output}" 2>&1
result=$?

# Exit with status from StarTeam
exit "$result"
