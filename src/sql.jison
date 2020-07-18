/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                   	/* skip whitespace */
"CREATE"								return 'CREATE'
"DROP"									return 'DROP'
"SCHEMA"								return 'SCHEMA'
"IF"										return 'IF'
"NOT"										return 'NOT'
"EXISTS"								return 'EXISTS'
[a-zA-Z_][a-zA-Z0-9_]* 	return 'NAME'
[0-9]+(\.[0-9]+)?				return 'NUMBER'
";"         			     	return 'EOS'
<<EOF>>      			     	return 'EOF'

/lex

/* operator associations and precedence */

// %left 'OR'
// %left 'AND'
// %left 'NOT'
// %left '+' '-'
// %left '*' '/'
// %left '^'
// %right '!'
// %right '%'
// %left UMINUS

%start sql

%% /* language grammar */

sql
	: statements EOF
		{ return $1; }
	;

statements
	: statements statement
		{ $statements.push($2); $$ = $statements; }
	| statement
		{ $$ = [$1]; }
	;

statement
	: ddl_statement EOS
		{ $$ = { statement: $1 }; }
	;

ddl_statement
	: createschema_statement
	| dropschema_statement
	;

createschema_statement
	: create_schema opt_if_not_exists schema_name
		{ $$ = { type: $1, name: $3, if_not_exists: $2 }; }
	;

dropschema_statement
	: drop_schema opt_if_exists schema_name
		{ $$ = { type: $1, name: $3, if_exists: $2 }; }
	;

create_schema
	: CREATE SCHEMA
		{ $$ = `${$1}_${$2}`; }
	;

drop_schema
	: DROP SCHEMA
		{ $$ = `${$1}_${$2}`; }
	;

opt_if_exists
	:
		{ $$ = false; }
	| IF EXISTS
		{ $$ = true; }
	;

opt_if_not_exists
	:
		{ $$ = false; }
	| IF NOT EXISTS
		{ $$ = true; }
	;

schema_name
	: NAME
		{ $$ = $1; }
	;
