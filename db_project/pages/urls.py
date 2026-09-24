from django.urls import path
from . import views

urlpatterns = [
    path("add_student/", views.add_student, name="add_student"),
    path("view_data/", views.view_data, name="view_data"),
    path("delete_data/", views.delete_data, name="delete_data"),
]
