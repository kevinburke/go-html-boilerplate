.PHONY: assets static templates

SHELL = /bin/bash -o pipefail

BENCHSTAT := $(GOPATH)/bin/benchstat
BUMP_VERSION := $(GOPATH)/bin/bump_version
DIFFER := $(GOPATH)/bin/differ
GENERATE_TLS_CERT = $(GOPATH)/bin/generate-tls-cert
GO_BINDATA := $(GOPATH)/bin/go-bindata
JUSTRUN := $(GOPATH)/bin/justrun
RELEASE := $(GOPATH)/bin/github-release

# Add files that change frequently to this list.
WATCH_TARGETS = $(shell find ./static ./templates -type f)
GO_FILES = $(shell find . -name '*.go')
GO_NOASSET_FILES := $(filter-out ./assets/bindata.go,$(GO_FILES))

test: vet
	go test -trimpath ./...

vet:
	staticcheck ./...
	go vet ./...

race-test: vet
	go test -race -trimpath ./...

diff: $(DIFFER)
	$(DIFFER) $(MAKE) assets

$(BENCHSTAT):
	go get golang.org/x/perf/cmd/benchstat

bench: | $(BENCHSTAT)
	tmp=$$(mktemp); go list ./... | grep -v vendor | xargs go test -benchtime=2s -bench=. -run='^$$' > "$$tmp" 2>&1 && $(BENCHSTAT) "$$tmp"

$(GOPATH)/bin/go-html-boilerplate: $(GO_FILES)
	go install .

serve: $(GOPATH)/bin/go-html-boilerplate
	$(GOPATH)/bin/go-html-boilerplate

$(GENERATE_TLS_CERT):
	go install github.com/kevinburke/generate-tls-cert@latest

certs/leaf.pem: | $(GENERATE_TLS_CERT)
	mkdir -p certs
	cd certs && $(GENERATE_TLS_CERT) --host=localhost,127.0.0.1

# Generate TLS certificates for local development.
generate_cert: certs/leaf.pem | $(GENERATE_TLS_CERT)

$(GO_BINDATA):
	go get -u github.com/kevinburke/go-bindata/...

assets/bindata.go: $(WATCH_TARGETS) | $(GO_BINDATA)
	$(GO_BINDATA) -o=assets/bindata.go --nocompress --nometadata --pkg=assets templates/... static/...

assets: assets/bindata.go

$(JUSTRUN):
	go get -u github.com/jmhodges/justrun

watch: | $(JUSTRUN)
	$(JUSTRUN) -v --delay=100ms -c 'make assets serve' $(WATCH_TARGETS) $(GO_NOASSET_FILES)

$(BUMP_VERSION):
	go get github.com/kevinburke/bump_version

$(DIFFER):
	go get github.com/kevinburke/differ

$(RELEASE):
	go get -u github.com/aktau/github-release

# Run "GITHUB_TOKEN=my-token make release version=major|minor|patch" to release a new version.
release: diff race-test | $(BUMP_VERSION) $(RELEASE)
ifndef version
	@echo "Please provide a version"
	exit 1
endif
	$(BUMP_VERSION) --tag-prefix=v $(version) main.go
	git push origin --tags
