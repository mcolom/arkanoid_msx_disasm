#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

'''
Print a data block with the DB directive

(c) 2019 Miguel Colom
http://mcolom.info
'''

# run ./db_block.py ../a.bin --offset 32768 --start 46452 --end 46707

import argparse
import struct
import sys

def get_db_line(values):
	'''
	Print a 'DB' assembly line with the given values
	'''
	string = "db "
	for i, v in enumerate(values):
		string += hex(int.from_bytes(v, byteorder='big'))
		if i != len(values) - 1:
			string += ", "
	return string
		

description = "Print a data block with the DB directive"
epilog = '(C) Miguel Colom, GNU GPL3 license. http://mcolom.info'

parser = argparse.ArgumentParser(description=description, epilog=epilog)
parser.add_argument("input")
parser.add_argument("--offset", default=0x8000, type=int)
parser.add_argument("--start", default=0xB574, type=int)
parser.add_argument("--end", default=0xB673, type=int)
parser.add_argument("--bpl", default=8, type=int) # bytes per lines
parser.parse_args()
args = parser.parse_args()

# Read arguments
input_filename = args.input
offset = args.offset
start = args.start
end = args.end
bpl = args.bpl

# Read words
with open(input_filename, 'rb') as f:
	f.seek(start - offset)
	data = f.read(end-start+1)

num_bytes = int(end-start+1) 
datab = struct.unpack('<' + 'c'*num_bytes, data)

# Print the DB lines
values = []
start_addr = start

for i, v in enumerate(datab):
	values.append(v)
	
	if (i+1) % bpl == 0:
		string = get_db_line(values)
		
		end_addr = start_addr + len(values) - 1
		string += " ; {} - {}".format(hex(start_addr), hex(end_addr))
		
		print(string)
		start_addr += len(values)
		values = []
