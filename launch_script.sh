#!/bin/bash

# Update repos and install curl and predependencies for Docker installation
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

# Adding Docker's GPG key

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Setting the repo

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the newly added repo
sudo apt-get update

### Installation ###

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Testing the install 

sudo docker run hello-world

#
sudo apt-get install unzip

#

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#

echo AKIAZMF5YECNQABEPP5Y | echo GR2zOZfsoGbH9qmWVW7zbYhZM4Rk5WZ8Kjt/O0Rl | echo us-east-2 | echo | aws configure

# Running new code

sudo docker pull 644643037339.dkr.ecr.us-east-2.amazonaws.com/ac-tt-version:latest

sudo docker run -d -p 80:80 5432:5432 644643037339.dkr.ecr.us-east-2.amazonaws.com/ac-tt-version:latest