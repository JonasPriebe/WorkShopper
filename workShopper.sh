#!/bin/bash

WORKSHOP_ID=$1

HEADERS="Content-Type: application/x-www-form-urlencoded"

DATA="collectioncount=1&publishedfileids[0]=$WORKSHOP_ID"

RESPONSE=$(curl -X POST \
  https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/ \
  -H "$HEADERS" \
  -d "$DATA")

PUBLISHEDFILEIDS=$(jq '.response.collectiondetails[0].children[] | .publishedfileid' <<< "$RESPONSE")

IFS=$'\n' read -rd '' -a array <<< "$PUBLISHEDFILEIDS"

ITEMCOUNT="itemcount=${#array[@]}"


curl_command="curl --location 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/'"
curl_command+=" -H \"$HEADERS\"
"
curl_command+=" --data-urlencode '${ITEMCOUNT}'"

for i in "${!array[@]}"; do
  array[i]="${array[$i]//\"/}"
  curl_command+=" --data-urlencode 'publishedfileids[$i]=${array[$i]}'"
done

echo "$curl_command"
RESPONSE=$(eval $curl_command)
echo "$RESPONSE"