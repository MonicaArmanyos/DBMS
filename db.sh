#!/bin/bash

readonly DBMS_DIR="Databases";

###############################################

create_DB()
{
	read -p "Database name: " db
	if test -d $db

	then echo "Couldn't create database. Database already exits!"

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

	table_name=$1

	read -p "Column name: " col_name

	while test "$col_name" == ""
	do	
		echo "Column name can't be empty!"
		read -p "Column name: " col_name
	done

	if grep -q "^$col_name.*$" ".$table_name" 
	then
		echo "Can't add column. Already exists!"

	else 
		read -p "Data type: " data_type

		while test "$data_type" == ""
		do	
			echo "Column data type can't be empty!"
			read -p "Data type: " data_type
		done
	
		read -p "Constrains? 'UNIQUE/NOTNULL'(type constrains separted by spaces): " constrains
		read -p	"Default value: " default

		sed -i "1s/$/|$col_name/" $table_name

		echo "$col_name|$data_type|$constrains|$default" >> .$table_name

		test "$default" == "" && default="null"
		sed -i "2,$ s/$/|$default/" $table_name
	fi
}

###############################################

add_primary(){

	table_name=$1	

	read -p "Primary key name: " col_name

	while test "$col_name" == ""
	do	
		echo "Primary key name can't be empty!"
		read -p "Primary key name: " col_name
	done

	read -p "Data type: " data_type

	while test "$data_type" == ""
	do	
		echo "Primary key data type can't be empty!"
		read -p "Data type: " data_type
	done

	echo "$col_name|$data_type|PK" >> .$table_name
	echo "$col_name" >> $table_name
}


###############################################

edit_column(){

	table_name=$1

	read -p "Column: " col_name

	while test "$col_name" == ""
	do	
		echo "Please enter column name!"
		read -p "Column: " col_name
	done
	
	if grep -q "^$col_name.*$" ".$table_name"
	then
		read -p "Column name: " new_col_name

		while test "$col_name" == ""
		do	
			echo "Column name can't be empty!"
			read -p "Column name: " new_col_name
		done

		read -p "Data type: " data_type

		while test "$data_type" == ""
		do	
			echo "Column data type can't be empty!"
			read -p "Data type: " data_type
		done

		read -p "Constrains? 'UNIQUE/NOTNULL'(type constrains separted by spaces): " constrains
		read -p	"Default value: " default
		sed -i "s/^$col_name.*$/$new_col_name|$data_type|$constrains|$default/g" ".$table_name"	
		sed -i "s/$col_name/$new_col_name/g" "$table_name"	
		test $? == 0 && echo "Column changed successfully"		 
		
	else
		echo "column doesn't exist"
	fi
}

###############################################

drop_column(){

	table_name=$1
	read -p "Column: " col_name

	while test "$col_name" == ""
	do	
		echo "Please enter column name!"
		read -p "Column: " col_name
	done

	if grep -q "^$col_name.*$" ".$table_name"
	then
		sed -i "/$col_name|/d" ".$table_name"
		test $? == 0 && echo "Column dropped successfully"

		column_num=`awk -F'|' -v col_name=$col_name '{ for(i=1;i<=NF;i++) { if($i == col_name){ print i } } }' "$table_name"`

		cut -d"|" -f-$((column_num - 1)),$((column_num + 1))- "$table_name" > tmp
		cat tmp > $table_name
		rm tmp
		
	else
		echo "column doesn't exist"
	fi
}

###############################################

create_table(){

	read -p "Table name: " table_name

	while test "$table_name" == ""
	do	
		echo "Please enter table name!"
		read -p "Table name: " table_name	
	done	

	#current_DB=`pwd`
	state=1
	if test -f $table_name 

	then 
		echo "Can't create table. Already exists" 
		state=0 
	else 
		touch $table_name 
		touch .$table_name
		echo "Field|Type|Constrains|Default" >> .$table_name
		test -f $table_name && echo "table $table_name created" || state=0
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

alter_table(){

	read -p "Table name: " table_name

	while test "$table_name" == ""
	do	
		echo "Please enter table name!"
		read -p "Table name: " table_name	
	done	

	if test -f $table_name 
	then
		while true
		do
			echo -e  "\n+---------Table Menu-------------+"
			echo "| 1. Add column                 |"			
			echo "| 2. Edit column                |"
			echo "| 3. Drop column                |"
			echo "| 4. Back                       |"
			echo "+-------------------------------+"
			read -p "Enter Choice: " n
			case $n in
			
			1)
				add_column $table_name 
				;;
			2) 
				edit_column $table_name 
				;;
			3)
				drop_column $table_name 
				;;
			4)
				break
				;;
			*)
				echo "Invalid option!"
			esac
		done	
	else
		echo "Table doen't exist"
	fi
		

}

###############################################

delete_record(){

	match_flag=0

	read -p "Table name: " table_name

	while test "$table_name" == ""
	do	
		echo "Please enter table name!"
		read -p "Table name: " table_name	
	done

	if test -f $table_name
	then
		
		#sed -i "/$col_name|/d" ".$table_name"
		
		read -p "certain value or regex? (type 'r' for regex or 'c' for certain value): " mode

		while test "$mode" == ""
		do
			read -p "certain value or regex? (type 'r' for regex or 'c' for certain value): " mode
		done

		if test $mode == "r"
		then
			awk -F'|' 'BEGIN {j=1} { if(NR == 1) { for(i = 1; i <= NF; i++) { print j" " $i;j++; } } }' "$table_name"
			read -p "Enter columns numbers separated by spaces to match with the pattern: " columns
			read -p "Enter pattern: " pattern
			matched_rows=()
			for col in $columns
			do
				matched_rows+=`awk -F'|' -v col=$col -v pat=$pattern '$col ~ pat { print } ' "$table_name"`
				matched_rows+=" "
			done
			for row in $matched_rows
			do
			 	sed -i "/$row/d" "$table_name"
				match_flag=1
			done	
		fi

		if test $mode == "c"
		then
			awk -F'|' 'BEGIN {j=1} { if(NR == 1) { for(i = 1; i <= NF; i++) { print j" " $i;j++; } } }' "$table_name"
			read -p "Enter columns numbers separated by spaces to match with the value: " columns
			read -p "Enter value: " value
			matched_rows=()
			for col in $columns
			do
				matched_rows+=`awk -F'|' -v col=$col -v value=$value '{ if($col == value) { print } } ' "$table_name"`
				matched_rows+=" "
			done
			for row in $matched_rows
			do
		 		sed -i "/$row/d" "$table_name"
				match_flag=1
			done
		fi

		test $match_flag -eq 0 && echo "No records found" || echo "Records deleted successfully"
	else
		echo "Table doesn't exist"
	fi
}

###############################################

format_menu()
{
                 echo "+------format------+"
                 echo "|1.CSV             |"
                 echo "|2.Web page        |"
                 echo "+------------------+"

}

#####################################################

select_record()
{
	read -p "Table name: " table
	if test -f $table 
	then
		
		awk 'BEGIN { FS="|";print "\n+-------------Select--------------+";j=1 } { if(NR == 1) {
		for(i = 1; i <= NF; i++) { 
		print j" " $i;
		j++;
                  }
                 } } END { print "+---------------------------------+"}' $table
		echo "Enter columns number: "
		IFS=" "  read -a fields
		field=""
		for i in ${fields[@]}
		 do
		 field="$field $i "
		 done      
                awk 'BEGIN { FS="|";print "\n+-------------Records-------------+\n1. All";j=2 } { if(NR == 1) {
                for(i = 1; i <= NF; i++) {
		gsub(/ /,"",$i); 
                 print j ". where " $i  " matches" ;
		 j++;
                  }
                 } } END { print "+---------------------------------+"}' $table

		 read -p "Enter option number: " option
                 if [ $option == 1 ]
		 then
                 format_menu
                 read -p "Enter format number: " format
			case $format in
			1)
			echo -n "" > ../../disp.csv
			j=0
			b=()
			for i in ${fields[@]}
			do
			b+=($(awk -va="$i" 'BEGIN{FS="|"} {if($0 == "") {} else {if($a == ""  ){ print "NULL"} else {gsub(/ /,"-",$a); print $a}}}' $table))
			(( j++ ))
			done
			i=0 
			rows=$(( ${#b[@]}/$j )) 
			while test $i -lt  $rows
			do
			m=0
			k=i
			while test $m -lt $j
			do
		 	echo -n ${b[$k]} "," >> ../../disp.csv 
			
			(( k+=$rows ))
			(( m++ ))
			done 
			echo >> ../../disp.csv
			(( i++ ))
			done
			cat  ../../disp.csv
			;;
			2)
			echo "<html><body><table border="1"> <tr>" > ../../display.html
			j=0
                	b=()
			for i in ${fields[@]}
			do
			echo
			awk -va="$i" 'BEGIN{FS="|"} { if(NR == 1 )  print "<th>"$a"</th>"}' $table >> ../../display.html
			done
			echo "</tr>" >> ../../display.html
			for i in ${fields[@]}
			do
			b+=($(awk -va="$i" 'BEGIN{FS="|"} { if(NR > 1) if($0 == "") {} else {if($a == ""  ){ print "NULL"} else {gsub(/ /,"-",$a); print $a}}}' $table))
			(( j++ ))
			done
			i=0
			rows=$(( ${#b[@]}/$j ))
			while test $i -lt  $rows
			do
                        m=0
                        k=i
			echo "<tr>" >> ../../display.html
                        while test $m -lt $j
                        do
                        echo "<td>${b[$k]}</td>" >> ../../display.html 
                        (( k+=$rows ))
                        (( m++ ))
                        done
			echo "</tr>" >> ../../display.html
			(( i++ ))
			done
			echo "</table></body></html>" >> ../../display.html
			xdg-open ../../display.html
			;;
			*) echo "Invalid format !"
			esac
		
		else 
		read -p "Enter regex :" regex 
		format_menu
		 read -p "Enter format number: " format

                        case $format in
                        1)
			echo -n "" > ../../disp.csv
                        j=0
                        b=()
                        for i in ${fields[@]}
                        do
                        b+=($(awk -va="$option" -vb="$i" -vc="$regex" 'BEGIN{FS="|"} {for(j = 1 ; j <= NF ; j++) if( j == a-1 ) if($j ~ c) if($b == ""  ){ print "NULL"} else{ gsub(/ /,"",$b); print $b}  }' $table))
                        (( j++ ))
                        done
                        i=0
                        rows=$(( ${#b[@]}/$j ))
                        while test $i -lt  $rows
                        do
                        m=0
                        k=i
                        while test $m -lt $j
                        do
                        echo -n ${b[$k]} "," >> ../../disp.csv 
                        (( k+=$rows ))
                        (( m++ ))
                        done
                        echo >> ../../disp.csv
                        (( i++ ))
                        done
			cat ../../disp.csv
                        ;;
                        2)
                        echo "<html><body><table border="1"> <tr>" > ../../display.html
                        j=0
                        b=()
                        for i in ${fields[@]}
                        do
                        echo
                        awk -va="$i" 'BEGIN{FS="|"} { if(NR == 1 )  print "<th>"$a"</th>"}' $table >> ../../display.html
                        done
                        echo "</tr>" >> ../../display.html
                        for i in ${fields[@]}
                        do
                        b+=($(awk -va="$option" -vb="$i" -vc="$regex" 'BEGIN{FS="|"} { if(NR > 1){ for(j = 1 ; j <= NF ; j++) if( j == a-1 ) if($j ~ c) if($b == ""  ){ print "NULL"} else{ gsub(/ /,"",$b); print $b}  } }' $table))
                        (( j++ ))
                        done
                        i=0
                        rows=$(( ${#b[@]}/$j ))
                        while test $i -lt  $rows
                        do
                        m=0
                        k=i
                        echo "<tr>" >> ../../display.html
                        while test $m -lt $j
                        do
                        echo "<td>${b[$k]}</td>" >> ../../display.html
                        (( k+=$rows ))
                        (( m++ ))
                        done
                        echo "</tr>" >> ../../display.html
                        (( i++ ))
                        done
                        echo "</table></body></html>" >> ../../display.html
                        xdg-open ../../display.html
                        ;;
                        *) echo "Invalid format !"
                        esac


 
		
		fi
	else
	echo "Sorry table doesn't exist"
	fi
}

#####################################################

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
		test -f $table && echo "$table"
	done
	echo "---------------"
}

###############################################

show_DBs(){

	
	ls  > ../.databases
	#count=0
	databases=`awk ' { print $1 } ' ../.databases`
	#echo $databases
	echo "---------------"
	echo "Databases"
	echo "---------------"
	for db in $databases
	do
		
		test -d $db && echo "$db"
	done
	echo "---------------"
}

#####################################################

drop_table()
{
	read -p "Enter table name :" table
	if test -f $table 
	then
	rm $table
	rm .$table
	if test -f $table  
	then 
		 echo "Could not drop table" 
		
	else
                if test -f .$table 
                then
                         echo "Could not drop table" 
                else 
                        echo "Table dropped succesfully"
                fi

	fi
	else
	echo "table doesn't exit"
	fi
}

#####################################################

sort_table()
{
	read -p "Enter table name :" table
	if test -f $table
	then
		echo "+------------Sort------------+"
		echo "|1.Ascendingly               |"
		echo "|2.Decendingly               |"
		echo "+----------------------------+"
		read -p "Choose option number :" option
                awk 'BEGIN { FS="|";print "\n+-------------Select--------------+";j=1 } { if(NR == 1) {
                for(i = 1; i <= NF; i++) { 
                print j" " $i;
                j++;
                  }
                 } } END { print "+---------------------------------+"}' $table
		read -p "Enter field number to sort according to :" field
		 b=`awk -va="$field" 'BEGIN { FS="|"} { if(NR == a+1) print $2 }' .$table`
		case $option in
		1)
			awk '{ if(NR == 1) print }' $table
			echo
			if [ $b == "str" ]
			then
			tail -n +2 $table | sort   -t "|" -k $field 
			else
	
			 tail -n +2 $table | sort -n  -t "|" -k $field 
			fi
			;;
		2)
			awk '{ if(NR == 1) print }' $table
			echo
			if [ $b == "str" ] 
			then
			 tail -n +2 $table | sort -r  -t "|" -k $field 
			else
			 tail -n +2 $table | sort -nr  -t "|" -k $field 
			fi
			;;
		*) echo "Invalid option"
		esac

	else
		echo "Sorry, table not found"
	fi
	
}

######################################################  

		
######################################################  

###############################################

displayTable(){
read -p "Enter table name:" tableName
 if  [ ! -f $tableName ]
     then
    echo "Table $tableName does not  existed ,choose another Table"
 else
 cat .$tableName
  fi
}

###############################################

renameDB(){
read -p "Enter current database name:" dbName
read -p "Enter new database name:" newdbName
 mv $dbName $newdbName
  if [[ $? == 0 ]]
then
    echo "Database Renamed Successfully"
  else
    echo "Error Renaming Database"
fi
}

###############################################

select_DB(){

	read -p "Database: " db
	state=1
	test -d $db && cd $db || state=0
	test $state == 1 && echo "Database changed to $db" || echo "Database doesn't exit"
	test $state == 1 && while true
	do
		echo -e  "\n+-------Database Menu-----------+"
		echo "| 1. Create Table               |"
		echo "| 2. Alter Table                |"
		echo "| 3. Drop Table                 |"
		echo "| 4. Show Tables                |"
		echo "| 5. Add record                 |"
		echo "| 6. Edit record                |"
		echo "| 7. Delete record              |"
		echo "| 8. Display table              |"
		echo "| 9. Sort table                 |"
		echo "| 10. Select record(s)          |"
		echo "| 11. Back                      |"
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
			updateTable
			;;
		7)
			delete_record
			;;
		8)
			displayTable
			;;
		9)
			sort_table
			;;
		10)
			select_record
			;;

		11)
			break
			;;
		*)
			echo "Invalid option!"
		esac
	done	
}

###############################################

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
	select_DB
	;;
  2)
	create_DB
	;;
  3)
	renameDB
	;;
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
}

###############################################

cd $DBMS_DIR
main_menu


