#!/bin/bash

SourceDir="/Users/Muzakkir/PycharmProjects/Test"
check=$SourceDir"/check.txt"   # check.txt will have entries of all the sql files in SourceDir

# Below command finds all sqls in the SourceDir and makes an entry of sql file names in a temp file called tmp.txt

findCksumCopy2temp () {

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
	#rm $1/tmp.txt
}


Compare() {

	for f in "$@"
	do
		if [[ $(grep -w $f check.txt ) ]];then

			Latest_Cksum=`cksum $f | awk '{print $1}'`
			Checktxt_Cksum=`grep -w $f check.txt | awk '{print $3}'`

			if [ "$Checktxt_Cksum" != "$Latest_Cksum" ];then
				echo "   * "$f"'s cksum is different"
				f=`echo $f | cut -d"." -f1`
				echo "   * executing the "$f".rollback.sql"
			fi
		else	
			# below variable stores all the new sqls filenames in it.
			 new+='\t'$f'\n'
		fi
	done

	if [[ ! -z $new ]];then
		echo "Following are new sqls :"'\n'$newa
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
	Compare `cat tmp.txt`	
fi

mv $SourceDir/temp.txt $check