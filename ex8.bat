@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PROJECT=helloworld"
set "LOG=%~dp0ex8-setup.log"
set "PYTHON=venv\Scripts\python.exe"
set "PY_LAUNCH="

> "%LOG%" echo Ex 8 Django Hello World setup
>> "%LOG%" echo Started: %date% %time%
echo Ex 8 Django Hello World setup
echo Detailed output: ex8-setup.log
echo Script: %~f0
echo.

for %%L in (run write_views write_pages_urls write_project_urls settings) do findstr /b /c:":%%L" "%~f0" >nul || goto :script_incomplete

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
if not exist manage.py call :run "Create Django project" "%PYTHON%" -m django startproject django_project .
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
call :settings "Add pages to INSTALLED_APPS"
if errorlevel 1 goto :file_failed

>> "%LOG%" echo Setup complete: %date% %time%
echo.
echo Setup complete. Open http://127.0.0.1:8000/
echo Press Ctrl+C to stop the server. The window will remain open.
echo Command: "%PYTHON%" manage.py runserver
"%PYTHON%" manage.py runserver >> "%LOG%" 2>&1
if errorlevel 1 echo [FAILED] Django server stopped. See ex8-setup.log.
echo.
echo Server stopped. Full output is in ex8-setup.log
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
> pages\views.py echo from django.http import HttpResponse
>> pages\views.py echo.
>> pages\views.py echo def home_page_view(request):
>> pages\views.py echo     return HttpResponse("Hello, World!")
if not exist pages\views.py exit /b 1
echo [OK] Write pages/views.py
exit /b 0

:write_pages_urls
echo [RUN] Write pages/urls.py
> pages\urls.py echo from django.urls import path
>> pages\urls.py echo from .views import home_page_view
>> pages\urls.py echo.
>> pages\urls.py echo urlpatterns = [
>> pages\urls.py echo     path("", home_page_view),
>> pages\urls.py echo ]
if not exist pages\urls.py exit /b 1
echo [OK] Write pages/urls.py
exit /b 0

:write_project_urls
echo [RUN] Update project URLs
> django_project\urls.py echo from django.contrib import admin
>> django_project\urls.py echo from django.urls import include, path
>> django_project\urls.py echo.
>> django_project\urls.py echo urlpatterns = [
>> django_project\urls.py echo     path("admin/", admin.site.urls),
>> django_project\urls.py echo     path("", include("pages.urls")),
>> django_project\urls.py echo ]
if not exist django_project\urls.py exit /b 1
echo [OK] Update project URLs
exit /b 0

:settings
echo [RUN] Update INSTALLED_APPS
"%PYTHON%" -c "from pathlib import Path; p=Path('django_project/settings.py'); s=p.read_text(encoding='utf-8'); s=s.replace('    '+chr(39)+'pages'+chr(39)+','+chr(10),'').replace('    '+chr(34)+'pages'+chr(34)+','+chr(10),''); s=s.replace('INSTALLED_APPS = [', 'INSTALLED_APPS = ['+chr(10)+'    '+chr(39)+'pages'+chr(39)+',', 1); p.write_text(s, encoding='utf-8')" >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1
echo [OK] Update INSTALLED_APPS
exit /b 0

:failed
echo.
echo Setup failed. Read ex8-setup.log for details.
>> "%LOG%" echo [FAILED] Setup stopped. Review the last command output above.
pause
exit /b 1

:script_incomplete
echo.
echo [FAILED] This Ex 8 batch file is incomplete or damaged.
echo Use the complete ex8-setup.bat from the bootstrap folder.
pause
exit /b 1

:python_missing
echo.
echo [FAILED] Python was not found. Install Python 3.10 or newer and enable PATH.
pause
exit /b 1

:project_failed
echo.
echo [FAILED] Could not create the project folder. Check permissions.
pause
exit /b 1

:venv_failed
echo.
echo [FAILED] Virtual environment creation failed. Check ex8-setup.log.
pause
exit /b 1

:pip_failed
echo.
echo [FAILED] Django or Black installation failed. Check ex8-setup.log.
pause
exit /b 1

:django_failed
echo.
echo [FAILED] Django project or app creation failed. Check ex8-setup.log.
pause
exit /b 1

:file_failed
echo.
echo [FAILED] Could not save a Django source file. Check permissions.
pause
exit /b 1
