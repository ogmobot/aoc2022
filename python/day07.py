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
            result.append(get_size(value))
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
sizes = []
get_all_sizes(root, sizes)
sizes.append(get_size(root))

total = 0
for item in sizes:
    if item <= 100000:
        total += item
print(total)

# part 2
TOTAL = 70000000
REQUIRED = 30000000
used = get_size(root)
remaining_space = TOTAL - used
need_to_delete = REQUIRED - remaining_space
candidates = [item for item in sizes if item >= need_to_delete]
print(min(candidates))
