Run download.sh to fetch the 3rd party geo IP files.

Start the server with start.sh.

Examples:

```sh
http://localhost:4567/en/v4/24.24.24.24
```

```json
{"country_iso_code":"US","country_name":"United States","subdivision_1_iso_code":"NY","subdivision_1_name":"New York"}
```

```sh
http://localhost:4567/en/v6/2607:fea8:2adf:fbb9:f1a6:3ed5:ff6c:24d7
```

```json
{"country_iso_code":"CA","country_name":"Canada","subdivision_1_iso_code":"ON","subdivision_1_name":"Ontario"}
```
