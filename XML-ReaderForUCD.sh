#!/bin/ksh

# script is for an urbancode deploy process template which reads XML and does stuff it needs to do.
 

IFS="," read -rA LocalQueueName <<< ${p:XMLReader/MQ.localQueues.localQname}
IFS="," read -rA LocalQP <<< ${p:XMLReader/MQ.localQueues.localQP}
IFS="," read -rA aliasQueueName <<< ${p:XMLReader/MQ.aliasQueues.alQname}
IFS="," read -rA alQsomeProp <<< ${p:XMLReader/MQ.aliasQueues.alQsomeProp}

echo ""
echo 'Length of LocalQueueName :' ${#LocalQueueName[@]}
echo ""

if [[ ${#LocalQueueName[@]} == ${#LocalQP[@]} ]];then

    for ((i=0;i<${#LocalQueueName[@]};i++));do
        echo "${LocalQueueName[i]} ${LocalQP[i]}"
    done

else
    echo 'Length of arrays not same.'
    exit 1
fi
    


echo ""
echo 'Length of aliasQueueName :' ${#aliasQueueName[@]}
echo ""
if [[ ${#aliasQueueName[@]} == ${#alQsomeProp[@]} ]];then

    for ((i=0;i<${#aliasQueueName[@]} ;i++));do
        echo "${aliasQueueName[i]} ${alQsomeProp[i]}"
    done

else
    echo 'Length of the arrays are not same.'
   exit 1
fi



