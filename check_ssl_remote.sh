#!/bin/bash

# Definir la cantidad de días antes de la expiración para notificar
DAYS_WARNING=30

# Archivo de texto que contiene los dominios (uno por línea)
DOMAIN_FILE="dominios.txt"

# Verificar si el archivo existe
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "⚠️ El archivo $DOMAIN_FILE no existe. Por favor, crea un archivo con los dominios a verificar."
    exit 1
fi

# Matriz para almacenar los dominios y sus fechas de vencimiento
declare -A DOMAIN_EXPIRATION

# Leer cada dominio del archivo
while IFS= read -r DOMAIN; do
    # Verificar si la línea no está vacía
    if [ -z "$DOMAIN" ]; then
        continue
    fi

    # Obtener el certificado del dominio remoto
    EXPIRATION_DATE=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)

    if [ -z "$EXPIRATION_DATE" ]; then
        echo "⚠️ No se pudo obtener el certificado para $DOMAIN. Verifica que el dominio esté accesible."
        continue
    fi

    # Convertir la fecha de vencimiento en segundos desde el Epoch
    EXPIRATION_EPOCH=$(date -d "$EXPIRATION_DATE" +%s)
    CURRENT_EPOCH=$(date +%s)

    # Calcular los días restantes para el vencimiento
    DAYS_LEFT=$(( (EXPIRATION_EPOCH - CURRENT_EPOCH) / 86400 ))

    # Guardar la información en la matriz: clave = días restantes, valor = dominio
    DOMAIN_EXPIRATION["$DOMAIN"]="$DAYS_LEFT"

done < "$DOMAIN_FILE"

# Ordenar los dominios por los días restantes hasta el vencimiento y mostrarlos
for DOMAIN in "${!DOMAIN_EXPIRATION[@]}" ; do
    echo "$DOMAIN ${DOMAIN_EXPIRATION[$DOMAIN]}"
done | sort -nk2 | while read -r DOMAIN DAYS_LEFT; do
    if [ "$DAYS_LEFT" -le "$DAYS_WARNING" ]; then
        echo "⚠️ El certificado para $DOMAIN caduca en $DAYS_LEFT días."
    else
        echo "✔️ El certificado para $DOMAIN es válido por $DAYS_LEFT días más."
    fi
done

