build_plugin:
	cd plugin && go build -o sqlc-gen-dart main.go

build_plugin_wasm:
	cd plugin && GOOS=wasip1 GOARCH=wasm go build -o sqlc-gen-dart.wasm main.go
