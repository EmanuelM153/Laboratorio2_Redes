import json
import numpy as np
import matplotlib.pyplot as plt

def count_tcp_packets_from_json(file_path, time_interval=1):
    # Leer los datos JSON desde el archivo
    with open(file_path, 'r') as f:
        data = json.load(f)

    # Extraer los tiempos de los paquetes desde el campo 'frame.time_epoch'
    timestamps = []
    for packet in data:
        if 'frame.time_epoch' in packet["_source"]["layers"]:
            timestamp = float(packet["_source"]["layers"]["frame.time_epoch"][0])
            timestamps.append(timestamp)

    total_packets = len(timestamps)
    print(f"Cantidad total de paquetes en {file_path}: {total_packets}")

    # Obtener el tiempo máximo para predefinir el tamaño del arreglo
    max_time = max(timestamps)
    num_intervals = int(max_time // time_interval) + 1

    # Crear el arreglo directamente con el número de intervalos
    packet_counts = np.zeros(num_intervals)

    # Contar paquetes en cada intervalo
    for timestamp in timestamps:
        interval_index = int(timestamp // time_interval)
        packet_counts[interval_index] += 1

    return packet_counts

# Contar paquetes desde JSON
packet_counts1 = count_tcp_packets_from_json('./captura250.congest.json')
packet_counts2 = count_tcp_packets_from_json('./captura1_50.congest.json')

# Filtrar los datos
threshold = 0
filtered_intervals1 = packet_counts1[packet_counts1 > threshold]
filtered_intervals2 = packet_counts2[packet_counts2 > threshold]

print(f"Numero maximo de paquetes que se pueden mostrar en archivo 1: {len(filtered_intervals1)}")
print(f"Numero maximo de paquetes que se pueden mostrar en archivo 2: {len(filtered_intervals2)}")

# Graficar
plt.plot(filtered_intervals1, color='green', label='Simulación')
plt.plot(filtered_intervals2, color='blue', label='Real')
plt.xlabel('Intervalo (s)')
plt.ylabel('Paquetes / 1 seg')
plt.title('Grafica de Paquetes por Intervalos de Tiempo')
plt.xlim(0, max(len(filtered_intervals1), len(filtered_intervals2)))
plt.grid(True)

plt.legend()
plt.show()