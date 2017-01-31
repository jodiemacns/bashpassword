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
    if [ -f $filename ]; then
       git checkout $filename
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
    echo "Example: pw -c passwd.gpg amazon.ca"
    echo "c = create"
    echo "g = get"
    echo "r = replace"
}

################################################################################
# 
# Main
#
################################################################################

#-------------------------------------------------------------------------------
# Set paramaters for pget
if [ $0 == "pget" ];then
   command="-c"    
    filename=$1
    site=$2

    if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
	echo "!!!!!!!!!!!!!!!!!!!!!! Error: We need 3 or 4 paramaters"
	echo "Example: pget passwd amazon.ca userforencrypt"
	echo "or: pw.sh passwd amazon.ca"
	exit 1
    fi
    
    # Check if the user is included
    if [ "$#" -eq 3 ]; then
	myrecp=$3
    else
	myrecp=$USER
    fi
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
