#!/bin/bash

echo "========================================"
echo "  SLITHER GAME - Servidor Multijugador"
echo "========================================"
echo ""
echo "Instalando dependencias..."
dart pub get
echo ""
echo "Iniciando servidor..."
echo "El servidor estará disponible en ws://localhost:8080"
echo "Presiona Ctrl+C para detener el servidor"
echo ""
dart server.dart





