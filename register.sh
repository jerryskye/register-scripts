#!/bin/bash

REGISTER_URL='http://192.168.0.100:3000/users/sign_up'
SECRET=`echo 'select secret from secret' | sqlite3 tokens.db`

tokens_count=`echo 'select count(*) from tokens' | sqlite3 tokens.db`

while true; do
  if [ $tokens_count -lt 1 ]; then
    echo Out of tokens!
    exit
  fi
  uid=`./read_uid`
  [ $? -ne 0 ] && echo "[`date`] Failed to read your card. Please try again, or contact the system administrator if the problem persists." && continue
  salt=`date +%s`
  token=`echo 'select token from tokens limit 1' | sqlite3 tokens.db`
  hsh=`echo -n "$SECRET$salt" | shasum -a 256 | awk '{ print $1 }'`
  echo "delete from tokens where token='$token'" | sqlite3 tokens.db
  ((tokens_count -= 1))
  echo -n "$REGISTER_URL?uid=$uid&salt=$salt&token=$token&hash=$hsh" | qrencode -o qr.png
done
