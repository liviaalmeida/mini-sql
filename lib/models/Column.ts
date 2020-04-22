export default class Column<T> {
	ctype: number
	name: string
	size?: number
	primary?: boolean
	default?: T
	nullAllowed?: boolean
	constraints?: Array<(value: T) => boolean>
	foreign?: {
		table: string
		column: string
	}

	constructor({ ctype, name, ...options }: Column<T>) {
		this.ctype = ctype
		this.name = name
		Object.assign(this, options)
	}

	valueConstrained(value: T): boolean {
		const constraints = this.constraints || []
		return constraints.every(constraint => constraint(value))
	}

	valueValid(value: T | undefined): boolean {
		if (!value) {
			return this.nullAllowed || false
		}
		return this.valueConstrained(value)
	}
}
