#!/bin/bash
# Cron job adder, with automatic checking to avoid duplicates

#=== Current path detection
# Current script filename
SCRIPTNAME=$(basename "$0")
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

#=== Help message
if [[ "$@" =~ "--help" ]]; then
	echo "Usage: sh $SCRIPTNAME 'crondate' 'crontask' [OPTION]...
Add only once a cron job to execute the specified crontask at a specified crondate interval. Will automatically check for duplicates, so that it will never add twice the same job inside cron.

WARNING: only use absolute paths, else cron may not be able to execute the task, and also the check for duplicates will fail.

Note: the duplicates checking will match any shorter crontask, eg: already added crontask 'mycronjob', if you try to add crontask 'mycron' it will be rejected because of being a duplicate.
  
  --verbose				Print verbose infos of oamps.sh
"
	exit
fi

#=== Arguments parsing
argslist=("$@") #store all arguments in a list so we can directly access the needed values for each argument
allargs="$@" #store all arguments in a line so we can use it for cron job
COUNT=0 #keep count of current argument so we can get the value in the next argument (eg : --port 27960)

# Parsing the arguments
for arg in "$@"
do
	if (( COUNT < 2)); then
		true # just pass until we get a new argument
    #echo $COUNT you typed ${arg}. #debugline
	elif [ "$arg" = "--verbose" ]; then
		verbose="-v"
    fi
    let COUNT=$COUNT+1
done

function add_to_cron {
	local crondate="$1"
	local crontask="$2"
	# current time
	local currtime=$(date '+%H:%M:%S')
	# Compare with current crontab and load the cron command
	local JOBPRESENT=$(crontab -l | grep -F -i "$crondate $crontask") # Check if a cronjob already exists for the current commandline (whole commandline with arguments !), -F is here to enforce the recognition of special meta-characters like * (star) or "
	if [ "$JOBPRESENT" == "" ]; then
		local statictime="$currtime" # We need to store the time once and for all in a var, or else the time could change in 1 sec, and the file would be different (since $currtime does call the date function dynamically)
		touch "$SCRIPTPATH/oacrontab_$statictime.tmp" # Creating an empty file
		echo -e "$(crontab -l)\n" >> "$SCRIPTPATH/oacrontab_$statictime.tmp" # Output inside the file the current cron jobs list
		echo "$crondate $crontask" >> "$SCRIPTPATH/oacrontab_$statictime.tmp" # Output our new cron job (an empty line will be created due to \n in the previous statement)
		crontab "$SCRIPTPATH/oacrontab_$statictime.tmp" # Update cron with the content of our temporary cronfile
		if [ -n "$verbose" ]; then cat "$SCRIPTPATH/oacrontab_$statictime.tmp"; fi # Show the content of our cronfile if verbose mode is activated
		unlink "$SCRIPTPATH/oacrontab_$statictime.tmp" # Delete the temp cronfile
		#echo -e "$(crontab -l)\n$crondate $crontask" > oacrontab.tmp ; crontab oacrontab.tmp # Old way to do all the previous stuff in one line, may not be as reliable
		echo "Successfully added the following cron job: $crondate $crontask"
	else
		echo "Same (or similar) cron job already exists ! This one will not be added: $crondate $crontask"
	fi
}

add_to_cron "${argslist[0]}" "${argslist[1]}"
