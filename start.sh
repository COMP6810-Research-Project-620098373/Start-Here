#!/bin/bash
readonly system_dependencies_required=("docker" "docker-compose" "git")
readonly marketplace_container_ipfs_hash="QmbYrFWgDMpudzP3W9C6GPgQzyYWq6m7ZFDHPnYQFn9arX"
readonly ipfs_container_ipfs_hash="QmSQMWXyXXeQixnQ9nE83Z5AVZvJpoNWVdQfKBv1Qp5QDG"
# readonly ethereum_container_ipfs_hash=""
# readonly ethereum_transaction_indexer_container_ipfs_hash=""

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
else
    printf "\nopenssl command not found. application may not have https support\n"
fi

cp -R ./sslcert ./dist
cp ./Marketplace-Backend/.env.template ./Marketplace-Backend/.env

while true
do
    if [ "$(docker inspect marketplace_ipfs --format '{{.State.Status}}')" = "running" ]; then
        if [ $(docker exec marketplace_ipfs /bin/sh -c 'ipfs files ls / | grep "start-here_marketplace.tar" | wc -c') -gt 0 ]; then
            # MARKETPLACE CONTAINER ALREADY ADDED TO LOCAL IPFS INSTANCE, SEEDING TO OTHER NODES\
            printf "\nMarketplace container successfully saved\n"
            break
        fi

        printf "\nAttempting to download marketplace container...\n"

        # ATTEMPT TO DOWNLOAD MARKETPLACE CONTAINER FROM IPFS IN BACKGROUND (60 MINUTES PROVIDED)
        timeout 3600 docker exec marketplace_ipfs /bin/sh -c "ipfs get $marketplace_container_ipfs_hash -o ./home" > /dev/null

        if [ $? -ne 0 ]; then
            # FAILED TO RETRIEVE THE MARKETPLACE CONTAINER FROM THE IPFS IN TIME
            # ATTEMPT TO CREATE MARKETPLACE CONTAINER BACKUP FROM SOURCE
            if [ "$(docker inspect marketplace --format '{{.State.Status}}')" -ne "running" ]; then
                # ERROR STARTING THE MARKETPLACE CONTAINER. CONTAINER UNAVAILABLE FOR BUILDING
                break
            fi

            docker commit marketplace start-here_marketplace_bkup:latest
            docker save start-here_marketplace_bkup > start-here_marketplace.tar
            docker cp ./start-here_marketplace.tar marketplace_ipfs:/home

            # TODO: ADD IPFS IMAGE AS WELL TO IPFS AND RETRIEVE FROM IPFS
        fi

        docker exec marketplace_ipfs /bin/sh -c 'ipfs add ./home/start-here_marketplace.tar --to-files /' > /dev/null
        break
    fi
    sleep 10
done &

printf "\n\nSetup complete. Starting Marketplace Application...\n\n"
docker-compose up

if [ "$(docker inspect marketplace_ipfs --format '{{.State.Status}}')" = "running" ] && [ "$(docker inspect marketplace --format '{{.State.Status}}')" -ne "running" ]; then
    if [ $(docker exec marketplace_ipfs /bin/sh -c 'ipfs files ls / | grep "start-here_marketplace.tar" | wc -c') -gt 0 ]; then

        printf "\nThe Marketplace container is failing to start"
        printf "\nIt appears that the Docker image that you attempted to generate already exists on the IPFS.\n\nWould you like to pull the image from the IPFS instead? [y/N] "

        read choice

        if [ $choice -ne "y" ] && [ $choice -ne "Y" ]; then
            exit 0
        fi

        printf "\nrestoring container image..\n"
        docker exec marketplace_ipfs /bin/sh -c "ipfs get $marketplace_container_ipfs_hash -o /home/start-here_marketplace.tar" > /dev/null
        docker cp marketplace_ipfs:/home/start-here_marketplace.tar ./start-here_marketplace.tar
        docker load < start-here_marketplace.tar
        docker tag start-here_marketplace_bkup start-here_marketplace
        docker-compose up
    fi
fi