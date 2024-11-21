#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

'''
Read from the Arkanoid ROM and generate the levels

(c) 2024 Miguel Colom
http://mcolom.info
'''

#import argparse
import struct
import sys

def get_db_line(values, addr):
    '''
    Print a 'DB' assembly line with the given values
    '''
    string = "db "
    for i, v in enumerate(values):
        string += str(v)
        if i != len(values) - 1:
            string += ", "

    string += f'   ; 0x{addr:X}'
    return string

NUM_LEVELS = 32
NUM_BRICKS = 66
NUM_COLS = 11
NUM_ROWS = 6

addr = 0x5E6F # in RAM

# Read words
with open('../arkanoid.rom', 'rb') as f:
    f.seek(0x1E6F)
    data = f.read(NUM_BRICKS * NUM_LEVELS)

    for l in range(0, NUM_LEVELS):
        level = data[l*NUM_BRICKS : (l+1)*NUM_BRICKS]
        print(f'; Level {l+1}, addr=0x{addr:X}')
        
        for r in range(NUM_ROWS):
            row = level[r*NUM_COLS : (r+1)*NUM_COLS]
            
            string = get_db_line(row, addr)
            addr += NUM_COLS

            print(string)
        print()
