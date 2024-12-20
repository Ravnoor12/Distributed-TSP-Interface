#!/usr/bin/bash
# name: Ravnoor Singh
# wNumber: w597rxs
# Project name: Proj03
# Assigned: Oct 29
# Due date: Nov 14
# Tested on: fry
fry='w597rxs@fry.cs.wright.edu'
owens='w597rxs@owens.osc.edu'
aws='ubuntu@3.217.212.133'
awspemfilepath='~w597rxs/aws/sshKeyFor7380.pem' #on fry
wnumber=$(echo "$owens" | awk -F'[@]' '{print $1}')
Pnumber='PWSU0510'
#params needed for the program to run
weightType=$1
#initialGuess=$2
randseed=$2
trys=$3
batchjob=$4

touch STARTED
rm "FINISHED"
function getCurrentBest() {
weightType=$1
distFile="database0$weightType.txt"
minDist=$(ssh "$owens" "tail -n 5 /users/PWSU0471/nehrbajo/proj03data/$distFile | head -n 1")
echo "$minDist"
}

function createInitialFile(){
distFile="database0$weightType.txt"
minDist=$(ssh "$owens" "tail -n 5 /users/PWSU0471/nehrbajo/proj03data/$distFile | head -n 1")

path=$(ssh "$owens" "tail -n 4 /users/PWSU0471/nehrbajo/proj03data/$distFile | head -n 1")
if [ -f "initialGuess.pickle" ]; then
    echo "Removing existing pickle file"
    rm "./initialGuess.pickle"
fi

python3 - <<EOF
import pickle

file_path = "./initialGuess.pickle"

with open(file_path, "wb") as f:
    pickle.dump($minDist, f)
    pickle.dump($path,f)

EOF

}

function dist_fromPickle(){
dist=$(python3 - <<EOF
import pickle
import sys
file_path = "./initialGuess.pickle"
with open(file_path, "rb") as f:
        pickleDist = pickle.load(f)
        picklePath = pickle.load(f)
        print(pickleDist)
EOF
        )
echo $dist
}

function getResults(){
owenfile=$1
owens_output_file="/users/$Pnumber/$wnumber/workflow/$owenfile"
#echo "1st $fry_output_file"
#echo "1st $owens_output_file"

owens_distance=$(head -n 1 "$owens_output_file")
#min_platform=""
#echo "fry dist :  $fry_distance "
#echo "owen dist : $owens_distance"
min_distance="$owens_distance"
min_platform="OWENS"

echo "$min_distance $min_platform"
}

if [ "$#" -lt 4 ]; then
    echo "$@"
    echo "inputs are less than 4, please check and rerun"
    exit 
fi 

if [ "$#" -gt 4 ]; then
    echo "checking if inputs are more than 4"
    echo "wrong inputs"
    exit
fi

createInitialFile

temp_dist=$(dist_fromPickle)
factor=0
initialGuess=("initialGuess.pickle")
START=1
END=$batchjob
if [ -f "savedState.pickle" ]; then
    echo "Saved state found, loading values..."

    readState=$(python3 - <<EOF
import pickle
with open("savedState.pickle", "rb") as f:
    state = pickle.load(f)
    print(state["ITERNATION_STATE"])
    print(state["WEIGHT"])
    print(state["END"])
    print(state["RAND_SEED"])
    print(state["PICKLE_FILE_NAME"])
    print(state["NO_OF_TRYS"])
EOF
    )
    echo "reading the vaalues from saved state : $readState"
    START=$(echo "$readState" | sed -n '1p')
    WEIGHT=$(echo "$readState" | sed -n '2p')
    END=$(echo "$readState" | sed -n '3p')
    RANDSEED=$(echo "$readState" | sed -n '4p')
    PICKLEFILE=$(echo "$readState" | sed -n '5p')
    NOOFTRYS=$(echo "$readState" | sed -n '6p')
    cp "$PICKLEFILE" "$initialGuess"
    weightType=$WEIGHT
    #cp "initialGuess.pickle" "$initialGuess"
    randseed=$RANDSEED
    trys=$NOOFTRYS

    echo "new values $randseed $trys $WEIGHT"
    rm "savedState.pickle"
fi


for (( batch=$START; batch<=$END; batch++ ))
do

if [ "$factor" -gt 0 ]; then
  randseed=$((randseed + factor * 16))
fi

touch "running_$batch"

echo "start : $START end: $END"
echo "values of variable $weightType $initialGuess $randseed $trys"

owens_job_id=$(sbatch owensTemplate.sbatch "$weightType" "$initialGuess" "$randseed" "$trys" "$batch" | awk '{print $4}')
echo $owens_job_id

echo "$owens_job_id" >> process_ids.txt

bestDistance=$(getCurrentBest $weightType)

owens_dir="/users/$Pnumber/$wnumber/workflow/job_owens_$owens_job_id"

while ! test -f "$owens_dir/FINISHED" || test -f "$owens_dir/STARTED"; do
    echo "Waiting for owen job to complete..."
    sleep 3
done


result=$(getResults "owen_output")
#echo $result
owen_bestDist=$(echo "$result" | awk '{print $1}')

cp "/users/$Pnumber/$wnumber/workflow/job_owens_$owens_job_id/best.pickle" "best_$batch.pickle"

cp "best_$batch.pickle" "$initialGuess"
cp "best_$batch.pickle" "bestIFoundSoFar0$weightType.pickle"

if [ "$owen_bestDist" -ge "$temp_dist" ] && [ "$owen_bestDist" -ge "$bestDistance" ]; then
  factor=$((factor + 1))
fi


if [ "$owen_bestDist" -lt "$bestDistance" ]; then
        echo "updating the database"
        data=$(python3 - <<EOF
import pickle
import sys
file_path = "./initialGuess.pickle"
with open(file_path, "rb") as f:
        pickleDist = pickle.load(f)
        picklePath = pickle.load(f)
        print(picklePath)
EOF
        )

        touch "BestestFile$weightType"
        echo "$bestDist" > "BestestFile$weightType"
        echo "$data" >> "BestestFile$weightType"
        #scp "./BestestFile$weightType" "$owens:~/"
       "./update03.sh $weightType ~/BestestFile$weightType"
fi
rm "running_$batch"
touch "FINISHED"

if [ -f "TERMINATE" ]; then
        echo "TERMINATE signal detected. Saving state and exiting."
:'
        python3 - <<EOF
import pickle

state = {
    "ITERNATION_STATE": $(($batch+1)),
    "WEIGHT": "$weightType",
    "END": $END,
    "RAND_SEED": $randseed,
    "PICKLE_FILE_NAME": "$initialGuess",
    "NO_OF_TRYS": $trys,
}

with open("savedState.pickle", "wb") as f:
    pickle.dump(state, f)
EOF

    echo "State saved to savedState.pickle."
    rm "TERMINATE"
'
    rm "./TERMINATE"
    exit
fi


done
