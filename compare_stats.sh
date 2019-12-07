#/bin/bash
sorting=""
sort="sort"
if [[ "$#" -lt 2 ]];then
	echo "Numero de argumentos nao esta correto"
	exit 1;
fi

while getopts "nrtai" o; do
    case "${o}" in
		n)
			if [[ $sorting = "s" ]];then
				echo "CANT"
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
				echo "CANT"
				exit 1;
			fi
			sort="$sort -n -k3 ";
			sorting="s";	
			;;	
		a)
			if [[ $sorting = "s" ]];then
				echo "CANT"
				exit 1;
			fi
			sort="$sort -n -k4 ";
			sorting="s";
			;;
		i) 	
			if [[ $sorting = "s" ]];then
				echo "CANT"
				exit 1;
			fi
			sort="$sort -n -k5 ";
			sorting="s";
			;;
        *)        
            
            ;;
    esac
done
shift $((OPTIND-1))	



declare -a users1;
declare -a users2;
function calculate(){

    IFS=$'\n'

    
	if ! [[ -f $1 ]];then
		echo "cannot read from file"
		exit 1
	fi
	if ! [[ -f $2 ]];then
		echo "cannot read from file"
		exit 1
	fi
	while IFS= read -r line; do
		IFS=$'\n'
    	users1+=($line);
	done < $1
	while IFS= read -r line; do
		IFS=$'\n'
    	users2+=($line);
	done < $2
    counter=0;

    for k in ${users1[@]}
    do
		name1=$(echo "$k" | awk '{print $1}');
        for i in ${users2[@]}
        do
			name2=$(echo "$i" | awk '{print $1}');
            if [[ "$name1" = "$name2" ]] ; then
				let "sessions=$(( $(echo "$k" | awk '{print $2}') - $(echo "$i" | awk '{print $2}') ))";
				let "time=$(( $(echo "$k" | awk '{print $3}') - $(echo "$i" | awk '{print $3}') ))"
				let "max_time=$(( $(echo "$k" | awk '{print $4}') - $(echo "$i" | awk '{print $4}') ))"
				let "min_time=$(( $(echo "$k" | awk '{print $5}') - $(echo "$i" | awk '{print $5}') ))"
            	userstats[counter]=$(echo "$name1 $sessions $time $max_time $min_time ");
                let "counter=counter +1"
            fi		

        done
	
    done

}
calculate $1 $2

for i in ${users1[@]}
do
	username=$(echo "$i" | awk '{print $1}');
	add="y"
	for j in ${userstats[@]}
	do
		temp_name=$(echo "$j" | awk '{print $1}');
		if [[ "$username" = "$temp_name" ]];then
			add="n"
		fi
	done
	if [[ "$add" = "y" ]];then
		userstats[counter]=$(echo "$i")
		let "counter=counter+1"
	fi
done
for i in ${users2[@]}
do
	add="y"
	username=$(echo "$i" | awk '{print $1}');
	for j in ${userstats[@]}
	do
		temp_name=$(echo "$j" | awk '{print $1}');
		if [[ "$username" = "$temp_name" ]];then
			add="n"
		fi
	done

	if [[ "$add" = "y" ]];then
		userstats[counter]=$(echo "$i")
		let "counter=counter+1"
	fi
done

IFS=$' '
printf '%s \n' "${userstats[@]}" | $sort
