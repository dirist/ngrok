.PHONY: all
all: fmt client server

server:
	go build -o ./bin/ngrokd ./src/ngrok/main/ngrokd

client: client-assets
	go build -o ./bin/ngrok ./src/ngrok/main/ngrok

client-assets:
	go-bindata -nomemcopy -pkg=assets \
		-o=./src/ngrok/client/assets/assets.go \
		assets/client/...

fmt:
	go fmt ./src/ngrok/...

contributors:
	echo "Contributors to ngrok, both large and small:\n" > CONTRIBUTORS
	git log --raw | grep "^Author: " | sort | uniq | cut -d ' ' -f2- | sed 's/^/- /' | cut -d '<' -f1 >> CONTRIBUTORS
