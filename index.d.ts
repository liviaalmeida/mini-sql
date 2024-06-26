export declare namespace miniSQL {
  interface Column {
    name: string;
    type: string;
    size?: string;
    precision?: string;
    constraints?: {
      null_allowed?: boolean;
      never_null?: boolean;
      primary?: boolean;
      unique?: boolean;
      default?: string;
    };
  }
  
  interface Constraint {
    primary?: Array<string>;
    unique?: Array<string>;
    foreign?: {
      keys: Array<string>;
      table: string;
      identifiers: Array<string>;
    };
  }
  
  interface CreateTable {
    constraints: Array<{
      column?: Column;
      constraint?: Constraint;
    }>;
    name: string;
    statement: string;
    temp?: boolean;
    type: 'CREATE_TABLE';
  }
  
  interface Insert {
    default?: boolean;
    reference: {
      name?: string;
      select?: object;
      as?: string;
      identifiers?: string[];
    };
    statement: string;
    values?: Array<Array<string>>;
    type: 'INSERT';
  }
  
  type SqlCommand = CreateTable | Insert

  interface ParseError {
    expected: string[];
    line: number;
    loc: {
      first_column: number;
      first_line: number;
      last_column: number;
      last_line: number;
    };
    text: string;
    token: string;
  }

  interface Parser {
    parse: (input: string) => SqlCommand[];
  }
}

declare const parser: miniSQL.Parser;
export default parser
