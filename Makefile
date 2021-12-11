.PHONY: build
build:
		/usr/local/go/bin/go build -v ./cmd/restserver

.PHONY: init
init:			
		python3 init/pyunit.py $(logname)

.PHONY: test
test:
		/usr/local/go/bin/go test -v -race -timeout 30s ./...
	
.DEFAULT_GOAL := build