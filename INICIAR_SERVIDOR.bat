@echo off
color 0A
echo ========================================
echo   SLITHER GAME - Servidor Multijugador
echo ========================================
echo.
echo [1/3] Verificando dependencias...
cd server
call dart pub get
echo.
echo [2/3] Tu IP actual es:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do echo      %%a
echo.
echo [3/3] Iniciando servidor...
echo.
echo SERVIDOR ACTIVO EN:
echo   - Local:  ws://localhost:8080
echo   - Red:    ws://TU_IP:8080
echo.
echo Los jugadores pueden conectarse usando esa direccion
echo Presiona Ctrl+C para detener el servidor
echo ========================================
echo.
dart server.dart
pause





