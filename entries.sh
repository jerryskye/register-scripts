#!/bin/bash

API_URL="http://192.168.0.100:3000/entries.json"
SECRET=`echo 'select secret from secret' | sqlite3 tokens.db`
JWT_HEADER=`echo -n '{"typ": "JWT", "alg": "HS256"}' | base64`
LOGFILE="`dirname $0`/curl.log"

while true; do
  uid=`./read_uid`
  [ $? -ne 0 ] && echo "[`date`] Failed to read your card. Please try again or contact the system administrator if the problem persists." && continue
  exp="$((`date +%s` + 5))"
  payload=`echo -n "{\"exp\": $exp}" | base64`
  signature=`echo -n "$JWT_HEADER.$payload" | hmac256 --binary "$SECRET" | base64`

  curl -s -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $JWT_HEADER.$payload.$signature" -d "{\"uid\": \"$uid\"}" "$API_URL" >> $LOGFILE
  echo >> $LOGFILE
done
