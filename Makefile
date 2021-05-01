ALL_ARCH = amd64 arm64

.EXPORT_ALL_VARIABLES:

VERSION_MAJOR ?= 1
VERSION_MINOR ?= 0
VERSION_BUILD ?= 0
TAG?=v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_BUILD)
FLAGS=
ENVVAR=
GOOS?=$(shell go env GOOS)
GOARCH?=$(shell go env GOARCH)
REGISTRY?=fred78290
BUILD_DATE?=`date +%Y-%m-%dT%H:%M:%SZ`
VERSION_LDFLAGS=-X main.phVersion=$(TAG)

IMAGE=$(REGISTRY)/test-go-github-action

all: deps $(addprefix build-arch-,$(ALL_ARCH))

deps:
	go mod vendor

build: build-arch-$(GOARCH)

build-arch-%: clean-arch-%
	$(ENVVAR) GOOS=$(GOOS) GOARCH=$* go build -ldflags="-X main.phVersion=$(TAG) -X main.phBuildDate=$(BUILD_DATE)" -a -o out/$(GOOS)/$*/test-go-github-action ${TAGS_FLAG}

container-push-manifest: container push-manifest

push-manifest:
	docker buildx build --pull --platform linux/amd64,linux/arm64 --push -t ${IMAGE}:${TAG} .
	@echo "Image ${TAG}* completed"

clean: $(addprefix clean-arch-,$(ALL_ARCH))

clean-arch-%:
	rm -f ./out/$(GOOS)/$*/test-go-github-action

docker-builder:
	docker build -t test-go-github-action-builder ./builder

build-in-docker: build-in-docker-arch-$(GOARCH)

build-in-docker-arch-%: clean-arch-% docker-builder
	docker run --rm -v `pwd`:/gopath/src/github.com/Fred78290/test-go-github-action/ test-go-github-action-builder:latest bash \
		-c 'cd /gopath/src/github.com/Fred78290/test-go-github-action \
		&& BUILD_TAGS=${BUILD_TAGS} make -e REGISTRY=${REGISTRY} -e TAG=${TAG} -e BUILD_DATE=`date +%Y-%m-%dT%H:%M:%SZ` build-arch-$*'

container: deps $(addprefix container-arch-,$(ALL_ARCH))

container-arch-%: build-in-docker-arch-%
	@echo "Full in-docker image ${TAG}${FOR_PROVIDER}-$* completed"

.PHONY: all build clean docker-builder build-in-docker push-manifest
