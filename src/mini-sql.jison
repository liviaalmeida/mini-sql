%lex

%options case-insensitive

%%

\'(\\\'|.)*?\'					return 'STRING_LITERAL'
\s+                   	/* skip whitespace */
'*'											return 'STAR'
'TEMP'									return 'TEMP'
'TEMPORARY'							return 'TEMP'
'ADD'										return 'ADD'
'ALTER'									return 'ALTER'
'COMMIT'								return 'COMMIT'
'CREATE'								return 'CREATE'
'DROP'									return 'DROP'
'INSERT'								return 'INSERT'
'MODIFY'								return 'MODIFY'
'RENAME'								return 'RENAME'
'ROLLBACK'							return 'ROLLBACK'
'SELECT'								return 'SELECT'
'USE'										return 'USE'
'TO'										return 'TO'
'AS'										return 'AS'
'COLUMN'								return 'COLUMN'
'DATA'									return 'DATA'
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
'NULLS'									return 'NULLS'
'AUTO_INCREMENT'				return 'AUTO_INCREMENT'
'AUTOINCREMENT'					return 'AUTO_INCREMENT'
'b\''										return 'BINARY_OPEN'
'['											return 'BRACKET_OPEN'
']'											return 'BRACKET_CLOSE'
'('											return 'PAREN_OPEN'
')'											return 'PAREN_CLOSE'
'"'											return 'QUOTE_DOUBLE'
'\''										return 'QUOTE_SINGLE'
'`'											return 'QUOTE_SINGLE_BENT'
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
'COLLATE'								return 'COLLATE'
'AFTER'									return 'AFTER'
'ALL'										return 'ALL'
'AND'										return 'AND'
'ANY'										return 'ANY'
'ASC'										return 'ASC'
'BEFORE'								return 'BEFORE'
'BY'										return 'BY'
'DEFAULT'								return 'DEFAULT'
'DESC'									return 'DESC'
'DISTINCT'							return 'DISTINCT'
'EXCEPT'								return 'EXCEPT'
'EXISTS'								return 'EXISTS'
'FIRST'									return 'FIRST'
'FROM'									return 'FROM'
'INTERSECT'							return 'INTERSECT'
'IN'										return 'IN'
'INTO'									return 'INTO'
'IS'										return 'IS'
'LAST'									return 'LAST'
'MINUS'									return 'MINUS'
'NOT'										return 'NOT'
'OR'										return 'OR'
'ORDER'									return 'ORDER'
'SOME'									return 'SOME'
'UNION'									return 'UNION'
'VALUES'								return 'VALUES'
'WHERE'									return 'WHERE'
'WITH'									return 'WITH'
'WITHOUT'								return 'WITHOUT'
'ZONE'									return 'ZONE'
[a-zA-Z_][a-zA-Z0-9_]* 	return 'NAME'
\-\d+\.\d+							return 'S_REAL'
\d+\.\d+								return 'U_REAL'
\d+											return 'U_INT'
\-\d+										return 'S_INT'
','											return 'COMMA'
'.'											return 'DOT'
';'         			     	return 'EOS'
<<EOF>>      			     	return 'EOF'
.*											return 'CHARS'


/lex

%start sql

%%

sql
  : statements EOF
    { return $1; }
  ;

statements
  : statements statement
    { $$ = [ ...$statements, $statement ]; }
  | statement
    { $$ = [{ statement: yy.lexer.matched, ...$statement }]; }
  ;

statement
  : ddl_statement EOS
    { $$ = $ddl_statement; }
  | dml_statement EOS
    { $$ = $dml_statement; }
  | tcl_statement EOS
    { $$ = $tcl_statement; }
  ;

ddl_statement
  : altertable_statement
  | alterschema_statement
  | createtable_statement
  | createschema_statement
  | droptable_statement
  | dropschema_statement
  | useschema_statement
  ;

dml_statement
  : select_statement
  | insert_statement
  ;

tcl_statement
  : commit_statement
  | rollback_statement
  ;

altertable_statement
  : ALTER TABLE name table_alteration
    { $$ = { alteration: $table_alteration, name: $name, type: 'ALTER_TABLE' }; }
  ;

alterschema_statement
  : ALTER SCHEMA name RENAME TO name
    { $$ = { name: $6, old_name: $3, type: 'ALTER_SCHEMA' }; }
  | ALTER SCHEMA name RENAME AS name
    { $$ = { name: $6, old_name: $3, type: 'ALTER_SCHEMA' }; }
  ;

createtable_statement
  : create_table name PAREN_OPEN table_constraints PAREN_CLOSE
    { $$ = { name: $name, constraints: $table_constraints, ...$create_table }; }
  ;

createschema_statement
  : CREATE SCHEMA name
    { $$ = { name: $name, type: 'CREATE_SCHEMA' }; }
  ;

droptable_statement
  : drop_table name
    { $$ = { name: $name, ...$drop_table }; }
  ;

dropschema_statement
  : DROP SCHEMA name
    { $$ = { name: $name, type: 'DROP_SCHEMA' }; }
  ;

useschema_statement
  : USE name
    { $$ = { name: $name, type: 'USE' }; }
  ;

select_statement
  : opt_with query opt_order_by
    { $$ = { query: $query, type: 'SELECT', ...$opt_with, ...$opt_order_by }; }
  | values
    { $$ = { values: $values, type: 'SELECT' }; }
  ;

insert_statement
  : opt_with INSERT opt_INTO insert_reference values
    { $$ = { reference: $insert_reference, values: $values, type: 'INSERT', ...$opt_with }; }
  | opt_with INSERT opt_INTO insert_reference DEFAULT VALUES
    { $$ = { reference: $insert_reference, default: true, type: 'INSERT', ...$opt_with }; }
  | opt_with INSERT opt_INTO insert_reference insert_select
    { $$ = { reference: $insert_reference, default: true, type: 'INSERT', ...$opt_with }; }
  ;

commit_statement
  : COMMIT
    { $$ = { type: 'COMMIT' }; }
  ;

rollback_statement
  : ROLLBACK
    { $$ = { type: 'ROLLBACK' }; }
  ;

table_alteration
  : ADD CONSTRAINT opt_identifier constraint
    { $$ = { constraint: $constraint, type: 'ADD', ...$opt_identifier }; }
  | ADD constraint
    { $$ = { constraint: $constraint, type: 'ADD' }; }
  | ADD COLUMN column opt_column_placement
    { $$ = { column: $column, type: 'ADD', ...$opt_column_placement }; }
  | ADD PAREN_OPEN table_constraints PAREN_CLOSE
    { $$ = { constraints: $table_constraints, type: 'ADD' }; }
  | ALTER COLUMN identifier column_alteration
    { $$ = { alteration: $column_alteration, type: 'ALTER', ...$identifier }; }
  | ALTER identifier column_alteration
    { $$ = { alteration: $column_alteration, type: 'ALTER', ...$identifier }; }
  | ALTER column
    { $$ = { column: $column, type: 'ALTER' }; }
  | ALTER PAREN_OPEN column PAREN_CLOSE
    { $$ = { column: $column, type: 'ALTER' }; }
  | ALTER CONSTRAINT identifier
    { $$ = { constraint: $identifier, type: 'ALTER' }; }
  | MODIFY COLUMN identifier column_alteration
    { $$ = { alteration: $column_alteration, type: 'MODIFY' }; }
  | MODIFY identifier column_alteration
    { $$ = { alteration: $column_alteration, type: 'MODIFY' }; }
  | MODIFY column
    { $$ = { column: $column, type: 'MODIFY' }; }
  | MODIFY PAREN_OPEN column PAREN_CLOSE
    { $$ = { column: $column, type: 'MODIFY' }; }
  | MODIFY CONSTRAINT identifier
    { $$ = { constraint: $identifier, type: 'MODIFY' }; }
  | RENAME COLUMN identifier TO identifier
    { $$ = { column: { old_name: $3, name: $5 }, type: 'RENAME' }; }
  | RENAME COLUMN identifier AS identifier
    { $$ = { column: { old_name: $3, name: $5 }, type: 'RENAME' }; }
  | RENAME CONSTRAINT identifier TO identifier
    { $$ = { constraint: { old_name: $3, name: $5 }, type: 'RENAME' }; }
  | RENAME CONSTRAINT identifier AS identifier
    { $$ = { constraint: { old_name: $3, name: $5 }, type: 'RENAME' }; }
  | RENAME TO identifier
    { $$ = { name: $identifier, type: 'RENAME' }; }
  | DROP COLUMN identifier
    { $$ = { column: $identifier, type: 'DROP' }; }
  | DROP identifier
    { $$ = { column: $identifier, type: 'DROP' }; }
  | DROP UNIQUE identifier
    { $$ = { unique: $identifier, type: 'DROP' }; }
  | DROP FOREIGN KEY identifier
    { $$ = { foreign: $identifier, type: 'DROP' }; }
  | DROP PRIMARY KEY identifier
    { $$ = { primary: $identifier, type: 'DROP' }; }
  | DROP PRIMARY KEY
    { $$ = { primary: true, type: 'DROP' }; }
  | DROP CONSTRAINT identifier
    { $$ = { constraint: $identifier, type: 'DROP' }; }
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
  : PRIMARY KEY PAREN_OPEN list_names PAREN_CLOSE
    { $$ = { primary: $list_names }; }
  | FOREIGN KEY PAREN_OPEN list_names PAREN_CLOSE REFERENCES foreign_reference
    { $$ = { foreign: { keys: $list_names, ...$foreign_reference } }; }
  | UNIQUE PAREN_OPEN list_names PAREN_CLOSE
    { $$ = { unique: $list_names }; }
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
  | DEFAULT term
    { $$ = { default: $term }; }
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
  | UNIQUE
    { $$ = { unique: true }; }
  | REFERENCES foreign_reference
    { $$ = { foreign: $foreign_reference }; }
  ;

opt_column_placement
  : { $$ = {}; }
  | FIRST
    { $$ = { first: true }; }
  | BEFORE identifier
    { $$ = { before: $identifier }; }
  | AFTER identifier
    { $$ = { after: $identifier }; }
  ;

column_alteration
  : SET DATA TYPE datatype NOT NULL
    { $$ = { constraints: { never_null: true }, ...$datatype }; }
  | SET DATA TYPE datatype NULL
    { $$ = { constraints: { null_allowed: true }, ...$datatype }; }
  | SET DATA TYPE datatype
    { $$ = { ...$datatype }; }
  | SET NOT NULL
    { $$ = { constraints: { never_null: true } }; }
  | SET NULL
    { $$ = { constraints: { null_allowed: true } }; }
  | NULL
    { $$ = { constraints: { null_allowed: true } }; }
  | TYPE datatype NOT NULL
    { $$ = { constraints: { never_null: true }, ...$datatype }; }
  | TYPE datatype NULL
    { $$ = { constraints: { null_allowed: true }, ...$datatype }; }
  | TYPE datatype
    { $$ = { ...$datatype }; }
  | RENAME AS identifier
    { $$ = { rename: $identifier }; }
  | RENAME TO identifier
    { $$ = { rename: $identifier }; }
  | DROP NOT NULL
    { $$ = { constraints: { null_allowed: true } }; }
  ;

foreign_reference
  : name PAREN_OPEN list_names PAREN_CLOSE
    { $$ = { table: $name, identifiers: $list_names }; }
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
  | COLLATE name
    { $$ = { collation: $name }; }
  ;

opt_with
  : { $$ = {}; }
  | WITH RECURSIVE list_identifiers_as
    { $$ = { with: [ ...$list_identifiers_as ], recursive: true }; }
  | WITH list_identifiers_as
    { $$ = { with: [ ...$list_identifiers_as ] }; }
  ;

query
  : query_term opt_query_ops
    { $$ = { ...$query_term, ...$opt_query_ops }; }
  ;

opt_order_by
  : { $$ = {}; }
  | ORDER BY list_sort_fields
    { $$ = { order_by: $list_sort_fields }; }
  ;

insert_reference
  : PAREN_OPEN select_statement PAREN_CLOSE opt_as_identifier opt_enclosed_list_identifiers
    { $$ = { select: $select_statement, ...$opt_as_identifier, ...$opt_enclosed_list_identifiers }; }
  | name opt_as_identifier opt_enclosed_list_identifiers
    { $$ = { name: $name, ...$opt_as_identifier, ...$opt_enclosed_list_identifiers }; }
  ;

insert_select
  : opt_with SELECT select_list opt_select_condition opt_query_intersects opt_query_ops opt_order_by
    { $$ = { list: $select_list, ...$opt_select_condition, ...$opt_query_intersects,
    ...$opt_query_ops, ...$opt_order_by }; }
  ;

values
  : VALUES enclosed_fields_list
    { $$ = [ ...$enclosed_fields_list ]; }
  ;

list_identifiers_as
  : list_identifiers_as COMMA identifier_as
    { $$ = [ ...$list_identifiers_as, $identifier_as ]; }
  | identifier_as
    { $$ = [$identifier_as]; }
  ;

identifier_as
  : identifier PAREN_OPEN list_identifiers PAREN_CLOSE AS PAREN_OPEN select_statement PAREN_CLOSE
    { $$ = { name: $identifier, as: $select_statement, columns: $list_identifiers }; }
  | identifier AS PAREN_OPEN select_statement PAREN_CLOSE
    { $$ = { name: $identifier, as: $select_statement }; }
  ;

query_term
  : query_select opt_query_intersects
    { $$ = { select: $query_select, ...$opt_query_intersects }; }
  ;

opt_query_ops
  :	{ $$ = {}; }
  | query_ops
    { $$ = { ops: $query_ops }; }
  ;

query_ops
  :	query_ops query_op
    { $$ = [ ...$query_ops, $query_op ]; }
  | query_op
    { $$ = [$query_op]; }
  ;

query_op
  : EXCEPT opt_ALL_or_DISTINCT query_term
    { $$ = { except: $query_term, ...$opt_ALL_or_DISTINCT }; }
  | MINUS opt_ALL_or_DISTINCT query_term
    { $$ = { minus: $query_term, ...$opt_ALL_or_DISTINCT }; }
  | UNION opt_ALL_or_DISTINCT query_term
    { $$ = { union: $query_term, ...$opt_ALL_or_DISTINCT }; }
  ;

list_sort_fields
  : list_sort_fields COMMA sort_field
    { $$ = [ ...$list_sort_fields, $sort_field]; }
  | sort_field
    { $$ = [$sort_field]; }
  ;

sort_field
  : field ASC NULLS FIRST
    { $$ = { field: $field, asc: true, nulls_first: true }; }
  | field ASC NULLS LAST
    { $$ = { field: $field, asc: true, nulls_last: true }; }
  | field ASC
    { $$ = { field: $field, asc: true }; }
  | field DESC NULLS FIRST
    { $$ = { field: $field, desc: true, nulls_first: true }; }
  | field DESC NULLS LAST
    { $$ = { field: $field, desc: true, nulls_last: true }; }
  | field DESC
    { $$ = { field: $field, desc: true }; }
  | field
    { $$ = { field: $field }; }
  ;

enclosed_fields_list
  : enclosed_fields_list COMMA PAREN_OPEN fields_list PAREN_CLOSE
    { $$ = [ ...$enclosed_fields_list, $fields_list ]; }
  | PAREN_OPEN fields_list PAREN_CLOSE
    { $$ = [$fields_list]; }
  ;

query_select
  : PAREN_OPEN select_statement PAREN_CLOSE
    { $$ = { select: $select_statement }; }
  | SELECT select_list opt_select_condition
    { $$ = { list: $select_list, ...$opt_select_condition }; }
  ;

opt_query_intersects
  :	{ $$ = {}; }
  | query_intersects
    { $$ = { intersects: $query_intersects }; }
  ;

query_intersects
  :	query_intersects query_intersect
    { $$ = [ ...$query_intersects, $query_intersect ]; }
  |	query_intersect
    { $$ = [$query_intersect]; }
  ;

query_intersect
  :	INTERSECT opt_ALL_or_DISTINCT query_select
    { $$ = { intersect: $query_select, ...$opt_ALL_or_DISTINCT }; }
  ;

select_list
  : select_list COMMA select_field
    { $$ = [ ...$select_list, $select_field ]; }
  | select_field
    { $$ = [$select_field]; }
  ;

opt_select_condition
  : { $$ = {}; }
  | select_condition
    { $$ = { ...$select_condition }; }
  ;

select_condition
  : FROM name WHERE field
    { $$ = { from: $name, where: $field }; }
  | FROM name
    { $$ = { from: $name }; }
  | WHERE field
    { $$ = { where: $field }; }
  ;

select_field
  : STAR
    { $$ = { star: true }; }
  | name DOT STAR
    { $$ = { star: true, from: $name }; }
  | field opt_as_identifier
    { $$ = { field: $field, ...$opt_as_identifier }; }
  ;

fields_list
  : fields_list COMMA field
    { $$ = [ ...$fields_list, $field]; }
  | field
    { $$ = [$field]; }
  ;

field
  : or
    { $$ = { ...$or }; }
  | term
  ;

term
  : name
  | string
  | binary
  | S_INT
  | U_INT
  | S_REAL
  | U_REAL
  | NULL
  ;

or
  : or OR and
    { $$ = { or: [ $or, $and ] }; }
  | and
    { $$ = { ...$and }; }
  ;

and
  : and AND not
    { $$ = { and: [ $and, $not ] }; }
  | not
    { $$ = { ...$not }; }
  ;

not
  : opt_NOT predicate
    { $$ = { ...$predicate, ...$opt_NOT }; }
  ;

predicate
  : EXISTS PAREN_OPEN select_statement PAREN_CLOSE
    { $$ = { exists: $select_statement }; }
  | UNIQUE PAREN_OPEN select_statement PAREN_CLOSE
    { $$ = { unique: $select_statement }; }
  ;

list_names
  : list_names COMMA name
    { $$ = [ ...$list_names, $name ]; }
  | name
    { $$ = [$name]; }
  ;

name
  : name DOT identifier
    { $$ = `${$name}.${$identifier}`; }
  | identifier
    { $$ = $identifier; }
  ;

opt_as_identifier
  : { $$ = {}; }
  | AS identifier
    { $$ = { as: $identifier }; }
  | identifier
    { $$ = { as: $identifier }; }
  ;

opt_enclosed_list_identifiers
  : { $$ = {}; }
  | PAREN_OPEN list_identifiers PAREN_CLOSE
    { $$ = { identifiers: $list_identifiers }; }
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
  : STRING_LITERAL
    { $$ = $1; }
  ;

binary
  : BINARY_OPEN U_INT QUOTE_SINGLE
    { $$ = `${$2}`; }
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

opt_ALL_or_DISTINCT
  : { $$ = {}; }
  | ALL
    { $$ = { all: true }; }
  | DISTINCT
    { $$ = { distinct: true }; }
  ;

opt_INTO
  : { $$ = {}; }
  | INTO
    { $$ = {}; }
  ;

opt_NOT
  : { $$ = {}; }
  | NOT
    { $$ = { not: true }; }
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
