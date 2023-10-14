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

ORDER = ['AA']

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

def dijkstra_maximise_score(flows, links, start_node, targets):
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
        for option in [n for n in targets if flows[n] > 0 and n not in node[2]]:
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

def solve_pair(flows, links, start_location):
    working_valves = [v for v in flows if flows[v] > 0]
    best = 0
    for division in range((len(working_valves) // 2), 0, -1):
        #print(f"division = {division}, {len(working_valves) - division}")
        for set_a in itertools.combinations(working_valves, division):
            set_b = set(working_valves) - set(set_a)
            scores_a = dijkstra_maximise_score(
                flows, links, (start_location, 26, frozenset()), set_a)
            scores_b = dijkstra_maximise_score(
                flows, links, (start_location, 26, frozenset()), set_b)
            if max(scores_a.values()) + max(scores_b.values()) > best:
                best = max(scores_a.values()) + max(scores_b.values())
                #print(set_a, set_b)
                #print(best)
    return best

flows = {}
links = {}
with open("input16.txt") as f:
    for line in f:
    #for line in test_lines:
        words = line.strip().split()
        flows[words[1]] = get_num(words[4])
        links[words[1]] = [w.strip(",") for w in words[9:]]

working_valves = [v for v in flows if flows[v] > 0]
# part 1
init_state = ("AA", 30, frozenset())
res = dijkstra_maximise_score(flows, links, init_state, list(flows.keys()))
print(max(res.values()))
print()

# part 2 (takes ~15 min, or ~9 min with pypy)
print(solve_pair(flows, links, "AA"))
