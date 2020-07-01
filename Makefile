export AWS_SDK_LOAD_CONFIG=1 

package:
	zip -j -r lambda_function_payload.zip ./src/main.py

clean_local: 
	rm lambda_function_payload.zip

plan: package
	AWS_SDK_LOAD_CONFIG=1 terraform plan -out planned_changes

deploy: plan
	AWS_SDK_LOAD_CONFIG=1 terraform apply planned_changes

undeploy:
	AWS_SDK_LOAD_CONFIG=1 terraform destroy -auto-approve

load_ddb:
	bash scripts/load.sh