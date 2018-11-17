#!/bin/sh
#------------------global variable declaration starts here---------------#
data=""
id=""
filename=""
rotate_cnt=""
arg_cnt=0
#------------------global variable declaration ends here---------------#

check_arg()
{
	if [ $arg_cnt -eq 0 ];
	then
		echo " Usage: zbackup [[--list | --delete | --export] target-dataset [ID] | [--import] target-dataset filename | target dataset [rotation count]] "
		exit 0
	fi
}

#function to check if the id is legal
check_id()
{
	case $1 in
		[0-9]*) #regex repeat
			;;

		'')
			;;

		*)
			error "Illegal numerical number!!"
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
	#echo "Function create snapshot d1 $1 d2 $2"
	#declare some required vars
	dataset=$1 #what the name for back up
	rot_cnt=$2 #rotation count

	#check if the rotate count number is illegal
	check_id $rot_cnt

	#adjust the rotate count, if not specified rotate count, just set it as 20
	if [ -z $rot_cnt ] ; 
	then 
		rotate_cnt=20; 
	fi

	#illegal rotate count, quit
	if [ $rot_cnt -eq 0 ] ; 
	then 
		error "Rotate count should in range [1, 20]"
		exit 0; 
	fi

	#iterate through the data and check if the oldest need to be deleted
	snap_cnt=$(zfs list -t snapshot | grep $dataset | wc -l)

	if [ $snap_cnt -ge $rot_cnt ];
	then
		#delete the oldest n, get their names, use ' ' as the delimeter of cut and get the first field
		echo "Current snapshot >= the rotation count, now delete the $(($snap_cnt-$rot_cnt)) snaps"
		to_del=$(zfs list -t snapshot | grep $dataset | head -n $(($snap_cnt-$rot_cnt+1)) | cut -d ' ' -f 1)

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

	#add timestamp: timestamp YYYY-MM-DD_HH:MM:SS
	timestamp=`date +"%Y-%m-%d_%H:%M:%S"`
	echo "$timestamp"
	zfs snapshot "$dataset@$timestamp"

	#create snapshot
	if [ $? -eq 0 ];
	then
		echo "Successfully create snapshot $i in dataset $dataset time $timestamp"
	else
		error "Unable to create the snapshot $i in dataset $dataset"
	fi


}

list()
{
	dataset=$1
	id=$2

	check_id $id
	check_dataset $dataset

	#if specified id, list the id of specified dataset, otherwise, list all of specified dataset
	if [ -z $id ];
	then
		printf "%s\t\t%s\t\t%s\t\n" "ID" "Dataset" "Time"
		zfs list -rt snapshot $dataset | awk 'BEGIN{ cnt=0 }{ ++cnt; if(cnt >= 2) { printf("%d@\t%s\t\n", cnt-1, $1); } } '| awk ' BEGIN { FS="@"; cnt=0 } { printf("%d\t%s\t%s\t\n", ++cnt, $2, $3)} '
	else
		printf "%s\t\t%s\t\t%s\t\n" "ID" "Dataset" "Time"
		zfs list -rt snapshot $dataset | awk 'BEGIN{ cnt=0 }{ ++cnt; if(cnt >= 2) { printf("%d@\t%s\t\n", cnt-1, $1); } } '| awk ' BEGIN { FS="@"; cnt=0 } { printf("%dTHID\t%s\t%s\t\n", ++cnt, $2, $3)} ' | grep $id"THID" | sed s/THID//
	fi

}

delete()
{
	dataset=$1
	id=$2

	check_id $id
	check_dataset $dataset

	#if specified id, list the id of specified dataset, otherwise, list all of specified dataset
	if [ -z $id ];
	then
		echo "Delete all the snapshots in dataset: $dataset"

		to_del=$(zfs list -rt snapshot $dataset | awk ' BEGIN{ cnt=0 }{ ++cnt; if(cnt >= 2) { printf("%s ", $1); } } ')
		for i in $to_del;
		do
			zfs destroy $i

			if [ $? -eq 0 ];
			then
				echo "Successfully delete snapshot $i in dataset $dataset"
			else
				error "Unable to delete the snapshot $i in dataset $dataset"
			fi
		done
	else
		to_del=$(zfs list -rt snapshot $dataset | awk -v to_del_id=$id ' BEGIN{ cnt=0 }{ ++cnt; if(cnt == to_del_id + 1) { printf("%s", $1); } } ')
		zfs destroy $to_del

		if [ $? -eq 0 ];
		then
			echo "Successfully delete snapshot $to_del in dataset $dataset"
		else
			error "Unable to delete the snapshot $to_del in dataset $dataset"
		fi
	fi
}

error()
{
	echo "Error: " $1
	exit 0
}

	#-------------------------------Main function starts here---------------------#
	#check if the main usage is correct
	arg_cnt=$#
	check_arg

	case $1 in

		--list)
			#          $1     $2            $3
			#./zbackup --list mypool/public    --> list all the snapshots in specified dataset
			#./zbackup --list mypool/public 2  --> list the snapshot with specified ID in specified dataset
			list $2 $3
			;;

		--delete)
			#          $1      $2             $3
			#./zbackup --delete mypool/public    --> list all the snapshots in specified dataset
			#./zbackup --delete mypool/public 2  --> delete the snapshot with specified ID in specified dataset
			delete $2 $3
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
	#-------------------------------Main function ends here---------------------#


