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

_path_cache = {}
def find_path(links, from_node, to_node):
    global _path_cache
    if (from_node, to_node) in _path_cache:
        return _path_cache[(from_node, to_node)]
    paths = [[from_node]]
    seen = set()
    while paths:
        path = paths.pop(0)
        if path[-1] == to_node:
            _path_cache[(from_node, to_node)] = path
            return path
        if path[-1] in seen:
            continue
        seen.add(path[-1])
        for adj in links[path[-1]]:
            paths.append(path + [adj])
    return


def dijkstra_maximise_score(flows, links, start_node):
    # node is (loc: str, time: int, open: valveset)
    best_scores = {} # store as positive score
    paths = [(0, start_node)] # store as negative score
    heapq.heapify(paths)
    while paths:
        #print(f"{paths=}")
        score, node = heapq.heappop(paths)
        #print(f"Testing {score=} {hash_node(node)}")
        score = -score
        if node in best_scores:
            if best_scores[node] >= score:
                #print(f"Discarding {score=} {node=}")
                continue # discard this path
        best_scores[node] = score
        for option in [n for n in flows if flows[n] > 0 and n not in node[2]]:
            distance = len(find_path(links, node[0], option))
            # time to move there AND turn valve means no -1
            if distance <= node[1]:
                score_delta = distance * sum(flows[v] for v in node[2])
                heapq.heappush(paths, (-score - score_delta, (
                        option,
                        node[1] - distance,
                        node[2].union([option])
                )))
        # the "do nothing" option
        score_delta = node[1] * sum(flows[v] for v in node[2])
        heapq.heappush(paths, (-score - score_delta, (node[0], 0, node[2])))
    return best_scores

def dijkstra_score_two_agents(flows, links, start_node):
    # node is (a_loc, a_target, b_loc, b_target, time, valves)
    best_scores = {}
    a_loc, b_loc, time, valves = start_node
    working_valves = [v for v in flows if flows[v] > 0]
    #working_valves.sort(key=(lambda v: flows[v]), reverse=True)

    paths = []
    heapq.heapify(paths)
    for v_a in working_valves:
        for v_b in working_valves:
            if v_a == v_b: continue
            heapq.heappush(paths, (0, (a_loc, v_a, b_loc, v_b, time, valves)))

    tmp = 0
    while paths:
        score, node = heapq.heappop(paths)
        score = -score
        if score > tmp:
            #print(score)
            tmp = score
        a_loc, a_target, b_loc, b_target, time, valves = node
        if time < 0:
            continue
        if time == 24:
            print(score, node)

        if node in best_scores:
            if best_scores[node] >= score:
                continue
        best_scores[node] = score

        if a_loc == a_target:
            # turn valve and select new target
            valves = valves.union([a_loc])
            a_targets = [v for v in working_valves
                if (v != b_target and v not in valves)]
            if not a_targets: a_targets = [""]
        else:
            # take a step toward target
            if a_target != "":
                a_path = find_path(links, a_loc, a_target)
                a_loc = a_path[1]
            a_targets = [a_target]

        for a_t in a_targets:
            if b_loc == b_target:
                # turn valve and select new target
                valves = valves.union([b_loc])
                b_targets = [v for v in working_valves
                    if (v != a_t and v not in valves)]
                if not b_targets: b_targets = [""]
            else:
                if b_target != "":
                    b_path = find_path(links, b_loc, b_target)
                    b_loc = b_path[1]
                b_targets = [b_target]

            new_score = score + sum(flows[v] for v in valves)
            for b_t in b_targets:
                heapq.heappush(paths, (-new_score,
                    (a_loc, a_t, b_loc, b_t, time - 1, valves)))
    return best_scores

flows = {}
links = {}
with open("input16.txt") as f:
    #for line in f:
    for line in test_lines:
        words = line.strip().split()
        flows[words[1]] = get_num(words[4])
        links[words[1]] = [w.strip(",") for w in words[9:]]

# part 1
init_state = ("AA", 30, frozenset())
res = dijkstra_maximise_score(flows, links, init_state)
print(max(res.values()))
print()

# part 2
init_state = ("AA", "AA", 26, frozenset())
res = dijkstra_score_two_agents(flows, links, init_state)
print(max(res.values()))

# 2058 is too low
