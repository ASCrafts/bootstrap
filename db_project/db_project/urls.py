from django.contrib import admin
from django.urls import include, path
from pages.views import add_student, view_data, delete_data

urlpatterns = [
    path("admin/", admin.site.urls),
    path("add_student/", add_student, name="add_student"),
    path("view_data/", view_data, name="view_data"),
    path("delete_data/", delete_data, name="delete_data"),
    path("pages/", include("pages.urls")),
]
