/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                   	/* skip whitespace */
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
	;

ddl_statement
	: createschema_statement
	| createtable_statement
	| dropschema_statement
	| useschema_statement
	;

createschema_statement
	: create_schema NAME
		{ $$ = { name: $2, ...$create_schema }; }
	;

createtable_statement
	: create_table NAME PAREN_OPEN table_constraints PAREN_CLOSE
		{ $$ = { name: $2, constraints: $table_constraints, ...$create_table }; }
	;

useschema_statement
	: use_schema NAME
		{ $$ = { name: $2, ...$use_schema }; }
	;

dropschema_statement
	: drop_schema NAME
		{ $$ = { name: $2, ...$drop_schema }; }
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
		{ $$ = { name: $identifier, datatype: $datatype, constraints: $column_complements }; }
	| identifier datatype
		{ $$ = { name: $identifier, datatype: $datatype }; }
	;

column_complements
	: column_complements column_complement
		{ $$ = [ ...$column_complements, ...$column_complement ]; }
	| column_complement
		{ $$ = [$column_complement]; }
	;

column_complement
	: CONSTRAINT opt_identifier column_constraint
		{ $$ = { constraint: $column_constraint, ...$opt_identifier }; }
	| column_constraint
		{ $$ = { constraint: $column_constraint }; }
	| NOT NULL
		{ $$ = { null_allowed: false }; }
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
	: ENUM PAREN_OPEN string opt_commaString PAREN_CLOSE opt_collation
		{ $$ = { type: $1, enum: [ $string, $opt_commaString ], ...$opt_collation }; }
	| CHAR opt_uintTyped opt_collation
		{ $$ = { type: $1, ...$opt_uintTyped, ...$opt_collation }; }
	| CHARACTER opt_uintTyped opt_collation
		{ $$ = { type: $1, ...$opt_uintTyped, ...$opt_collation }; }
	| CHARACTER VARYING opt_uintTyped opt_collation
		{ $$ = { type: $1, varying: true, ...$opt_uintTyped, ...$opt_collation }; }
	| VARCHAR opt_uintTyped opt_collation
		{ $$ = { type: $1, ...$opt_uintTyped, ...$opt_collation }; }
	| VARCHAR2 opt_uintTyped opt_collation
		{ $$ = { type: $1, ...$opt_uintTyped, ...$opt_collation }; }
	| DOUBLE opt_PRECISION opt_float
		{ $$ = { type: $1, ...$opt_PRECISION, ...$opt_float }; }
	| CLOB opt_uint opt_collation
		{ $$ = { type: $1, ...$opt_uint, ...$opt_collation }; }
	| LONG NVARCHAR opt_uint opt_collation
		{ $$ = { type: $2, long: true, ...$opt_uint, ...$opt_collation }; }
	| LONG VARCHAR opt_uint opt_collation
		{ $$ = { type: $2, long: true, ...$opt_uint, ...$opt_collation }; }
	| NCHAR opt_uint opt_collation
		{ $$ = { type: $1, ...$opt_uint, ...$opt_collation }; }
	| NVARCHAR opt_uint opt_collation
		{ $$ = { type: $1, ...$opt_uint, ...$opt_collation }; }
	| TEXT opt_uint opt_collation
		{ $$ = { type: $1, ...$opt_uint, ...$opt_collation }; }
	| TIME opt_uint opt_TIMEZONE
		{ $$ = { type: $1, ...$opt_uint, ...$opt_TIMEZONE }; }
	| INT opt_uint opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_uint, ...$opt_UNSIGNED }; }
	| INTEGER opt_uint opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_uint, ...$opt_UNSIGNED }; }
	| MEDIUMINT opt_uint opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_uint, ...$opt_UNSIGNED }; }
	| SMALLINT opt_uint opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_uint, ...$opt_UNSIGNED }; }
	| TINYINT opt_uint opt_UNSIGNED
		{ $$ = { type: $1, ...$opt_uint, ...$opt_UNSIGNED }; }
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
	| DECIMAL opt_decimal
		{ $$ = { type: $1, ...$opt_decimal }; }
	| NUMBER opt_decimal
		{ $$ = { type: $1, ...$opt_decimal }; }
	| NUMERIC opt_decimal
		{ $$ = { type: $1, ...$opt_decimal }; }
	| FLOAT opt_float
		{ $$ = { type: $1, ...$opt_float }; }
	| REAL opt_float
		{ $$ = { type: $1, ...$opt_float }; }
	| BINARY opt_uint
		{ $$ = { type: $1, ...$opt_uint }; }
	| BIT opt_uint
		{ $$ = { type: $1, ...$opt_uint }; }
	| BLOB opt_uint
		{ $$ = { type: $1, ...$opt_uint }; }
	| LONG VARBINARY opt_uint
		{ $$ = { type: $2, long: true, ...$opt_uint }; }
	| TIMESTAMPTZ opt_uint
		{ $$ = { type: $1, ...$opt_uint }; }
	| TIMETZ opt_uint
		{ $$ = { type: $1, ...$opt_uint }; }
	| VARBINARY opt_uint
		{ $$ = { type: $1, ...$opt_uint }; }
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

opt_decimal
	: { $$ = {}; }
	| decimal
	;

decimal
	: PAREN_OPEN STAR COMMA S_INT PAREN_CLOSE
		{ $$ = { value: `${$2},${$4}` }; }
	| PAREN_OPEN STAR PAREN_CLOSE
		{ $$ = { value: `${$2}` }; }
	| float
	;

opt_float
	: { $$ = {}; }
	| float
	;

float
	: PAREN_OPEN U_INT COMMA S_INT PAREN_CLOSE
		{ $$ = { value: `${$2},${$4}` }; }
	| PAREN_OPEN U_INT COMMA U_INT PAREN_CLOSE
		{ $$ = { value: `${$2},${$4}` }; }
	| PAREN_OPEN U_INT PAREN_CLOSE
		{ $$ = { value: `${$2}` }; }
	;

list_identifiers
	: list_identifiers COMMA identifier
		{ $$ = [ ...$list_identifiers, ...$identifier ]; }
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

string
	: QUOTE_SINGLE CHARS QUOTE_SINGLE
		{ $$ = $2; }
	;

opt_uintTyped
	: { $$ = {}; }
	| PAREN_OPEN U_INT BYTE PAREN_CLOSE
		{ $$ = { value: $2, value_type: $3 }; }
	| PAREN_OPEN U_INT CHAR PAREN_CLOSE
		{ $$ = { value: $2, value_type: $3 }; }
	| uint
	;

opt_uint
	: { $$ = {}; }
	| uint
	;

uint
	: PAREN_OPEN U_INT PAREN_CLOSE
		{ $$ = { value: $2 }; }
	;

create_schema
	: CREATE SCHEMA
		{ $$ = { type: `${$1}_${$2}` }; }
	;

create_table
	: CREATE TEMP TABLE
		{ $$ = { type: `${$1}_${$3}`, temp: true }; }
	| CREATE TABLE
		{ $$ = { type: `${$1}_${$2}` }; }
	;

drop_schema
	: DROP SCHEMA
		{ $$ = { type: `${$1}_${$2}` }; }
	;

use_schema
	: USE
		{ $$ = { type: $1 }; }
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
