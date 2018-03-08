#!/bin/bash

#create_table(){}


#alter_table(){}


show_databases(){

	DBMS_DIR="/home/DBMS"
	databases=`ls`
	count=0
	for db in $databases
	do
		test -d $db && echo "((++$count))- $db"
	done



}


#select_database(){}


#show_databases(){}


#delete_record(){}

show_databases

