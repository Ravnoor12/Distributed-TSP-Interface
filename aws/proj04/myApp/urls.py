from django.urls import path
from . import views

urlpatterns = [
    path("", views.update_or_start, name="index"),
]

