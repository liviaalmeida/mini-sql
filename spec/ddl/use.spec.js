describe("USE command should return a command ", () => {
	test('use schema my_new_schema', () => {
		const statement = singleCommand('USE my_new_schema;')

		expect(statement.type).toEqual('USE')
		expect(statement.name).toEqual('my_new_schema')
	})
})
