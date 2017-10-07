var express = require('express');
var bodyParser = require('body-parser');
var request = require('request');
var app = express();
var fs = require('fs');

app.use(bodyParser.json());

var port = process.env.PORT || 3000;
app.set('port', port);

var db = require('./db.js');
var chatbot = require('./bot')

app.post("/updateInfo", function (req, res) {
    console.log("Update method invoked..");
    var data = req.body

    if (data != null && data.email != null && data.password != null) {


        db.get('users', { revs_info: true }, function (err, doc) {
            if (err) {
                res.status(500).json({ error: true, error_reason: "INTERNAL_SERVER_ERROR" })
            } else {

                var registeredUsers = doc.registeredUsers
                var user = registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() })
                if (user.length == 1) {


                    var users = doc.users;
                    console.log(user);
                    if (users[user[0].id]["password"] == data.password) {
                        // Get user accounts Balance
                        console.log(" Checking user accounts");
                        getAccoutnsBalance(users[user[0].id], 0, [], function (accounts) {
                            users[user[0].id].accounts = accounts;
                            res.status(200).json(users[user[0].id])
                        })
                    } else {
                        console.log("Wrong password")
                        res.status(403).json({ error: true, error_reason: "WRONG_PASSWORD" })

                    }


                } else {
                    res.status(404).json({ error: true, error_reason: "EMAIL_NOT_FOUND" })
                }

            }
        })

    } else {
        res.status(400).json({ error: true, error_reason: "BAD_REQUEST" })
    }

})

app.post('/login', (req, res) => {
    console.log('Login method invoked');
    const data = req.body;
    if (data != null && data.email != null && data.password != null) {
        db.getUsers((err, doc) => {

            if (err) {
                res.status(500).json({ error: true, error_reason: "INTERNAL_SERVER_ERROR" })
            } else {
                console.log("checking user")
                var registeredUsers = doc.registeredUsers;
                var user = registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() })
                if (user.length == 1) {
                    var users = doc.users;
                    console.log(user);
                    if (users[user[0].id]["password"] == data.password) {
                        // Get user accounts Balance
                        console.log(" Checking user accounts");
                        getAccoutnsBalance(users[user[0].id], 0, [], function (accounts) {
                            users[user[0].id].accounts = accounts;
                            res.status(200).json(users[user[0].id])
                        })
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
    } else {
        res.status(400).json({ error: true, error_reason: "BAD_REQUEST" })
    }
})

// app.post('/login', function (req, res) {
//     console.log('Login method invoked..')
//     var data = req.body;

//     if (data != null && data.email != null && data.password != null) {
//         db.get('users', { revs_info: true }, function (err, doc) {
//             if (err) {
//                 //Error
//                 console.log('Um erro ocorreu')
//                 res.status(500).json({ error: true, error_reason: "INTERNAL_SERVER_ERROR" })
//             } else {
//                 console.log("checking user")
//                 var registeredUsers = doc.registeredUsers;
//                 var user = registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() })
//                 if (user.length == 1) {
//                     var users = doc.users;
//                     console.log(user);
//                     if (users[user[0].id]["password"] == data.password) {
//                         // Get user accounts Balance
//                         console.log(" Checking user accounts");
//                         getAccoutnsBalance(users[user[0].id], 0, [], function (accounts) {
//                             users[user[0].id].accounts = accounts;
//                             res.status(200).json(users[user[0].id])
//                         })
//                     } else {
//                         console.log("Wrong password")
//                         res.status(403).json({ error: true, error_reason: "WRONG_PASSWORD" })

//                     }
//                 } else {
//                     // User not found
//                     console.log('User not found');
//                     res.status(404).json({ error: true, error_reason: "EMAIL_NOT_FOUND" })
//                 }
//             }
//         })
//     } else {
//         res.status(400).json({ error: true, error_reason: "BAD_REQUEST" })
//     }
// })


function getAccoutnsBalance(user, index, accounts, callback) {

    if (index >= user.accounts.length) {
        callback(accounts)
    } else {
        var options = {
            uri: "http://demos-node-red.mybluemix.net/getBalance",
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(user.accounts[index])
        }
        request(options, function (error, response, body) {

            if (!error && response.statusCode == 200) {
                user.accounts[index].accountBalance = parseFloat(body)
                accounts.push(user.accounts[index])
                getAccoutnsBalance(user, index + 1, accounts, callback)
            } else {
                getAccoutnsBalance(user, index + 1, accounts, callback)
            }
        })
    }
}

app.post('/createAccount', function (req, res) {
    console.log('Create account method invoked.. ');
    var data = req.body;

    console.log(JSON.stringify(data, null, 2));

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


app.post("/conversation", function (req, res) {
    processChatMessage(req, res);
})


const processChatMessage = (req, res) => {
    chatbot.sendMessage(req, (err, data) => {
        if (err) {
            console.log("Error in sending message: ", err);
            res.status(err.code || 500).json(err);
        } else {
            console.log('Got response: ', JSON.stringify(data));
            res.status(200).json(data);
        }
    });
}




app.listen(port, function () {
    console.log(`Client server is listening on port ${port}`);
})