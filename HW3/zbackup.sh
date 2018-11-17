#!/bin/sh

#------------------global variable declaration starts here---------------#
data=""
id=""
filename=""
rotate_cnt=""
arg_cnt=0
#------------------global variable declaration ends here---------------#

#function to check if the id is legal
check_id()
{
	case $1 in
		[0-9]*) #regex repeat
			;;

		'')
			;;

		*)
			error "Illegal ID number!!"
			;;
	esac
}

check_dataset()
{
	for data in $(zfs list | cut -d ' ' -f 1); 
	do
		if [ $1 = $data ] ; 
		then
			return
		fi
	done
	error "Dataset does not exist!!"
}


create()
{
	echo "Function create snapshot"
	#declare some required vars
	local rot_cnt=$2 #rotation count
	dataset=$1 #what the name for back up

	#check if the id is illegal
	check_id $1

	#adjust the rotate count
	#if no specified rotate count, just set it as 20
	if [ -z "$rot_cnt" ] ; 
	then 
		rotate_cnt=20; 
	fi

	#illegal rotate count
	if [ $rot_cnt -eq 0 ] ; 
	then 
		error "Rotate count should in range [1, 20]"
		exit 0; 
	fi

	#snapshot the data and check if the oldest need to be deleted
	snap_cnt=$(zfs list -t snapshot | grep $dataset | wc -l)

	if [ $snap_cnt -ge $rot_cnt ];
	then
		#delete the oldest n, get their names, use ' ' as the delimeter of cut and get the first field
		to_del=$(zfs list -t snapshot | grep $dataset | head -n $(($snap_cnt-rot_cnt)) | cur -d '  ' f 1)

		for i in $to_del;
		do
			zfs destroy $i #delete the i oldest snapshots in the given dataset
			if [ $? -eq 0 ];
			then
				echo "Successfully delete snapshot $i in dataset $dataset"
			else
				error "Unable to delete the snapshot $i in dataset $dataset"
			fi
		done
	fi
	#timestamp YYYY-MM-DD_HH-MM-SS
	timestamp=$(data "+%Y-%m-%d %H-%M-%S")
	zfs snapshot "$dataset@$timestamp"

	if [ $? -eq 0 ];
	then
		echo "Successfully create snapshot $i in dataset $dataset time $timestamp"
	else
		error "Unable to create the snapshot $i in dataset $dataset"
	fi


}

list()
{

}

delete()
{

}

check_arg()
{
	if [ $arg_cnt -eq 0 ];
	then
		echo " Usage: zbackup [[--list | --delete | --export] target-dataset [ID] | [--import] target-dataset filename | target dataset [rotation count]] "
		exit 0
	fi
}

error()
{
	echo "Error: " $1
	exit 0
}

main()
{
	#check if the main usage is correct
	arg_cnt=$#
	check_arg

	case $1 in

		--list)
			#list all the backup'd zfs datasets
			list
			;;

		--delete)
			#delete the dataset with specified id
			delete $3
			;;

		--export)
			;;

		--import)
			;;

		'')
			error "Missing argument!!"
			;;

		*)
			#default, create the dataset $1 is the name and $2 is the max rotate count of that data set
			create $1 $2
			;;
	esac

}

main


