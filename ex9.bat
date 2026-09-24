@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PROJECT=hello_world"
set "LOG=%~dp0ex9-setup.log"
set "PYTHON=venv\Scripts\python.exe"
set "PY_LAUNCH="

> "%LOG%" echo Ex 9 Django Template setup
>> "%LOG%" echo Started: %date% %time%
echo Ex 9 Django Template setup
echo Detailed output: ex9-setup.log
echo Script: %~f0
echo.

for %%L in (run write_views write_pages_urls write_project_urls write_template settings) do findstr /b /c:":%%L" "%~f0" >nul || goto :script_incomplete

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
if not exist manage.py call :run "Create Django project" "%PYTHON%" -m django startproject helloworld_project .
if errorlevel 1 goto :django_failed
if not exist pages call :run "Create pages app" "%PYTHON%" manage.py startapp pages
if errorlevel 1 goto :django_failed
if not exist pages\views.py goto :django_failed

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

echo.
echo Setup complete. Open http://127.0.0.1:8000/hello/
echo Press Ctrl+C to stop the server. The window will remain open.
>> "%LOG%" echo Setup complete: %date% %time%
echo Command: "%PYTHON%" manage.py runserver
"%PYTHON%" manage.py runserver >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [FAILED] Django server stopped with an error. See ex9-setup.log.
  >> "%LOG%" echo [FAILED] Django server stopped with an error.
)
echo.
echo Server stopped. Full output is in ex9-setup.log
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

:write_views
echo [RUN] Write pages/views.py
echo Command: write pages\views.py
>> "%LOG%" echo [STEP] Write pages/views.py
> pages\views.py echo from django.shortcuts import render
>> pages\views.py echo.
>> pages\views.py echo def hello_world(request):
>> pages\views.py echo     return render(request, "hello.html")
if not exist pages\views.py exit /b 1
echo [OK] Write pages/views.py
exit /b 0

:write_pages_urls
echo [RUN] Write pages/urls.py
echo Command: write pages\urls.py
>> "%LOG%" echo [STEP] Write pages/urls.py
> pages\urls.py echo from django.urls import path
>> pages\urls.py echo from pages.views import hello_world
>> pages\urls.py echo.
>> pages\urls.py echo urlpatterns = [
>> pages\urls.py echo     path("hello/", hello_world, name="hello_world"),
>> pages\urls.py echo ]
if not exist pages\urls.py exit /b 1
echo [OK] Write pages/urls.py
exit /b 0

:write_project_urls
echo [RUN] Update project URLs
echo Command: write helloworld_project\urls.py
>> "%LOG%" echo [STEP] Update project URLs
> helloworld_project\urls.py echo from django.contrib import admin
>> helloworld_project\urls.py echo from django.urls import include, path
>> helloworld_project\urls.py echo.
>> helloworld_project\urls.py echo urlpatterns = [
>> helloworld_project\urls.py echo     path("admin/", admin.site.urls),
>> helloworld_project\urls.py echo     path("", include("pages.urls")),
>> helloworld_project\urls.py echo ]
if not exist helloworld_project\urls.py exit /b 1
echo [OK] Update project URLs
exit /b 0

:write_template
echo [RUN] Write pages/templates/hello.html
echo Command: mkdir pages\templates and write hello.html
>> "%LOG%" echo [STEP] Write pages/templates/hello.html
if not exist pages\templates mkdir pages\templates >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1
> pages\templates\hello.html echo ^<html^>
>> pages\templates\hello.html echo ^<head^>
>> pages\templates\hello.html echo ^  ^<title^>Hello Django!^</title^>
>> pages\templates\hello.html echo ^</head^>
>> pages\templates\hello.html echo ^<body^>
>> pages\templates\hello.html echo ^  ^<h1^>Hello, World! from Django HTML^</h1^>
>> pages\templates\hello.html echo ^</body^>
>> pages\templates\hello.html echo ^</html^>
if not exist pages\templates\hello.html exit /b 1
echo [OK] Write pages/templates/hello.html
exit /b 0

:settings
echo [RUN] Update template DIRS
echo Command: update helloworld_project\settings.py
>> "%LOG%" echo [STEP] Update template DIRS
"%PYTHON%" -c "from pathlib import Path; p=Path('helloworld_project/settings.py'); s=p.read_text(encoding='utf-8'); apps=s if chr(39)+'pages'+chr(39) in s else s.replace('INSTALLED_APPS = [', 'INSTALLED_APPS = [' + chr(10) + '    ' + chr(39) + 'pages' + chr(39) + ',', 1); templates=apps if 'pages/templates' in apps else apps.replace(chr(39)+'DIRS'+chr(39)+': []', chr(39)+'DIRS'+chr(39)+': [BASE_DIR / '+chr(39)+'pages/templates'+chr(39)+']', 1); p.write_text(templates, encoding='utf-8')" >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1
echo [OK] Update template DIRS
exit /b 0

:failed
echo.
echo Setup failed. Read ex9-setup.log for details.
>> "%LOG%" echo [FAILED] Setup stopped. Review the last command output above.
pause
exit /b 1

:script_incomplete
echo.
echo [FAILED] This Ex 9 batch file is incomplete or damaged.
echo Use the complete ex9-setup.bat from the bootstrap folder.
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
echo [FAILED] Virtual environment creation failed. Check ex9-setup.log.
>> "%LOG%" echo [FAILED] Virtual environment creation failed.
pause
exit /b 1

:pip_failed
echo.
echo [FAILED] Django or Black installation failed. Check internet and ex9-setup.log.
>> "%LOG%" echo [FAILED] Package installation failed.
pause
exit /b 1

:django_failed
echo.
echo [FAILED] Django project or app creation failed. Check ex9-setup.log.
>> "%LOG%" echo [FAILED] Django project or app creation failed.
pause
exit /b 1

:file_failed
echo.
echo [FAILED] Could not save a Django source or template file. Check permissions.
>> "%LOG%" echo [FAILED] Could not save a Django source or template file.
pause
exit /b 1
