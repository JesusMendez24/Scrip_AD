import csv
from fuzzywuzzy import fuzz
from fuzzywuzzy import process

# Cargar los nombres de empleados y usuarios desde archivos CSV (cambia los nombres de archivo según corresponda)
with open('empleados.csv', 'r', encoding='latin-1') as empleados_file:
    empleados = [line.strip() for line in empleados_file]

with open('usuarios_ad.csv', 'r', encoding='latin-1') as usuarios_ad_file:
    usuarios_ad = [line.strip() for line in usuarios_ad_file]

# Crear una lista para almacenar las coincidencias encontradas
coincidencias = []

# Definir umbral de similitud
umbral_similitud = 86 

# Comparar los nombres de usuarios en Active Directory con los nombres de empleados
for usuario_ad in usuarios_ad:
    mejor_coincidencia, similitud = process.extractOne(usuario_ad, empleados)
    if similitud >= umbral_similitud:
        coincidencias.append((usuario_ad, mejor_coincidencia))

# Escribir las coincidencias en un archivo CSV
nombre_archivo = "coincidencias.csv"
with open(nombre_archivo, "w", newline="") as archivo_csv:
    writer = csv.writer(archivo_csv)
    writer.writerow(["Usuario en AD", "Mejor Coincidencia de Empleado"])
    writer.writerows(coincidencias)

print("Coincidencias exportadas correctamente a", nombre_archivo)