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
require('dotenv').load();

app.post("/updateInfo", function (req, res) {
    console.log("Update method invoked..");
    var data = req.body
    console.log(JSON.stringify(data));
    if (data != null && data.email != null && data.cpf != null && data.password != null) {

        db.getUsers((err, doc) => {

            if (err) {
                res.status(500).json({ error: true, error_reason: "INTERNAL_SERVER_ERROR" })
            } else {

                var registeredUsers = doc.registeredUsers
                var user = registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() })[0] || null
                if (user) {
                    var users = doc.users;
                    if (users[user.id]["password"] == data.password) {
                        // Get user accounts Balance
                        console.log(" Checking user accounts");
                        getAccountsBalance(users[user.id], 0, [], function (accounts) {
                            users[user.id].accounts = accounts;
                            res.status(200).json(users[user.id])
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
                console.error("Error on retrieving users info");
                res.status(500).json({ error: true, error_reason: "INTERNAL_SERVER_ERROR" })
            } else {
                console.log("checking user")
                var registeredUsers = doc.registeredUsers;
                var user = registeredUsers.filter(function (user) { return user.email == data.email.toLowerCase() })[0] || null;
                if (user) {
                    var users = doc.users;
                    if (users[user.id]["password"] == data.password) {
                        // Get user accounts Balance
                        console.log(" Checking user accounts");
                        getAccountsBalance(users[user.id], 0, [], function (accounts) {
                            users[user.id].accounts = accounts;
                            res.status(200).json(users[user.id])
                        })
                    } else {
                        console.error("Wrong password")
                        res.status(403).json({ error: true, error_reason: "WRONG_PASSWORD" })

                    }
                } else {
                    // User not found
                    console.error('User not found');
                    res.status(404).json({ error: true, error_reason: "EMAIL_NOT_FOUND" })
                }
            }

        })
    } else {
        res.status(400).json({ error: true, error_reason: "BAD_REQUEST" })
    }
})

function getAccountsBalance(user, index, accounts, callback) {
    if (index >= user.accounts.length) {
        callback(accounts)
    } else {

        // Check the cpf with Davi
        var options = {
            uri: `https://api.us.apiconnect.ibmcloud.com/bluemix-brasil-openbanking/sb/open-banking/v1.0/accounts/30722200867/balances`,
            method: "GET",
            headers: {
                "Content-Type": "application/json",
                "X-IBM-Client-Id": "31649214-f2e6-4ea0-a997-1701d8cbfcfc",
                "x-fapi-financial-id": user.accounts[index].name
            }
        }
        request(options, function (error, response, body) {
            
            body = JSON.parse(body);
            if (!error && response.statusCode == 200) {
                user.accounts[index].balance = body.balance[0];
                user.accounts[index].limit = body.limit[0];
                user.accounts[index].current_limit = body.current_limit[0];
                accounts.push(user.accounts[index])
                getAccountsBalance(user, index + 1, accounts, callback)
            } else {
                console.log("an error occured");
                getAccountsBalance(user, index + 1, accounts, callback)
            }
        })
    }
}



require('./randomData')((result) => {

    console.log(JSON.stringify(result, null, 2))
    // var accountsName  = result.accounts.map((account) => { return account.accountName })
    // console.log(JSON.stringify(result.accounts.filter( (account, index) => {  return accountsName.lastIndexOf(account.accountName) == index } )));


})

app.post('/createAccount', (req, res) => {
    console.log('Create account method invoked..');
    const data = req.body;
    if (data != null && data.email != null && data.name != null && data.cpf != null && data.password != null && data.accounts != null && data.payments != null) {
        //  Fixed Accounts
        data.accounts = [
            {
                "name": "BANK01"
            },
            {
                "name": "BANK02"
            },
            {
                "name": "CORRETORA01"
            }
        ]
        getAccountsBalance(data, 0, [], (accounts) => {
            data.accounts = accounts;

            db.addUser(data, (response) => {
                res.status(response.statusCode).json(response.data);
            });
        });
    } else {
        console.log("Bad request");
        res.status(400).json({ error: true, error_reason: "BAD_REQUEST" });
    }
});


app.post("/conversation", function (req, res) {
    console.log("Conversation method invoked..");
    processChatMessage(req, res);
})


const processChatMessage = (req, res) => {
    chatbot.sendMessage(req, (err, data) => {
        if (err) {
            console.log("Error in sending message: ", err);
            res.status(err.code || 500).json(err);
        } else {
            console.log('Got response: ', JSON.stringify(data, null, 2));


            // Check for any action required
            if (data.output.action != null) {
                switch (data.output.action) {
                    case "payBill":
                        console.log('Paying user method invoked..');
                        payBillUserAccount(data, res);
                        break;

                    default:

                        res.status(200).json(data);
                }
            } else {
                res.status(200).json(data);
            }
        }
    });
}

const payBillUserAccount = (data, res) => {
    var user = data.context.user;
    db.getUserByEmail(user.email, (error, user) => {
        if (error) {
            res.status(error.statusCode).json({ error: true, error_reason: error.error_reason });
        } else {
            // Pay the bill for the user !
            // You can call an API of the corresponding bank.
            user.accounts[0].oldBalance = user.accounts[0].balance;
            user.accounts[0].balance = user.accounts[0].balance - user.payments[0].bill;
            user.accounts[0].services[0].balance = parseFloat(user.accounts[0].services[0].balance + parseInt(user.payments[0].bill)).toFixed(2);
            user.payments.shift();
            // Here the user info updated
            // Update on Cloudant
            db.updateUser(user, (error, updatedUser) => {
                if (error) {
                    res.status(error.statusCode).json({ error: true, error_reason: error.error_reason });
                } else {
                    // User updated, now send to watson conversation to notify the user about the new balance! 
                    data.context.user = updatedUser;
                    data.context.paid = true;
                    var req = {
                        body: data
                    }
                    processChatMessage(req, res);
                }
            })
        }
    })
};


app.listen(port, function () {
    console.log(`Client server is listening on port ${port}`);
})