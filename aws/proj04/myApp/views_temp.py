from django.shortcuts import render, redirect
from .forms import WorkflowForm
from .models import WorkflowInput

def update_or_start(request):
    # Track the start/stop state
    start_stop_state = request.session.get("start_stop_state", "start")  # Default state
    start_stop_label = "Start" if start_stop_state == "start" else "Stop"

    if request.method == "POST":
        form = WorkflowForm(request.POST)
        if form.is_valid():
            # Save the form data to the database
            workflow_input = form.save(commit=False)  # Create an instance but don't save yet
            weight_type = workflow_input.weight_type
            random_seed = workflow_input.random_seed
            num_tries = workflow_input.no_of_trys
            batch_jobs = workflow_input.batch_jobs

            # Handle Start/Stop
            action = request.POST.get("action")
            if action == "update":
                # Update logic
                best_distance = get_best_distance(weight_type)  # Implement this function
                form.cleaned_data["best_distance"] = best_distance  # Update the display-only field
                workflow_input.save()  # Save the instance to the database
                return render(request, "index.html", {
                    "form": form,
                    "start_stop_state": start_stop_state,
                    "start_stop_label": start_stop_label,
                    "success": "Values updated successfully!",
                    "best_distance": best_distance
                })
            elif action == start_stop_label:
                if start_stop_state == "start":
                    # Start logic
                    process_started = start_process_on_owens(weight_type, random_seed, num_tries, batch_jobs)
                    if process_started:
                        request.session["start_stop_state"] = "stop"
                        workflow_input.save()  # Save the instance to the database
                        return render(request, "index.html", {
                            "form": form,
                            "start_stop_state": "stop",
                            "start_stop_label": "Stop",
                            "success": "Process started on Owens!"
                        })
                else:
                    # Stop logic
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
        # Initial form rendering
        form = WorkflowForm()

    return render(request, "index.html", {
        "form": form,
        "start_stop_state": start_stop_state,
        "start_stop_label": start_stop_label
    })

