#!/bin/bash

if [ -z "$WEBAPP_URL" ]; then
  echo 'Invalid WEBAPP_URL variable'
  exit 1
fi

ENTRIES_URL="$WEBAPP_URL/entries.json"
SECRET=`echo 'select secret from secret' | sqlite3 tokens.db`
DEVICE_ID=`echo 'select device_id from secret' | sqlite3 tokens.db`
JWT_HEADER=`echo -n '{"typ": "JWT", "alg": "HS256"}' | base64 -w 0`
LOGFILE="`dirname $0`/curl.log"

while true; do
  uid=`./read_uid`
  [ $? -ne 0 ] && echo "[`date`] Failed to read your card. Please try again or contact the system administrator if the problem persists." && continue
  exp="$((`date +%s` + 5))"
  payload=`echo -n "{\"exp\": $exp}" | base64 -w 0`
  signature=`echo -n "$JWT_HEADER.$payload" | hmac256 --binary "$SECRET" | base64 -w 0`

  curl -s -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $JWT_HEADER.$payload.$signature" -d "{\"uid\": \"$uid\", \"device_id\": \"$DEVICE_ID\"}" "$ENTRIES_URL" >> $LOGFILE
  echo >> $LOGFILE
done
