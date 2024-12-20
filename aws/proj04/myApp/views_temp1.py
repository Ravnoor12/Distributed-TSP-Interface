from django.shortcuts import render, redirect
from .forms import WorkflowForm
import os
import logging
import subprocess

logger = logging.getLogger(__name__)

def update_or_start(request):
    # Track the start/stop state

    if "start_stop_state" not in request.session:
        request.session["start_stop_state"] = "start"

    start_stop_state = request.session.get("start_stop_state", "start")  # Default state
    start_stop_label = "Start" if start_stop_state == "start" else "Stop"

    # Fixed initial values (no dependency on database)
    initial_values = {
        'weight_type': '00',
        'random_seed': 0,
        'no_of_trys': 1000000,
        'batch_jobs': 1,
        'best_distance': "NA"  # Default, can be updated dynamically
    }

    if request.method == "POST":
        form = WorkflowForm(request.POST)
        if form.is_valid():
            workflow_input = form.save(commit=False)  # Save data to the model
            action = request.POST.get("action")

            if action == "update":
                # Update logic
                weight_type=workflow_input.weight_type
                command = f"bash /home/ubuntu/project04/get_best.sh {weight_type}"
                #process = subprocess.Popen(command, shell=True)
                os.system(command)
                start_output_file="/home/ubuntu/project04/bestDist.txt"
                with open(start_output_file, "r") as file:
                    process_id = file.readline().strip()
                #best_distance = process_id
                workflow_input.batch_jobs=90
                best_distance = "ksjaj"  # Update the field
                workflow_input.save()

                form = WorkflowForm(initial={
                    'weight_type': workflow_input.weight_type,
                    'random_seed': workflow_input.random_seed,
                    'no_of_trys': workflow_input.no_of_trys,
                    'batch_jobs': workflow_input.batch_jobs,
                    'best_distance': best_distance
                })


                return render(request, "index.html", {
                    "form": form,
                    "start_stop_state": start_stop_state,
                    "start_stop_label": start_stop_label,
                    "success": "Values updated successfully!",
                    "best_distance": best_distance
                })
            elif action == start_stop_label:
                if start_stop_state == "start":
                    weight_type=workflow_input.weight_type
                    random_seed=workflow_input.random_seed
                    no_of_trys=workflow_input.no_of_trys
                    batch_jobs=workflow_input.batch_jobs
                    command = f"bash /home/ubuntu/project04/start.sh {weight_type} {random_seed} {no_of_trys} {batch_jobs}"
                    process = subprocess.Popen(command, shell=True)
                    #os.system(command)
                    start_output_file="/home/ubuntu/project04/start_output"
                    with open(start_output_file, "r") as file:
                        process_id = file.readline().strip()
                    request.session["start_stop_state"] = "stop"
                    workflow_input.save()  # Save to DB
                    logger.info(f"Process ID: {process_id}")
                    return render(request, "index.html", {
                        "form": form,
                        "start_stop_state": "stop",
                        "start_stop_label": "Stop",
                        "success": "Process started on Owens!",
                        "process_id":f"{process_id}"
                    })
                else:
                    process_stopped = stop_process_on_owens()
                    if process_stopped:
                        request.session["start_stop_state"] = "start"
                        return render(request, "index.html", {
                            "form": form,
                            "start_stop_state": "start",
                            "start_stop_label": "Start",
                            "success": "Process stopped on Owens!"
                        })
    else:
        # Initialize the form with fixed initial values
        form = WorkflowForm(initial=initial_values)
        request.session["start_stop_state"] = "start"
        start_stop_label="Start"
    return render(request, "index.html", {
        "form": form,
        "start_stop_state": start_stop_state,
        "start_stop_label": start_stop_label
    })

