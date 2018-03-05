#!/bin/bash

create_DB()
{
	read -p "Database name: " db
	if test -d $db
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
	break
	;;
  *)
	echo "Invalid option!"
  esac
  done
