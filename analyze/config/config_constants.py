#!/bin/python3

import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), "../../shared/python"))
from shared_constants import HOME, ELEMENTS, PRECURSOR, CALCULATION_MODES, METALS, LIGAND_ELEMENTS, CONSTANTS

# tables
ROW = {
    "metal": None,
    "element": None,
    "ligand": None,
    "modification": None,
    "optional": None,
    "c_type": None,
    "name": None,
    "E(el) [Eh]": None,
    "G [Eh]": None,
}
