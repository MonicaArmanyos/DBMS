#!/bin/bash
readonly DATABASES="Databases";

create_DB()
{
	read -p "Database name: " db
	if test -d $DATABASES/$db
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
select_record()
{
	 read -p "Table name: " table
	if test -f $table 
	then
		awk 'BEGIN { FS="|";print "\n+-------------Select--------------+"; } { if(NR == 2) {
		 for(i = 2; i < NF; i++) { 
		print "	" $i;
                  }
                 } } END { print "+---------------------------------+"}' $table
	         echo "Enter columns: "
		 IFS=" "  read -a fields
      
                awk 'BEGIN { FS="|";print "\n+-------------Records-------------+\n1. All";j=2 } { if(NR == 2) {
                 for(i = 2; i < NF; i++) {
		gsub(/ /,"",$i); 
                 print j ". where " $i  " =" ;
		 j++;
                  }
                 } } END { print "+---------------------------------+"}' $table

		 read -p "Enter option number: " option
                 if [ $option == 1 ]
		 then
                 echo "+------format------+"
		 echo "|1.CSV             |"
                 echo "|2.Web page        |"
                 echo "+------------------+"
                  read -p "Enter format number: " format
		case $format in
		1) awk 'BEGIN { FS="|"; OFS=","} { if(NR > 2) { print $0 }}' $table
		2);;
		*) echo "Invalid format !"
		esac

		fi

		 # for i in ${fields[@]}
		 # do
		 # echo  $i
		 # done
	else
	echo "Sorry table doesn't exist"
	fi
}

table-menu(){
  while true
  do
  echo -e  "\n+----------table Menu-----------+"
  echo "| 1. Create table               |"
  echo "| 2. Select record(s)           |"
  echo "| 3. Edit record                |"
  echo "| 4. Delete record              |"
  echo "| 5. Sort table                 |"
  echo "| 6. Alter table                |"
  echo "| 7. Delete Record              |"
  echo "| 8. Add Record                 |"
  echo "| 9. Display table              |"
  echo "| 10. Drop table                |"
  echo "| 11. Exit                      |"
  echo "+-------------------------------+"
  read -p "Enter Choice: " n
  case $n in
 1);;  
 2)
select_record
;;
  3)
        ;;
  4);;
  5)
        ;;
  6);;
  7);;
  8);;
  9);;
  10);;
  11)
        cd ..
        break
        ;;
  *)
        echo "Invalid option!"
  esac
  done
}

main_menu(){
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
cd Students
table-menu
;;
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
}

cd $DATABASES
main_menu

