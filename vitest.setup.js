import { parser } from './mini-sql'
global.parser = parser
global.parse = parser.parse
global.singleCommand = (input) => parser.parse(input)[0]
