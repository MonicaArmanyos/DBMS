#!/bin/bash

readonly DBMS_DIR="/home/iman/DBMS"

###############################################

create_DB()
{
	read -p "Database name: " db
	if test -d $DBMS_DIR/$db
	then echo "Couldn't create database.Database already exits!"
	else
		mkdir $db
		if test -d $db
		then 
		echo "Database created successfully." 
		else
		echo "an error occured"
		fi
	fi
}

###############################################

drop_DB()
{
	read -p "Database name: " db
	if test -d $db
	then
	rm -r $db
	test -d $db && echo "Error occured" || echo "Database Dropped successfully"
	else
	echo "Database not found"
	fi
}

###############################################

add_column(){

	current_DB=`pwd`
	table_name=$1
	
	read -p "Column name: " col_name
	read -p "Constrains? 'unique/not-null/default=value'(type constrains separted by spaces): " constrains	
	echo "$col_name $constrains" >> $current_DB/.$table_name

}

###############################################

add_primary(){

	current_DB=`pwd`
	table_name=$1
	
	read -p "Primary key name: " col_name
	echo "$col_name pimary_key" > $current_DB/.$table_name 
}

###############################################

create_table(){

	read -p "Table name: " table_name	
	current_DB=`pwd`
	state=1
	if test -f $current_DB/$table_name 
	then 
		echo "Can't create table. Already exists" 
		state=0 
	else 
		touch $current_DB/$table_name 
		touch $current_DB/.$table_name
		test -f $current_DB/$table_name && echo "tbale $table_name created" || state=0
	fi
	if test $state == 1 
	then 
		add_primary $table_name
		while true
		do
			echo -e  "\n+---------Table Menu-------------+"
			echo "| 1. Add column                 |"
			echo "| 2. Back                       |"
			echo "+-------------------------------+"
			read -p "Enter Choice: " n
			case $n in
			1) 
				add_column $table_name 
				;;
			2)
				break
				;;
			*)
				echo "Invalid option!"
			esac
		done
	fi	
}

###############################################


#alter_table(){}

###############################################

#delete_record(){}

###############################################

show_tables(){
	
	current_DB=`pwd`
	ls > .tables
	#count=0
	tables=`awk ' { print $1 } ' .tables`
	#echo $databases
	echo
	echo "---------------"
	echo "Tables"
	echo "---------------"
	for table in $tables
	do
		test -f $current_DB/$table && echo "$table"
	done
	echo "---------------"
}

###############################################

show_DBs(){

	
	ls $DBMS_DIR > $DBMS_DIR/.databases
	#count=0
	databases=`awk ' { print $1 } ' $DBMS_DIR/.databases`
	#echo $databases
	echo "---------------"
	echo "Databases"
	echo "---------------"
	for db in $databases
	do
		#test -d $DBMS_DIR/$db && echo "$((++count))- $db"
		test -d $DBMS_DIR/$db && echo "$db"
	done
	echo "---------------"
}

###############################################

select_DB(){

	read -p "Database: " db
	state=1
	test -d $DBMS_DIR/$db && cd $DBMS_DIR/$db || state=0
	test $state == 1 && echo "Database changed to $db" || echo "Database doesn't exit"
	test $state == 1 && while true
	do
		echo -e  "\n+---------Database Menu-------------+"
		echo "| 1. Create Table               |"
		echo "| 2. Alter Table                |"
		echo "| 3. Drop Table                 |"
		echo "| 4. Show Tables                |"
		echo "| 5. Add record                 |"
		echo "| 6. Edit record                |"
		echo "| 7. Delete record              |"
		echo "| 8. Display table              |"
		echo "| 9. Sort table                 |"
		echo "| 10. Back                      |"
		echo "+-------------------------------+"
		read -p "Enter Choice: " n
		case $n in
		1)
			create_table
			;;
		2)
			alter_table
			;;
		3)
			drop_table
			;;
		4)
			show_tables
			;;
		5)
			add_record
			;;
		6)
			edit_record
			;;
		7)
			delete_record
			;;
		8)
			display_table
			;;
		9)
			sort_table
			;;
		10)
			break
			;;
		*)
			echo "Invalid option!"
		esac
	done	
}


###############################################

cd $DBMS_DIR
while true
do
	echo -e  "\n+---------Main Menu-------------+"
	echo "| 1. Select DB                  |"
	echo "| 2. Create DB                  |"
	echo "| 3. Rename DB                  |"
	echo "| 4. Drop DB                    |"
	echo "| 5. Show DBs                   |"
	echo "| 6. Exit                       |"
	echo "+-------------------------------+"
	read -p "Enter Choice: " n
	case $n in
	1)
		select_DB
		;;
	2)
		create_DB
		;;
	3)	;;
	4)
		drop_DB
		;;
	5)
		show_DBs
		;;
	6)
		cd ..
		break
		;;
	*)
		echo "Invalid option!"
	esac
done

###############################################




