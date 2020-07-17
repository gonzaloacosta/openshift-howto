echo "AWS Cli Install..."
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /bin/aws
aws --version
rm -rf /root/awscli-bundle /root/awscli-bundle.zip

OCP_VERSION=4.4.9
echo "Openshfit Client Install..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-client-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-client-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-client-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/oc
ls -l /usr/bin/{oc,openshift-install}

echo "Openshfit Installer Install..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-install-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-install-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/openshift-install

echo "Openshift Bash Completion Install..."
oc completion bash >/etc/bash_completion.d/openshift

echo "Configure AWD Cliente..."
export AWSKEY=AKIASIWOZXF5DPH3EGMK
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

