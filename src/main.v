import os
import encoding.csv

//[csv: 'without_headers']
struct Coffee {
	id                int
	company           string
	bean_origin       string
	ref               int
	review_date       int    [csv: 'Review Date']
	cocoa_percent     string [csv: 'Cocoa Percent']
	company_location  string [csv: 'Company Location']
	rating            f64
	bean_type         string [csv: 'Bean Type']
	broad_bean_origin string
}

fn generate_struct[T](csv_data string) []T {
	mut parser := csv.new_reader(csv_data)
	// mut include_headers := true
	//$for attr in T.attributes {
	//	if attr.arg == 'without_headers' && attr.name == 'csv' {
	//		include_headers = false
	//	}
	//}
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
			if field.attrs != [] {
				csv_name = field.attrs[0].split(':')[1].trim_space()
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
	}
	return output
}

fn main() {
	csv_data := os.read_file('flavors_of_cacao.csv') or { panic(err) }
	output := generate_struct[Coffee](csv_data)
	println(output)
}
