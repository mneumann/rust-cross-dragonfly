HOST=192.168.0.102

scp target/app ${HOST}:/home/mneumann
ssh ${HOST} ./app 
