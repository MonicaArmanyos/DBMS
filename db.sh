#!/bin/bash

readonly DBMS_DIR="/home/iman/DBMS"

#create_table(){}


#alter_table(){}


show_databases(){

	
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


select_database(){

	selected_database=$1
	cd $DBMS_DIR/$selected_database
	echo "Database changed to $selected_database" 
}


#delete_record(){}

show_databases
read db
select_database $db
