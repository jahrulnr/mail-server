build:
	docker build . -t mail-server --progress plain
 
up: build
	docker compose up -d
	
bash:
	docker exec -it vm-mail-server bash

save: build
	docker save mail-server | gzip > mail-server.tar.gz