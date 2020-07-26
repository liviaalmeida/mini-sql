/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                   	/* skip whitespace */
'COMMIT'								return 'COMMIT'
'ROLLBACK'							return 'ROLLBACK'
'*'											return 'STAR'
'CREATE'								return 'CREATE'
'TEMP'									return 'TEMP'
'TEMPORARY'							return 'TEMP'
'DROP'									return 'DROP'
'USE'										return 'USE'
'SCHEMA'								return 'SCHEMA'
'TABLE'									return 'TABLE'
'IF'										return 'IF'
'NOT'										return 'NOT'
'EXISTS'								return 'EXISTS'
'CONSTRAINT'						return 'CONSTRAINT'
'PRIMARY'								return 'PRIMARY'
'UNIQUE'								return 'UNIQUE'
'FOREIGN'								return 'FOREIGN'
'KEY'										return 'KEY'
'REFERENCES'						return 'REFERENCES'
'ASC'										return 'ASC'
'DESC'									return 'DESC'
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
	: createtable_statement
	| createschema_statement
	| droptable_statement
	| dropschema_statement
	| useschema_statement
	;

tcl_statement
	: commit_statement
	| rollback_statement
	;

createtable_statement
	: create_table NAME PAREN_OPEN table_constraints PAREN_CLOSE
		{ $$ = { name: $2, constraints: $table_constraints, ...$create_table }; }
	;

createschema_statement
	: create_schema NAME
		{ $$ = { name: $2, ...$create_schema }; }
	;

droptable_statement
	: drop_table NAME
		{ $$ = { name: $2, ...$drop_table }; }
	;

dropschema_statement
	: drop_schema NAME
		{ $$ = { name: $2, ...$drop_schema }; }
	;

useschema_statement
	: use_schema NAME
		{ $$ = { name: $2, ...$use_schema }; }
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
		{ $$ = { type: $1, enum: [ $string, $opt_commaString ], ...$opt_collation }; }
	| CHAR opt_size_typed opt_collation
		{ $$ = { type: $1, ...$opt_size_typed, ...$opt_collation }; }
	| CHARACTER opt_size_typed opt_collation
		{ $$ = { type: $1, ...$opt_size_typed, ...$opt_collation }; }
	| CHARACTER VARYING opt_size_typed opt_collation
		{ $$ = { type: $1, varying: true, ...$opt_size_typed, ...$opt_collation }; }
	| VARCHAR opt_size_typed opt_collation
		{ $$ = { type: $1, ...$opt_size_typed, ...$opt_collation }; }
	| VARCHAR2 opt_size_typed opt_collation
		{ $$ = { type: $1, ...$opt_size_typed, ...$opt_collation }; }
	| DOUBLE opt_PRECISION opt_size_float
		{ $$ = { type: $1, ...$opt_PRECISION, ...$opt_size_float }; }
	| CLOB opt_size opt_collation
		{ $$ = { type: $1, ...$opt_size, ...$opt_collation }; }
	| LONG NVARCHAR opt_size opt_collation
		{ $$ = { type: $2, long: true, ...$opt_size, ...$opt_collation }; }
	| LONG VARCHAR opt_size opt_collation
		{ $$ = { type: $2, long: true, ...$opt_size, ...$opt_collation }; }
	| NCHAR opt_size opt_collation
		{ $$ = { type: $1, ...$opt_size, ...$opt_collation }; }
	| NVARCHAR opt_size opt_collation
		{ $$ = { type: $1, ...$opt_size, ...$opt_collation }; }
	| TEXT opt_size opt_collation
		{ $$ = { type: $1, ...$opt_size, ...$opt_collation }; }
	| TIME opt_size opt_TIMEZONE
		{ $$ = { type: $1, ...$opt_size, ...$opt_TIMEZONE }; }
	| INT opt_size opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_size, ...$opt_UNSIGNED }; }
	| INTEGER opt_size opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_size, ...$opt_UNSIGNED }; }
	| MEDIUMINT opt_size opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_size, ...$opt_UNSIGNED }; }
	| SMALLINT opt_size opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_size, ...$opt_UNSIGNED }; }
	| TINYINT opt_size opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_size, ...$opt_UNSIGNED }; }
	| BIGINT opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_UNSIGNED }; }
	| LONGTEXT opt_collation
		{ $$ = { type: $1, ...$opt_collation }; }
	| MEDIUMTEXT opt_collation
		{ $$ = { type: $1, ...$opt_collation }; }
	| NCLOB opt_collation
		{ $$ = { type: $1, ...$opt_collation }; }
	| TINYTEXT opt_collation
		{ $$ = { type: $1, ...$opt_collation }; }
	| DECIMAL opt_size_decimal
		{ $$ = { type: $1, ...$opt_size_decimal }; }
	| NUMBER opt_size_decimal
		{ $$ = { type: $1, ...$opt_size_decimal }; }
	| NUMERIC opt_size_decimal
		{ $$ = { type: $1, ...$opt_size_decimal }; }
	| FLOAT opt_size_float
		{ $$ = { type: $1, ...$opt_size_float }; }
	| REAL opt_size_float
		{ $$ = { type: $1, ...$opt_size_float }; }
	| BINARY opt_size
		{ $$ = { type: $1, ...$opt_size }; }
	| BIT opt_size
		{ $$ = { type: $1, ...$opt_size }; }
	| BLOB opt_size
		{ $$ = { type: $1, ...$opt_size }; }
	| LONG VARBINARY opt_size
		{ $$ = { type: $2, long: true, ...$opt_size }; }
	| TIMESTAMPTZ opt_size
		{ $$ = { type: $1, ...$opt_size }; }
	| TIMETZ opt_size
		{ $$ = { type: $1, ...$opt_size }; }
	| VARBINARY opt_size
		{ $$ = { type: $1, ...$opt_size }; }
	| ARRAY
		{ $$ = { type: $1 }; }
	| BOOL
		{ $$ = { type: $1 }; }
	| BOOLEAN
		{ $$ = { type: $1 }; }
	| DATE
		{ $$ = { type: $1 }; }
	| LONGBLOB
		{ $$ = { type: $1 }; }
	| MEDIUMBLOB
		{ $$ = { type: $1 }; }
	| OTHER
		{ $$ = { type: $1 }; }
	| TINYBLOB
		{ $$ = { type: $1 }; }
	| UUID
		{ $$ = { type: $1 }; }
	;

opt_collation
	: { $$ = {}; }
	| COLLATE NAME
		{ $$ = { collation: $2 }; }
	;

opt_commaString
	: { $$ = ''; }
	| COMMA string
		{ $$ = $string; }
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

create_schema
	: CREATE SCHEMA
		{ $$ = { type: `CREATE_SCHEMA` }; }
	;

drop_table
	: DROP TEMP TABLE
		{ $$ = { type: `DROP_TABLE`, temp: true }; }
	| DROP TABLE
		{ $$ = { type: `DROP_TABLE` }; }
	;

drop_schema
	: DROP SCHEMA
		{ $$ = { type: `DROP_SCHEMA` }; }
	;

use_schema
	: USE
		{ $$ = { type: 'USE' }; }
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
