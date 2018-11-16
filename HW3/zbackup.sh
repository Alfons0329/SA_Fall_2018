#!/bin/sh

data=""
id=""
filename=""
rotate_cnt=""
arg_cnt=0
check_id()
{
	case $id in

		[0-9]*) #regex repeat
			;;

		'')
			;;

		*)
			error "Invalid ID number!!"
			;;
	esac
}
create()
{

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
			dataset=$1

			create $2
			;;
	esac


}


