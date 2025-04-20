#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

'''
Print a data block with the DB directive

(c) 2019 Miguel Colom
http://mcolom.info
'''

# ./dw_block.py ../a.bin --offset 0x8000 --start 0xB6A0 --end 0xBF2F

import argparse
import struct
import sys

def get_dw_line(values):
	'''
	Print a 'DW' assembly line with the given values
	'''
	string = "dw "
	for i, v in enumerate(values):
		string += hex(v)
		if i != len(values) - 1:
			string += ", "
	return string
		

description = "Print a data block with the DB directive"
epilog = '(C) Miguel Colom, GNU GPL3 license. http://mcolom.info'

parser = argparse.ArgumentParser(description=description, epilog=epilog)
parser.add_argument("input")
parser.add_argument("--offset", default=0x8000, type=int)
parser.add_argument("--start", default=0xB6A0, type=int)
parser.add_argument("--end", default=0xBF2F, type=int)
parser.parse_args()
args = parser.parse_args()

# Read arguments
input_filename = args.input
offset = args.offset
start = args.start
end = args.end

# Read words
with open(input_filename, 'rb') as f:
	f.seek(start - offset)
	data = f.read(end-start+1)

num_words = int((end-start+1) / 2)
dataw = struct.unpack('<' + 'H'*num_words, data)

# Print the DW lines
values = []
start_addr = start

for i, v in enumerate(dataw):
	values.append(v)
	
	if (i+1) % 8 == 0:
		string = get_dw_line(values)
		
		end_addr = start_addr + 2*len(values) - 1
		string += "; {} - {}".format(hex(start_addr), hex(end_addr))
		
		print(string)
		start_addr += 2*len(values)
		values = []
