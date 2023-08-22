import os
import csv

struct Cacao {
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

fn main() {
	csv_data := os.read_file('flavors_of_cacao.csv') or { panic(err) }
	output := csv.generate_struct[Cacao](csv_data)
	println(output)
}
