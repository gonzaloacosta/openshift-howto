#!/bin/bash
# Instalacion de clientes para deploy de OCP IPI

export OCP_VERSION=4.5.13
export AWSKEY=AKIAVIV7HIY4RDDUEAHG
export AWSSECRETKEY=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
export REGION=us-east-2

echo "Install Tools"
sudo yum -y install nc tmux jq nmap 

echo "AWS Cli Install..."
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /bin/aws
aws --version
#sudo rm -rf ./awscli-bundle ./awscli-bundle.zip

echo "Openshfit Client Install..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-client-linux-${OCP_VERSION}.tar.gz
sudo tar zxvf openshift-client-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-client-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
sudo chmod +x /usr/bin/oc
ls -l /usr/bin/{oc,openshift-install}

echo "Openshfit Installer Install..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-linux-${OCP_VERSION}.tar.gz
sudo tar zxvf openshift-install-linux-${OCP_VERSION}.tar.gz -C /usr/bin
sudo rm -f openshift-install-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
sudo chmod +x /usr/bin/openshift-install

echo "Openshift Bash Completion Install..."
sudo oc completion bash >/etc/bash_completion.d/openshift

echo "Configure AWD Cliente..."
mkdir $HOME/.aws
cat << EOF >>  $HOME/.aws/credentials
[default]
aws_access_key_id = ${AWSKEY}
aws_secret_access_key = ${AWSSECRETKEY}
region = $REGION
EOF
aws sts get-caller-identity
oc version
openshift-install version

# seguir con ./install-ocp-ipi.sh