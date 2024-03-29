import { parser } from './mini-sql'

global.parser = parser
global.singleCommand = (input) => parser.parse(input)[0]
