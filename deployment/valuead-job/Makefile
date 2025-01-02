VERSION=v4.1.4a

build:
	@echo "Building images..."
	docker build --platform=linux/amd64 -t thaovu/valuead_java_job:${VERSION} .
push:
	@echo "Pushing images..."
	docker push thaovu/valuead_java_job:${VERSION}

ecr-login:
	@echo "Logging into ECR..."
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/s9j3e2g3

build-push:
	@echo "Building and pushing images..."
	docker build --platform=linux/amd64 -t public.ecr.aws/s9j3e2g3/valuead-sale-job:${VERSION} .
	docker push public.ecr.aws/s9j3e2g3/valuead-sale-job:${VERSION}