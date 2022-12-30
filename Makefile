.PHONY: ansible
ansible:
	ansible-playbook -i ansible/inventory.yaml ansible/playbook.yaml