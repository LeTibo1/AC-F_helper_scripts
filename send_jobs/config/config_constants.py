#!/bin/python3

import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), "../../shared/python"))
from shared_constants import HOME, ELEMENTS, PRECURSOR, CALCULATION_MODES, METALS

# tables
ROW = {
    "metal": None,
    "element": None,
    "ligand": None,
    "modification": None,
    "optional": None,
    "c_type": None,
    "name": None,
    "cluster": None,
    "date": None,
    "status": None,
    "clean structure": None,
    "comment": None,
    "col1": None,
    "col2": None,
    "col3": None,
}
