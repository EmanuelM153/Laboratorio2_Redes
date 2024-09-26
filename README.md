# Simulación Procotolo TCP

En este repositorio se guardan los códigos y las configuraciones de las herramientas usadas para el laboratorio de simulación del protocolo TCP.

## Archivos
- dce-global-variables.cc: versión modificada del archivo fuente con el mismo nombre, usado en el módulo DCE del simulador NS-3
    - Se reemplazó la función propia del simulador `ns3_fdopen` por la propia del sistema operativo `fdopen`, debido a un error en tiempo de ejecución para abrir los descriptores de archivo `stdin`, `stdout`, `stderr`.
- simulacion
    - simulacion.cc: archivo con el código de la simulación
    - wscript: archivo de configuración para la compilación de este script
- image_plot.py: archivo con el código para procesar el json de las capturas con los timestamps, y graficar los paquetes por segundo en el intervalo de envío de los datos
