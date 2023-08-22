module csv

import encoding.csv

pub fn generate_struct[T](csv_data string) []T {
	mut parser := csv.new_reader(csv_data)
	mut data := []map[string]string{}
	headers := parser.read() or { panic(err) }
	for {
		mut input := map[string]string{}
		items := parser.read() or { break }
		for idx, item in items {
			header_name := headers[idx].replace(' ', '_').to_lower()
			input[header_name] = item
		}
		data << input
	}
	mut output := []T{}
	for idx, part in data {
		mut structed_data := T{}
		$for field in T.fields {
			mut csv_name := field.name
			csv_attrs := field.attrs.filter(it.contains('csv'))
			if csv_attrs != [] {
				params := csv_attrs[0].split(':')
				csv_name = params[1].trim_space()
				csv_name = csv_name.replace(' ', '_').to_lower()
			}
			$if field.typ is string {
				structed_data.$(field.name) = part[csv_name]
			}
			$if field.typ is int {
				structed_data.$(field.name) = part[csv_name].int()
				$if field.name == 'id' {
					if !headers.contains('id') {
						structed_data.$(field.name) = idx
					}
				}
			}
			$if field.typ is f64 {
				structed_data.$(field.name) = part[csv_name].f64()
			}
			$if field.typ is f32 {
				structed_data.$(field.name) = part[csv_name].f32()
			}
		}
		output << structed_data
		break
	}
	return output
}
