#!/bin/python3

import pandas as pd
import os
import sys
import ast

sys.path.append(os.path.join(os.path.dirname(__file__), "../../config"))
import config_constants as cst

def parse_name(name):
    if name.endswith(".47"):
        name = name.rsplit(".", 1)[0] + ".nbo.out"
    elif not name.endswith(".out"):
        name = name.rsplit(".", 1)[0] + ".out"
    return name

def parse_entry(ctype):
    # NaN, None oder leerer String -> leerer String
    if ctype is None:
        return ""
    else:
        return ctype

def parse_list(value):
    if value is None or (isinstance(value, float) and pd.isna(value)) or value == "":
        return []
    if isinstance(value, list):
        return value
    try:
        parsed = ast.literal_eval(value)
        return parsed if isinstance(parsed, list) else [parsed]
    except (ValueError, SyntaxError):
        # kein gültiges Python-Literal -> als einzelnen String-Wert behandeln
        return [value]

def get_files():
    df = pd.read_excel(f"{cst.HOME}/tables/log.xlsx", sheet_name="log")

    for idx, row in df[df["status"] == "pending"].iterrows():
        name = parse_name(row["name"])
        c_type = parse_entry(row["c_type"])
        optional = parse_list(row["optional"])
        cluster = row["cluster"]
        mod = parse_entry(row["modification"])
        ligand = parse_entry(row["ligand"])
        element = parse_entry(row["element"])
        metal = parse_entry(row["metal"])

        path = create_path(metal, element, ligand, mod, name, c_type, optional)
        print(f"{path}|{c_type}|{cluster}")

def create_path(metal, element, ligand, mod, name, c_type, optional):
    if metal is None or (isinstance(metal, float) and pd.isna(metal)):
        metal = ""

    path = metal
    if element:
        path = f"{path}/{element}"
    if ligand:
        path = f"{path}/{ligand}"
    if mod:
        path = f"{path}/{mod}"
    if c_type:
        path = f"{path}/{c_type}"
    for o in optional:
        path = f"{path}/{o}"
    path = f"{path}/{name}"
    return path

def main():
    get_files()

if __name__ == '__main__':
    main()
