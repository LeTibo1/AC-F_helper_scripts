#!/usr/bin/env python3
import pexpect
import sys

gbw_base = sys.argv[1]
log = sys.argv[2]
# automatisieren ...
ECP = "No"
el_reason = "2"

child = pexpect.spawn(f"orca_2nbo {gbw_base}", timeout=None)
child.logfile = open(log, "ab")

while True:
    i = child.expect([
        r"Type in the MOLDEN/GABEDIT file name within 150 characters:",
        r"Is ECP or MCP used\? \(\[Yes\] / No\)",
        r"Warning: the total electron is different from the sum of occupations!",
        r"Press <ENTER> to continue",
        r"Press <ENTER> to exit",
        pexpect.EOF
    ])
    if i == 0:
        child.sendline("")
    elif i == 1:
        child.sendline(ECP)
    elif i == 2:
        child.sendline(el_reason)
    elif i == 3:
        child.sendline("")
    elif i == 4:
        child.sendline("")
    else:
        break

child.close()
sys.exit(child.exitstatus)
