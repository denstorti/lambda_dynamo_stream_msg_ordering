## Testing message ordering in DynamoDB Streams

Insert items --> DDB Table --> DDB Stream --> Lambda

Steps:
1. Insert a high volume of data (100k) **in order** to a table.
2. Let it DDB stream this to the Lambda (no concurrency).
3. Lambda will append the message number to a S3 file.
4. Validation: S3 file should have all message numbers in order

