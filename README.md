# System module

This module provides basic system management for Feather CMS.

## Installation

You can use the Swift Package Manager to integrate this module.

```swift
// add to your dependencies 
.package(url: "https://github.com/FeatherCMS/system-module", from: "1.0.0-beta"),

// add to your target
.product(name: "SystemModule", package: "system-module"),
```

## System module hooks

### model-install

You can add your own modules through the model install hook during the system installation process. 

```swift
app.hooks.register("model-install", use: modelInstallHook)

func modelInstallHook(args: HookArguments) -> EventLoopFuture<Void> {
    let req = args["req"] as! Request
    
    /// create your models here...

    return req.eventLoop.future()
}
```

### system-variables-install

You can add your own system variables by implementing this hook. 

```swift
app.hooks.register("model-install", use: modelInstallHook)

func systemVariablesInstallHook(args: HookArguments) -> [[String: Any]] {
    [
        [
            "key": "[custom.key.for.the.variable]",
            "name": "[custom name]",
            "value": "[custom value]",
            "note": "[custom notes about the variable]",
        ],
    ]
}
```

## System Module API

### Authentication

```sh
# login
curl -X POST \
-H "Content-Type: application/json" \
-d '{"email": "root@feathercms.com", "password": "FeatherCMS"}' \
"http://localhost:8080/api/user/login/"
```
The response is a `UserTokenObject`, you can use the token value from the response as a `Bearer` token or a `vapor-session` cookie to perform authenticated API calls.

cURL header value examples: 
- using the session cookie: `-H "Cookie: vapor-session=[session]"`
- using the API token value: `-H "Authorization: Bearer [token]"`


### System variable API

```sh
# list
curl -X GET \
-H "Authorization: Bearer [token]" \
"http://localhost:8080/api/system/variables/"


# get
curl -X GET \
-H "Authorization: Bearer [token]" \
"http://localhost:8080/api/system/variables/[id]/"


# create
curl -X POST \
-H "Authorization: Bearer [token]" \
-H "Content-Type: application/json" \
-d '{"key":"xyz", "name":"xyz name"}' \
"http://localhost:8080/api/system/variables/"


# update
curl -X PUT \
-H "Authorization: Bearer [token]" \
-H "Content-Type: application/json" \
-d '{"key":"xyz", "name":"xyz name"}' \
"http://localhost:8080/api/system/variables/[id]/"


# patch
curl -X PATCH \
-H "Authorization: Bearer [token]" \
-H "Content-Type: application/json" \
-d '{"key":"xyz"}' \
"http://localhost:8080/api/system/variables/[id]/"


# delete
curl -X DELETE \
-H "Authorization: Bearer [token]" \
"http://localhost:8080/api/system/variables/[id]/"
```
