# DEVOPS INFRA
Infrastructure deployment configuration for progect

## Required tools
- terraform
- ansible

## Run
1. Copy files to your .keys folder:
   - sshkey - your private ssh key to auth on servers
   - sshkey.pub - public ssh key
   - token - your yandex cloud token
   - github-token - your github private token with permissions:
     - Actions: rw
     - Administrate: rw

2. Copy **terraform/inputvariables.tfvars.json.default** into **terraform/inputvariables.tfvars.json**
    And set your configuration

3. Install ansible role `ansible-galaxy role install MonolithProjects.github_actions_runner`
4. Run `terraform -chdir=terraform/ apply -var-file 'inputvariables.tfvars.json'`

