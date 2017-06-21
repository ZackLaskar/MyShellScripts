#!/bin/ksh

timestamp=`date +%m%h%y.%H%M%S`
SourceDir="/Users/Muzakkir/Test"
check=$SourceDir"/check.txt"   # check.txt will have entries of all the sql files in SourceDir

#if check.txt is empty then find all the sqls ($2) at path ($1) and executes them and makes an entry with cksum in check.txt eg. 1.sql ( 987987495 )
# also creates a sql.txt with all the sqls entries only. 

findCksumCopy2temp() {

        	if [[ $(find $1 -maxdepth 1 -type f -name '*.'$2) ]];then
                	find $1 -maxdepth 1 -type f -name '*.'$2 -exec basename {} \; > $1/sql.txt
               		for file in `cat $1/sql.txt | grep -v rollback`
               		do
				i=`echo $file | cut -d"." -f1`
	
				if [[ -f $1/"$i".rollback.sql ]];then 
                        		echo "$file ( `cksum $file | awk '{print $1}'` )" >> $1/temp.txt
				else
					echo $file "doesn't have rollback."
				fi

                	done
        	else
                	echo " => No sqls found"
                	exit
        	fi
		
		if [[ ! -f $1/temp.txt ]];then
			echo "No rollbacks found for the sqls, hence sqls will not be executed.."
			echo ""
		fi
}

#checks for any new sqls in the source dir

checkForNewSqls() {

		findCksumCopy2temp $SourceDir sql
 
		if [[ $(grep -vf check.txt temp.txt) ]]; then
			newfiles=`grep -vf check.txt temp.txt`
			if [[ ! -z $newfiles ]];then 
				echo "New Sql files found."
				echo "Exceuting these sql file(s).." 
				echo $newfiles
			fi
		else
			echo ""
			echo "No new sql filenames found"
			echo ""
		fi
}
		


rollback() {
	for i in "$@"
	do
		i=`echo $i | cut -d"." -f1`
        	if [[ -f "$i".rollback.sql ]];then
                	echo "\tExecuting rollback " $i.rollback.sql
                	echo ""
        	else
                	echo "     "$i".rollback.sql does not exist."
                	echo ""
        	fi
	done
}

#if check.txt is not empty then this functions takes sql from sql.txt and compares with sqls in the dir for any cksum changes
#on finding any cksum change rollback function runs the rollback of sqls with changed ckum and missing sqls. 

Compare() {
	counter=0
	for f in "$@"
	do
		if [[ $(find $SourceDir -maxdepth 1 -type f -name $f) ]];then

	                Latest_Cksum=`cksum $f | awk '{print $1}'`
                        Checktxt_Cksum=`grep -w $f check.txt | awk '{print $3}'`

                        if [ "$Checktxt_Cksum" != "$Latest_Cksum" ];then

				echo "   * "$f"'s cksum is different, looking for its rollback file.."
                                rollback $f
				counter+=1
			fi
		else
			missingSqls+='\t'$f'\n'
		fi
	done

	if [[ $counter == 0 ]];then
		echo "Cksum comparison between sql in check.txt and sqls in the sourcedir have no difference"
	fi
	
	if [[ ! -z $missingSqls ]];then
                echo "Following sqls are missing, executing their rollbacks :"'\n'$missingSqls
		rollback `echo $missingSqls`
        fi
	
	#After comparing check.txt with sql in source dir, below function checks for any new sqls.
	
	checkForNewSqls
}	

# first if condition checks if check.txt is emtpy, then finds and runs all the sqls, makes an entry in check.txt.
# if check.txt is not empty compare function investigate for any cksum difference or missing sqls between source dir and check.txt, accordingly runs rollback
# and then  
main() {

	if [[ ! -f $SourceDir/check.txt ]];then
		touch $SourceDir/check.txt
	fi
	
	if [[ ! -s $check ]]; then
		echo ""
        	echo "Check.txt is empty."
		echo "Scanning Source dir for sql and sql rollbacks.."
		findCksumCopy2temp $SourceDir sql
		if [[ -f $SourceDir/temp.txt ]];then
			mv $SourceDir/temp.txt $check
			echo "Executing all the sql files.."	
			cat check.txt | awk '{print $1}'
		fi
	else
		echo ""
		echo "Check.txt is not Empty."
        	echo "Comparing sql files in this directory with the filenames in check.txt.."
		echo ""
		Compare `cat $SourceDir/check.txt| awk '{print $1}' | grep -v rollback`
		mv $SourceDir/temp.txt $check
	fi


}

main | tee CmpFilesForDevopsv2.log.$timestamp
