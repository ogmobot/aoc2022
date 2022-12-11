class Monkey:
    def __init__(self):
        self.modval = 1
        pass

    def give_item(self, val):
        self.held.append(val)

    def set_attribs(self, text):
        lines = text.split("\n")
        self.name = int(lines[0].strip().rstrip(":").split()[1])
        # starting items
        self.held = [
            int(x) for x in (lines[1].strip().split(":")[1]).split(",")
        ]
        # operation
        operation = lines[2].strip().split("new = ")[1]
        if operation == "old * old":
            self.op = lambda x: x * x
        else:
            val = int(operation.split()[-1])
            if "*" in operation:
                self.op = lambda x: x * val
            else:
                self.op = lambda x: x + val
        # test
        self.div_test = int(lines[3].strip().split()[-1])
        self.dest_true = int(lines[4].strip().split()[-1])
        self.dest_false = int(lines[5].strip().split()[-1])

    def inspect(self, monkey_dict, part1):
        item = self.held.pop(0) % self.modval
        item = self.op(item)
        if part1:
            item = item // 3
        if item % self.div_test == 0:
            monkey_dict[self.dest_true].give_item(item)
        else:
            monkey_dict[self.dest_false].give_item(item)

    def do_turn(self, monkey_dict, tracker, part1):
        while self.held:
            self.inspect(monkey_dict, part1)
            tracker[self.name] = tracker.get(self.name, 0) + 1

with open("input11.txt") as f:
    monkey_texts = f.read().split("\n\n")

monkeys = {}
monkeys_2 = {}
modval = 1
for monkey_text in monkey_texts:
    m = Monkey()
    m.set_attribs(monkey_text)
    monkeys[m.name] = m
    n = Monkey()
    n.set_attribs(monkey_text)
    monkeys_2[n.name] = n
    modval *= m.div_test

for m in monkeys_2.values(): # optionally do this in part 1 too
    m.modval = modval

# do 20 rounds
tracker = {}
for r in range(20):
    for i in range(len(monkeys)):
        monkeys[i].do_turn(monkeys, tracker, True)

# monkey business
mb = sorted(list(tracker.values()))[-2:]
print(mb[0] * mb[1])

# do 10000 rounds
tracker = {}
for r in range(10000):
    for i in range(len(monkeys_2)):
        monkeys_2[i].do_turn(monkeys_2, tracker, False)

mb = sorted(list(tracker.values()))[-2:]
print(mb[0] * mb[1])
