import * as Lexer from 'lex'

var lines = 0;
var chars = 0;

const lexer = new Lexer()
 
lexer.addRule(/\n/, function () {
	lines++;
	chars++;
}).addRule(/./, function () {
	chars++;
}).setInput("Hello World!").lex();

export default lexer
