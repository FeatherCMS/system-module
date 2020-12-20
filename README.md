# System module

This module provides basic system management for Feather CMS.


## System Module API

```sh
# list system variables
curl -X GET \
-H "Cookie: vapor-session=[session]" \
"http://localhost:8080/api/system/variables/"


# get system variable by id
curl -X GET \
-H "Cookie: vapor-session=[session]" \
"http://localhost:8080/api/system/variables/[id]/"


# create new system variable
curl -X POST \
-H "Cookie: vapor-session=[session]" \
-H "Content-Type: application/json" \
-d '{"key":"xyz", "name":"xyz name"}' \
"http://localhost:8080/api/system/variables/"


# create update system variable
curl -X PUT \
-H "Cookie: vapor-session=[session]" \
-H "Content-Type: application/json" \
-d '{"key":"xyz", "name":"xyz name"}' \
"http://localhost:8080/api/system/variables/[id]/"


# patch system variable
curl -X PATCH \
-H "Cookie: vapor-session=[session]" \
-H "Content-Type: application/json" \
-d '{"key":"xyz"}' \
"http://localhost:8080/api/system/variables/[id]/"


# delete system variable
curl -X DELETE \
-H "Cookie: vapor-session=[session]" \
"http://localhost:8080/api/system/variables/[id]/"
```
