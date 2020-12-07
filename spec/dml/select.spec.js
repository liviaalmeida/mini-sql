const tables = {
	'users': {
		command: 'SELECT * FROM users;',
		result: {
			query: {
				term: {
					select: {
						list: [ { star: true } ],
						from: 'users'
					}
				}
			},
			type: 'SELECT'
		}
	}
}

describe("SELECT command should return a command ", () => {
	test('select all from table users', () => {
		const { command, result } = tables['users']
		const statement = singleCommand(command)

		expect(statement.type).toEqual(result.type)
		expect(statement.query).toMatchObject(result.query)
	})
})
