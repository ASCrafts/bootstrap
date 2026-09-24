from django.http import HttpResponse
from django.shortcuts import render
from .models import Student

def add_student(request):
    Student.objects.get_or_create(email="ram@example.com", defaults={"name": "Ram", "age": 20})
    return HttpResponse("Student added successfully!")

def view_data(request):
    return render(request, "view_data.html", {"my_data": Student.objects.all()})

def delete_data(request):
    Student.objects.all().delete()
    return HttpResponse("All data deleted successfully!")
