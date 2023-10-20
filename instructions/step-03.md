#Create a Kubernetes cluster

Next, lets create a Kubernetes cluster using the RKE1 distribution.

##Run the following commands on the victim VM.

To start out, we will generate a new SSH Keypair and place this keypair on the node we will install Kubernetes onto. As we will be using the victim node to run Kubernetes, we will simply copy the public key into the authorized_keys file of this node.

The following command will generate the keypair and copy it into the file.

```
ssh-keygen -b 2048 -t rsa -f \
/home/ubuntu/.ssh/id_rsa -N ""
cat /home/ubuntu/.ssh/id_rsa.pub \
>> /home/ubuntu/.ssh/authorized_keys
```

RKE1 uses a command line tool to provision a cluster on remote hosts. Let's install this tool:

```
wget https://github.com/rancher/rke/releases/download/v1.4.7/rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
chmod +x /usr/local/bin/rke
```

We now need to configure where and with which configuration our cluster should be created:

```
cat <<EOF > ~/cluster.yml
nodes:
  - address: ${PUBLIC_IP}
    user: ubuntu
    role:
      - controlplane
      - etcd
      - worker
kubernetes_version: v1.23.16-rancher2-3   
EOF
```

Check the cluster.yml file, that the IP address is set.
```cat cluster.yml```


To deploy the Kubernetes cluster, run

```
rke up --config ~/cluster.yml
```
