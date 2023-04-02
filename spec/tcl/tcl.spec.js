import { describe, expect, test } from 'vitest'

describe('TCL command ', () => {
  test('commit should work', () => {
    const statement = singleCommand('commit;')

    expect(statement.type).toEqual('COMMIT')
  })
  
  test('rollback should work', () => {
    const statement = singleCommand('rollback;')

    expect(statement.type).toEqual('ROLLBACK')
  })
})
