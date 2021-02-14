IMAGE_TAG:=aitorpazos/create-debian-iso

.PHONY: build
build:
	docker build --rm -t $(IMAGE_TAG) .

.PHONY: testExample
testExample:
	docker run -t --rm -v $(shell pwd)/example:/root/files $(IMAGE_TAG)
