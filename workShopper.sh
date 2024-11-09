#!/bin/bash

WORKSHOP_ID=$1

echo "Starting Search for $WORKSHOP_ID"
echo
echo
HEADERS="Content-Type: application/x-www-form-urlencoded"

DATA="collectioncount=1&publishedfileids[0]=$WORKSHOP_ID"

RESPONSE=$(curl -s -X POST \
  https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/ \
  -H "$HEADERS" \
  -d "$DATA")

PUBLISHEDFILEIDS=$(jq '.response.collectiondetails[0].children[] | .publishedfileid' <<< "$RESPONSE")

IFS=$'\n' read -rd '' -a array <<< "$PUBLISHEDFILEIDS"

ITEMCOUNT="itemcount=${#array[@]}"


curl_command="curl -s --location 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/'"
curl_command+=" -H \"$HEADERS\"
"
curl_command+=" --data-urlencode '${ITEMCOUNT}'"

for i in "${!array[@]}"; do
  array[i]="${array[$i]//\"/}"
  curl_command+=" --data-urlencode 'publishedfileids[$i]=${array[$i]}'"
done


RESPONSE=$(eval $curl_command)
DESCRIPTIONS=$(jq '.response.publishedfiledetails[].description' <<< "$RESPONSE")
mapfile -t DESCRIPTIONS_ARRAY <<< "$DESCRIPTIONS"

CURRENTWORKSHOPID=0
RESULTS=""
for line in "${DESCRIPTIONS_ARRAY[@]}"; do
    matches=()
    while IFS= read -r match; do
        clean_match=$(echo "$match" | sed 's/^Mod ID: //')
        matches+=("$clean_match;")
    done < <(echo "$line" | grep -o "Mod ID: [[:alnum:]_-]*")
    if [ ${#matches[@]} -gt 1 ]; then
        echo "Multiple Mod IDs found for ${array[$CURRENTWORKSHOPID]}: ${matches[@]}"
        ((CURRENTWORKSHOPID++))
    fi
     RESULTS+="${matches[@]}"
done
RESULTS=${RESULTS%?}
echo
echo "Workshop IDs for Collection $WORKSHOP_ID: {$RESULTS}"