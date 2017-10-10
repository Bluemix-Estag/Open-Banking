var jsf = require('json-schema-faker');

var schema = {
    "type": "object",
    "properties": {
        accounts: {
            "type": "array",
            "minItems": 3,
            "maxItems": 6,
            "uniqueItems": true,
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
                            "finance.amount": [10000, 40000, 2]
                        }
                    },
                    services: {
                        "type": "array",
                        "minItems": 2,
                        "maxItems": 5,
                        "items": {
                            "type": "object",
                            "properties": {
                                name: {
                                    "type": "string",
                                    "faker": "finance.accountName"
                                },
                                balance: {
                                    "type": "number",
                                    "faker": {
                                        "random.number": [1000]
                                    }
                                }
                            },
                            required: ['name', 'balance']
                        },

                    }
                },
                required: ['accountName', 'balance', 'services']

            }            
        },
        payments: {
            "type": "array",
            "minItems": 1,
            "maxItems": 1,
            "uniqueItems": true,
            "items": {
                "type": "object",
                "properties": {
                    name: {
                        "type": "string",
                        "faker": "company.companyName"
                    },
                    bill: {
                        "type": "number",
                        "faker": {
                            "finance.amount": [100, 10000, 2]
                        }
                    },
                    date: {
                        "type": "string",
                        "faker": "custom.billDate"
                    }
                },
                required: ['name', 'bill', 'date']
            }

        }
    },
    required: ["accounts", "payments"]
}


jsf.extend('faker', function () {
    var faker = require('faker');
    faker.locale = "pt_BR";
    faker.custom = {
        billDate: function () {
            var date = new Date();
            date.setMonth(date.getMonth() + 1);
            return faker.date.between(new Date(), date).toString().split(" ").slice(1, -1).slice(0, 3).join("/");;
        }

    }
    return faker;
});


const getMockData = (callback) => {
    jsf.resolve(schema).then((result) => {
        callback(result);
    });
}

module.exports = getMockData