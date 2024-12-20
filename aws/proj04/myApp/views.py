from django.shortcuts import render
import os
import subprocess
import logging
import time

logger = logging.getLogger(__name__)


def update_or_start(request):
    # Initialize state
    if "start_stop_state" not in request.session:
        request.session["start_stop_state"] = "start"
    start_stop_state = request.session["start_stop_state"]
    start_stop_label = "Start" if start_stop_state == "start" else "Stop"

    # Default values for the form
    context = {
        "weight_type": "00",
        "random_seed": 0,
        "no_of_trys": 1000000,
        "batch_jobs": 1,
        "best_distance": "NA",
        "start_stop_label": start_stop_label,
        "job_status": "None Submitted"
    }

    if request.method == "POST":

        action = request.POST.get("action")
        weight_type = request.POST.get("weight_type", "00")
        random_seed = int(request.POST.get("random_seed", 0))
        no_of_trys = int(request.POST.get("no_of_trys", 1000000))
        batch_jobs = int(request.POST.get("batch_jobs", 1))
        
        if action == "reset":
            # Call reset.sh script
            subprocess.run("bash /home/ubuntu/project04/reset.sh", shell=True)

            # Reset all items to initial values
            request.session["start_stop_state"] = "start"
            context.update({
                "weight_type": "00",
                "random_seed": 0,
                "no_of_trys": 1000000,
                "batch_jobs": 1,
                "best_distance": "NA",
                "start_stop_label": "Start",
                "job_status": "None Submitted",
            })
            return render(request, "index.html", context)


        # Update action
        elif action == "update":
            # Fetch best distance from the system

            command = f"bash /home/ubuntu/project04/get_best.sh {weight_type}"
            subprocess.run(command, shell=True)
            best_distance_file = "/home/ubuntu/project04/bestDist.txt"
            best_distance = "NA"
            if os.path.exists(best_distance_file):
                with open(best_distance_file, "r") as file:
                    best_distance = file.readline().strip()
            time.sleep(5)
            command = f"bash /home/ubuntu/project04/find_status.sh" 
            subprocess.run(command, shell=True)
            job_status_file="/home/ubuntu/project04/job_status.txt"
            job_status="None submitted"
            if os.path.exists(job_status_file):
                with open(job_status_file,"r") as file:
                    job_status=file.readline().strip()
            context.update({
                "weight_type": weight_type,
                "random_seed": random_seed,
                "no_of_trys": no_of_trys,
                "batch_jobs": batch_jobs,
                "best_distance": best_distance,
                "job_status":job_status
            })
            return render(request, "index.html", context)

        # Start/Stop action
        elif action == start_stop_label:
            if start_stop_state == "start":
                # Start script
                command = f"bash /home/ubuntu/project04/start.sh {weight_type} {random_seed} {no_of_trys} {batch_jobs}"
                subprocess.run(command, shell=True)
                command = f"bash /home/ubuntu/project04/get_best.sh {weight_type}"
                subprocess.run(command, shell=True)

                best_distance_file = "/home/ubuntu/project04/bestDist.txt"
                with open(best_distance_file, "r") as file:
                    best_distance = file.readline().strip()
                time.sleep(3)
                #command = f"bash /home/ubuntu/project04/find_status.sh"
                #subprocess.run(command, shell=True)
                #job_status_file="/home/ubuntu/project04/job_status.txt"
                job_status="Job Submitted, starting soon"
                #if os.path.exists(job_status_file):
                #    with open(job_status_file,"r") as file:
                #        job_status=file.readline().strip()
                request.session["start_stop_state"] = "stop"
            else:
                # Stop script
                command = f"bash /home/ubuntu/project04/stop.sh"
                subprocess.run(command, shell=True)

                command = f"bash /home/ubuntu/project04/get_best.sh {weight_type}"
                subprocess.run(command, shell=True)

                best_distance_file = "/home/ubuntu/project04/bestDist.txt"
                with open(best_distance_file, "r") as file:
                    best_distance = file.readline().strip()
                time.sleep(5)
                request.session["start_stop_state"] = "start"
                job_status="none submitted"
            context.update({
                "start_stop_label": "Stop" if request.session["start_stop_state"] == "stop" else "Start",
                "weight_type": weight_type,
                "random_seed": random_seed,
                "no_of_trys": no_of_trys,
                "batch_jobs": batch_jobs,
                "best_distance": best_distance,
                "job_status":job_status,
            })
            return render(request, "index.html", context)

    # Initial page load
    return render(request, "index.html", context)

