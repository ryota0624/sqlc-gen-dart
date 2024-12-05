## Features

* generate dart code from sql
* support only postgresql (for now)

## Getting started

write sqlc.yaml & schema.sql & queries.sql

```
version: "2"
plugins:
  - name: sql-gen-dart
    wasm:
      url: https://github.com/ryota0624/buf-sandbox/releases/download/v0.0.0/sqlc-gen-dart.wasm
      sha256: "ef0820d29c596338b1d5ed96286399993c8cfc27e317f94e63cf57ff29b3fbf9  sqlc-gen-dart.wasm"
sql:
  - engine: "postgresql"
    queries: "queries.sql"
    schema: "schema.sql"
    codegen:
      - out: generated
        plugin: sql-gen-dart
        options:
          filename: "query.dart"
          domain_inner_type_mapping:
            - type_name: "your_string_based_domain"
              inner_type: "String"
```

run sqlc

```
sqlc generate
```

## Run Example

require
* [devbox](https://www.jetify.com/devbox)
* docker


```bash
docker compose -f ./example/compose.yaml up -d
devbox shell
cd example
make generate 
make run_example
```

## Usage

see [example](./example/main.dart)
