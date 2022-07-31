describe('DROP SCHEMA command should return a command ', () => {
  test('drop schema for my_new_schema', () => {
    const statement = singleCommand('DROP SCHEMA my_new_schema;')

    expect(statement.type).toEqual('DROP_SCHEMA')
    expect(statement.name).toEqual('my_new_schema')
  })
})
