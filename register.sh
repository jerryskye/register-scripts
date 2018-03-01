#!/bin/bash

REGISTER_URL='http://192.168.0.100:3000/users/sign_up'
SECRET=`echo 'select secret from secret' | sqlite3 tokens.db`

tokens_count=`echo 'select count(*) from registration_tokens' | sqlite3 tokens.db`

while true; do
  if [ $tokens_count -lt 1 ]; then
    echo Out of tokens!
    exit
  fi
  uid=`./read_uid`
  [ $? -ne 0 ] && echo "[`date`] Failed to read your card. Please try again or contact the system administrator if the problem persists." && continue
  token=`echo 'select token from registration_tokens limit 1' | sqlite3 tokens.db`
  hmac=`echo -n $token | hmac256 "$SECRET"`
  echo "delete from registration_tokens where token='$token'" | sqlite3 tokens.db
  ((tokens_count -= 1))
  echo -n "$REGISTER_URL?uid=$uid&token=$token&hmac=$hmac" | qrencode -o qr.png
  timeout --foreground 8 fbi -a qr.png > /dev/null 2>&1
done
