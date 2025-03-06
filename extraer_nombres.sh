#!/bin/bash

# Verificar que se proporcionó un archivo como parámetro
if [ -z "$1" ]; then
    echo "Ejemplo: $0 /etc/bind/master/fi.uncoma.edu.ar.zone"
    exit 1
fi

archivo_bind="$1"
archivo_salida="dominios.txt"  # Nombre del archivo de salida

# Extraer nombres de registros A y CNAME, excluir líneas que comienzan con @ o ;, formatearlos y ordenarlos
grep -E '\s+(A|CNAME)\s+' "$archivo_bind" | grep -v -E '^\s*[@;]' | awk '{print $1}' | sed 's/\.$//' | sort | uniq | while read -r nombre; do
    echo "${nombre}.fi.uncoma.edu.ar"
done > "$archivo_salida"  # Redirigir la salida al archivo

echo "Los dominios se han guardado en $archivo_salida"
