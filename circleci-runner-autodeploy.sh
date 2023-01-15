#!/bin/bash

set -eu pipefail

echo -e "\033[0;34mWelcome to the CircleCI Runner Installer\033[0m"
echo ""
echo -e "\033[0;31mMake sure you've read https://circleci.com/docs/runner-installation/#machine-runner-prerequisites\033[0m"
echo ""

os=""

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    os=$ID
    elif type lsb_release >/dev/null 2>&1; then
    os=$(lsb_release -si)
else
    echo -e "\033[0;31mCannot detect OS, supported OSes are Ubuntu/Debian and CentOS/RHEL.\033[0m"
    exit 1
fi

if [[ $os != "ubuntu" && $os != "debian" ]]; then
    echo -e "\033[0;31mOS not supported, supported OSes are Ubuntu/Debian.\033[0m"
    exit 1
fi

platform=""

if [[ $(uname -m) == "x86_64" ]]; then
    platform="linux/amd64"
    elif [[ $(uname -m) == "aarch64" ]]; then
    platform="linux/arm64"
else
    echo -e "\033[0;31mCould not detect platform, supported platforms are linux/amd64 and linux/arm64.\033[0m"
    exit 1
fi

token=""
read -p "Enter resource class token: " token

while [[ -z $token ]]; do
    echo ""
    echo -e "\033[0;31mResource class token cannot be empty!\033[0m"
    echo ""
    read -p "Enter resource class token: " token
done

echo ""

username=""
echo -e "\033[0;33mEnter a username for the runner to run jobs as, this will be used to create a new user on the machine (e.g. runner-01)\033[0m"
echo -e "\033[0;33mWill be automatically created if it doesn't exist\033[0m"
echo ""
echo -e "\033[0;31mMust be 32 characters or less and only contain a-z, 0-9, and - (dashes)\033[0m"
echo ""
read -p "Enter username: " username

while [[ ! $username =~ ^[a-z0-9-]{1,32}$ ]]; do
    echo ""
    echo -e "\033[0;31mInvalid username, must be 32 characters or less and only contain a-z, 0-9, and - (dashes)\033[0m"
    echo ""
    read -p "Enter username: " username
done

echo ""

runner_name=""
echo -e "\033[0;33mEnter a name for the runner, this will be used to identify the runner in the CircleCI UI (e.g. runner-01)\033[0m"
echo -e "\033[0;33mMust be unique, if you have multiple runners you must use a different name for each one\033[0m"
echo -e "\033[0;33mThis script won't check if the name you're using is already taken, so becareful!\033[0m"
echo ""
read -p "Enter runner name: " runner_name

while [[ -z $runner_name ]]; do
    echo ""
    echo -e "\033[0;31mRunner name cannot be empty!\033[0m"
    echo ""
    read -p "Enter runner name: " runner_name
done

echo ""

echo -e "\033[0;33mDetected OS: $os\033[0m"
echo -e "\033[0;33mDetected platform: $platform\033[0m"
echo ""
echo -e "\033[0;33mResource class token: $token\033[0m"
echo -e "\033[0;33mRunner username: $username\033[0m"
echo -e "\033[0;33mRunner name: $runner_name\033[0m"
echo ""

response=""

while [[ ! $response =~ ^[YyNn]$ ]]; do
    read -p "Continue? [y/n]: " -n 1 -r response
    echo ""
done

if [[ $response =~ ^[Nn]$ ]]; then
    echo ""
    echo -e "\033[0;31mExiting...\033[0m"
    exit 1
fi

echo ""

# exit 1;

echo -e "\033[0;34mInstalling CircleCI Runner for ${platform}\033[0m"
echo ""

base_url="https://circleci-binary-releases.s3.amazonaws.com/circleci-launch-agent"
if [ -z ${agent_version+x} ]; then
    agent_version=$(curl "${base_url}/release.txt")
fi

echo ""
echo -e "\033[0;34mSetting up CircleCI Runner directories\033[0m"
sudo mkdir -p /var/opt/$username /opt/$username

echo ""
echo -e "\033[0;33mUsing CircleCI Launch Agent version ${agent_version}\033[0m"
echo ""

echo -e "\033[0;34mDownloading and verifying CircleCI Launch Agent Binary\033[0m"

curl -sSL "${base_url}/${agent_version}/checksums.txt" -o checksums.txt
file="$(grep -F "${platform}" checksums.txt | cut -d ' ' -f 2 | sed 's/^.//')"
mkdir -p "${platform}"

echo -e "\033[0;34mDownloading CircleCI Launch Agent: ${file}\033[0m"
echo ""

curl --compressed -L "${base_url}/${agent_version}/${file}" -o "${file}"

echo ""
echo -e "\033[0;34mVerifying CircleCI Launch Agent download\033[0m"
echo ""

error=false
grep "${file}" checksums.txt | sha256sum --check && chmod +x "${file}" || error=true
if [ "$error" = true ]; then
    echo ""
    echo -e "\033[0;31mInvalid checksum for CircleCI Launch Agent, please try download again\033[0m"
    exit 1
fi
sudo cp "${file}" "/opt/$username/circleci-launch-agent"

echo ""
echo -e "\033[0;34mCreating user and working directory...\033[0m"
echo ""

id -u $username &>/dev/null || sudo adduser --disabled-password --gecos GECOS $username
sudo mkdir -p /var/opt/$username
sudo chmod 0750 /var/opt/$username
sudo chown -R $username /var/opt/$username /opt/$username/circleci-launch-agent

echo ""
echo -e "\033[0;34mCreating CircleCI runner configuration...\033[0m"
echo ""

sudo mkdir -p /etc/opt/$username
sudo touch /etc/opt/$username/launch-agent-config.yaml
sudo chown $username: /etc/opt/$username/launch-agent-config.yaml
sudo chmod 600 /etc/opt/$username/launch-agent-config.yaml

sudo tee /etc/opt/$username/launch-agent-config.yaml <<EOF
api:
  auth_token: $token

runner:
  name: $runner_name
  working_directory: /var/opt/$username/workdir
  cleanup_working_directory: true
EOF

echo ""
echo -e "\033[0;34mEnabling the systemd unit...\033[0m"
echo ""

sudo touch /usr/lib/systemd/system/$username.service
sudo chown root: /usr/lib/systemd/system/$username.service
sudo chmod 644 /usr/lib/systemd/system/$username.service

sudo tee /usr/lib/systemd/system/$username.service <<EOF
[Unit]
Description=CircleCI Runner - $username
After=network.target
[Service]
ExecStart=/opt/$username/circleci-launch-agent --config /etc/opt/$username/launch-agent-config.yaml
Restart=always
User=$username
NotifyAccess=exec
TimeoutStopSec=18300
[Install]
WantedBy = multi-user.target
EOF

sudo systemctl enable $username.service
sudo systemctl start $username.service

echo ""
echo -e "\033[0;32mCircleCI runner installed and started successfully!\033[0m"
echo ""
echo -e "\033[0;32mFor more information, visit https://github.com/iUnstable0/CircleCI-Runner-Autodeploy\033[0m"

# echo -e "\033[0;32mTo check the status of the runner\033[0m"
# echo ""
# echo -e "\033[0;32m- sudo systemctl status $username.service\033[0m"
# echo ""
# echo -e "\033[0;32mTo check the logs\033[0m"
# echo ""
# echo -e "\033[0;32m- sudo journalctl -u $username.service -f\033[0m"
# echo ""
# echo -e "\033[0;32mTo disable it from auto starting on boot\033[0m"
# echo ""
# echo -e "\033[0;32m- sudo systemctl disable $username.service\033[0m"
# echo ""
# echo -e "\033[0;32mTo stop the runner\033[0m"
# echo ""
# echo -e "\033[0;32m- sudo systemctl stop $username.service\033[0m"
# echo ""
# echo -e "\033[0;32mTo uninstall the runner\033[0m"
# echo ""
# echo -e "\033[0;32m- sudo systemctl stop $username.service\033[0m"
# echo -e "\033[0;32m- sudo systemctl disable $username.service\033[0m"
# echo -e "\033[0;32m- sudo rm -rf /var/opt/$username /opt/$username /etc/opt/$username /usr/lib/systemd/system/$username.service\033[0m"
# echo -e "\033[0;32m- sudo userdel -r $username\033[0m"
# echo ""