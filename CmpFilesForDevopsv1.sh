#!/bin/bash

SourceDir="/Users/Muzakkir/PycharmProjects/Test"
check=$SourceDir"/check.txt"   # check.txt will have entries of all the sql files in SourceDir

findCksumCopy2temp() {

	# Usage :	
	# finds all sqls in the SourceDir and makes an entry of sql file names in a temp file called tmp.txt
	# loops thru file name in tmp and creates a new file with sql file name with its cksum in front of it, eg. example.sql ( 3282809881 )

	if [[ $(find $1 -maxdepth 1 -type f -name '*.'$2) ]];then
		basename `find $1 -maxdepth 1 -type f -name '*.'$2` > $1/tmp.txt
		for file in `cat $1/tmp.txt`
		do 
			echo "$file ( `cksum $file | awk '{print $1}'` )" >> $1/temp.txt 
		done
	else
		echo " => No sqls found"
		exit
	fi
}

rollback() {

        if [[ -f "$1".rollback.sql ]];then
                echo "\tExecuting rollback " $1.rollback.sql
                echo ""
        else
                echo "     "$1".rollback.sql does not exist."
                echo ""
        fi
}

Compare() {

	# Usgae :	
	# checks if the sqls in the directory are new then executes those sqls
	# If old sqls there, then compares latest cksum with the old cksum, incase of any difference the rollbacks are run and then the modified sqls are exceuted. 

	for f in "$@"
	do
		if [[ $(grep -w $f check.txt ) ]];then

			Latest_Cksum=`cksum $f | awk '{print $1}'`
			Checktxt_Cksum=`grep -w $f check.txt | awk '{print $3}'`

			if [ "$Checktxt_Cksum" != "$Latest_Cksum" ];then
				echo "   * "$f"'s cksum is different, looking for its rollback file.."
				f=`echo $f | cut -d"." -f1`
				rollback $f
			fi
		else	
			# below variable stores all the new sqls filenames in it.
			 new+='\t'$f'\n'
		fi
	done

	if [[ ! -z $new ]];then
		echo "Following are new sqls :"'\n'$new
	fi
	
}


findCksumCopy2temp $SourceDir sql

if [[ ! -s $check ]]; then
        echo "Check.txt is empty.."
        echo "Executing all the sql files.."
else
	echo ""
	echo " => Check.txt is not Empty."
        echo " => Comparing sql files in this directory with the filenames in check.txt.."
	echo ""
	Compare `cat $SourceDir/tmp.txt`	
fi

rm $SourceDir/tmp.txt 
mv $SourceDir/temp.txt $check



