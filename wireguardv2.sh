#!/bin/bash

# Directorio donde se encuentran los archivos de configuración de WireGuard
WG_DIR="/etc/wireguard"

# Función para obtener el estado de una VPN (activa o no)
obtener_estado_vpn() {
    local interface="$1"
    if sudo wg show "$interface" &>/dev/null; then
        echo "🟢"
    else
        echo "🔴"
    fi
}

# Función para listar las configuraciones disponibles con estado
listar_vpns() {
    mapfile -t VPNS < <(sudo find "$WG_DIR" -maxdepth 1 -type f -name "*.conf" 2>/dev/null)

    if [[ ${#VPNS[@]} -eq 0 ]]; then
        echo "No se encontraron configuraciones de VPN en $WG_DIR"
        return 1
    fi

    echo "=== Configuraciones disponibles ==="
    for i in "${!VPNS[@]}"; do
        INTERFACE=$(basename "${VPNS[$i]%.conf}") # Eliminar la extensión .conf
        ESTADO=$(obtener_estado_vpn "$INTERFACE")
        echo "$((i + 1))) $INTERFACE $ESTADO"
    done
    echo
    return 0
}

# Función para seleccionar una VPN
seleccionar_vpn() {
    listar_vpns
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    read -p "Selecciona una VPN (número): " seleccion

    if [[ "$seleccion" =~ ^[0-9]+$ && "$seleccion" -ge 1 && "$seleccion" -le "${#VPNS[@]}" ]]; then
        echo "${VPNS[$((seleccion - 1))]}"
    else
        echo "Selección inválida."
        return 1
    fi
}

# Función para conectar una VPN
conectar_vpn() {
    VPN=$(seleccionar_vpn)
    if [[ $? -eq 0 && -n "$VPN" ]]; then
        INTERFACE=$(basename "${VPN%.conf}")
        echo "Conectando a la VPN $INTERFACE..."
        sudo wg-quick up "$INTERFACE"
        if [[ $? -eq 0 ]]; then
            echo "VPN $INTERFACE conectada exitosamente."
        else
            echo "Hubo un problema al conectar la VPN $INTERFACE."
        fi
    fi
}

# Función para desconectar una VPN
desconectar_vpn() {
    VPN=$(seleccionar_vpn)
    if [[ $? -eq 0 && -n "$VPN" ]]; then
        INTERFACE=$(basename "${VPN%.conf}")
        echo "Desconectando la VPN $INTERFACE..."
        sudo wg-quick down "$INTERFACE"
        if [[ $? -eq 0 ]]; then
            echo "VPN $INTERFACE desconectada exitosamente."
        else
            echo "Hubo un problema al desconectar la VPN $INTERFACE."
        fi
    fi
}

# Función para ver el estado de una VPN
ver_estado() {
    VPN=$(seleccionar_vpn)
    if [[ $? -eq 0 && -n "$VPN" ]]; then
        INTERFACE=$(basename "${VPN%.conf}")
        echo "Estado de la VPN $INTERFACE:"
        if sudo ip link show "$INTERFACE" &>/dev/null; then
            sudo wg show "$INTERFACE"
        else
            echo "La interfaz $INTERFACE no está activa."
        fi
    fi
}

# Bucle principal del script con listado automático de VPNs
while true; do
    echo "========================="
    echo " WireGuard VPN Manager"
    echo "========================="
    listar_vpns
    echo "1) Conectar VPN"
    echo "2) Desconectar VPN"
    echo "3) Ver estado de una VPN"
    echo "4) Salir"
    echo
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) conectar_vpn ;;
        2) desconectar_vpn ;;
        3) ver_estado ;;
        4) echo "Saliendo del script."; exit 0 ;;
        *) echo "Opción inválida, intenta de nuevo." ;;
    esac
done
