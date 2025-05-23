APP        := app
REGISTRY   ?= ghcr.io/bwoogmy
VERSION    := $(shell git describe --tags --abbrev=0)
BUILD_DIR  := bin
ARCH       ?= amd64
GOOS_LIST  := linux windows darwin
IMAGE_TAG  := $(REGISTRY)/$(APP):$(VERSION)
TARGETOS   ?= linux
TARGETARCH ?= amd64
CGO_ENABLED ?= 0
BINARY     := $(APP)

.PHONY: all deps build multi-build image push run clean

all: deps multi-build image

deps:
	go mod tidy

$(GOOS_LIST):
	$(MAKE) build TARGETOS=$@ TARGETARCH=$(ARCH)

build: deps
	GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) CGO_ENABLED=$(CGO_ENABLED) \
		go build -o $(BUILD_DIR)/$(BINARY)-$(TARGETOS)-$(TARGETARCH) .

multi-build: deps
	for GOOS in $(GOOS_LIST); do \
		GOOS=$$GOOS GOARCH=$(ARCH) CGO_ENABLED=$(CGO_ENABLED) \
			go build -o $(BUILD_DIR)/$(BINARY)-$$GOOS-$(ARCH) . ; \
	done

image:
	docker build \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg BINARY=$(BINARY)-$(TARGETOS)-$(TARGETARCH) \
		-t $(IMAGE_TAG) .

push:
	docker push $(IMAGE_TAG)

run:
	docker run --rm $(IMAGE_TAG)

clean:
	rm -rf $(BUILD_DIR)
	docker rmi $(IMAGE_TAG) || true
