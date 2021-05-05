rubyVersion := 2.7.3
suite := dev

.PHONY: all build install test-ubuntu2004 test-amazonlinux2 test-centos8 test-opensuse152 clean

all: build install test-ubuntu2004 test-amazonlinux2 test-centos8 test-opensuse152

build:
	[ -d build/salt ] || mkdir -p build/salt
	cp -a states/* build/salt/
	cp -a pillar build/
	cp .kitchen.yml build/salt/

install:
	rbenv init || echo "go on.."
	rbenv local $(rubyVersion) || rbenv install $(rubyVersion) && rbenv local $(rubyVersion)
	bundle config set --local path 'bundle'
	bundle install

test-ubuntu2004: build
	export DOCKER_BUILDKIT=0
	cd build/salt && bundle exec kitchen converge $(suite)-ubuntu-2004
	cd build/salt && bundle exec kitchen verify $(suite)-ubuntu-2004

test-amazonlinux2: build
	export DOCKER_BUILDKIT=0
	cd build/salt && bundle exec kitchen converge $(suite)-amazonlinux-2
	cd build/salt && bundle exec kitchen verify $(suite)-amazonlinux-2

test-centos8: build
	export DOCKER_BUILDKIT=0
	cd build/salt && bundle exec kitchen converge $(suite)-centos-8
	cd build/salt && bundle exec kitchen verify $(suite)-centos-8

test-opensuse152: build
	export DOCKER_BUILDKIT=0
	cd build/salt && bundle exec kitchen converge $(suite)-opensuse-leap-152
	cd build/salt && bundle exec kitchen verify $(suite)-opensuse-leap-152

clean:
	bundle exec kitchen destroy
	[ ! -d build ] || rm -rf build
	[ ! -d bundle ] || rm -rf bundle
	[ ! -d .bundle ] || rm -rf .bundle
	[ ! -f Gemfile.lock ] || rm -f Gemfile.lock