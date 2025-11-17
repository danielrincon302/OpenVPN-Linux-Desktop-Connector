#!/bin/bash

# Script para configurar sudo sin contraseña para OpenVPN
# Este script debe ejecutarse con privilegios de administrador

echo "=== Configuración de sudo para VPN Linux Desktop Connector ==="
echo ""

# Verificar que se ejecuta con sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Este script debe ejecutarse con sudo"
    echo "   Ejecuta: sudo bash setup-sudo.sh"
    exit 1
fi

# Obtener el usuario real (no root)
REAL_USER="${SUDO_USER:-$USER}"

# Verificar que openvpn está instalado
if ! command -v openvpn &> /dev/null; then
    echo "❌ OpenVPN no está instalado"
    echo "   Instálalo con: sudo apt-get install openvpn"
    exit 1
fi

# Obtener la ruta completa de openvpn
OPENVPN_PATH=$(which openvpn)

echo "✓ Usuario: $REAL_USER"
echo "✓ OpenVPN encontrado en: $OPENVPN_PATH"
echo ""

# Crear archivo de configuración sudoers
SUDOERS_FILE="/etc/sudoers.d/vpn-linux-desktop-connector"

echo "Creando configuración sudoers..."

# Crear el archivo con la regla
cat > "$SUDOERS_FILE" << EOF
# Permitir ejecutar OpenVPN sin contraseña para VPN Linux Desktop Connector
# Generado automáticamente por setup-sudo.sh
$REAL_USER ALL=(ALL) NOPASSWD: $OPENVPN_PATH
EOF

# Establecer permisos correctos (CRÍTICO para sudoers)
chmod 0440 "$SUDOERS_FILE"

# Validar el archivo sudoers
if visudo -c -f "$SUDOERS_FILE" &> /dev/null; then
    echo "✓ Configuración sudoers creada correctamente en: $SUDOERS_FILE"
    echo ""
    echo "=== Configuración completada ==="
    echo ""
    echo "Ahora puedes ejecutar la aplicación desde el escritorio sin que solicite contraseña."
    echo ""
else
    echo "❌ Error: El archivo sudoers tiene errores de sintaxis"
    rm -f "$SUDOERS_FILE"
    exit 1
fi

# Mostrar instrucciones adicionales
echo "NOTA DE SEGURIDAD:"
echo "  - Esta configuración permite ejecutar SOLO OpenVPN sin contraseña"
echo "  - Para revertir esta configuración, ejecuta:"
echo "    sudo rm $SUDOERS_FILE"
echo ""
