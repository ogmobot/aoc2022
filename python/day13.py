FILENAME = "input13.txt"
from functools import cmp_to_key

def compare(a, b):
    # returns negative if a < b
    # return 0 if a == b
    # returns positive if a > b
    if type(a) == int and type(b) == int:
        return a - b
    elif type(a) == list and type(b) == list:
        for i in range(min(len(a), len(b))):
            test = compare(a[i], b[i])
            if test != 0:
                return test
        if len(a) != len(b):
            return len(a) - len(b)
        return 0
    elif type(a) == int: # type(b) must be list
        return compare([a], b)
    else:
        return compare(a, [b])

with open(FILENAME) as f:
    pairs_text = [pair.split("\n")[:2] for pair in f.read().split("\n\n")]
    pairs = [(eval(a), eval(b)) for a, b in pairs_text]

total = 0
for i, p in enumerate(pairs):
    a, b = p
    if compare(a, b) < 0:
        total += (i + 1)
print(total)

with open(FILENAME) as f:
    packets = [eval(line.strip()) for line in f if line.strip()]

divpack_a = [[2]]
divpack_b = [[6]]
packets.append(divpack_a)
packets.append(divpack_b)

packets.sort(key=cmp_to_key(compare))

print((packets.index(divpack_a) + 1) * (packets.index(divpack_b) + 1))
