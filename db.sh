#!/bin/bash

readonly DBMS_DIR="/home/iman/DBMS"

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
  1);;
  2)
	create_DB
	;;
  3);;
  4)
	drop_DB
	;;
  5);;
  6)
	cd ..
	break
	;;
  *)
	echo "Invalid option!"
  esac
  done

######################

#create_table(){}


#alter_table(){}


show_DBs(){

	
	ls $DBMS_DIR > $DBMS_DIR/.databases
	#count=0
	databases=`awk ' { print $1 } ' $DBMS_DIR/.databases`
	#echo $databases
	for db in $databases
	do
		#test -d $DBMS_DIR/$db && echo "$((++count))- $db"
		test -d $DBMS_DIR/$db && echo "$db"
	done
}


select_DB(){

	selected_database=$1
	cd $DBMS_DIR/$selected_database
	echo "Database changed to $selected_database" 
}


#delete_record(){}

show_DBs
read db
select_DB $db
