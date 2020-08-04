const tables = {
	'my_existing_table': {
		command: 'ALTER TABLE my_existing_table ADD COLUMN ID INT NOT NULL FIRST;',
		result: {
			alteration: {
        column: {
          constraints: { never_null: true },
          name: 'ID',
          type: 'INT'
        },
        first: true, type: 'ADD'
			},
			name: 'my_existing_table', type: 'ALTER_TABLE'
		}
  },
  'contacts': {
    command: 'ALTER TABLE contacts MODIFY last_name varchar(50) NULL;',
    result: {
      alteration: {
        column: {
          constraints: { null_allowed: true },
          name: 'last_name', size: '50', type: 'VARCHAR'
        },
        type: 'MODIFY'
      },
      name: 'contacts', type: 'ALTER_TABLE'
    }
  }
}

describe("ALTER TABLE command should return a command ", () => {
	test('to alter table my_existing_table adding new column id', () => {
		const { command, result } = tables['my_existing_table']
		const { statement } = singleCommand(command)

    expect(statement).toMatchObject(result)
  })

  test('to alter table contacts modifying column last_name to be varchar(50) and allow NULL values', () => {
		const { command, result } = tables['contacts']
    const { statement } = singleCommand(command)

    expect(statement).toMatchObject(result)
  })

})
