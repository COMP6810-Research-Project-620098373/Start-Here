#!/bin/bash
# Required System Dependencies: docker, docker-compose, git

printf "\nDownloading Resources..."
git clone git@github.com:COMP6810-Research-Project-620098373/Marketplace-Backend.git &> /dev/null
git clone git@github.com:COMP6810-Research-Project-620098373/Marketplace.git &> /dev/null
git clone git@github.com:COMP6810-Research-Project-620098373/IPFS.git &> /dev/null
wait

printf "\n\nDownload complete. Starting Marketplace Application...\n\n"
docker-compose up
