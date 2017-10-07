# Open Banking Back-end

## App Configurations

Clone this app to your machine and let's set up to run it on your bluemix account.

### Configure locally before submit it to Bluemix.

You need to create a **Node.js Cloudant DB Web Starter** on Bluemix.

#### 1. **CLOUDANT** 

Get the Cloudant credentials from the app created before and edit the **vcap.json** file as follow

```json
    {
        "services": {
            "cloudantNoSQLDB":[
                {
                    "label": "cloudantNoSQLDB",
                    "name": "cloudantNoSQLDB",
                    "credentials":{
                        "username": "<CLOUDANT_USERNAME",
                        "password": "<CLOUDANT_PASSWORD",
                        "host": "<CLOUDANT_HOST>",
                        "port": <CLOUDANT_PORT>,
                        "URL": "<CLOUDANT_URL>"
                    }
                }
            ]
        }
    }
```
### 2. **CONVERSATION**

Create a **Conversation** service from Bluemix catalog and copy the service credentials, later access the Conversation platform and create a new **Workspace** and copy its **Workspace ID**.
Now open the **vcap.json** file and edit it as follow

```json
    {
        "services": {
            "conversation": [
                {
                    "label": "conversation",
                    "name": "conversation",
                    "credentials": {
                        "url": "<CONVERSATION_URL>",
                        "username": "<CONVERSATION_USERNAME>",
                        "password": "<CONVERSATION_PASSWORD>",
                        "conversationWorkspace": "<WORKSPACE_ID>"
                    }
                }
            ]
        }
    }
```

That's it.

Make sure your **vcap.json** looks like this

```json
    {
        "services": {
            "cloudantNoSQLDB":[
                {
                    "label": "cloudantNoSQLDB",
                    "name": "cloudantNoSQLDB",
                    "credentials":{
                        "username": "<CLOUDANT_USERNAME",
                        "password": "<CLOUDANT_PASSWORD",
                        "host": "<CLOUDANT_HOST>",
                        "port": <CLOUDANT_PORT>,
                        "URL": "<CLOUDANT_URL>"
                    }
                }
            ],
            "conversation": [
                {
                    "label": "conversation",
                    "name": "conversation",
                    "credentials": {
                        "url": "<CONVERSATION_URL>",
                        "username": "<CONVERSATION_USERNAME>",
                        "password": "<CONVERSATION_PASSWORD>",
                        "conversationWorkspace": "<WORKSPACE_ID>"
                    }
                }
            ]
        }
    }
```

> FILLED WITH YOUR APP CREDENTIALS


## Upload to Bluemix

Open the **manifest.yml** file and edit the name and host as follow

```yml
    applications:
        - path: .
        memory: 128M
        instances: 1
        domain: mybluemix.net
        name: <YOUR_APP_NAME>
        host: <YOUR_APP_HOST>
        disk_quota: 256M

```

> Feel free to change the other attributes as your needs

Now we have to push the app to bluemix.

Open the terminal/cmd and move to the app directory.

login to Cloud Foundry

``` 
    cf login [-sso]
```
> [OPTIONAL] : if you are an IBMer, login in using sso.

After choosing your org and space, write this command to push the app to bluemix.

```
    cf push
```

That's it! The back-end now is running on Bluemix and ready to be used! 

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




