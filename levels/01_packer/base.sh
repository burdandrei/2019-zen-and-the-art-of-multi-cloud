set -x
set -e
export TERM=xterm-256color
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    jq \
    unzip


# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Checking latest Consul and Nomad versions..."
CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
#CONSUL_VERSION=$(curl -s "${CHECKPOINT_URL}"/consul | jq -r .current_version)
NOMAD_VERSION=$(curl -s "${CHECKPOINT_URL}"/nomad | jq -r .current_version)
CONSUL_VERSION="1.20.4"
VAULT_VERSION="1.18.5"

cd /tmp/

echo "Fetching Consul version ${CONSUL_VERSION} ..."
curl -s https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
echo "Installing Consul version ${CONSUL_VERSION} ..."
unzip -n consul.zip
chmod +x consul
mv consul /usr/local/bin/consul

echo "Fetching Nomad version ${NOMAD_VERSION} ..."
curl -s https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
echo "Installing Nomad version ${NOMAD_VERSION} ..."
unzip -n nomad.zip
chmod +x nomad
mv nomad /usr/local/bin/nomad

echo "Fetching Vault version ${VAULT_VERSION} ..."
curl -s https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
echo "Installing Nomad version ${VAULT_VERSION} ..."
unzip -n vault.zip
chmod +x vault
mv vault /usr/local/bin/vault

mkdir -p /var/lib/consul /var/lib/vault /var/lib/nomad /etc/consul.d /etc/vault.d /etc/nomad.d
