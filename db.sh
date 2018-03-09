#!/bin/bash
readonly DBMS_DIR="Databases";

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

###############################################

add_column(){

	current_DB=`pwd`
	table_name=$1
	
	read -p "Column name: " col_name
	read -p "Data type: " data_type
	read -p "Constrains? 'unique/not-null/default=value'(type constrains separted by spaces): " constrains	
	echo "$col_name $data_type $constrains" >> .$table_name

}

###############################################

add_primary(){

	current_DB=`pwd`
	table_name=$1
	
	read -p "Primary key name: " col_name
	read -p "Data type: " data_type
	echo "$col_name $data_type pimary_key" > .$table_name 
}


###############################################
edit_column(){

	table_name=$1

	read -p "Column: " col_name
	
	if grep -q "^$col_name.*$" ".$table_name"
	then
		read -p "Column name: " new_col_name
		read -p "Data type: " data_type
		read -p "Constrains? 'unique/not-null/default=value'(type constrains separted by spaces): " constrains	
		sed -i "s/^$col_name.*$/$new_col_name $data_type $constrains/g" ".$table_name"	
		test $? == 0 && echo "Column changed successfully"		 
		
	else
		echo "column doesn't exist"
	fi
}

###############################################

drop_column(){

	table_name=$1
	read -p "Column: " col_name

	if grep -q "^$col_name.*$" ".$table_name"
	then
		sed -i "/$col_name/d" ".$table_name"
		test $? == 0 && echo "Column dropped successfully"		 
		
	else
		echo "column doesn't exist"
	fi
}
###############################################

create_table(){

	read -p "Table name: " table_name	
	#current_DB=`pwd`
	state=1
	if test -f $table_name 
	then 
		echo "Can't create table. Already exists" 
		state=0 
	else 
		touch $table_name 
		touch .$table_name
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

	current_DB=`pwd`
	read -p "Table: " table_name	
	if test -f $table_name 
	then
		while true
		do
			echo -e  "\n+---------Table Menu-------------+"
			echo "| 1. Edit column                |"
			echo "| 2. Drop column                |"
			echo "| 3. Back                       |"
			echo "+-------------------------------+"
			read -p "Enter Choice: " n
			case $n in
			1) 
				edit_column $table_name 
				;;
			2)
				drop_column $table_name 
				;;
			3)
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
format_menu()
{
                 echo "+------format------+"
                 echo "|1.CSV             |"
                 echo "|2.Web page        |"
                 echo "+------------------+"

}
select_record()
{
	read -p "Table name: " table
	if test -f $table 
	then
		
		awk 'BEGIN { FS="|";print "\n+-------------Select--------------+";j=1 } { if(NR == 2) {
		for(i = 2; i < NF; i++) { 
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
                awk 'BEGIN { FS="|";print "\n+-------------Records-------------+\n1. All";j=2 } { if(NR == 2) {
                for(i = 2; i < NF; i++) {
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
			j=0
			b=()
			for i in ${fields[@]}
			do
			b+=($(awk -va="$i" 'BEGIN{FS="|"} { if(NR >= 2 && NR != 3) if($(a+1) == "       "|| $(a+1) == ""  ){ print "NULL"}else{gsub(/ /,"",$(a+1)); print $(a+1)} }' $table))
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
		 	echo -n ${b[$k]} "," 
			
			(( k+=$rows ))
			(( m++ ))
			done
			echo
			(( i++ ))
			done
			;;
			2)
			echo "<html><body><table border="1"> <tr>" > ../../display.html
			j=0
                	b=()
			for i in ${fields[@]}
			do
			echo
			awk -va="$i" 'BEGIN{FS="|"} { if(NR == 2 )  print "<th>"$(a+1)"</th>"}' $table >> ../../display.html
			done
			echo "</tr>" >> ../../display.html
			for i in ${fields[@]}
			do
			b+=($(awk -va="$i" 'BEGIN{FS="|"} { if(NR > 2 && NR != 3)  if($(a+1) == "       " || $(a+1) == "" ){ print "NULL"}else{gsub(/ /,"",$(a+1));  print $(a+1)} }' $table))
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
                        j=0
                        b=()
                        for i in ${fields[@]}
                        do
                        b+=($(awk -va="$option" -vb="$i" -vc="$regex" 'BEGIN{FS="|"} {for(j = 0 ; j<= NF ; j++) if( j == a) if($j ~ c) if($(b+1) == "       " || $(b+1) == ""  ){ print "NULL"}else{gsub(/ /,"",$(b+1)); print $(b+1)} }' $table))
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
                        echo -n ${b[$k]} "," 
                        (( k+=$rows ))
                        (( m++ ))
                        done
                        echo
                        (( i++ ))
                        done
                        ;;
                        2)
                        echo "<html><body><table border="1"> <tr>" > ../../display.html
                        j=0
                        b=()
                        for i in ${fields[@]}
                        do
                        echo
                        awk -va="$i" 'BEGIN{FS="|"} { if(NR == 2 )  print "<th>"$(a+1)"</th>"}' $table >> ../../display.html
                        done
                        echo "</tr>" >> ../../display.html
                        for i in ${fields[@]}
                        do
                        b+=($(awk -va="$option" -vb="$i" -vc="$regex" 'BEGIN{FS="|"} {for(j = 0 ; j<= NF ; j++) if( j == a) if($j ~ c) if($(b+1) == "       " || $(b+1) == ""   ){ print "NULL"}else{gsub(/ /,"",$(b+1)); print $(b+1)} }' $table))
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

#		for i in ${fields[@]}
#               do
#               awk -va="$option" -vb="$i" -vc="$regex" 'BEGIN{FS="|"} {for(j = 0 ; j<= NF ; j++) if( j == a) if($j ~ c) print $(b+1) }' $table
#               done
 
		
		fi

		 # for i in ${fields[@]}
		 # do
		 # echo  $i
		 # done
	else
	echo "Sorry table doesn't exist"
	fi
}


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
  
select_DB(){

	read -p "Database: " db
	state=1
	test -d $db && cd $db || state=0
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
  3);;
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

cd $DBMS_DIR
main_menu

