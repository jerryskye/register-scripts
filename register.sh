#!/bin/bash

REGISTER_URL='http://192.168.0.100:3000/users/sign_up'
SECRET=`echo 'select secret from secret' | sqlite3 tokens.db`
JWT_HEADER=`echo -n '{"typ": "JWT", "alg": "HS256"}' | base64 -w 0`

while true; do
  uid=`./read_uid`
  [ $? -ne 0 ] && echo "[`date`] Failed to read your card. Please try again or contact the system administrator if the problem persists." && continue
  exp="$((`date +%s` + 86400))"
  payload=`echo -n "{\"exp\": $exp, \"sub\": \"$uid\", \"admin\": false}" | base64 -w 0`
  signature=`echo -n "$JWT_HEADER.$payload" | hmac256 --binary "$SECRET" | base64 -w 0`
  echo -n "$REGISTER_URL?token=$JWT_HEADER.$payload.$signature" | qrencode -o qr.png
  timeout --foreground 8 fbi -a qr.png > /dev/null 2>&1
done
