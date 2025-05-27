#!/bin/bash
gcc -o xmlparser parser.c lex.yy.c -lfl || { echo "Compile failed"; exit 1; }
./xmlparser < uploads/$1
