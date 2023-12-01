SNAFU = {-2: "=", -1: "-", 0: "0", 1: "1", 2: "2"}
UFANS = {"=": -2, "-": -1, "0": 0, "1": 1, "2": 2}

def dec2snafu(n):
    digits = []
    while n > 0:
        digits.append(((n + 2) % 5) - 2)
        n += 2
        n //= 5
    if not digits:
        digits = [0]
    return "".join(SNAFU[d] for d in reversed(digits))

def snafu2dec(s):
    result = 0
    for place, value in enumerate(reversed(s)):
        result += ((5 ** place) * UFANS[value])
    return result

with open("input25.txt") as f:
    lines = [l.strip() for l in f]

total = 0
for line in lines:
    total += snafu2dec(line)
print(dec2snafu(total))
