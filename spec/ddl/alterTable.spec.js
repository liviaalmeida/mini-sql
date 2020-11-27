const tables = {
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
	},
	'customers': {
		command: 'ALTER TABLE customers ADD (customer_name char(50) NOT NULL, state char(2));',
		result: {
      alteration: {
        constraints: [
          {
            column: {
							constraints: { never_null: true },
							name: 'customer_name', size: '50', type: 'CHAR'
            }
          },
          {
            column: {
              name: 'state', size: '2', type: 'CHAR'
            }
          }
        ],
        type: 'ADD'
      },
      name: 'customers', type: 'ALTER_TABLE'
		}
	},
	'd1': {
		command: 'ALTER TABLE d1 DROP CONSTRAINT check_age;',
		result: {
      alteration: {
        constraint: 'check_age', type: 'DROP'
      },
      name: 'd1', type: 'ALTER_TABLE'
		}
	},
	'departments': {
		command: 'ALTER TABLE departments RENAME COLUMN department_name to dept_name;',
		result: {
      alteration: {
        column: {
          name: 'dept_name', old_name: 'department_name'
        }
      },
      name: 'departments', type: 'ALTER_TABLE'
		}
	},
	'my_existing_table': {
		command: 'ALTER TABLE my_existing_table ADD COLUMN ID INT NOT NULL FIRST;',
		result: {
			alteration: {
				column: {
					constraints: { never_null: true },
					name: 'ID', type: 'INT'
				},
				first: true, type: 'ADD'
			},
			name: 'my_existing_table', type: 'ALTER_TABLE'
		}
	},
	'salaries': {
		command: 'ALTER TABLE salaries RENAME TO employees_salaries;',
		result: {
			alteration: {
        name: 'employees_salaries', type: 'RENAME'
      },
      name: 'salaries', type: 'ALTER_TABLE'
		}
	}
}

describe('ALTER TABLE command should return a command ', () => {
	test('to alter table my_existing_table adding new column id', () => {
		const { command, result } = tables['my_existing_table']
		const statement = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('to alter table customers adding two new columns, customer_name and state', () => {
		const { command, result } = tables['customers']
		const statement = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('to alter table contacts modifying column last_name to be varchar(50) and allow NULL values', () => {
		const { command, result } = tables['contacts']
		const statement = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('to alter table departments renaming column department_name to dept_name', () => {
		const { command, result } = tables['departments']
		const statement = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('to alter table salaries renaming it to employees_salaries', () => {
		const { command, result } = tables['salaries']
		const statement = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

	test('to alter table d1 droping constraint check_age', () => {
		const { command, result } = tables['d1']
		const statement = singleCommand(command)

		expect(statement).toMatchObject(result)
	})

})
