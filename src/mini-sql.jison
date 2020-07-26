/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                   	/* skip whitespace */
'*'											return 'STAR'
'TEMP'									return 'TEMP'
'TEMPORARY'							return 'TEMP'
'ALTER'									return 'ALTER'
'CREATE'								return 'CREATE'
'DROP'									return 'DROP'
'USE'										return 'USE'
'COMMIT'								return 'COMMIT'
'ROLLBACK'							return 'ROLLBACK'
'RENAME'								return 'RENAME'
'TO'										return 'TO'
'AS'										return 'AS'
'SCHEMA'								return 'SCHEMA'
'TABLE'									return 'TABLE'
'CONSTRAINT'						return 'CONSTRAINT'
'PRIMARY'								return 'PRIMARY'
'UNIQUE'								return 'UNIQUE'
'FOREIGN'								return 'FOREIGN'
'KEY'										return 'KEY'
'REFERENCES'						return 'REFERENCES'
'NOT'										return 'NOT'
'NULL'									return 'NULL'
'AUTO_INCREMENT'				return 'AUTO_INCREMENT'
'AUTOINCREMENT'					return 'AUTO_INCREMENT'
'('											return 'PAREN_OPEN'
')'											return 'PAREN_CLOSE'
'"'											return 'QUOTE_DOUBLE'
'\''										return 'QUOTE_SINGLE'
'`'											return 'QUOTE_SINGLE_BENT'
'['											return 'BRACKET_OPEN'
']'											return 'BRACKET_CLOSE'
'ARRAY'									return 'ARRAY'
'BINARY'								return 'BINARY'
'BIGINT'								return 'BIGINT'
'BIT'										return 'BIT'
'BLOB'									return 'BLOB'
'BOOL'									return 'BOOL'
'BOOLEAN'								return 'BOOLEAN'
'CHAR'									return 'CHAR'
'CHARACTER'							return 'CHARACTER'
'CLOB'									return 'CLOB'
'BYTE'									return 'BYTE'
'DATE'									return 'DATE'
'ENUM'									return 'ENUM'
'FLOAT'									return 'FLOAT'
'DECIMAL'								return 'DECIMAL'
'DOUBLE'								return 'DOUBLE'
'INT'										return 'INT'
'INTEGER'								return 'INTEGER'
'LONGBLOB'							return 'LONGBLOB'
'LONGTEXT'							return 'LONGTEXT'
'MEDIUMBLOB'						return 'MEDIUMBLOB'
'MEDIUMINT'							return 'MEDIUMINT'
'MEDIUMTEXT'						return 'MEDIUMTEXT'
'NCHAR'									return 'NCHAR'
'NCLOB'									return 'NCLOB'
'NUMBER'								return 'NUMBER'
'NUMERIC'								return 'NUMERIC'
'NVARCHAR'							return 'NVARCHAR'
'REAL'									return 'REAL'
'SMALLINT'							return 'SMALLINT'
'TIME'									return 'TIME'
'TIMESTAMPTZ'						return 'TIMESTAMPTZ'
'TIMETZ'								return 'TIMETZ'
'TINYBLOB'							return 'TINYBLOB'
'TINYINT'								return 'TINYINT'
'TINYTEXT'							return 'TINYTEXT'
'UUID'									return 'UUID'
'VARBINARY'							return 'VARBINARY'
'VARCHAR'								return 'VARCHAR'
'VARCHAR2'							return 'VARCHAR2'
'VARYING'								return 'VARYING'
'LONG'									return 'LONG'
'PRECISION'							return 'PRECISION'
'UNSIGNED'							return 'UNSIGNED'
'OTHER'									return 'OTHER'
'ZONE'									return 'ZONE'
'WITH'									return 'WITH'
'WITHOUT'								return 'WITHOUT'
'COLLATE'								return 'COLLATE'
[a-zA-Z_][a-zA-Z0-9_]* 	return 'NAME'
\d+											return 'U_INT'
-\d+										return 'S_INT'
','											return 'COMMA'
';'         			     	return 'EOS'
<<EOF>>      			     	return 'EOF'
.*											return 'CHARS'

/lex

/* operator associations and precedence */

// %left 'OR'
// %left 'AND'
%left 'NOT'
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
		{ $$ = [ ...$statements, ...$statement ]; }
	| statement
		{ $$ = [$statement]; }
	;

statement
	: ddl_statement EOS
		{ $$ = { statement: $ddl_statement }; }
	| tcl_statement EOS
		{ $$ = { statement: $tcl_statement }; }
	;

ddl_statement
	: alterschema_statement
	| createtable_statement
	| createschema_statement
	| droptable_statement
	| dropschema_statement
	| useschema_statement
	;

tcl_statement
	: commit_statement
	| rollback_statement
	;

alterschema_statement
	: ALTER SCHEMA NAME RENAME TO NAME
		{ $$ = { name: $6, old_name: $3, type: 'ALTER_SCHEMA' }; }
	| ALTER SCHEMA NAME RENAME AS NAME
		{ $$ = { name: $6, old_name: $3, type: 'ALTER_SCHEMA' }; }
	;

createtable_statement
	: create_table NAME PAREN_OPEN table_constraints PAREN_CLOSE
		{ $$ = { name: $2, constraints: $table_constraints, ...$create_table }; }
	;

createschema_statement
	: CREATE SCHEMA NAME
		{ $$ = { name: $3, type: 'CREATE_SCHEMA' }; }
	;

droptable_statement
	: drop_table NAME
		{ $$ = { name: $2, ...$drop_table }; }
	;

dropschema_statement
	: DROP SCHEMA NAME
		{ $$ = { name: $3, type: 'DROP_SCHEMA' }; }
	;

useschema_statement
	: USE NAME
		{ $$ = { name: $2, type: 'USE' }; }
	;

commit_statement
	: COMMIT
		{ $$ = { type: 'COMMIT' }; }
	;

rollback_statement
	: ROLLBACK
		{ $$ = { type: 'ROLLBACK' }; }
	;

table_constraints
	: table_constraints COMMA table_constraint
		{ $$ = [ ...$table_constraints, $table_constraint ]; }
	| table_constraint
		{ $$ = [$table_constraint]; }
	;

table_constraint
	: CONSTRAINT opt_identifier constraint
		{ $$ = { constraint: $constraint, ...$opt_identifier }; }
	| constraint
		{ $$ = { constraint: $constraint }; }
	| column
		{ $$ = { column: $column }; }
	;

constraint
	: PRIMARY KEY PAREN_OPEN list_identifiers PAREN_CLOSE
		{ $$ = { primary: $list_identifiers }; }
	| FOREIGN KEY PAREN_OPEN list_identifiers PAREN_CLOSE REFERENCES foreign_reference
		{ $$ = { foreign: $list_identifiers, reference: $foreign_reference}; }
	;

column
	: identifier datatype column_complements
		{ $$ = { name: $identifier, constraints: $column_complements, ...$datatype }; }
	| identifier datatype
		{ $$ = { name: $identifier, ...$datatype }; }
	;

column_complements
	: column_complements column_complement
		{ $$ = { ...$column_complements, ...$column_complement }; }
	| column_complement
	;

column_complement
	: CONSTRAINT opt_identifier column_constraint
		{ $$ = { ...$column_constraint, ...$opt_identifier }; }
	| column_constraint
		{ $$ = { ...$column_constraint }; }
	| NOT NULL
		{ $$ = { never_null: true }; }
	| NULL
		{ $$ = { null_allowed: true }; }
	| AUTO_INCREMENT
		{ $$ = { auto_increment: true}; }
	;

column_constraint
	: PRIMARY KEY
		{ $$ = { primary: true }; }
	| UNIQUE KEY
		{ $$ = { unique: true }; }
	| REFERENCES foreign_reference
		{ $$ = { foreign: $foreign_reference }; }
	;

foreign_reference
	: NAME PAREN_OPEN list_identifiers PAREN_CLOSE
		{ $$ = { table: $1, identifiers: $list_identifiers }; }
	;

datatype
	: ENUM PAREN_OPEN list_strings PAREN_CLOSE opt_collation
		{ $$ = { type: 'ENUM', enum: [ $string, $list_strings ], ...$opt_collation }; }
	| CHAR opt_size_typed opt_collation
		{ $$ = { type: 'CHAR', ...$opt_size_typed, ...$opt_collation }; }
	| CHARACTER opt_size_typed opt_collation
		{ $$ = { type: 'CHARACTER', ...$opt_size_typed, ...$opt_collation }; }
	| CHARACTER VARYING opt_size_typed opt_collation
		{ $$ = { type: 'CHARACTER', varying: true, ...$opt_size_typed, ...$opt_collation }; }
	| VARCHAR opt_size_typed opt_collation
		{ $$ = { type: 'VARCHAR', ...$opt_size_typed, ...$opt_collation }; }
	| VARCHAR2 opt_size_typed opt_collation
		{ $$ = { type: 'VARCHAR2', ...$opt_size_typed, ...$opt_collation }; }
	| DOUBLE opt_PRECISION opt_size_float
		{ $$ = { type: 'DOUBLE', ...$opt_PRECISION, ...$opt_size_float }; }
	| CLOB opt_size opt_collation
		{ $$ = { type: 'CLOB', ...$opt_size, ...$opt_collation }; }
	| LONG NVARCHAR opt_size opt_collation
		{ $$ = { type: 'NVARCHAR', long: true, ...$opt_size, ...$opt_collation }; }
	| LONG VARCHAR opt_size opt_collation
		{ $$ = { type: 'VARCHAR', long: true, ...$opt_size, ...$opt_collation }; }
	| NCHAR opt_size opt_collation
		{ $$ = { type: 'NCHAR', ...$opt_size, ...$opt_collation }; }
	| NVARCHAR opt_size opt_collation
		{ $$ = { type: 'NVARCHAR', ...$opt_size, ...$opt_collation }; }
	| TEXT opt_size opt_collation
		{ $$ = { type: 'TEXT', ...$opt_size, ...$opt_collation }; }
	| TIME opt_size opt_TIMEZONE
		{ $$ = { type: 'TIME', ...$opt_size, ...$opt_TIMEZONE }; }
	| INT opt_size opt_UNSIGNED
		{ $$ = { type: 'INT', ...$opt_size, ...$opt_UNSIGNED }; }
	| INTEGER opt_size opt_UNSIGNED
		{ $$ = { type: 'INTEGER', ...$opt_size, ...$opt_UNSIGNED }; }
	| MEDIUMINT opt_size opt_UNSIGNED
		{ $$ = { type: 'MEDIUMINT', ...$opt_size, ...$opt_UNSIGNED }; }
	| SMALLINT opt_size opt_UNSIGNED
		{ $$ = { type: 'SMALLINT', ...$opt_size, ...$opt_UNSIGNED }; }
	| TINYINT opt_size opt_UNSIGNED
		{ $$ = { type: 'TINYINT', ...$opt_size, ...$opt_UNSIGNED }; }
	| BIGINT opt_UNSIGNED
		{ $$ = { type: 'BIGINT', ...$opt_UNSIGNED }; }
	| LONGTEXT opt_collation
		{ $$ = { type: 'LONGTEXT', ...$opt_collation }; }
	| MEDIUMTEXT opt_collation
		{ $$ = { type: 'MEDIUMTEXT', ...$opt_collation }; }
	| NCLOB opt_collation
		{ $$ = { type: 'NCLOB', ...$opt_collation }; }
	| TINYTEXT opt_collation
		{ $$ = { type: 'TINYTEXT', ...$opt_collation }; }
	| DECIMAL opt_size_decimal
		{ $$ = { type: 'DECIMAL', ...$opt_size_decimal }; }
	| NUMBER opt_size_decimal
		{ $$ = { type: 'NUMBER', ...$opt_size_decimal }; }
	| NUMERIC opt_size_decimal
		{ $$ = { type: 'NUMERIC', ...$opt_size_decimal }; }
	| FLOAT opt_size_float
		{ $$ = { type: 'FLOAT', ...$opt_size_float }; }
	| REAL opt_size_float
		{ $$ = { type: 'REAL', ...$opt_size_float }; }
	| BINARY opt_size
		{ $$ = { type: 'BINARY', ...$opt_size }; }
	| BIT opt_size
		{ $$ = { type: 'BIT', ...$opt_size }; }
	| BLOB opt_size
		{ $$ = { type: 'BLOB', ...$opt_size }; }
	| LONG VARBINARY opt_size
		{ $$ = { type: 'VARBINARY', long: true, ...$opt_size }; }
	| TIMESTAMPTZ opt_size
		{ $$ = { type: 'TIMESTAMPTZ', ...$opt_size }; }
	| TIMETZ opt_size
		{ $$ = { type: 'TIMETZ', ...$opt_size }; }
	| VARBINARY opt_size
		{ $$ = { type: 'VARBINARY', ...$opt_size }; }
	| ARRAY
		{ $$ = { type: 'ARRAY' }; }
	| BOOL
		{ $$ = { type: 'BOOL' }; }
	| BOOLEAN
		{ $$ = { type: 'BOOLEAN' }; }
	| DATE
		{ $$ = { type: 'DATE' }; }
	| LONGBLOB
		{ $$ = { type: 'LONGBLOB' }; }
	| MEDIUMBLOB
		{ $$ = { type: 'MEDIUMBLOB' }; }
	| OTHER
		{ $$ = { type: 'OTHER' }; }
	| TINYBLOB
		{ $$ = { type: 'TINYBLOB' }; }
	| UUID
		{ $$ = { type: 'UUID' }; }
	;

opt_collation
	: { $$ = {}; }
	| COLLATE NAME
		{ $$ = { collation: $2 }; }
	;

list_identifiers
	: list_identifiers COMMA identifier
		{ $$ = [ ...$list_identifiers, $identifier ]; }
	| identifier
		{ $$ = [$identifier]; }
	;

opt_identifier
	: { $$ = {}; }
	| identifier
		{ $$ = { identifier: $identifier }; }
	;

identifier
	: QUOTE_DOUBLE NAME QUOTE_DOUBLE
		{ $$ = $2; }
	| QUOTE_SINGLE_BENT NAME QUOTE_SINGLE_BENT
		{ $$ = $2; }
	| BRACKET_OPEN NAME BRACKET_CLOSE
		{ $$ = $2; }
	| NAME
		{ $$ = $1; }
	;

list_strings
	: list_strings COMMA string
		{ $$ = [ ...$list_strings, ...$string ]; }
	| string
		{ $$ = [$string]; }
	;

string
	: QUOTE_SINGLE CHARS QUOTE_SINGLE
		{ $$ = $2; }
	;

opt_size_decimal
	: { $$ = {}; }
	| size_decimal
	;

size_decimal
	: PAREN_OPEN STAR COMMA S_INT PAREN_CLOSE
		{ $$ = { size: $2, precision: $4 }; }
	| PAREN_OPEN STAR PAREN_CLOSE
		{ $$ = { size: $2 }; }
	| size_float
	;

opt_size_float
	: { $$ = {}; }
	| float
	;

size_float
	: PAREN_OPEN U_INT COMMA S_INT PAREN_CLOSE
		{ $$ = { size: $2, precision: $4 }; }
	| PAREN_OPEN U_INT COMMA U_INT PAREN_CLOSE
		{ $$ = { size: $2, precision: $4 }; }
	| PAREN_OPEN U_INT PAREN_CLOSE
		{ $$ = { size: $2 }; }
	;

opt_size_typed
	: { $$ = {}; }
	| PAREN_OPEN U_INT BYTE PAREN_CLOSE
		{ $$ = { size: $2, size_type: $3 }; }
	| PAREN_OPEN U_INT CHAR PAREN_CLOSE
		{ $$ = { size: $2, size_type: $3 }; }
	| size
	;

opt_size
	: { $$ = {}; }
	| size
	;

size
	: PAREN_OPEN U_INT PAREN_CLOSE
		{ $$ = { size: $2 }; }
	;

create_table
	: CREATE TEMP TABLE
		{ $$ = { type: `CREATE_TABLE`, temp: true }; }
	| CREATE TABLE
		{ $$ = { type: `CREATE_TABLE` }; }
	;

drop_table
	: DROP TEMP TABLE
		{ $$ = { type: `DROP_TABLE`, temp: true }; }
	| DROP TABLE
		{ $$ = { type: `DROP_TABLE` }; }
	;

opt_PRECISION
	: { $$ = {}; }
	| PRECISION
		{ $$ = { precision: true }; }
	;

opt_TIMEZONE
	: { $$ = {}; }
	| WITH TIME ZONE
		{ $$ = { timezone: true }; }
	| WITHOUT TIME ZONE
		{ $$ = { timezone: false }; }
	;

opt_UNSIGNED
	: { $$ = {}; }
	| UNSIGNED
		{ $$ = { unsigned: true }; }
	;
