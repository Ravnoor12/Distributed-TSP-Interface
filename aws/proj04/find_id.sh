#!/usr/bin/bash


OWENS="w597rxs@owens.osc.edu"
OWENS_WORKFLOW_DIR="/users/PWSU0510/w597rxs/workflow/"

LATEST_JOB_ID=$(ssh "$OWENS" "tail -n 1 $OWENS_WORKFLOW_DIR/process_ids.txt")

if [[ -z "$LATEST_JOB_ID" ]]; then
    echo "No job ID found, process not started"
    exit 1
fi

echo "$LATEST_JOB_ID"
