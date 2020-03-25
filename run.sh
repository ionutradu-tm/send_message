#!/bin/bash


function send_message(){

  local BOT_MESSAGE="$1"
  local BOT_GROUP_ID="$2"
  local BOT_URL="$3"


  if [[ -n ${BOT_GROUP_ID} ]] && [[ -n ${BOT_URL} ]];then
    echo -e "{\n}" > bot_body.json
    cat bot_body.json |
    jq 'setpath(["groupId"]; "'"${BOT_GROUP_ID}"'")'|
    jq 'setpath(["message"]; "'"${BOT_MESSAGE}"'")' > bot_body_send.json
    RESPONSE_CODE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST --data @bot_body_send.json ${BOT_URL} -H "Content-Type: application/json")
    echo ${RESPONSE_CODE}
  fi
}

if [[ ${WERCKER_RESULT} == "failed" ]];then
  export BOT_MESSAGE="(angryface) (angryface) (angryface) (angryface)${WERCKER_SEND_MESSAGE_FAILED_MESSAGE} (angryface) (angryface) (angryface)"
else
  export BOT_MESSAGE="(like) (like) (like) ${WERCKER_SEND_MESSAGE_PASSED_MESSAGE} (like) (like) (like)"
fi

send_message "${BOT_MESSAGE}" "${WERCKER_SEND_MESSAGE_BOT_GROUP_ID}" "${WERCKER_SEND_MESSAGE_BOT_URL}"
