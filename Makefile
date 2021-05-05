rubyVersion := 2.6.7
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

test-ubuntu2004: build install | build/salt/
	bundle exec kitchen converge $(suite)-ubuntu-2004
	bundle exec kitchen verify $(suite)-ubuntu-2004

test-amazonlinux2: build install | build/salt/
	bundle exec kitchen converge $(suite)-amazonlinux-2
	bundle exec kitchen verify $(suite)-amazonlinux-2

test-centos8: build install | build/salt/
	bundle exec kitchen converge $(suite)-centos-8
	bundle exec kitchen verify $(suite)-centos-8

test-opensuse152: build install | build/salt/
	bundle exec kitchen converge $(suite)-opensuse-leap-152
	bundle exec kitchen verify $(suite)-opensuse-leap-152

clean:
	bundle exec kitchen destroy
	[ ! -d build ] || rm -rf build
	[ ! -d bundle ] || rm -rf bundle