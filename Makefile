IMAGE_TAG:=aitorpazos/create-debian-iso

.PHONY: build
build: buildDebianBullseye buildUbuntuBionic buildUbuntuFocal buildKdeNeon

.PHONY: buildDebianBullseye
buildDebianBullseye:
	docker build --rm --build-arg DISTRO=debian --build-arg DISTRO_VERSION=bullseye -t $(IMAGE_TAG) -t $(IMAGE_TAG):debian-bullseye .

.PHONY: buildUbuntuBionic
buildUbuntuBionic:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=bionic -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-bionic .

.PHONY: buildUbuntuFocal
buildUbuntuFocal:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=focal -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-focal .

.PHONY: buildKdeNeon
buildKdeNeon:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=focal --build-arg DISTRO_FLAVOR=neon -t $(IMAGE_TAG) -t $(IMAGE_TAG):kde-neon .

.PHONY: test
test: testExampleBullseye testExampleBionic testExampleFocal testExampleNeon

.PHONY: testExampleBullseye
testExampleBullseye:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):debian-bullseye
	
.PHONY: testExampleBionic
testExampleBionic:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-bionic

.PHONY: testExampleFocal
testExampleFocal:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-focal

.PHONY: testExampleNeon
testExampleNeon:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):kde-neon
