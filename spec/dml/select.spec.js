const tables = {
	'posters': {
		command: 'select * from posters where exists (select id from commenters);',
		result: {
			query: {
				select: {
					list: [
						{ star: true }
					],
					from: 'posters',
					where: {
						exists: {
							query: {
								select: {
									list: [
										{ field: 'id' }
									],
									from: 'commenters'
								}
							},
							type: 'SELECT'
						}
					}
				}
			},
			type: 'SELECT'
		}
	},
	'product': {
		command: 'SELECT Name, ProductNumber, ListPrice AS Price FROM Production.Product ORDER BY Name ASC;',
		result: {
			query: { 
				select: {
					list: [
						{ field: 'Name' },
						{ field: 'ProductNumber' },
						{ field: 'ListPrice', as: 'Price' }
					],
					from: 'Production.Product'
				}
			},
			type: 'SELECT',
			order_by: [
				{ field: 'Name', asc: true }
			]
		}
	},
	'users': {
		command: 'SELECT * FROM users;',
		result: {
			query: {
				select: {
					list: [ { star: true } ],
					from: 'users'
				}
			},
			type: 'SELECT'
		}
	}
}

describe('SELECT command should return a command ', () => {
	test('select all columns from table users', () => {
		const { command, result } = tables['users']
		const statement = singleCommand(command)

		expect(statement.type).toEqual(result.type)
		expect(statement.query).toMatchObject(result.query)
	})

	test('select some columns from a table of products', () => {
		const { command, result } = tables['product']
		const statement = singleCommand(command)

		expect(statement.type).toEqual(result.type)
		expect(statement.query).toMatchObject(result.query)
	})

	test('select all columns from a table of posters if they are in table of commenters', () => {
		const { command, result } = tables['posters']
		const statement = singleCommand(command)

		expect(statement.type).toEqual(result.type)
		expect(statement.query).toMatchObject(result.query)
	})
})
