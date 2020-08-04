const tables = {
	'my_new_table': {
		command: 'CREATE TABLE my_new_table (ID INT NOT NULL);',
		result: {
			constraints: [
				{
					column: {
						constraints: { never_null: true },
						name: 'ID', type: 'INT'
					}
				}
			],
			name: 'my_new_table', type: 'CREATE_TABLE'
		}
	},
	'some__table': {
		command: 'CREATE TEMP TABLE some_temp_table(ID INT NOT NULL PRIMARY KEY,\
			NAME VARCHAR (20) NOT NULL,\
			YEAR SMALLINT NOT NULL,\
			DESCRIPTION CHAR (50),\
			INVESTMENT DECIMAL (12, 2),\
			PRIMARY KEY (ID, NAME));',
		result: {
			constraints: [
				{
					column: {
						constraints: { never_null: true, primary: true },
						name: 'ID', type: 'INT'
					}
				},
				{
					column: {
						constraints: { never_null: true },
						name: 'NAME', type: 'VARCHAR', size: '20'
					}
				},
				{
					column: {
						constraints: { never_null: true },
						name: 'YEAR', type: 'SMALLINT'
					}
				},
				{
					column: {
						name: 'DESCRIPTION', size: '50', type: 'CHAR'
					}
				},
				{
					column: {
						name: 'INVESTMENT', precision: '2', size: '12', type: 'DECIMAL'
					}
				},
				{
					constraint: { primary: [ 'ID', 'NAME' ] }
				}
			],
			name: 'some_temp_table', temp: true, type: 'CREATE_TABLE'
		}
	},
	'the_temporary_table': {
		command: 'CREATE TEMP TABLE the_temporary_table (ID INT);',
		result: {
			constraints: [
				{
					column: {
						name: 'ID', type: 'INT'
					}
				}
			],
			name: 'the_temporary_table', temp: true, type: 'CREATE_TABLE'
		}
	},
	'CUSTOMERS': {
		command: 'CREATE TABLE CUSTOMERS(ID INT NOT NULL,\
			NAME VARCHAR (20) UNIQUE KEY,\
			AGE INT NOT NULL,\
			ADDRESS CHAR (25),\
			SALARY DECIMAL (18, 2),\
			PRIMARY KEY (ID));',
		result: {
			constraints: [
				{
					column: {
						constraints: { never_null: true },
						name: 'ID', type: 'INT'
					}
				},
				{
					column: {
						constraints: { unique: true },
						name: 'NAME', size: '20', type: 'VARCHAR'
					}
				},
				{
					column: {
						constraints: { never_null: true },
						name: 'AGE', type: 'INT'
					}
				},
				{
					column: {
						name: 'ADDRESS', size: '25', type: 'CHAR'
					}
				},
				{
					column: {
						name: 'SALARY', precision: '2', size: '18', type: 'DECIMAL'
					}
				},
				{
					constraint: { primary: [ 'ID' ] }
				}
			],
			name: 'CUSTOMERS', type: 'CREATE_TABLE'
		}
	}
}

describe("CREATE TABLE command should return a command ", () => {
	test('create table my_new_table', () => {
		const { command, result } = tables['my_new_table']
		const { statement } = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('create temporary table the_temporary_table', () => {
		const { command, result } = tables['the_temporary_table']
		const { statement } = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('create table CUSTOMERS with expected data types', () => {
		const { command, result } = tables['CUSTOMERS']
		const { statement } = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('create temporary some__table with expected data types', () => {
		const { command, result } = tables['some__table']
		const { statement } = singleCommand(command)

		expect(statement).toMatchObject(result)

	})
	
})
