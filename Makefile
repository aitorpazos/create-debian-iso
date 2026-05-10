IMAGE_TAG:=aitorpazos/create-debian-iso

.PHONY: build
build: buildDebianBookworm buildUbuntuNoble buildKdeNeon

.PHONY: buildDebianBookworm
buildDebianBookworm:
	docker build --rm --build-arg DISTRO=debian --build-arg DISTRO_VERSION=bookworm -t $(IMAGE_TAG) -t $(IMAGE_TAG):debian-bookworm .

.PHONY: buildUbuntuNoble
buildUbuntuNoble:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=noble -t $(IMAGE_TAG) -t $(IMAGE_TAG):ubuntu-noble .

.PHONY: buildKdeNeon
buildKdeNeon:
	docker build --rm --build-arg DISTRO=ubuntu --build-arg DISTRO_VERSION=noble --build-arg DISTRO_FLAVOR=neon -t $(IMAGE_TAG) -t $(IMAGE_TAG):kde-neon .

.PHONY: test
test: testExampleBookworm testExampleNoble testExampleNeon

.PHONY: testExampleBookworm
testExampleBookworm:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):debian-bookworm

.PHONY: testExampleNoble
testExampleNoble:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):ubuntu-noble

.PHONY: testExampleNeon
testExampleNeon:
	docker run -t --rm --privileged -v $(shell pwd)/example:/root/files $(IMAGE_TAG):kde-neon

.PHONY: lint
lint:
	shellcheck create-iso.sh chroot-script.sh example/config/configure.sh
