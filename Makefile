IMAGE_TAG:=aitorpazos/create-debian-iso

.PHONY: build
build: buildDebianBullseye buildUbuntuBionic buildUbuntuJammy buildKdeNeon

.PHONY: buildDebianBullseye
buildDebianBullseye:
	docker build --rm --build-arg DISTRO=debian --build-arg DISTRO_VERSION=bullseye -t $(IMAGE_TAG) -t $(IMAGE_TAG):debian-bullseye .

.PHONY: buildUbuntuBionic
buildUbuntuBionic:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=bionic -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-bionic .

.PHONY: buildUbuntuJammy
buildUbuntuJammy:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=jammy -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-jammy .

.PHONY: buildKdeNeon
buildKdeNeon:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=jammy --build-arg DISTRO_FLAVOR=neon -t $(IMAGE_TAG) -t $(IMAGE_TAG):kde-neon .

.PHONY: test
test: testExampleBullseye testExampleBionic testExampleJammy testExampleNeon

.PHONY: testExampleBullseye
testExampleBullseye:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):debian-bullseye
	
.PHONY: testExampleBionic
testExampleBionic:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-bionic

.PHONY: testExampleJammy
testExampleJammy:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-jammy

.PHONY: testExampleNeon
testExampleNeon:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):kde-neon
