#!/bin/bash
timestamp=`date +%H%M_%d%h%Y`
Path="/tmp"

#sourcing the properties file.
. /tmp/path.properties

EXIT() {
    if [$? != 0 ];then
        echo $1
        echo ""
        exit
    fi
	}

sourceDir_check() 
{
    for dir in "$@"
    do
        if [ ! -d $dir ];then
            echo " '$dir' doest not exist."
        else
            echo "Taking a tar backup. Please wait.."
	fi
     done
}

DestDir_check() {
    echo "Enter destination dir to place the tarred dir :";read dirname
    while [ ! -d $Path/$dirname ]
    do
        echo "No such dir found. Try again.. "; read dirname
    done
		}

echo "-------------------------------"
cat /tmp/path.properties 2> /dev/null
EXIT "Couldn't locate/read /tmp/path.properties. Script terminating.."

echo ""
DestDir_check

echo ""
echo "Tar all the above fileSystem in '$Path/$dirname'. (y/n)"
read opt
if [ $opt = y ];then
    echo "tarring up...."
    for i in `cat /tmp/path.properties | cut -f1 -d'='`
    do
        x=`echo $i`
        y='$'$x
        #eval is used to create/construct command by concatenating arguments.
        eval y='$'$x
        sourceDir_check $y
        /usr/bin/tar -cZf $Path/$dirname/$i.$timestamp.tar.gz $y 2>/dev/null
        echo "'$y' is tarred."
    done
else
    echo "Scripting terminating.."
    exit
fi
