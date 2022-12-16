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

class Agent:
    def __init__(self, loc, links):
        self.loc = loc
        self.path = []
        self.links = links
        self.target = None
    def set_target(self, target):
        p = find_path(self.links, self.loc, target)
        if p:
            self.path = p[1:] + [p[-1]] # turn valve
            self.target = target
    def step(self):
        if self.path:
            self.loc = self.path.pop(0)
            if len(self.path) == 0:
                self.target = None
                return True # turned valve
        return False
    def copy(self):
        res = Agent(self.loc, self.links)
        res.path = self.path.copy()
        res.target = self.target
        return res

    def __lt__(self, other):
        return self.loc < other.loc

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

def hn(node): # hash of node
    agent_a, agent_b, time, valves, claimed = node
    return (
        agent_a.loc, #agent_a.target,
        agent_b.loc, #agent_b.target,
        time, valves,
        claimed)

#MAX_HEAP = 1000
def dijkstra_score_two_agents(flows, links, start_node):
    # node is (agent_a, agent_b, time, valves, claimed)
    best_scores = {}
    paths = [(0, start_node)]
    heapq.heapify(paths)
    working_valves = [v for v in flows if flows[v] > 0]
    working_valves.sort(key=(lambda v: flows[v]), reverse=True)
    tmp = 0
    while paths:
        #if len(paths) > MAX_HEAP:
            #print("culling heap...")
            #paths = [heapq.heappop(paths) for _ in range(MAX_HEAP)]
            #heapq.heapify(paths)
        score, node = heapq.heappop(paths)
        score = -score
        if score > tmp:
            print(score)
            tmp = score
        agent_a, agent_b, time, valves, claimed = node
        #if time == 25:
            #print(f"{score=} {agent_a.loc=} {agent_b.loc=} {time=} {claimed=}")

        # both agents MUST have paths to follow (if one is available)
        done = (len(claimed) == len(working_valves))
        if (not agent_a.path) and (not done):
            for option in [n for n in working_valves if n not in claimed]:
                sub_a = agent_a.copy()
                sub_a.set_target(option)
                heapq.heappush(paths, (-score, (
                    sub_a, agent_b.copy(), time,
                    valves, claimed.union([option]))))
            continue
        if (not agent_b.path) and (not done):
            for option in [n for n in working_valves if n not in claimed]:
                sub_b = agent_b.copy()
                sub_b.set_target(option)
                heapq.heappush(paths, (-score, (
                    agent_a.copy(), sub_b, time,
                    valves, claimed.union([option]))))
            continue

        if hn(node) in best_scores:
            if best_scores[hn(node)] >= score:
                continue
        best_scores[hn(node)] = score

        # both agents are guaranteed to have paths if not all valves are open
        score_delta = sum(flows[v] for v in valves)
        turned_a = agent_a.step()
        turned_b = agent_b.step()
        if turned_a:
            valves = valves.union([agent_a.loc])
        if turned_b:
            valves = valves.union([agent_b.loc])
        if time > 0:
            heapq.heappush(paths,
                (-score - score_delta,
                    (agent_a.copy(), agent_b.copy(), time - 1,
                    valves, claimed)))
    return best_scores

flows = {}
links = {}
with open("input16.txt") as f:
    for line in f:
    #for line in test_lines:
        words = line.strip().split()
        flows[words[1]] = get_num(words[4])
        links[words[1]] = [w.strip(",") for w in words[9:]]

# part 1
init_state = ("AA", 30, frozenset())
res = dijkstra_maximise_score(flows, links, init_state)
print(max(res.values()))
print()

# part 2
init_state = (
        Agent("AA", links), Agent("AA", links), 26,
        frozenset(), frozenset()
)
res = dijkstra_score_two_agents(flows, links, init_state)
print(max(res.values()))

# 2058 is too low
