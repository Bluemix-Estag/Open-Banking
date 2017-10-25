/**
 * This file contains all of the web and hybrid functions for interacting with
 * Cloudant service.
 *
 * @summary   Functions for Cloudant.
 * @author  Rabah Zeineddine
 *
 */

var watson = require('watson-developer-cloud');
var cfenv = require('cfenv');
var fs = require('fs');
// load local VCAP configuration
var vcapLocal = null;
var appEnv = null;
var appEnvOpts = {};
var conversationWorkspace, conversation;


fs.stat('./vcap.json', function (err, stat) {
    if (err && err.code === 'ENOENT') {
        // file does not exist
        console.log('No vcap.json');
        initializeAppEnv();
    }
    else if (err) {
        console.log('Error retrieving local vcap: ', err.code);
    }
    else {
        vcapLocal = require("./vcap.json");
        console.log("Loaded VCAP", vcapLocal);
        appEnvOpts = {
            vcap: vcapLocal
        };
        initializeAppEnv();
    }
});



function initializeAppEnv() {
    appEnv = cfenv.getAppEnv(appEnvOpts);
    appEnv.services = appEnvOpts.vcap.services;
    initCloudant();
}

// =====================================
// CLOUDANT SETUP ======================
// =====================================

var dbname = "open_banking_db";
var db;

function initCloudant() {
    console.log(JSON.stringify(appEnv.getServiceCreds("cloudantNoSQLDB")))
    var cloudantURL = appEnv.getServiceCreds("cloudantNoSQLDB").url || process.env.CLOUDANT_URL;
    var Cloudant = require('cloudant')({
        url: cloudantURL
        , plugin: 'retry'
        , retryAttempts: 10
        , retryTimeout: 500
    });

    // Create the accounts Logs if it doesn't exist
    Cloudant.db.create(dbname, function (err, body) {
        if (err) {
            console.log("Database already exists: ", dbname);
        }
        else {
            console.log("New database created: ", dbname);
        }
    });
    db = Cloudant.db.use(dbname);

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
}


const getUsers = (callback) => {
    db.get('users', { revs_info: true }, (err, doc) => {
        if (err) {
            callback(true, null);
        } else {
            callback(false, doc)
        }
    })
}

const getUserByEmail = (email,callback) => {

    db.get('users', { revs_info: true} , (err, doc) => {
        if (err ) {
            callback({"error": true, "error_reason": "INTERNAL_SERVER_ERROR" , statusCode: 500 }, null);
        }else{
            var registeredUsers = doc.registeredUsers;
            var user = registeredUsers.filter(function (user) { return user.email == email.toLowerCase() })
            if ( user.length == 1){
                var users = doc.users;
                callback(null, users[user[0].id]);
            }else{
                callback({ error: true, error_reason: "EMAIL_NOT_FOUND" , statusCode: 404 } , null );
            }
        }
    });
}

const updateUser = (updatedUser,callback) => {
    getUsers( (error, doc )=> {
        if (error){
            // return error
            callback({error: true, error_reason: "INTERNAL_SERVER_ERROR" , statusCode: 500}, null);
        }else{

            var registeredUsers = doc.registeredUsers;
            var user = registeredUsers.filter( function(user) { return user.email == updatedUser.email.toLowerCase() });
            if ( user.length == 1 ){

                var users = doc.users;
                users[user[0].id] = updatedUser;
                doc.users = users;
                db.insert(doc,'users', (err, document) => {
                    if (err){
                        // Error
                        callback({error: true, error_reason: "INTERNAL_SERVER_ERROR" , statusCode: 500}, null);

                    }else{
                        callback(null, doc.users[user[0].id]);
                    }
                })
            }else{
                callback({ error: true, error_reason: "EMAIL_NOT_FOUND" , statusCode: 404 } , null );
            }
        }
    })


}

const addUser = (user, callback) => {
    let response = {

    }
    getUsers((err, doc) => {
        if (err) {
            console.log('Error getting users in addUser method');
            response.statusCode = 500;
            response.data = {
                error: true,
                error_reason: "INTERNAL_SERVER_ERROR"
            }
            callback(response);
        } else {

            if (doc.registeredUsers.filter(function (registeredUser) { return registeredUser.email == user.email.toLowerCase() }).length == 1) {
                response.statusCode = 403;
                response.data = {
                    error: true,
                    error_reason: "EMAIL_ALREADY_REGISTERED"
                }
                callback(response);
            } else {
                var users = doc.users;
                var keys = Object.keys(users);
                var key;
                if (keys.length > 0) {
                    key = parseInt(keys[keys.length - 1]) + 1;
                    users[key] = user;
                } else {
                    // First User to be registered
                    key = "1"
                    users['1'] = user;
                }
                doc.users = users;
                doc.registeredUsers.push({ email: user.email.toLowerCase(), id: key });

                db.insert(doc, 'users', (error, document) => {
                    if (error) {
                        console.log("Error on adding new user");
                        response.statusCode = 500
                        response.data = {
                            error: true,
                            error_reason: "INTERNAL_SERVER_ERROR"
                        }
                        callback(response);
                    } else {
                        console.log("User registered successfully");
                        response.statusCode = 200
                        response.data = {
                            error: false,
                            msg: "User registered successfully",
                            user: user
                        }
                        callback(response)
                    }
                })
            }
        }
    })
}

module.exports = {
    getUsers,
    addUser,
    getUserByEmail,
    updateUser
}