set -e

echo "installing requirements and setting up docker..."
amazon-linux-extras install docker -y
systemctl start docker
docker pull quay.io/oauth2-proxy/oauth2-proxy
mkdir -p docker /etc/letsencrypt/

if [[ "$(docker network ls | grep "${networkName}")" == "" ]] ; then
    echo "creating docker network ${networkName}..."   
    docker network create "${networkName}"
else
    echo "network ${networkName} already exists. continuing..."
fi

echo ${allowedEmail} > docker/authenticated_emails.txt

echo "docker setup complete. retrieving TLS certs..."

chmod -R 755 /etc/letsencrypt/


aws s3api get-object --bucket ${bucketName} \
--key /certs/${domainName}/privkey.pem \
/etc/letsencrypt/live/${domainName}/privkey.pem

aws s3api get-object --bucket ${bucketName} \
--key /certs/${domainName}/fullchain.pem \
/etc/letsencrypt/live/${domainName}/fullchain.pem

echo "... certificates retrieved"


# sample app no port
sudo docker run -d --rm --name demo-webserver --network budget-net nginxdemos/hello

