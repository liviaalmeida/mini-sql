describe("ALTER SCHEMA command should return a command ", () => {
	test('to alter schema old_schema to new_schema', () => {
		const { statement } = singleCommand('ALTER SCHEMA old_schema RENAME TO new_schema;')

		expect(statement.type).toEqual('ALTER_SCHEMA')
		expect(statement.name).toEqual('new_schema')
    })
    
    test('to alter schema old_schema as new_schema', () => {
		const { statement } = singleCommand('ALTER SCHEMA old_schema RENAME AS new_schema;')

		expect(statement.type).toEqual('ALTER_SCHEMA')
		expect(statement.name).toEqual('new_schema')
	})
})
