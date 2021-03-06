#!/bin/bash

################################################################################
# create
# Create the new password. It will create the file if it is necessary.
################################################################################
create () {
    echo "Create function";
    git checkout $filename.asc
    
    if [ -f $filename.asc ]; then
       echo "$filename already exist"
       gpg -d $filename.asc > $filename
    else
       touch $filename
       echo "$filename created!"
    fi
    while read p; do
	mycompare="$(echo $p | awk '{ print $1;}')"
	if [ $mycompare == $site ]; then
	    echo "Site $site already exist"
	    exit
        fi
    done < $filename

    pw="$(openssl rand -base64 21)"
    line="$site $pw"
    echo "$line" >> $filename
    gpg -a -e -r $myrecp $filename
    git add $filename.asc
    rm $filename
    git commit -m"Added password for $site"
    echo "checked in file"
}

################################################################################
# get
# get the password.
################################################################################
get () {
    echo "get function";
    git checkout $filename.asc
    if [ -f $filename.asc ]; then
       gpg -d $filename.asc > $filename
    else
       echo "$filename Does not exist!"
       exit
    fi

    while read p; do
	compare="$(echo $p | awk '{print $1;}')"
	if [ $compare == $site ]; then
	    password="$(echo $p | awk '{print $2;}')"
	    echo "Password = $password"
	    echo $password | xclip -i
	    exit
	fi
    done < $filename
    }

################################################################################
# replace 
# Replace the password with a new one
################################################################################
replace () {
    echo "replace function";

    if [ -f .tmp.txt ]; then
	rm .tmp.txt
    fi

    while read p; do
	mycompare="$(echo $p | awk '{ print $1;}')"

	if [ $mycompare != $site ]; then
	    echo $p >> .tmp.txt
	    echo "keep: $p"
	else
	    echo "remove: $p"
        fi
    done < $filename

    rm $filename
    mv .tmp.txt $filename
    create
    }

################################################################################
# help 
# Show help file.
################################################################################
help () {
    echo "pw [command] [pwfile] [site]"
    echo "Example: pw -c passwd amazon.ca"
    echo "c = create"
    echo "g = get"
    echo "r = replace"
}

################################################################################
# 
# Main
#
################################################################################
# create the simple form first
command=$(basename "$0")

if [ ! -f ./pget ]; then
    ln -s ./pw.sh ./pget 
fi

if [ ! -f ./pset ]; then
    ln -s ./pw.sh ./pset 
fi

#-------------------------------------------------------------------------------
# Set paramaters for pget
echo "executing from:$command" 

if [ $command == "pget" ]; then
    if [ $command == "pget" ]; then
        command="-g"
    fi
    if [ $command == "pset" ]; then
        command="-c"
    fi
    filename="$USER"pw
    site=$1

    if [ "$#" -lt 1 ]; then
	    echo "!Error: We need 2 paramaters got: $#"
	    echo "Example: pget amazon.ca userforencrypt"
        echo "or: pw.sh passwd amazon.ca (Looks for the users key)"
	    exit 1
    fi
    
    # Check if the user is included
    if [ "$#" -eq 3 ]; then
	    myrecp=$2
    else
	    myrecp=$USER
    fi

    echo "Here is the command: filename: $filename command:$command site:$site myrecp: $myrecp"
#-------------------------------------------------------------------------------
# Set paramaters for default
else
    command=$1
    filename=$2
    site=$3

    # check for correct number of paramaters
    if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
	echo "!!!!!!!!!!!!!!!!!!!!!! Error: We need 3 or 4 paramaters"
	echo "Example: pw.sh -g passwd amazon.ca userforencrypt"
	echo "or: pw.sh -g passwd amazon.ca"
	exit 1
    fi
    
    # Check if the user is included
    if [ "$#" -eq 4 ]; then
        myrecp=$4
    else
	    myrecp=$USER
    fi
fi

echo $myrecp

#-------------------------------------------------------------------------------
case $command in
    -c) echo "Creating!"
	create
  ;;
    -g) echo "getting"
	get
  ;;
   -r) echo "Replace" 
       replace
  ;;
   -h) echo "help" 
       help
  ;;
   *) echo "!!!!!!!!!!!!!!!!!! Error: Command needs to be -c for create or -g for get or -r to replace"
      exit 1
      ;;
esac
