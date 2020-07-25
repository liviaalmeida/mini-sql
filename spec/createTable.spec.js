describe("CREATE TABLE command should return a command ", () => {
	test('create table my_new_table', () => {
		const { statement } = singleCommand('CREATE TABLE my_new_table (ID INT NOT NULL);')

		expect(statement.type).toEqual('CREATE_TABLE')
		expect(statement.name).toEqual('my_new_table')
	})

	test('create temporary table my_new_table', () => {
		const { statement } = singleCommand('CREATE TEMP TABLE my_new_table (ID INT NOT NULL);')

		expect(statement.type).toEqual('CREATE_TABLE')
		expect(statement.name).toEqual('my_new_table')
		expect(statement.temp).toEqual(true)
	})

	test('create table CUSTOMERS with expected data types', () => {
		const { statement } = singleCommand('CREATE TABLE CUSTOMERS(ID INT NOT NULL, NAME VARCHAR (20) NOT NULL, AGE INT NOT NULL, ADDRESS CHAR (25), SALARY DECIMAL (18, 2), PRIMARY KEY (ID));')

		expect(statement.type).toEqual('CREATE_TABLE')
		expect(statement.name).toEqual('CUSTOMERS')
	})
})
