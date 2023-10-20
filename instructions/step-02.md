# Prepare the victim VM

##Run the following commands on the victim VM

The victim VM is running an older Ubuntu 18.04 with an outdated kernel that has some vulnerabilities.

We want to ensure that this VM stays vulnerable and disable unattended upgrades.

```
sudo apt remove unattended-upgrades
```

Next, we will install some standard packages

```
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl socat jq
```

and an older Docker version:

```curl -fsSl "https://download.docker.com/linux/ubuntu/gpg" | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt install -y docker-ce=18.06.3~ce~3-0~ubuntu
```

add the ubuntu user to the docker group and create the group docker

```
sudo usermod -aG docker ubuntu
newgrp docker
```

We also want to disable and uninstall apparmor

```
sudo systemctl disable apparmor
sudo systemctl stop apparmor
sudo apt purge -y apparmor
```