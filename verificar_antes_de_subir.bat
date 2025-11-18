@echo off
echo ========================================
echo   VERIFICACION ANTES DE SUBIR A GITHUB
echo ========================================
echo.

echo [1/5] Verificando estructura de archivos...
if not exist "server\Dockerfile" (
    echo [ERROR] Falta server\Dockerfile
    pause
    exit /b 1
)
if not exist "server\server.dart" (
    echo [ERROR] Falta server\server.dart
    pause
    exit /b 1
)
if not exist "server\pubspec.yaml" (
    echo [ERROR] Falta server\pubspec.yaml
    pause
    exit /b 1
)
echo [OK] Todos los archivos necesarios existen
echo.

echo [2/5] Verificando dependencias del servidor...
cd server
if exist "pubspec.lock" (
    echo [OK] Las dependencias del servidor estan instaladas
) else (
    echo [INFO] Instalando dependencias del servidor...
    dart pub get
)
cd ..
echo.

echo [3/5] Verificando dependencias de Flutter...
if exist "pubspec.lock" (
    echo [OK] Las dependencias de Flutter estan instaladas
) else (
    echo [INFO] Instalando dependencias de Flutter...
    flutter pub get
)
echo.

echo [4/5] Verificando configuracion de Supabase...
findstr /C:"supabaseUrl = 'https://xxxxx" lib\config\supabase_config.dart >nul
if %errorlevel%==0 (
    echo [ADVERTENCIA] Parece que aun no has configurado Supabase
    echo    Edita: lib\config\supabase_config.dart
    echo    Pero puedes continuar, lo configuraras despues.
) else (
    echo [OK] Supabase parece estar configurado
)
echo.

echo [5/5] Verificando Git...
git --version >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Git esta instalado
) else (
    echo [ERROR] Git no esta instalado o no esta en el PATH
    echo    Descargalo de: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo.

echo ========================================
echo   VERIFICACION COMPLETADA
echo ========================================
echo.
echo Todo listo para subir a GitHub!
echo.
echo Proximos pasos:
echo   1. Sigue las instrucciones en PASOS_RAPIDOS_RENDER.md
echo   2. Sube tu codigo a GitHub
echo   3. Despliega en Render
echo   4. Configura game_config.dart con tu URL de Render
echo.
pause

