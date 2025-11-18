@echo off
color 0A
echo ========================================
echo   SLITHER GAME - INICIO COMPLETO
echo ========================================
echo.
echo [PASO 1/3] Iniciando Servidor...
echo.
start "Servidor Slither" cmd /k "cd server && dart pub get && dart server.dart"
timeout /t 3 /nobreak > nul

echo [PASO 2/3] El servidor esta corriendo!
echo.
echo [PASO 3/3] Ahora ejecuta en otra terminal:
echo    flutter run
echo.
echo ========================================
echo   INSTRUCCIONES:
echo ========================================
echo 1. El servidor ya esta corriendo
echo 2. Abre OTRA terminal
echo 3. Ejecuta: flutter run
echo 4. En el juego: Jugar como Invitado
echo 5. Ve a Multijugador
echo 6. Crea o une a juego!
echo ========================================
pause





