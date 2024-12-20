from django.db import models

class WorkflowInput(models.Model):
    weight_type = models.CharField(max_length=2)  # e.g., "00", "01", ...
    random_seed = models.IntegerField()
    no_of_trys = models.IntegerField()
    batch_jobs = models.IntegerField()
    timestamp = models.DateTimeField(auto_now_add=True)  

    def __str__(self):
        return f"Weight: {self.weight_type}, Seed: {self.random_seed}"

