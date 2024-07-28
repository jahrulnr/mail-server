build:
	docker build . -t mail-server --progress plain
 
up: build
	docker compose up -d
	
bash:
	docker exec -it vm-mail-server bash

save: up
	docker save mail-server | gzip > mail-server.tar.gz