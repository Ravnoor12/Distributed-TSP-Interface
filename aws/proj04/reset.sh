#!/bin/bash

WORKFLOW_DIR="/users/PWSU0510/w597rxs/workflow"
TERMINATE_FILE="$WORKFLOW_DIR/TERMINATE"

JOB_STATUS=$(./find_status.sh)

if [[ "$JOB_STATUS" == "Completed" || "$JOB_STATUS" == "None Submitted" ]]; then
    echo "Job is completed. Resetting values to initial state."
else
    echo "Job is still running. Creating TERMINATE file to stop all jobs."
    SSH_COMMAND="touch '$TERMINATE_FILE'"
    ssh w597rxs@owens.osc.edu "$SSH_COMMAND"
    echo "Terminate signal sent. Resetting values to initial state."
fi


