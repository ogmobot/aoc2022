#!/usr/bin/env python3

with open("input01.txt", "r") as f:
    supplies = [
        sum(int(x) for x in elf.split()) for elf in f.read().split("\n\n")
    ]

print(max(supplies))
print(sum(sorted(supplies)[-3:]))
