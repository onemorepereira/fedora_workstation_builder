FEDORA_VERSION ?= 44
IMAGE          := fwb-test:fedora-$(FEDORA_VERSION)

lint:
	yamllint .
	ansible-lint

build:
	test -f docker/temp_key || ssh-keygen -f docker/temp_key -t ed25519 -q -N "" -C fwb-test
	podman build -t $(IMAGE) --build-arg FEDORA_VERSION=$(FEDORA_VERSION) docker/

run:
	podman run -d --rm --name fwb-test -p 2222:22 $(IMAGE)

test:
	ansible-playbook play.yaml \
		-i docker/inventory \
		--extra-vars @examples/profile.yaml \
		-e variable_host=podman \
		-e ansible_port=2222 \
		-e ansible_user=root \
		-e ansible_ssh_private_key_file=docker/temp_key \
		-e 'ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"' \
		-e sys_user=test

connect:
	ssh -i docker/temp_key -o StrictHostKeyChecking=no root@localhost -p 2222

clean:
	rm -f docker/temp_key docker/temp_key.pub
	-podman rm -f fwb-test
	-podman rmi -f $(IMAGE)

.PHONY: lint build run test connect clean
