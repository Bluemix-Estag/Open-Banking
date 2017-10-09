var jsf = require('json-schema-faker');

var schema = {
    "type": "object",
    "properties": {
        accounts: {
            "type": "array",
            "minItems": 2,
            "maxItems": 6,
            "items": {
                "type": "object",
                "properties": {
                    accountName: {
                        "type": "string",
                        "faker": "finance.accountName"
                    },
                    balance: {
                        "type": 'number',
                        "faker": {
                            "finance.amount": [100, 40000, 2]
                        }
                    }

                },
                required: ['accountName', 'balance']
            }
        },
        payments: {
            "type": "array",
            "minItems": 1,
            "maxItems": 1,
            "items": {
                "type": "object",
                "properties": {
                    name: {
                        "type": "string",
                        "faker": "commerce.productName"
                    },
                    bill: {
                        "type": "number",
                        "faker": {
                            "finance.amount": [100,10000,2]
                        }
                    }
                },
                required: ['name','bill']
            }
        }
    },
    required: ['accounts', 'payments']
}


jsf.extend('faker', function () {
    return require('faker');;
});


const getMockData = (callback) => {
    jsf.resolve(schema).then((result) => {
        callback(result);
    });
}

module.exports = getMockData