import { Parser } from 'jison'

import lexer from '../lexer'

var grammar = {
	"bnf": {
			"expression" :[[ "e EOF",   "return $1;"  ]],
			"e" :[[ "NUMBER",  "$$ = Number(yytext);" ]]
	}
}

const parser = new Parser(grammar)
parser.lexer = lexer

export default parser
