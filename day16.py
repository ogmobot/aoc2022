import heapq
import itertools

test_lines = """
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
""".strip().split("\n")

def get_num(text):
    digits = [d for d in list(text) if d.isdigit()]
    return int("".join(digits))

def make_hashable(state):
    loc, time_remaining, open_valves, score = state
    return (loc + "," + ",".join(sorted(open_valves)), score)

def find_best(flows, links, init_state):
    states = [init_state]
    heapq.heapify(states)
    best_release = 0
    seen_states = {}
    max_valves = len([key for key, val in flows.items() if val > 0])
    while states:
        #print(states)
        score, loc, time_remaining, open_valves = heapq.heappop(states)
        if time_remaining == 0:
            if score < best_release:
                best_release = score
                print(-score)
                #print(loc, open_valves)
            continue
        statehash = loc + "," + ",".join(sorted(open_valves))
        if statehash in seen_states:
            old_time, old_score = seen_states.get(statehash)
            if old_time > time_remaining and old_score <= score:
                continue
        seen_states[statehash] = (time_remaining, score)
        sumflows = sum(flows[v] for v in open_valves)
        if len(open_valves) == max_valves:
            heapq.heappush(states,
                (score - sumflows, loc, time_remaining - 1, open_valves))
            continue
        if loc not in open_valves and flows[loc] > 0:
            heapq.heappush(states,
                (score - sumflows, loc, time_remaining - 1, open_valves.union([loc]))
            )
        for link in links[loc]:
            heapq.heappush(states,
                (score - sumflows, link, time_remaining - 1, open_valves)
            )
        #states.sort(key=(lambda s: s[3]), reverse=True)
    return

#def find_path(links, from_node, to_node):
def cost_to_reach(links, from_node, to_node):
    paths = [[from_node]]
    seen = set()
    while paths:
        path = paths.pop(0)
        if path[-1] == to_node:
            return len(path) - 1
        if path[-1] in seen:
            continue
        seen.add(path[-1])
        for adj in links[path[-1]]:
            paths.append(path + [adj])
    return

def test_permutation(flows, links, seq):
    # seq is a sequence of node names
    loc = seq[0]
    timer = 30
    open_valves = set()
    score = 0
    for i in range(1, len(seq)):
        #path = find_path(links, loc, seq[i])[1:]
        path_cost = cost_to_reach(links, loc, seq[i])
        flowsum = sum(flows[v] for v in open_valves)
        #print(f"releasing {flowsum} pressure.")
        # TODO
        while timer > 0:
            if path:
                loc = path.pop(0)
                #print(f"Travelled to {loc}.")
                timer -= 1
                score += flowsum
            else:
                open_valves.add(loc)
                #print(f"Opened valve {loc}.")
                timer -= 1
                score += flowsum
                break
        if timer == 0:
            break
    flowsum = sum(flows[v] for v in open_valves)
    while timer > 0:
        score += flowsum
        timer -= 1
    return score

flows = {}
links = {}
with open("input16.txt") as f:
    for line in f:
    #for line in test_lines:
        words = line.strip().split()
        flows[words[1]] = get_num(words[4])
        links[words[1]] = [w.strip(",") for w in words[9:]]

# state = (-pressure: int, loc: str, time: int, open: set(), pressure: int)

init_state = (0, "AA", 30, set())

#print(find_best(flows, links, init_state))

best = 0
for perm in itertools.permutations([key for key, value in flows.items() if value > 0]):
    path = ["AA"] + list(perm)
    score = test_permutation(flows, links, path)
    if score > best:
        print(score)
        best = score

print(best)
