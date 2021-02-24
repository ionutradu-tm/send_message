#!/bin/bash

BOT_APP=${WERCKER_SEND_MESSAGE_BOT_APP}
BOT_USERNAME=${WERCKER_SEND_MESSAGE_BOT_USERNAME}
BOT_EMOJI=${WERCKER_SEND_MESSAGE_BOT_EMOJI}


function send_message(){

  local BOT_MESSAGE="$1"
  local BOT_GROUP_ID="$3"
  local BOT_URL="$2"

  if [[ ${BOT_APP,,} == "slack" ]];then
    BOT_USERNAME=${BOT_USERNAME:"SlackBot"}
    BOT_EMOJI=${BOT_EMOJI:"ghost"}
    if [[ -n ${BOT_URL} ]] && [[ -n ${BOT_MESSAGE} ]];then
      PAYLOAD=$(echo -e "{\n}" |
      jq 'setpath(["username"]; "'"${BOT_USERNAME}"'")'|
      jq 'setpath(["text"]; "'"${BOT_MESSAGE}"'")' |
      jq 'setpath(["icon_emoji"]; "'"${BOT_EMOJI}"'")' )
      RESPONSE_CODE=$(curl -k --write-out %{http_code} --silent --output /dev/null -X POST --data-urlencode "payload=$PAYLOAD" ${BOT_URL} )
      echo "Slack response_conde: ${RESPONSE_CODE} "
    fi
  elif [[ -n ${BOT_GROUP_ID} ]] && [[ -n ${BOT_URL} ]];then
    echo -e "{\n}" > bot_body.json
    cat bot_body.json |
    jq 'setpath(["groupId"]; "'"${BOT_GROUP_ID}"'")'|
    jq 'setpath(["message"]; "'"${BOT_MESSAGE}"'")' > bot_body_send.json
    RESPONSE_CODE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST --data @bot_body_send.json ${BOT_URL} -H "Content-Type: application/json")
    echo ${RESPONSE_CODE}
  fi
}

if [[ ${WERCKER_RESULT} == "failed" ]];then
    export BOT_MESSAGE="(devil) Branch: ${WERCKER_GIT_BRANCH}, PIPE: ${WERCKER_FAILED_STEP_DISPLAY_NAME}, ERROR: ${WERCKER_FAILED_STEP_MESSAGE} (devil)"
    SEND="1"
else  
  if [[ ${WERCKER_SEND_MESSAGE_NOTIFY_ON} != "failed" ]];then
    export BOT_MESSAGE="(like)  ${WERCKER_SEND_MESSAGE_PASSED_MESSAGE} (like)"
    SEND="1"
  fi
fi
if [[ -n ${SEND} ]];then
  send_message "${BOT_MESSAGE}" "${WERCKER_SEND_MESSAGE_BOT_URL}" "${WERCKER_SEND_MESSAGE_BOT_GROUP_ID}"
fi