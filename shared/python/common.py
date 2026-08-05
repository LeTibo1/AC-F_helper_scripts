#!/bin/python3

import os
import sys
from datetime import datetime
import shared_constants as cst

def get_parts(file):
    """
    Get file name, c_type(calculation type: opt/sp),
    ligand specification, ligand/precursor,
    element/ligand from path name
    """

    parts= {}
    file = file.strip()
    splits = file.split("/")
    s = splits.copy()

    parts["name"] = s.pop(-1)

    metal = list(set(x.lower() for x in s) & set(cst.METALS))
    if len(metal) == 1:
        metal = str(metal[0])
        parts["metal"] = metal
        idx = [x.lower() for x in splits].index(metal)
    elif len(metal) > 1:
        print("Error: multiple metals in paths")
    else:
        print("Error: no metals in paths")
        return

    element = list(set(x.lower() for x in s) & set(cst.ELEMENTS))
    if len(element) == 1:
        element = str(element[0])
        parts["element"] = element
        idx = splits.index(element)
    elif len(element) == 0:
        parts["element"] = None
    else:
        print("Error: multiple elements in paths")
        return

    for i in range(idx + 1):
        s.pop(0)

    parts["ligand"] = s.pop(0)
    if s[0] not in cst.CALCULATION_MODES:
        parts["specification"] = s.pop(0)

    parts["c_type"] = None
    if s and s[0] in cst.CALCULATION_MODES:
        parts["c_type"] = s.pop(0)

    if s:
        parts["optional"] = []
        for p in s:
            parts["optional"].append(p)
    else:
        parts["optional"] = None

    result = None
    if file.endswith(".inp") or file.endswith(".47") or file.endswith(".nbo.out"):
        stat_info = os.stat(file)
        timestamp = stat_info.st_mtime
        dt = datetime.fromtimestamp(timestamp)
        result = dt.strftime("%d.%m.%Y")
    elif file.endswith(".out"):
        match = "* Starting time: "
        with open(file) as f:
            for l in f:
                l = l.strip()
                if l.startswith(match):
                    date_str = l.split(match)[1]
                    date = datetime.strptime(date_str, "%a %b %d %H:%M:%S %Y")
                    result = date.strftime("%d.%m.%Y")

    parts["date"] = result

    return parts
