#!/bin/bash

AWS_START_OUTPUT="/home/ubuntu/project04/start_output"

OWENS="w597rxs@owens.osc.edu"
OWENS_WORKFLOW_DIR="/users/PWSU0510/w597rxs/workflow"

JOB_STATUS="None Submitted"

if [[ -f "$AWS_START_OUTPUT" ]]; then
	JOB_ID=$(./find_id.sh)   
   	TOTAL_BATCHES=$(sed -n '2p' "$AWS_START_OUTPUT")
	echo "$JOB_ID  $TOTAL_BATCHES"

	OWENS_JOB_DIR="$OWENS_WORKFLOW_DIR/job_owens_$JOB_ID"
	SSH_COMMAND="
            if [[ -d '$OWENS_JOB_DIR' ]]; then
                if [[ -f '$OWENS_JOB_DIR/FINISHED' ]]; then
                    echo 'Completed';
                elif [[ -f '$OWENS_JOB_DIR/STARTED' ]]; then
			RUNNING_FILE=\$(find '$OWENS_WORKFLOW_DIR' -name 'running_*' | head -n 1);
                    if [[ -n \"\$RUNNING_FILE\" ]]; then
                        RUNNING_BATCH=\$(basename \"\$RUNNING_FILE\" | awk -F_ '{print \$2}');
                        echo \"Running \$RUNNING_BATCH of $TOTAL_BATCHES jobs\";
                    else
                        echo \"Running 0 of $TOTAL_BATCHES jobs\";
                    fi
                else
                    echo 'None Submitted';
                fi
            else
                echo 'none submitted';
            fi
	"

	JOB_STATUS=$(ssh "$OWENS" "$SSH_COMMAND")
else
	JOB_STATUS="None submitted"
fi 

echo "$JOB_STATUS" > job_status.txt
