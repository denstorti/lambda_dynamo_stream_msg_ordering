export AWS_SDK_LOAD_CONFIG=1 

AWS_SDK_LOAD_CONFIG=1

init:
	terraform init

package:
	zip -j -r lambda_function_payload.zip ./src/main.py

clean_local: 
	rm lambda_function_payload.zip

plan: package
	terraform plan -out planned_changes

deploy: plan
	terraform apply planned_changes

undeploy:
	terraform destroy -auto-approve

load_ddb:
	bash scripts/load.sh

describe_stream:
	aws dynamodbstreams describe-stream --stream-arn `terraform output stream_arn`