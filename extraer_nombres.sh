#!/bin/bash

# Verificar que se proporcionó un archivo como parámetro
if [ -z "$1" ]; then
    echo "Uso: $0 <archivo_bind>"
    exit 1
fi

archivo_bind="$1"

# Extraer nombres de registros A y CNAME, excluir líneas que comienzan con @ o ;, formatearlos y ordenarlos
grep -E '\s+(A|CNAME)\s+' "$archivo_bind" | grep -v -E '^\s*[@;]' | awk '{print $1}' | sed 's/\.$//' | sort | uniq | while read -r nombre; do
    echo "${nombre}.fi.uncoma.edu.ar"
done