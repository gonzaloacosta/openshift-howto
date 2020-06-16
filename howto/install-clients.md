# Instalacion de clientes para un ambiente Openshift

# Como root
```
sudo -i
```

### AWD Client 
```
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /bin/aws
aws --version
rm -rf /root/awscli-bundle /root/awscli-bundle.zip
```

### Openshift Install CLI (openshift-install)
```
OCP_VERSION=4.4.3
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-install-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-install-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/openshift-install
```

### Openshift Clinent OC
```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-client-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-client-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-client-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/oc
ls -l /usr/bin/{oc,openshift-install}
```

### OCP Bash Completion
```
oc completion bash >/etc/bash_completion.d/openshift
```

### Configure AWS Client
```
export AWSKEY=AKIA34VFN53M2WXSLVL6
export AWSSECRETKEY=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
export REGION=us-east-2
 
mkdir $HOME/.aws
cat << EOF >>  $HOME/.aws/credentials
[default]
aws_access_key_id = ${AWSKEY}
aws_secret_access_key = ${AWSSECRETKEY}
region = $REGION
EOF
aws sts get-caller-identity
```


