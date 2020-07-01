#!/bin/bash
set -xe

for n in $(seq 0 50)
do
 aws dynamodb put-item --table-name GameScores --item "{ \"UserId\": { \"S\": \"1\" }, \"GameTitle\": { \"S\": \""$n"\" }, \"Term_session_id\": { \"S\": \""$TERM_SESSION_ID"\"} }" | jq
 echo Result: $?
done