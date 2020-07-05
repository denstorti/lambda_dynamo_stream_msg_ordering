// applications/kinesis_streamer/lib/handler.js

import AWS from 'aws-sdk';
const kinesis = new AWS.Kinesis();

export function receiveEvent(event, context, callback) {
  console.log('receiveEvent');
  console.log(`Event: ${JSON.stringify(event, null, 2)}`);
  console.log(`Context: ${JSON.stringify(context, null, 2)}`);
  const base64Data = event.Records[0].kinesis.data;
  const base64Decoded = new Buffer(base64Data, 'base64').toString()
  console.log(base64Decoded);
  return callback();
}

export function publishEvent(event, context, callback) {
  console.log('publishEvent');
  console.log(`Event: ${JSON.stringify(event, null, 2)}`);
  console.log(`Context: ${JSON.stringify(context, null, 2)}`);

  const params = {
    Data: '{ sample: "json-object" }',
    PartitionKey: 'resource-1',
    StreamName: 'terraform-kinesis-streamer-demo-stream'
  };

  console.log('putting kinesis record');
  kinesis.putRecord(params, (err, data) => {
    if (err) {
      console.error('error putting kinesis record');
      console.error(err);
      return callback(err);
    }

    console.log('kinesis put success');
    console.log(JSON.stringify(data, null, 2));
    return callback();
  });
}