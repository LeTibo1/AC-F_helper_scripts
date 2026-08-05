#!/bin/python3

import sys
import argparse

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--files", nargs="+")
    parser.add_argument("--file")
    parser.add_argument("--dir")
    parser.add_argument("--cluster")
    parser.add_argument("--status")

    return parser.parse_args()
