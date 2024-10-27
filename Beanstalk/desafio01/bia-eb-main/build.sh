versao=$(git rev-parse HEAD | cut -c 1-7)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 593793059846.dkr.ecr.us-east-1.amazonaws.com
docker build -t bia-image .
docker tag bia-image:latest 593793059846.dkr.ecr.us-east-1.amazonaws.com/bia-image:$versao
docker push 593793059846.dkr.ecr.us-east-1.amazonaws.com/bia-image:$versao
rm .env 2> /dev/null
./gerar-compose.sh
rm bia-versao-*zip
zip -r bia-versao-$versao.zip docker-compose.yml
#git checkout docker-compose.yml
