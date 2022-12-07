from collections import defaultdict

def get_size(d):
    total = 0
    for item in d.values():
        if type(item) == int:
            total += item
        else: # dir
            total += get_size(item)
    return total

def show_directories(d, indent = 0):
    for k, v in d.items():
        print(" "*indent, end="")
        if type(v) == int:
            print(f"- {k} (file, size={v})")
        else:
            print(f"- {k} (dir) ==> TOTAL {get_size(v)}")
            show_directories(v, indent + 2)

def get_all_sizes(d, result):
    for key, value in d.items():
        if type(value) == dict:
            result[key].append(get_size(value)) # multiple dirs have same name!
            get_all_sizes(value, result)

with open("input07.txt") as f:
    lines = [l.strip() for l in f.readlines()]

#{
    #'a':{...},
    #'b':14848514,
#}

root = {}
current_path = []
for line in lines:
    if line.startswith("$"):
        if line == "$ cd /":
            current_path = []
        elif line == "$ cd ..":
            current_path.pop()
        elif line == "$ ls":
            pass
        else:
            parts = line.split()
            assert(parts[0] == "$" and parts[1] == "cd")
            current_path.append(parts[2])
        working_directory = root
        for item in current_path:
            working_directory = working_directory[item]
    else: #listing
        parts = line.split()
        if parts[0].isnumeric(): # file
            working_directory[parts[1]] = int(parts[0])
        elif parts[0] == "dir":
            working_directory[parts[1]] = {}

# part 1
result = defaultdict(list)
get_all_sizes(root, result)
result["/"] = [get_size(root)]

total = 0
for k, v in result.items():
    for item in v:
        if item <= 100000:
            total += item
print(total)

# part 2
TOTAL = 70000000
REQUIRED = 30000000
used = sum(result["/"])
remaining_space = TOTAL - used
need_to_delete = REQUIRED - remaining_space
candidates = [item
    for v in result.values()
        for item in v if item >= need_to_delete]
print(min(candidates))

# 6905 too low
# 33223068 is too high
