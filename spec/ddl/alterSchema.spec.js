describe('ALTER SCHEMA command should return a command ', () => {
  test('to alter schema old_schema to new_schema', () => {
    const statement = singleCommand('ALTER SCHEMA old_schema RENAME TO new_schema;')

    expect(statement.name).toEqual('new_schema')
    expect(statement.old_name).toEqual('old_schema')
    expect(statement.type).toEqual('ALTER_SCHEMA')
  })
    
  test('to alter schema another_old_schema as the_newest_schema', () => {
    const statement = singleCommand('ALTER SCHEMA another_old_schema RENAME AS the_newest_schema;')

    expect(statement.name).toEqual('the_newest_schema')
    expect(statement.old_name).toEqual('another_old_schema')
    expect(statement.type).toEqual('ALTER_SCHEMA')
  })
})
