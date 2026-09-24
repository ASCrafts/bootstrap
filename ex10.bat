@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PROJECT=db_project"
set "LOG=%~dp0ex10-setup.log"
set "PYTHON=venv\Scripts\python.exe"
set "PY_LAUNCH="

> "%LOG%" echo Ex 10 Django Student Model setup
>> "%LOG%" echo Started: %date% %time%
echo Ex 10 Django Student Model setup
echo Detailed output: ex10-setup.log
echo Script: %~f0
echo.

for %%L in (run write_models write_views write_pages_urls write_project_urls write_template settings) do findstr /b /c:":%%L" "%~f0" >nul || goto :script_incomplete

echo Command: netstat -ano | findstr :8000
netstat -ano | findstr /r /c:":8000 .*LISTENING" >nul
if not errorlevel 1 goto :port_busy

echo Command: where py
where py >nul 2>&1
if not errorlevel 1 set "PY_LAUNCH=py -3"
if not defined PY_LAUNCH (
  echo Command: where python
  where python >nul 2>&1
  if not errorlevel 1 set "PY_LAUNCH=python"
)
if not defined PY_LAUNCH (
  echo Command: where python3
  where python3 >nul 2>&1
  if not errorlevel 1 set "PY_LAUNCH=python3"
)
if not defined PY_LAUNCH goto :python_missing
echo [INFO] Python launcher: %PY_LAUNCH%
>> "%LOG%" echo [INFO] Python launcher: %PY_LAUNCH%
call :run "Check Python version" %PY_LAUNCH% --version
if errorlevel 1 goto :failed

if not exist "%PROJECT%" (
  echo Command: mkdir "%PROJECT%"
  mkdir "%PROJECT%" >> "%LOG%" 2>&1
  if errorlevel 1 goto :project_failed
)
cd /d "%~dp0%PROJECT%"

call :run "Create virtual environment" %PY_LAUNCH% -m venv venv
if errorlevel 1 goto :venv_failed
if not exist "%PYTHON%" goto :venv_failed

call :run "Install Django and Black" "%PYTHON%" -m pip install django black
if errorlevel 1 goto :pip_failed
if not exist manage.py call :run "Create Django project" "%PYTHON%" -m django startproject db_project .
if errorlevel 1 goto :django_failed
if not exist pages call :run "Create pages app" "%PYTHON%" manage.py startapp pages
if errorlevel 1 goto :django_failed
if not exist pages\models.py goto :django_failed

call :write_models
if errorlevel 1 goto :file_failed
call :write_views
if errorlevel 1 goto :file_failed
call :write_pages_urls
if errorlevel 1 goto :file_failed
call :write_project_urls
if errorlevel 1 goto :file_failed
call :write_template
if errorlevel 1 goto :file_failed
call :settings
if errorlevel 1 goto :file_failed

call :run "Create model migrations" "%PYTHON%" manage.py makemigrations pages
if errorlevel 1 goto :migration_failed
call :run "Apply database migrations" "%PYTHON%" manage.py migrate
if errorlevel 1 goto :migration_failed

>> "%LOG%" echo Setup complete: %date% %time%
echo.
echo Setup complete. Open http://127.0.0.1:8000/add_student/
echo Then open http://127.0.0.1:8000/view_data/
echo Press Ctrl+C to stop the server. The window will remain open.
echo Command: "%PYTHON%" manage.py runserver
"%PYTHON%" manage.py runserver >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [FAILED] Django server stopped with an error. See ex10-setup.log.
  >> "%LOG%" echo [FAILED] Django server stopped with an error.
)
echo.
echo Server stopped. Full output is in ex10-setup.log
pause
exit /b 0

:run
set "STEP=%~1"
echo [RUN] %STEP%
echo Command: %2 %3 %4 %5 %6 %7 %8 %9
>> "%LOG%" echo [STEP] %STEP%
>> "%LOG%" echo [COMMAND] %2 %3 %4 %5 %6 %7 %8 %9
%2 %3 %4 %5 %6 %7 %8 %9 >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [FAILED] %STEP%
  >> "%LOG%" echo [FAILED] %STEP%
  exit /b 1
)
echo [OK] %STEP%
exit /b 0

:write_models
echo [RUN] Write pages/models.py
echo Command: write pages\models.py
>> "%LOG%" echo [STEP] Write pages/models.py
> pages\models.py echo from django.db import models
>> pages\models.py echo.
>> pages\models.py echo class Student(models.Model):
>> pages\models.py echo     name = models.CharField(max_length=100)
>> pages\models.py echo     age = models.IntegerField()
>> pages\models.py echo     email = models.EmailField(unique=True)
>> pages\models.py echo.
>> pages\models.py echo     def __str__(self):
>> pages\models.py echo         return self.name
if not exist pages\models.py exit /b 1
echo [OK] Write pages/models.py
exit /b 0

:write_views
echo [RUN] Write pages/views.py
echo Command: write pages\views.py
>> "%LOG%" echo [STEP] Write pages/views.py
> pages\views.py echo from django.http import HttpResponse
>> pages\views.py echo from django.shortcuts import render
>> pages\views.py echo from .models import Student
>> pages\views.py echo.
>> pages\views.py echo def add_student(request):
>> pages\views.py echo     Student.objects.get_or_create(email="ram@example.com", defaults={"name": "Ram", "age": 20})
>> pages\views.py echo     return HttpResponse("Student added successfully!")
>> pages\views.py echo.
>> pages\views.py echo def view_data(request):
>> pages\views.py echo     return render(request, "view_data.html", {"my_data": Student.objects.all()})
>> pages\views.py echo.
>> pages\views.py echo def delete_data(request):
>> pages\views.py echo     Student.objects.all().delete()
>> pages\views.py echo     return HttpResponse("All data deleted successfully!")
if not exist pages\views.py exit /b 1
echo [OK] Write pages/views.py
exit /b 0

:write_pages_urls
echo [RUN] Write pages/urls.py
echo Command: write pages\urls.py
>> "%LOG%" echo [STEP] Write pages/urls.py
> pages\urls.py echo from django.urls import path
>> pages\urls.py echo from . import views
>> pages\urls.py echo.
>> pages\urls.py echo urlpatterns = [
>> pages\urls.py echo     path("add_student/", views.add_student, name="add_student"),
>> pages\urls.py echo     path("view_data/", views.view_data, name="view_data"),
>> pages\urls.py echo     path("delete_data/", views.delete_data, name="delete_data"),
>> pages\urls.py echo ]
if not exist pages\urls.py exit /b 1
echo [OK] Write pages/urls.py
exit /b 0

:write_project_urls
echo [RUN] Update project URLs
echo Command: write db_project\urls.py
>> "%LOG%" echo [STEP] Update project URLs
> db_project\urls.py echo from django.contrib import admin
>> db_project\urls.py echo from django.urls import include, path
>> db_project\urls.py echo from pages.views import add_student, view_data, delete_data
>> db_project\urls.py echo.
>> db_project\urls.py echo urlpatterns = [
>> db_project\urls.py echo     path("admin/", admin.site.urls),
>> db_project\urls.py echo     path("add_student/", add_student, name="add_student"),
>> db_project\urls.py echo     path("view_data/", view_data, name="view_data"),
>> db_project\urls.py echo     path("delete_data/", delete_data, name="delete_data"),
>> db_project\urls.py echo     path("pages/", include("pages.urls")),
>> db_project\urls.py echo ]
if not exist db_project\urls.py exit /b 1
echo [OK] Update project URLs
exit /b 0

:write_template
echo [RUN] Write pages/templates/view_data.html
echo Command: mkdir pages\templates and write view_data.html
>> "%LOG%" echo [STEP] Write pages/templates/view_data.html
if not exist pages\templates mkdir pages\templates >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1
> pages\templates\view_data.html echo ^<html^>
>> pages\templates\view_data.html echo ^<head^>^<title^>Students^</title^>^</head^>
>> pages\templates\view_data.html echo ^<body^>
>> pages\templates\view_data.html echo ^<h1^>Students^</h1^>
>> pages\templates\view_data.html echo ^<ul^>
>> pages\templates\view_data.html echo ^{%% for student in my_data %%^}
>> pages\templates\view_data.html echo ^<li^>{{ student.name }} - {{ student.age }} - {{ student.email }}^</li^>
>> pages\templates\view_data.html echo ^{%% empty %%^}^<li^>No students found.^</li^>
>> pages\templates\view_data.html echo ^{%% endfor %%^}
>> pages\templates\view_data.html echo ^</ul^>
>> pages\templates\view_data.html echo ^</body^>
>> pages\templates\view_data.html echo ^</html^>
if not exist pages\templates\view_data.html exit /b 1
echo [OK] Write pages/templates/view_data.html
exit /b 0

:settings
echo [RUN] Update INSTALLED_APPS and template DIRS
echo Command: update db_project\settings.py
>> "%LOG%" echo [STEP] Update db_project/settings.py
"%PYTHON%" -c "from pathlib import Path; p=Path('db_project/settings.py'); s=p.read_text(encoding='utf-8'); s=s.replace('    '+chr(39)+'pages'+chr(39)+','+chr(10),'').replace('    '+chr(34)+'pages'+chr(34)+','+chr(10),''); s=s.replace('INSTALLED_APPS = [', 'INSTALLED_APPS = ['+chr(10)+'    '+chr(39)+'pages'+chr(39)+',', 1); s=s.replace(chr(39)+'DIRS'+chr(39)+': []', chr(39)+'DIRS'+chr(39)+': [BASE_DIR / '+chr(39)+'pages/templates'+chr(39)+']').replace(chr(34)+'DIRS'+chr(34)+': []', chr(34)+'DIRS'+chr(34)+': [BASE_DIR / '+chr(34)+'pages/templates'+chr(34)+']'); p.write_text(s, encoding='utf-8')" >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1
echo [OK] Update settings.py
exit /b 0

:failed
echo.
echo Setup failed. Read ex10-setup.log for details.
>> "%LOG%" echo [FAILED] Setup stopped. Review the last command output above.
pause
exit /b 1

:script_incomplete
echo.
echo [FAILED] This Ex 10 batch file is incomplete or damaged.
echo Use the complete ex10-setup.bat from the bootstrap folder.
>> "%LOG%" echo [FAILED] Required batch labels are missing from %~f0
pause
exit /b 1

:python_missing
echo.
echo [FAILED] Python was not found.
echo Install Python 3.10 or newer and enable Add Python to PATH.
>> "%LOG%" echo [FAILED] Python was not found on PATH.
pause
exit /b 1

:project_failed
echo.
echo [FAILED] Could not create the project folder. Check permissions.
>> "%LOG%" echo [FAILED] Could not create the project folder.
pause
exit /b 1

:venv_failed
echo.
echo [FAILED] Virtual environment creation failed. Check ex10-setup.log.
>> "%LOG%" echo [FAILED] Virtual environment creation failed.
pause
exit /b 1

:pip_failed
echo.
echo [FAILED] Django or Black installation failed. Check internet and ex10-setup.log.
>> "%LOG%" echo [FAILED] Package installation failed.
pause
exit /b 1

:django_failed
echo.
echo [FAILED] Django project or app creation failed. Check ex10-setup.log.
>> "%LOG%" echo [FAILED] Django project or app creation failed.
pause
exit /b 1

:migration_failed
echo.
echo [FAILED] Database migration failed. Check ex10-setup.log.
>> "%LOG%" echo [FAILED] Database migration failed.
pause
exit /b 1

:file_failed
echo.
echo [FAILED] Could not save a Django source or template file. Check permissions.
>> "%LOG%" echo [FAILED] Could not save a Django source or template file.
pause
exit /b 1

:port_busy
echo.
echo [FAILED] Port 8000 is already in use by another application or Django exercise.
echo Stop the old server with Ctrl+C, then run ex10-setup.bat again.
>> "%LOG%" echo [FAILED] Port 8000 is already in use.
pause
exit /b 1
