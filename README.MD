# WireGuard VPN Manager

## Importante

Para que este script funcione correctamente, es necesario otorgar permisos de ejecución a ambos archivos:

```bash
chmod +x wireguard.sh
chmod +x vpn-manager.desktop

## Permisos de Ejecución en el Icono del Escritorio
Además, asegúrate de otorgar permisos de ejecución al archivo del icono del escritorio (vpn-manager.desktop) para que pueda ejecutarse correctamente.


## Descripción
Este es un simple script que lista todas las configuraciones existentes dentro de /etc/wireguard y permite interactuar directamente con ellas para conectar o desconectar la VPN.

Nota:
Dado que /etc/wireguard solo es accesible con permisos de root, al igual que la ejecución de wg-quick, el script solicitará la clave de superusuario (su) o utilizará sudo para realizar estas operaciones.

## Requisitos
WireGuard debe estar instalado y configurado en tu sistema.
El usuario debe tener permisos para usar sudo.

## Uso
Otorga permisos de ejecución a los archivos:
bash
Copiar código
chmod +x wireguard.sh
chmod +x vpn-manager.desktop
Ejecuta el script desde la terminal:
bash
Copiar código
./wireguard.sh
O desde el icono del escritorio, si has configurado vpn-manager.desktop.


## Funcionamiento del Script
Listar configuraciones: Muestra todas las configuraciones de WireGuard en /etc/wireguard.
Conectar: Permite seleccionar una configuración y conectarse a la VPN.
Desconectar: Permite desconectarse fácilmente de la VPN.

