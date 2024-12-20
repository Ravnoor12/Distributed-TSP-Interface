#!/bin/bash

AWS_START_OUTPUT="/home/ubuntu/project04/start_output.txt"

OWENS="w597rxs@owens.osc.edu"
OWENS_WORKFLOW_DIR="/users/PWSU0510/w597rxs/workflow"

JOB_ID=$(./find_id.sh)
OWENS_JOB_DIR="$OWENS_WORKFLOW_DIR/job_owens_$JOB_ID"
echo "printing from stop script: $JOB_ID"
SSH_COMMAND="
            if [ -d '$OWENS_JOB_DIR' ]; then
                echo 'Started';
            else
                echo 'Not Started';
            fi
        "
JOB_STATUS=$(ssh "$OWENS" "$SSH_COMMAND")

echo "PRINTING from stop script: $JOB_STATUS"

if [[ "$JOB_STATUS" == "Started" ]]; then
	SSH_COMMAND="touch '$OWENS_JOB_DIR/STOP'"
        ssh "$OWENS" "$SSH_COMMAND"
        echo "STOP file created $OWENS_JOB_DIR on Owens."
else 
	SSH_COMMAND="scancel $JOB_ID"
	ssh "$OWENS" "$SSH_COMMAND"
fi




