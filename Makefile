export LAMBDA_FUNCTION_NAME = lambda-function-test
export DIST_DIR = dist

.PHONY: create-role
create-role:
	@aws iam create-role \
		--role-name lambda-role \
		--assume-role-policy-document file://role.json \
		--output yaml \
		--no-cli-pager

.PHONY: create
create:
	@ARN=$$(aws iam get-role \
            --role-name lambda-role \
            --output yaml \
            --no-cli-pager | grep "Arn:" | sed 's/  Arn: //') \
	&& echo "ARN: $$ARN" \
	&& aws lambda create-function \
		--function-name ${LAMBDA_FUNCTION_NAME} \
		--runtime python3.10 \
		--role $$ARN \
		--handler lambda_function.lambda_handler \
		--zip-file fileb://${DIST_DIR}/lambda.zip \
		--timeout 5 \
		--memory-size 128 \
		--output yaml \
		--no-cli-pager 

.PHONY: build
build:
	@if [ -d ${DIST_DIR} ]; then rm -r ${DIST_DIR}; fi
	@poetry export -f requirements.txt --output requirements.txt.tmp --without-hashes --only main \
		&& poetry run pip install -r requirements.txt.tmp -t ${DIST_DIR}/lambda \
		&& rm requirements.txt.tmp
	@cp -r src/* ./${DIST_DIR}/lambda
	@cd ${DIST_DIR}/lambda && zip -r ../lambda.zip * -x '*.pyc' -x '__pycache__/*'
	@du -smh ${DIST_DIR}/lambda ${DIST_DIR}/lambda.zip

.PHONY: push
push:
	@aws lambda update-function-code \
		--function-name ${LAMBDA_FUNCTION_NAME} \
		--zip-file fileb://${DIST_DIR}/lambda.zip \
		--no-cli-pager \
		--output yaml 

.PHONY: update
update: build push

.PHONY: invoke
invoke:
	@aws lambda invoke --function-name ${LAMBDA_FUNCTION_NAME} \
		--payload '{"type": "programming"}' \
		--cli-binary-format raw-in-base64-out output.json

.PHONY: test
test:
	python -m pytest