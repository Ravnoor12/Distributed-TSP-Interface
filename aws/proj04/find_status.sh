#!/bin/bash

AWS_START_OUTPUT="/home/ubuntu/project04/start_output"

OWENS="w597rxs@owens.osc.edu"
OWENS_WORKFLOW_DIR="/users/PWSU0510/w597rxs/workflow"

JOB_STATUS="None Submitted"
MAX_RETRIES=4
SLEEP_INTERVAL=5

if [[ -f "$AWS_START_OUTPUT" ]]; then
    JOB_ID=$(./find_id.sh)
    TOTAL_BATCHES=$(sed -n '2p' "$AWS_START_OUTPUT")
    echo "$JOB_ID  $TOTAL_BATCHES"

    OWENS_JOB_DIR="$OWENS_WORKFLOW_DIR"
    SSH_COMMAND="
        if [[ -d '$OWENS_JOB_DIR' ]]; then
            if [[ -f '$OWENS_JOB_DIR/FINISHED' ]]; then
                echo 'Completed';
            elif [[ -f '$OWENS_JOB_DIR/STARTED' ]]; then
                RUNNING_BATCH='None'
                for ((i=1; i<=$MAX_RETRIES; i++)); do
                    RUNNING_FILE=\$(find '$OWENS_WORKFLOW_DIR' -name 'running_*' | head -n 1);
                    if [[ -n \"\$RUNNING_FILE\" ]]; then
                        RUNNING_BATCH=\$(basename \"\$RUNNING_FILE\" | awk -F_ '{print \$2}');
                        echo \"Running \$RUNNING_BATCH of $TOTAL_BATCHES jobs\";
                        break;
                    fi
                    sleep $SLEEP_INTERVAL;
                done
                if [[ \"\$RUNNING_BATCH\" == 'None' ]]; then
                    echo 'Waiting for the next batch to start...';
                fi
            else
                echo 'None Submitted';
            fi
        else
            echo 'None Submitted';
        fi
    "

    JOB_STATUS=$(ssh "$OWENS" "$SSH_COMMAND")
else
    JOB_STATUS="None Submitted"
fi

echo "$JOB_STATUS" > job_status.txt
