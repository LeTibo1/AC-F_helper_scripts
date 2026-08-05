from prettytable import PrettyTable
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), "../shared/python"))
from cli_parser import parse_args

R = "\033[0;31;40m" #RED
G = "\033[0;32;40m" # GREEN
N = "\033[0m" # Reset

def get_nrgs(files):
    nrgs = {}

    for file in files:
        with open(file) as f:
            for l in f:
                l = l.strip()
                if l.startswith("Final Gibbs free energy"):
                    nrg = float(l.split()[5])

        name = file.split("/")[-2]
        if name.endswith("."):
            name = "main"
        nrgs[name] = nrg * 2625.5

    return nrgs

def get_difs(nrgs):
    min_val = min(nrgs.values())
    difs = []

    for k, v in nrgs.items():
        difs.append([k, str(round(v - min_val, 2))])

    return difs

def print_difs(difs):
    t = PrettyTable(("Name", "ΔE / kJ/mol"))
    for dif in difs:
        if "main" in dif:
            color = R
            if "0.0" in dif:
                color = G

            tmp_dif = []
            for i in dif:
                tmp_dif.append(color+i+N)
            dif = tmp_dif
        t.add_row(dif)

    print(t)

def main():
    args = parse_args()
    nrgs = get_nrgs(args.files)
    difs = get_difs(nrgs)
    print_difs(difs)

if __name__ == '__main__':
    main()
