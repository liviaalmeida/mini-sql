const minisql = require('./../mini-sql')
global.parser = minisql.parser
global.parse = minisql.parser.parse
global.singleCommand = (input) => minisql.parser.parse(input)[0]
