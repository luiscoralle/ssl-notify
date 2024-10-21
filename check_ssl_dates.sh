#!/bin/bash

# Archivo de texto que contiene los dominios (uno por línea)
DOMAIN_FILE="dominios.txt"

# Verificar si el archivo existe
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "⚠️ El archivo $DOMAIN_FILE no existe. Por favor, crea un archivo con los dominios a verificar."
    exit 1
fi

# Leer cada dominio del archivo
while IFS= read -r DOMAIN; do
    # Verificar si la línea no está vacía
    if [ -z "$DOMAIN" ]; then
        continue
    fi

    # Obtener el certificado del dominio remoto
    CERT_INFO=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates)

    if [ -z "$CERT_INFO" ]; then
        echo "⚠️ No se pudo obtener el certificado para $DOMAIN. Verifica que el dominio esté accesible."
        continue
    fi

    # Extraer la fecha de emisión (notBefore) y la fecha de vencimiento (notAfter)
    ISSUED_DATE=$(echo "$CERT_INFO" | grep 'notBefore' | cut -d= -f2)
    EXPIRATION_DATE=$(echo "$CERT_INFO" | grep 'notAfter' | cut -d= -f2)

    # Mostrar la información
    echo "Dominio: $DOMAIN"
    echo "Fecha de emisión: $ISSUED_DATE"
    echo "Fecha de vencimiento: $EXPIRATION_DATE"
    echo "-----------------------------------"
    
done < "$DOMAIN_FILE"

