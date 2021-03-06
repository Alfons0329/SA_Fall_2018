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


create_snap()
{
	#echo "Function create snapshot d1 $1 d2 $2"
	#declare some required vars
	dataset=$1 #what the name for back up
	rot_cnt=$2 #rotation count

	#check if the dataset is illegal
	check_dataset $dataset
	#check if the rotate count number is illegal
	check_id $rot_cnt

	#adjust the rotate count, if not specified rotate count, just set it as 20
	if [ -z $rot_cnt ] ; 
	then 
		rot_cnt=20; 
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
		echo "Current snapshot >= the rotation count, now delete the $(($snap_cnt-$rot_cnt+1)) snaps"
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
	zfs snapshot "$dataset@$timestamp"

	#create snapshot
	if [ $? -eq 0 ];
	then
		echo "Successfully create snapshot $i in dataset $dataset time $timestamp"
	else
		error "Unable to create the snapshot $i in dataset $dataset"
	fi


}

list_snap()
{
	dataset=$1

	#if specified dataset, list all of the specified dataset, otherwise, list all the snapshots in all dataset
	if [ -z $dataset ];
	then
		printf "%s\t\t%s\t\t%s\t\n" "ID" "Dataset" "Time"
		for cnt in 1 2 3;
		do
			
			case $cnt in
				1)
					dataset="mypool/hidden"
					;;
				2)
					
					dataset="mypool/public"
					;;
				3)
					dataset="mypool/upload"
					;;
				*)
					;;
			esac

			zfs list -t snapshot | grep $dataset | awk 'BEGIN{ cnt=0 }{ ++cnt; if(cnt >= 1) { printf("%d@\t%s\t\n", cnt-1, $1); } } ' | awk ' BEGIN { FS="@"; cnt=0 } { printf("%d\t%s\t%s\t\n", NR, $2, $3)} '
		done
	else
		check_dataset $dataset
		printf "%s\t\t%s\t\t%s\t\n" "ID" "Dataset" "Time"
		zfs list -t snapshot | grep $dataset | awk 'BEGIN{ cnt=0 }{ ++cnt; if(cnt >= 2) { printf("%d@\t%s\t\n", cnt-1, $1); } } '| awk ' BEGIN { FS="@"; cnt=0 } { printf("%d\t%s\t%s\t\n", ++cnt, $2, $3)} '
	fi

}

delete_snap()
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

export_snap()
{
	dataset=$1
	id=$2

	#id default to 1
	if [ -z $id ];
	then
		id=1
	fi

	check_id $id
	check_dataset $dataset

	#get the export data with specified id, cut the format of dataset@date without detailed time 
	to_export=$(zfs list -rt snapshot $dataset | awk -v to_exp_id=$id ' BEGIN{ cnt=0 }{ ++cnt; if(cnt == to_exp_id + 1) { printf("%s", $1); } } ')
	target_dir=$(echo $to_export | cut -d '_' -f 1)
	target_dir="snapshot_send/$dataset"

	#make the target dir according to dataset, send to it, compress and encrypt
	mkdir -p snapshot_send
	mkdir -p $target_dir
	target_file=$(echo $to_export | cut -d '@' -f 2)
	zfs send $to_export > $target_dir/$target_file && \
		xz -z $target_dir/$target_file && \
		openssl enc -aes-256-cbc -in $target_dir/$target_file.xz -out $target_dir/$target_file.xz.enc

	#output the result if success
	if [ $? -eq 0 ];
	then
		echo "Successfully export ID $id in $dataset to $target_dir/$target_name "
	fi

	#remove the unnecessary file
	rm -f $target_dir/$target_file.xz
}

import_snap()
{
	#check if the file to be imported or the dataset exists
	target_file=$1
	dataset=$2
	check_dataset $dataset
	if ! [ -e $target_file ];
	then
		error "$target_file , No such file to import"
	fi

	#decrypt, remove '.enc' then decompress and finally import to the specified dataset
	timestamp=`date +"%Y-%m-%d_%H:%M:%S"`
	to_do=$(echo $target_file | cut -d '.' -f 1)
	openssl enc -d -aes-256-cbc -in $to_do.xz.enc -out $to_do.xz &&\
		xz -d $to_do.xz

	#delete the snap before receive it
	delete_snap $dataset
	zfs receive -F "$dataset@$timestamp" < $to_do

	#output the result if success
	if [ $? -eq 0 ];
	then
		echo "Successfully import $target_file to $dataset in snapshot with name $dataset@$timestamp "
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
			#./zbackup --list 				   --> list all the snapshots in all dataset
			#./zbackup --list mypool/public    --> list all the snapshots in specified dataset
			list_snap $2 
			;;

		--delete)
			#          $1      $2             $3
			#./zbackup --delete mypool/public    --> list all the snapshots in specified dataset
			#./zbackup --delete mypool/public 2  --> delete the snapshot with specified ID in specified dataset
			delete_snap $2 $3
			;;

		--export)
			#          $1      $2             $3
			#./zbackup --export mypool/public 2  --> export the snapshot with specified ID in specified dataset
			export_snap $2 $3
			;;

		--import)
			#          $1		$2										$3
			#./zbackup --import snapshot_send/mypool/public/timstamp.xz	mypool/public -->import the snapshot with specified sent file in another pool
			import_snap $2 $3
			;;


		'')
			error "Missing argument!!"
			;;

		*)
			#default, create the dataset $1 is the name and $2 is the max rotate count of that data set
			create_snap $1 $2
			;;
	esac
	#-------------------------------Main function ends here---------------------#


