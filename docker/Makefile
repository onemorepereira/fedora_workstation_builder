test:
		ansible-playbook test.yaml \
		--ask-vault-pass \
		-i inventory \
		--extra-vars @profile.yaml \
		-e variable_host=docker \
		-e ansible_ssh_private_key_file=temp_key \
		-e ansible_port=2222 \
		-e ansible_user=root \
		-e sys_user=test \
		--start-at-task "Add management public key to target systems"

build:
		ssh-keygen -f temp_key -t ecdsa -b 521 -q -N "" -C noname
		docker build -t ansible:fedora --build-arg FEDORA_VERSION=rawhide .

run:
		docker run -p 2222:22 ansible:fedora

clean:
		rm temp_key
		rm temp_key.pub
		
		$(eval CONTAINER=$(shell docker ps |grep "ansible:fedora" |awk '{print $$13}'))
		$(eval IMAGE=$(shell docker images |grep "fedora" |grep "ansible" |awk '{print $$3}'))
		docker rm  -f $(CONTAINER);
		docker rmi -f $(IMAGE);

connect:
	ssh -i temp_key root@localhost -p 2222