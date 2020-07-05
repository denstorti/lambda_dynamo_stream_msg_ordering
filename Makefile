export AWS_SDK_LOAD_CONFIG=1 

AWS_SDK_LOAD_CONFIG=1
TERRAFORM_FOLDER=./iac

init:
	terraform init ${TERRAFORM_FOLDER}

package:
	$(MAKE) clean_local
	mkdir output
	zip -j -r output/lambda_function_payload.zip ./src/main.py
	zip -j -r output/lambda_code.zip ./src/lambda_kinesis_handler.mjs

clean_local: 
	rm -rf output/

plan: package
	terraform plan -out output/planned_changes ${TERRAFORM_FOLDER} 

deploy: plan
	terraform apply output/planned_changes

undeploy:
	terraform destroy -auto-approve ${TERRAFORM_FOLDER} 

load_ddb:
	bash scripts/load.sh

describe_stream:
	aws dynamodbstreams describe-stream --stream-arn `terraform output stream_arn`