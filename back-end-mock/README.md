# Open Banking Back-end


## Login API

To signin, you need to call this API sending the user email and password as follow

```
    METHOD: POST https://openbanking.mybluemix.net/login
```

the request body 
```
    {
        "email" : "<USER_EMAIL>",
        "password": "USER_PASSWORD"
    }
```

the response possibilities

| status code | response body |
| --- | --- |
| 200 |  {  "email" : "<EMAIL>" , "name" : "<NAME>" ,  "password" :"<PASSWORD"> , "accounts": [ {"accountName": "<ACCOUNT_NAME>", "accountBalance": xxxx}] } |
| 400 |  { "error" : true , "error_reason" : "BAD_REQUEST" } | 
| 403 |  { "error" : true, "error_reason": "WRONG_PASSWORD"} | 
| 404 |  { "error" : true , "error_reason": "EMAIL_NOT_FOUND"} | 
| 500 |  { "error" : true , "error_reason": "INTERNAL_SERVER_ERROR"}




