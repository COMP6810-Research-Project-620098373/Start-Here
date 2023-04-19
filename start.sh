#!/bin/bash
system_dependencies_required=("docker" "docker-compose" "git")

for dep in ${system_dependencies_required[@]}; do
    which $dep > /dev/null
    if [ "$?" != "0" ]; then
        printf "System dependency '$dep' is missing. Please install $dep and try again\n"
        exit
    fi
done

printf "\nDownloading Resources..."
git clone git@github.com:COMP6810-Research-Project-620098373/Marketplace-Backend.git &> /dev/null
git clone git@github.com:COMP6810-Research-Project-620098373/Marketplace.git &> /dev/null
git clone git@github.com:COMP6810-Research-Project-620098373/IPFS.git &> /dev/null
wait

cp ./Marketplace-Backend/.env.template ./Marketplace-Backend/.env

printf "\n\nDownload complete. Starting Marketplace Application...\n\n"
docker-compose up
