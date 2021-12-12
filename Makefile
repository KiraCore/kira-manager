.PHONY: build
build:
		/usr/local/go/bin/go build -v ./cmd/restserver

.PHONY: init
init:	
		pip3 install -r requirements.txt		
		python3 init/pyunit.py

.PHONY: test
test:
		/usr/local/go/bin/go test -v -race -timeout 30s ./...
	
.DEFAULT_GOAL := build