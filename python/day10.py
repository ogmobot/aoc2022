def generate_sigs(instructions):
    x = 1
    sigs = [1]
    for instr in instructions:
        if instr == "noop":
            sigs.append(x)
        else: #addx
            sigs.append(x)
            sigs.append(x)
            num = int(instr.split()[1])
            x += num
    return sigs

def drawbuff(vals):
    for row in range(6):
        for col in range(40):
            cycle = 40 * row + col
            sig = vals[cycle]
            if sig <= col and col <= sig + 2:
                symbol = "# "
            else:
                symbol = "  "
            print(symbol, end="")
        print()

with open("input10.txt") as f:
    sigs = generate_sigs(line.strip() for line in f)

print(sum(key * sigs[key] for key in range(20, len(sigs), 40)))

drawbuff(sigs)
