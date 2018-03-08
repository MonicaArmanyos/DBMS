#!/bin/bash

#create_table(){}


#alter_table(){}


show_databases(){

	DBMS_DIR="/home/iman/DBMS"
	ls $DBMS_DIR > $DBMS_DIR/.databases
	count=0
	databases=`awk ' { print $1 } ' $DBMS_DIR/.databases`
	#echo $databases
	for db in $databases
	do
		test -d $DBMS_DIR/$db && echo "$((++count))- $db"
	done
}


#select_database(){}


#show_databases(){}


#delete_record(){}

show_databases

