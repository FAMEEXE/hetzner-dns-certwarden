#!/bin/bash

CERTBOT_DOMAIN=$1
CERTBOT_VALIDATION=$2

search_name=$( echo $CERTBOT_DOMAIN | rev | cut -d'.' -f 1,2 | rev)
zone=$(curl \
	-H "Authorization: Bearer ${HETZNER_TOKEN}" \
        "https://api.hetzner.cloud/v1/zones/${search_name}")
echo $zone
zone_id=$(echo "$zone" | grep -o '"id":[[:space:]]*[0-9]*' | grep -o '[0-9]*')

name=$(echo "${CERTBOT_DOMAIN}" | awk -F'.' '{print $1}')
curl \
        -X POST \
        -H "Authorization: Bearer ${HETZNER_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${name}\",\"type\":\"TXT\",\"ttl\":300,\"records\":[{\"value\": \"\\\"${CERTBOT_VALIDATION}\\\"\",\"comment\":\"Created by certbot, do not edit\"}]}" \
        "https://api.hetzner.cloud/v1/zones/${zone_id}/rrsets"

# just make sure we sleep for a while (this should be a dig poll loop)
sleep 30
