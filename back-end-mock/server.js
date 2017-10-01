var express = require('express');
var bodyParser = require('body-parser');
var app = express();
var fs = require('fs');

app.use(bodyParser.json());

var port = process.env.PORT || 3000;
app.set('port', port);



var db;

var cloudant;

var dbCredentials = {
    dbName: 'open_banking_db'
};

function getDBCredentialsUrl(jsonData) {
    var vcapServices = JSON.parse(jsonData);
    for (var vcapService in vcapServices) {
        if (vcapService.match(/cloudant/i)) {
            return vcapServices[vcapService][0].credentials.url;
        }
    }
}


function initDBConnection() {
    if (process.env.VCAP_SERVICES) {
        dbCredentials.url = getDBCredentialsUrl(process.env.VCAP_SERVICES);
    } else {
        dbCredentials.url = getDBCredentialsUrl(fs.readFileSync("vcap-local.json", "utf-8"));
    }

    cloudant = require('cloudant')(dbCredentials.url);
    cloudant.db.create(dbCredentials.dbName, function (err, res) {
        if (err) {
            console.log('Could not create new db: ' + dbCredentials.dbName + ', it might already exist.');
        }
    });

    db = cloudant.use(dbCredentials.dbName);
    // Check Stores document.
    db.get('users', {
        revs_info: true
    }, function (err, doc) {
        if (err) {
            console.log('Creating Users document...');
            creatUsers();
        } else {
            console.log('Users document already exists!');
        }
    })
}
initDBConnection();

function creatUsers() {
    var doc = {
        "users": {

        },
        "registeredUsers": []
    }
    db.insert(doc, 'users', function (err, document) {
        if (err) {
            console.log('Error on creating users document')
        } else {
            console.log('users document created successfully');
        }
    })
}


app.post('/login', function (req, res) {
    console.log('Login method invoked..')
    var data = req.body;

    db.get('users', { revs_info: true }, function (err, doc) {
        if (err) {
            //Error
            console.log('Um erro ocorreu')
        } else {
            console.log("checking user")
            var registeredUsers = doc.registeredUsers;
            var user = registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() })
            if (user.length == 1) {
                var users = doc.users;
                console.log(user);
                if (users[user[0].id]["password"] == data.password) {

                    res.status(200).json(users[user[0].id])

                } else {
                    console.log("Wrong password")
                    res.status(403).json({ error: true, error_reason: "WRONG_PASSWORD" })

                }
            } else {
                // User not found
                console.log('User not found');
                res.status(404).json({ error: true, error_reason: "EMAIL_NOT_FOUND" })
            }
        }
    })
})


app.post('/createAccount', function (req, res) {
    console.log('Create account method invoked.. ');
    var data = req.body;


    db.get('users', {
        revs_info: true
    }, function (err, doc) {
        if (err) {
            console.log("Error on retrieving data");
        } else {
            if (doc.registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() }).length == 1) {
                res.status(200).json({
                    error: true,
                    statusCode: 400,
                    error_reason: "EMAIL_ALREADY_REGISTERED"
                })
            } else {
                var users = doc.users;
                var keys = Object.keys(users);
                var key;
                if (keys.length > 0) {
                    key = parseInt(keys[keys.length - 1]) + 1;
                    users[key] = data;
                } else {
                    // First User to be registered
                    key = "1"
                    users['1'] = data;
                }

                doc.users = users;
                doc.registeredUsers.push({ email: data.email.toLowerCase(), id: key });
                db.insert(doc, users, function (err, document) {
                    if (err) {
                        console.log('Error on registering the new user');
                    } else {
                        console.log('User registered successfully');

                        res.status(200).json({ "erro": "test", statusCode: 200 });
                    }
                })

            }
        }
    })


})


app.listen(port, function () {
    console.log(`Client server is listening on port ${port}`);
})