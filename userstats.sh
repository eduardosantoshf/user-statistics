#!/bin/bash
sort="sort";
sorting="";
last="last -w"
getRules(){

	echo " Invalid Option
	-u OPTION : search for users that has regex OPTION
	-g OPTION : seacrh for users that belongs to group OPTION
	-f FILE   : command last retrieves information from the FILE
	-s DATE   : shows sessions after DATE
	-e DATE   : show sessions before DATE
	-r	  : reverse order
	-n	  : sorts the sessions by number of sessions
	-t	  : sorts the sessions by time
	-a	  : sorts the sessions by max time
	-i	  : sorts the sessions by min time

		"	
}
while getopts "::g:u:s:e:f::nrtai" o; do
    case "${o}" in
        u)	
            u=${OPTARG}
            ;;
        f)
            f=${OPTARG}
			last="$last -f $f"
            ;;
		n)
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			sort="$sort -k2 -n ";
			sorting="s";
			;;
		r)	
			sort="$sort -r";	
			;;
		t)
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			sort="$sort -n -k3 ";
			sorting="s";	
			;;	
		a)
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			sort="$sort -n -k4 ";
			sorting="s";
			;;
		i) 	
			if [[ $sorting = "s" ]];then
				echo "ERROR : More than 2 sorting options were selected"
				exit 1;
			fi
			sort="$sort -n -k5 ";
			sorting="s";
			;;
		g)
			group=${OPTARG};
			;;
		s)
			start_date=$(date -d"$OPTARG" "+%y-%m-%d %H:%M" );
			last="$last -s \"$start_date\"";
			;;
		e)
			end_date=$(date -d "$OPTARG" "+%Y-%m-%d %H:%M");
			last="$last -t \"$end_date\"";
			;;
        *)
			getRules
			exit 1						
            ;;
    esac
done
shift $((OPTIND-1))	

if [[ -z $f ]];then
	f="/var/log/wtmp"
else
	if ! [[ -f $f ]];then
		echo "ERROR : Can not read from file."
		exit 1
	fi

fi

contador=0;
getUsers()	{

	if [[ -n "$u" ]];then
		users=($(eval $last | grep -v "logged" | awk '{print $1}' | grep -v "reboot" | grep -v "wtmp" | sort |  uniq | grep "$u" ))
	else
		users=($(eval $last | grep -v "logged" | awk '{print $1}' | grep -v "reboot" | grep -v "wtmp" | sort | uniq | tr '\n' ' '))
	fi
	
	

	if [[ -n "$group" ]];then
		for g in ${users[@]}
		do	
			isGroup="n"
			usersgroup=($(groups "$g"));
			for i in ${usersgroup[@]}
			do
				if [[ "$i" = "$group" ]];then
					isGroup="y"
					break
				fi
			done
			
			if [[ "$isGroup" = "n" ]];then
				users=(${users[@]/$g})
			fi

		done
	fi
	 
	if  [[ ${users[@]} ]] ;then
	for i in "${users[@]}"
	do

		counter=$(eval $last  | awk '{print $1;}' | grep "$i" | wc -l )
		time=($(eval $last  | grep "$i" | awk '{print $10}' | grep -v "in" | grep -v "no" | grep -v "on" | grep -v "logged" | grep -v "running" | grep -v "still"))

		y=${time[0]};
		if [[ ${#y} -gt 7 ]];then
			day=$(echo $y | cut -d '+' -f 1 | cut -d '(' -f 2);
			hour=$(echo $y | cut -d '+' -f 2 | cut -d ')' -f 1 | cut -d ':' -f 1 | awk '{sub(/^0/,"");}1');
			min=$(echo $y | cut -d '+' -f 2 | cut -d ')' -f 1 | cut -d ':' -f 2 | awk '{sub(/^0/,"");}1');
			min_time=$(($day*24*60+$hour*60 + $min))
			max_time=$(($day*24*60+$hour*60 + $min))
		else
			hour=$(echo $y | cut -d '(' -f 2 | cut -d ':' -f 1 | awk '{sub(/^0/,"");}1');
			min=$(echo $y | cut -d '+' -f 2 | cut -d ')' -f 1 | cut -d ':' -f 2 | awk '{sub(/^0/,"");}1');
			min_time=$(($hour*60 + $min))
			max_time=$(($hour*60 + $min))
		fi
		total_time=0;
		for k in "${time[@]}"
		do

			if [[ ${#k} -gt 8 ]];then
				day=$(echo $k | cut -d '+' -f 1 | cut -d '(' -f 2);
				hour=$(echo $k | cut -d '+' -f 2 | cut -d ')' -f 1 | cut -d ':' -f 1 | awk '{sub(/^0/,"");}1');
				min=$(echo $k | cut -d '+' -f 2 | cut -d ')' -f 1 | cut -d ':' -f 2 | awk '{sub(/^0/,"");}1');
				min_time=$(($day*24*60+$hour*60 + $min))
				max_time=$(($day*24*60+$hour*60 + $min))
				temp_time=$(( $day*24*60+$hour*60 + $min ))
			else
				hour=$(echo $y | cut -d '+' -f 2 | cut -d '(' -f 2 | cut -d ':' -f 1 | awk '{sub(/^0/,"");}1');
				min=$(echo $y | cut -d '+' -f 2 | cut -d ')' -f 1 | cut -d ':' -f 2 | awk '{sub(/^0/,"");}1');
				temp_time=$(($hour*60 + $min))
			fi
			
			if [[ $temp_time -lt $min_time ]];then
				min_time=$temp_time;
			fi	

			if [[ $temp_time -gt $max_time ]];then
				max_time=$temp_time;
			fi
			total_time=$(( $total_time+$temp_time ))			
		done
		
		userstats[contador]=$(echo "$i $counter $total_time $max_time $min_time")
		let "contador=contador +1";
		
	done
	else
		echo "No users found."
		exit 1
	fi

}
getUsers
IFS=$' '
printf '%s \n' "${userstats[@]}" | $sort