# ManyDesigns - Ansible docker image
Provide a ready to use ansible (2.10+) image with additional dependencies for work with Hashicorp Vault 

## Usage
Ansible need to access hosts with SSH, so the easiest way is to propagate an ssh client configuration to the container.
An Configuration-as-Code approach would be to have the ssh configuration and playbook/roles in the same directory,
like this:
```
.ssh/
    config
    deploy_key
    deploy_key.pub
inventory
playbook.yml
```
Given a structure like this we can easly run ansible with this command:
```shell
docker run --rm --it --volume $PWD:/ansible manydesigns/ansible ansible-playbook -i inventory playbook.yml
```

- `docker run --rm` create and run the container. Remove the container after the command is finished
- `--volume $PWD:/ansible` mount the current directory inside '/ansible' in the container. This is the home directory for the user 'ansible' provided by the image
- `manydesigns/ansible` the image to use for creating the container. If no version is specified 'latest' is used

If you need to provide a password to "unlock" the keys (OF COURSE YOU NEED IT!) you PROBABLY use an ssh agent on the host.
You can check that:
```shell
# Connect to the agent ans print the keys in memory
ssh-add -l
# The variable is not empty
echo $SSH_AUTH_SOCK
```
If not you can start the agent in the current shell and add the key
```shell
eval $(ssh-agent)
ssh-add .ssh/deploy_key
```

To propagate the agent to the ansible container you "just" 
- mount the socket path using the $SSH_AUTH_SOCK variable `--volume $SSH_AUTH_SOCK:/tmp/ssh-agent` 
- and provide the variable to the new mounted path `--env SSH_AUTH_SOCK=/tmp/ssh-agent`

So this bring us to this more complete command line 
```
docker run -it --rm --volume $SSH_AUTH_SOCK:/tmp/ssh-agent --env SSH_AUTH_SOCK=/tmp/ssh-agent --volume ${PWD}:/ansible manydesigns/ansible
```



## TLTR; Use with alias

Put this snippet in your `~/.bashrc` or `~/.bash_aliases`, open a new terminal and enjoy! 
```shell
export DOCKER_ANSIBLE_VERSION=latest
docker_ansible() {
	docker run -it --rm --volume $SSH_AUTH_SOCK:/tmp/ssh-agent --env SSH_AUTH_SOCK=/tmp/ssh-agent --volume $PWD:/ansible manydesigns/ansible:$DOCKER_ANSIBLE_VERSION $@
}
alias ansible='docker_ansible ansible'
alias ansible-playbook='docker_ansible ansible-playbook'
alias ansible-vault='docker_ansible ansible-vault'
alias ansible-galaxy='docker_ansible ansible-galaxy'
```
(stolen from https://github.com/kibatic/docker-ansible)


## WARNINGS - SSH AGENT PROPAGATION

This is a good `.ssh/config` configuration
```
# Disable the host checking to avoid the confirm at the first connection
# also 'disable' the save of the KnownHosts file 
Host *
	StrictHostKeyChecking no
	UserKnownHostsFile /dev/null

Host server-test
	IdentitiesOnly yes
	Hostname tstserver.example.com
	User deploy
	IdentityFile ~/.ssh/deploy_key
```

Without `IdentitiesOnly yes` ALL the keys in the agent will be tested. Often the server will complain returning the error
`Too many authentication failures`. So it's strongly advised to always have `IdentitiesOnly yes`.

**The VERY hard lesson is that if you don't have the public key `.ssh/deploy_key.pub` some openssh-client implementation
are not able to match the identity with the one loaded in the agent.**
Strangely this problem not appeared in the first versions of the image based on Alpine Linux, but is present in
debian and ubuntu openssh-client implementations.
