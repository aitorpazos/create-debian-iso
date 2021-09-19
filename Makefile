IMAGE_TAG:=aitorpazos/create-debian-iso

.PHONY: build
build: buildDebianBuster buildUbuntuBionic buildUbuntuFocal

.PHONY: buildDebianBuster
buildDebianBuster:
	docker build --rm --build-arg DISTRO=debian --build-arg DISTRO_VERSION=buster -t $(IMAGE_TAG) -t $(IMAGE_TAG):debian-buster .

.PHONY: buildUbuntuBionic
buildUbuntuBionic:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=bionic -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-bionic .

.PHONY: buildUbuntuFocal
buildUbuntuFocal:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=focal -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-focal .

.PHONY: test
test: testExampleBuster testExampleBionic testExampleFocal

.PHONY: testExampleBuster
testExampleBuster:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):debian-buster
	
.PHONY: testExampleBionic
testExampleBionic:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-bionic

.PHONY: testExampleFocal
testExampleFocal:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-focal
