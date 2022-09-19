# Budget

## Description

This repository contains two directories - `budget` and `ansible`. `budget` is a Terraform stack describing the infrastructure underpinning the budget application, and `ansible` contains the inventories and playbooks which act on the main EC2 instance created by Terraform. The playbook and inventory are generated dynamically.

## Usage

`./tasks <<init/plan/apply>> budget <<stack_name>>`

e.g. `./tasks plan budget budget`, if the stack name is `budget`.


Running `apply` will also generate the inventory and playbook.

You can then run the Ansible playbook from the root of the project with:

`ansible-playbook -i ansible/inventory.yaml ansible/playbook.yam`