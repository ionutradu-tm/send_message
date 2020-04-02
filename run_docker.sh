#!/bin/bash

if [[ -n ${BOT_GROUP_ID} ]] && [[ -n ${BOT_URL} ]] && [[ -n ${BOT_MESSAGE} ]];then
  echo -e "{\n}" > bot_body.json
  cat bot_body.json |
  jq 'setpath(["groupId"]; "'"${BOT_GROUP_ID}"'")'|
  jq 'setpath(["message"]; "'"${BOT_MESSAGE}"'")' > bot_body_send.json
  RESPONSE_CODE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST --data @bot_body_send.json ${BOT_URL} -H "Content-Type: application/json")
  echo ${RESPONSE_CODE}
fi