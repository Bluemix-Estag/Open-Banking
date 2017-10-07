/**
 * This file contains all of the web and hybrid functions for interacting with
 * Watson Conversation service. When API calls are not needed, the
 * functions also do basic messaging between the client and the server.
 *
 * @summary   Functions for Chat Bot.
 * @author  Rabah Zeineddine
 *
 */

const watson = require('watson-developer-cloud'),
    cfenv = require('cfenv'),
    fs = require('fs');

// load local VCAP configuration
let vcapLocal = null,
    appEnv = null,
    appEnvOpts = {},
    conversationWorkspace, conversation;


fs.stat('./vcap.json', function (err, stat) {
    if (err && err.code === 'ENOENT') {
        // file does not exist
        console.log('No vcap.json');
        initializeAppEnv();
    } else if (err) {
        console.log('Error retrieving local vcap: ', err.code);
    } else {
        vcapLocal = require("./vcap.json");
        console.log("Loaded VCAP", vcapLocal);
        appEnvOpts = {
            vcap: vcapLocal
        };
        initializeAppEnv();
    }
});

// get the app environment from Cloud Foundry, defaulting to local VCAP
function initializeAppEnv() {
    appEnv = cfenv.getAppEnv(appEnvOpts);
    appEnv.services = appEnvOpts.vcap.services;
    initConversation(); 
}

// =====================================
// CREATE THE SERVICE WRAPPER ==========
// =====================================
// Create the service wrapper

function initConversation() {
    console.log("Initializing conversation..")
    const conversationCredentials =  appEnv.getServiceCreds('conversation'); // Get credentials from env. on bluemix, otherwise get it locally
    const conversationUsername = process.env.CONVERSATION_USERNAME || conversationCredentials.username;
    const conversationPassword = process.env.CONVERSATION_PASSWORD || conversationCredentials.password;
    const conversationURL = process.env.CONVERSATION_URL || conversationCredentials.url;
    conversationWorkspace = process.env.CONVERSATION_WORKSPACE || conversationCredentials.conversationWorkspace;

    conversation = watson.conversation({
        url: conversationURL,
        username: conversationUsername,
        password: conversationPassword,
        version_date: '2017-05-26',
        version: 'v1'
    });

    // check if the workspace ID is specified in the environment
    console.log(`Looking for a workspace named '${conversationWorkspace}'...`);
    conversation.listWorkspaces((err, result) => {
        if (err) {
            console.log('Failed to query workspaces. Conversation will not work.', err);
        } else {
            const workspace = result.workspaces.find(workspace => workspace.workspace_id === conversationWorkspace);
            if (workspace) {
                conversationWorkspace = workspace.workspace_id;
                console.log("Using Watson Conversation with username", conversationUsername, "and workspace", conversationWorkspace);
            } else {
                console.log('Importing workspace from ./conversation/conversation.json');
                // create the workspace
                const watsonWorkspace = JSON.parse(fs.readFileSync('./conversation/conversation.json'));
                // force the name to our expected name
                watsonWorkspace.name = "Open Banking";
                conversation.createWorkspace(watsonWorkspace, (createErr, workspace) => {
                    if (createErr) {
                        console.log('Failed to create workspace', err);
                    } else {
                        conversationWorkspace = workspace.workspace_id;
                        console.log(`Successfully created the workspace '${watsonWorkspace.name}'`);
                        console.log("Using Watson Conversation with username", conversationUsername, "and workspace", conversationWorkspace);
                    }
                });
            }
        }
    });

}
// =====================================
// REQUEST =====================
// =====================================
// Allow clients to interact
var chatbot = {
    sendMessage: function (req, callback) {
        buildContextObject(req, function (err, params) {
            if (err) {
                console.log("Error in building the parameters object: ", err);
                return callback(err);
            }
            if (params) {
                // Send message to the conversation service with the current context
                conversation.message(params, function (err, data) {
                    if (err) {
                        console.log("Error in sending message: ", err);
                        return callback(err);
                    } else {
                        var conv = data.context.conversation_id;
                        console.log("Got response from Conversation: ", JSON.stringify(data));
                        callback(null, data);
                    }
                });
            }
        })
    }
};




// ===============================================
// UTILITY FUNCTIONS FOR CHATBOT          ========
// ===============================================
/**
 * @summary Form the parameter object to be sent to the service
 *
 * Update the context object based on the user state in the conversation and
 * the existence of variables.
 *
 * @function buildContextObject
 * @param {Object} req - Req by user sent in POST with session and user message
 */

function buildContextObject(req, callback) {
    var message = req.body.text;
    var context;
    if (!message) {
        message = '';
    }
    // Null out the parameter object to start building
    var params = {
        workspace_id: conversationWorkspace,
        input: {},
        context: {}
    };

    if (req.body.context) {
        context = req.body.context;
        params.context = context;
    } else {
        context = '';
    }
    // Set parameters for payload to Watson Conversation
    params.input = {
        text: message // User defined text to be sent to service
    };
    return callback(null, params);
}
module.exports = chatbot;