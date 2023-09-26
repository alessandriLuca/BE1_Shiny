@echo off
setlocal enabledelayedexpansion

REM Ottieni il percorso assoluto della cartella corrente
for %%i in ("%cd%") do set "current_directory=%%~fi"

REM Esegui il build del Docker
docker build -t my-shiny-app "%current_directory%"

REM Verifica se la cartella "Data" esiste
if not exist "%current_directory%\Data" (
  mkdir "%current_directory%\Data"
  wget https://figshare.com/ndownloader/files/42312711 -O "%current_directory%\Data\zip"
  unzip -o "%current_directory%\Data\zip" -d "%current_directory%\Data"
  move "%current_directory%\Data\BE1run12\*" "%current_directory%\Data\"
  rmdir /s /q "%current_directory%\Data\__MACOSX"
  rmdir /s /q "%current_directory%\Data\BE1run12"
  del "%current_directory%\Data\zip"
)

REM Avvia il contenitore Docker
docker run --rm -p 3838:3838 -v "%current_directory%\Data:/scratch" --name shiny my-shiny-app
