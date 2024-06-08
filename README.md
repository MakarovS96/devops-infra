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

    ``` javascript
    {
      "yandex_data": {
          "cloud" :"your-folder-id",
          "folder" :"your-cloud-id",
          "zone" :"zone-name",
          "token" :"../.keys/token"
        },

      "ssh_user": {
          "name": "your-username",
          "private_key": "../.keys/sshkey",
          "pub_key": "../.keys/sshkey.pub"
      },

      "instances_count": 2,

      "github_data": {
          "token": "../.keys/github-token",
          "repo": "repo-name",
          "account": "account-name"
      }
    }
    ```

3. Install ansible role `ansible-galaxy role install MonolithProjects.github_actions_runner`
4. Run `terraform -chdir=terraform/ apply -var-file 'inputvariables.tfvars.json'`

