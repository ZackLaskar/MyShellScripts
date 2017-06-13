#!/bin/sh

SourceDir="/Users/Muzakkir/PycharmProjects/Test"
check=$SourceDir"/check.txt"   # check.txt will have entries of all the sql files in SourceDir

# Below command finds all sqls in the SourceDir and makes an entry of sql file names in a temp file called tmp.txt

basename `find $SourceDir -maxdepth 1 -type f -name '*sql'` > $SourceDir/tmp.txt


if [[ ! -s $check ]]; then	
	echo "Check.txt is empty.."
	echo "Executing all the sql files.."
else
	echo ""
	echo "Check.txt is not Empty."
	echo "Comparing sql files in this directory with the files names in check.txt.."
	# grep -vf get the diff between contents of the two files, check.txt & tmp.txt should be in same order in the cmd.
	
	if [[ $(grep -vf check.txt tmp.txt) ]]; then
		echo ""
		echo "New Sql files found."
		echo "Exceuting only these sql file(s).." 
		grep -vf check.txt tmp.txt
	else
		echo "No new sql filenames found"
	fi

fi

mv $SourceDir/tmp.txt $check
