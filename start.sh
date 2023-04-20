#!/bin/bash
system_dependencies_required=("docker" "docker-compose" "git")

for dep in ${system_dependencies_required[@]}; do
    which $dep > /dev/null
    if [ "$?" != "0" ]; then
        printf "System dependency '$dep' is missing. Please install $dep and try again\n"
        exit 1
    fi
done

printf "\nDownloading Resources..."
git clone git@github.com:COMP6810-Research-Project-620098373/Marketplace-Backend.git &> /dev/null
git clone git@github.com:COMP6810-Research-Project-620098373/Marketplace.git &> /dev/null
git clone git@github.com:COMP6810-Research-Project-620098373/IPFS.git &> /dev/null
wait

which openssl > /dev/null
if [ "$?" == "0" ]; then
    [ ! -d "./sslcert" ] && (
        mkdir sslcert
    )

    [ ! -f "./sslcert/key.pem" ] || [ ! -f "./sslcert/cert.pem" ] && (
        printf "\n\n"
        printf "===============================\n"
        printf "======     SSL SETUP    =======\n"
        printf "===============================\n\n"
        openssl req -x509 -sha256 -nodes -days 365000 -newkey rsa:4096 -keyout ./sslcert/key.pem -out ./sslcert/cert.pem  
    )
fi

cp -R ./sslcert ./dist
cp ./Marketplace-Backend/.env.template ./Marketplace-Backend/.env

printf "\n\nSetup complete. Starting Marketplace Application...\n\n"
docker-compose up
