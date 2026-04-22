
search_name=$( echo $CERTBOT_DOMAIN | rev | cut -d'.' -f 1,2 | rev)
zone=$(curl \
        -H "Authorization: Bearer ${HETZNER_TOKEN}" \
        "https://api.hetzner.cloud/v1/zones/${search_name}")
echo $zone
zone_id=$(echo "$zone" | grep -o '"id":[[:space:]]*[0-9]*' | grep -o '[0-9]*')
curl \
	-X DELETE \
	-H "Authorization: Bearer ${HETZNER_TOKEN}" \
	"https://api.hetzner.cloud/v1/zones/${zone_id}/rrsets/_acme-challenge/TXT"
