import * as Lexer from 'lex'

var lines = 0;
var chars = 0;

const lexer = new Lexer()
 
lexer.addRule(/\n/, function () {
	lines++
	chars++
}).addRule(/./, function () {
	chars++
})

lexer.addRule(/\s+/, function() {
	/* skip whitespace */
}).addRule({ source: /SELECT/, ignoreCase: true }, function() {
	return 'SELECT'
}).addRule(/\*/, function() {
	return '*'
}).addRule({ source: /FROM/, ignoreCase: true }, function() {
	return 'FROM'
}).addRule({ source: /WHERE/, ignoreCase: true }, function() {
	return 'WHERE'
}).addRule({ source: /LIKE/, ignoreCase: true }, function() {
	return 'LIKE'
}).addRule({ source: /ORDER/, ignoreCase: true }, function() {
	return 'ORDER'
}).addRule({ source: /BY/, ignoreCase: true }, function() {
	return 'BY'
}).addRule({ source: /ASC/, ignoreCase: true }, function() {
	return 'ASC'
}).addRule({ source: /DESC/, ignoreCase: true }, function() {
	return 'DESC'
}).addRule({ source: /AND/, ignoreCase: true }, function() {
	return 'AND'
}).addRule({ source: /OR/, ignoreCase: true }, function() {
	return 'OR'
}).addRule({ source: /NOT/, ignoreCase: true }, function() {
	return 'NOT'
}).addRule({ source: /INSERT/, ignoreCase: true }, function() {
	return 'INSERT'
}).addRule({ source: /VALUES/, ignoreCase: true }, function() {
	return 'VALUES'
}).addRule({ source: /UPDATE/, ignoreCase: true }, function() {
	return 'UPDATE'
}).addRule({ source: /SET/, ignoreCase: true }, function() {
	return 'SET'
}).addRule({ source: /NULL/, ignoreCase: true }, function() {
	return 'NULL'
}).addRule({ source: /IS/, ignoreCase: true }, function() {
	return 'IS'
}).addRule({ source: /NOT/, ignoreCase: true }, function() {
	return 'NOT'
}).addRule(/\(/, function() {
	return '('
}).addRule(/\)/, function() {
	return ')'
}).addRule(/>=/, function() {
	return 'COMPARISON'
}).addRule(/<=/, function() {
	return 'COMPARISON'
}).addRule(/>/, function() {
	return 'COMPARISON'
}).addRule(/</, function() {
	return 'COMPARISON'
}).addRule(/==/, function() {
	return 'COMPARISON'
}).addRule(/=/, function() {
	return '='
}).addRule(/(true|false)\b/, function() {
	return 'BOOLEAN'
}).addRule(/[a-zA-Z_][a-zA-Z0-9_]*/, function() {
	return 'NAME'
}).addRule(/[0-9]+(\.[0-9]+)?/, function() {
	return 'NUM'
}).addRule(/\'[^'\n]*\'/, function() {
	return 'STRING'
}).addRule(/\"[^'\n]*\"/, function() {
	return 'STRING'
}).addRule(/,/, function() {
	return ','
}).addRule(/;/, function() {
	return 'EOC'
})

export default lexer
