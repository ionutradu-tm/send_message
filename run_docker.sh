#!/bin/bash


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
elif [[ -n ${BOT_GROUP_ID} ]] && [[ -n ${BOT_URL} ]] && [[ -n ${BOT_MESSAGE} ]];then
  echo -e "{\n}" > bot_body.json
  cat bot_body.json |
  jq 'setpath(["groupId"]; "'"${BOT_GROUP_ID}"'")'|
  jq 'setpath(["message"]; "'"${BOT_MESSAGE}"'")' > bot_body_send.json
  RESPONSE_CODE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST --data @bot_body_send.json ${BOT_URL} -H "Content-Type: application/json")
  echo ${RESPONSE_CODE}
fi