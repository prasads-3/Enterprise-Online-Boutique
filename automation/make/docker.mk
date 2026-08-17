.PHONY: docker-build docker-push

docker-build:
	@bash automation/scripts/docker-build.sh

docker-push:
	@bash automation/scripts/docker-push.sh
