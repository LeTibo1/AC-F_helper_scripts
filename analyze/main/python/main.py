#!/bin/python3

from create_sort import create_sort
from create_log import create_log
from create_dif import create_dif
from create_nbo import create_nbo

# extern imports
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), "../../shared/python"))
from cli_parser import parse_args

def main():
    args = parse_args()
    files = args.files

    create_log(files)
    create_sort(files)
    create_nbo(files)
#    create_dif(files)

if __name__ == '__main__':
    main()
