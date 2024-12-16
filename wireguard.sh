#!/bin/bash

# Directorio donde se encuentran los archivos de configuración de WireGuard
WG_DIR="/etc/wireguard"

# Función para mostrar el menú principal
menu_principal() {
    echo "========================="
    echo " WireGuard VPN Manager"
    echo "========================="
    echo "1) Conectar VPN"
    echo "2) Desconectar VPN"
    echo "3) Ver estado de una VPN"
    echo "4) Listar configuraciones disponibles"
    echo "5) Salir"
    echo
    read -p "Selecciona una opción: " opcion
}

# Función para listar las configuraciones disponibles
listar_vpns() {
    echo "=== Configuraciones disponibles ==="
    # Buscar archivos .conf y almacenarlos en un array
    mapfile -t VPNS < <(sudo find "$WG_DIR" -maxdepth 1 -type f -name "*.conf" 2>/dev/null)
    if [[ ${#VPNS[@]} -eq 0 ]]; then
        echo "No se encontraron configuraciones de VPN en $WG_DIR"
        return 1
    fi
    for i in "${!VPNS[@]}"; do
        echo "$((i + 1))) $(basename "${VPNS[$i]}")"
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

    # Validar selección
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
        INTERFACE=$(basename "${VPN%.conf}") # Eliminar la extensión .conf
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
        INTERFACE=$(basename "${VPN%.conf}") # Eliminar la extensión .conf
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
        INTERFACE=$(basename "${VPN%.conf}") # Eliminar la extensión .conf
        echo "Estado de la VPN $INTERFACE:"
        if sudo ip link show "$INTERFACE" &>/dev/null; then
            sudo wg show "$INTERFACE"
        else
            echo "La interfaz $INTERFACE no está activa. Por favor, conéctala primero."
        fi
    fi
}

# Bucle principal del script
while true; do
    menu_principal
    case $opcion in
        1)
            conectar_vpn
            ;;
        2)
            desconectar_vpn
            ;;
        3)
            ver_estado
            ;;
        4)
            listar_vpns
            ;;
        5)
            echo "Saliendo del script."
            exit 0
            ;;
        *)
            echo "Opción inválida, intenta de nuevo."
            ;;
    esac
done
