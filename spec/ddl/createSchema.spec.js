describe("CREATE SCHEMA command should return a command ", () => {
	test('create schema for my_new_schema', () => {
		const { statement } = singleCommand('CREATE SCHEMA my_new_schema;')

		expect(statement.type).toEqual('CREATE_SCHEMA')
		expect(statement.name).toEqual('my_new_schema')
	})
})
