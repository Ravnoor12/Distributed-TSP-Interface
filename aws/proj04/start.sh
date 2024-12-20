#!/usr/bin/bash

#weightType=$1
randseed=$2
trys=$3
batchjob=$4

echo "opening the file"
echo "$@"
weightType=$(echo "$1" | cut -c2)
path="/users/PWSU0510/w597rxs/workflow/"
(ssh w597rxs@owens.osc.edu "cd "$path" && bash $path/workflow.sh $weightType $randseed $trys $batchjob" &)

echo "proces started"


jobID=$(ssh w597rxs@owens.osc.edu "cd /users/PWSU0510/w597rxs/workflow/ && ls -td job_owens_* | head -n 1 | awk -F'_' '{print \$3}'")
echo "$jobID" > start_output
echo "$4" >> start_output
echo "$jobID"



#echo "I will fakking to call the owens workflow.sh"
#echo $@ > start_output
