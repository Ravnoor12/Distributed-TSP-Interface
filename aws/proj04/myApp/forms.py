from django import forms
from .models import WorkflowInput

class WorkflowForm(forms.ModelForm):
    class Meta:
        model = WorkflowInput
        fields = ['weight_type', 'random_seed', 'no_of_trys', 'batch_jobs']
        labels = {
            'weight_type': 'Weight Type',
            'random_seed': 'Random Seed',
            'no_of_trys': 'Number of Tries',
            'batch_jobs': 'Number of Batch Jobs',
        }
        widgets = {
            'weight_type': forms.Select(
                choices=[(f"{i:02}", f"Weight {i:02}") for i in range(10)],
                attrs={'class': 'form-control'}
            ),
            'random_seed': forms.NumberInput(attrs={'class': 'form-control', 'min': 0, 'max': 32000}),
            'no_of_trys': forms.NumberInput(attrs={'class': 'form-control', 'min': 1}),
            'batch_jobs': forms.NumberInput(attrs={'class': 'form-control', 'min': 1}),
        }

    best_distance = forms.CharField(
        initial="NA",
        label="Best Distance So Far",
        widget=forms.TextInput(attrs={
            "readonly": "readonly",
            "class": "form-control"
        }),
        required=False
    )

