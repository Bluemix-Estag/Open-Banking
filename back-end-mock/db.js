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

module.exports = db