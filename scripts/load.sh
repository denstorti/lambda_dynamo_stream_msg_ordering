#!/bin/bash
set -xe

for n in $(seq 0 100)
do
 aws dynamodb put-item --table-name GameScores --item "{ \"UserId\": { \"S\": \""`uuidgen`"\" }, \"GameTitle\": { \"S\": \"asdasdasd\" } }" | jq
 echo Result: $?
done