import heapq
import time
START = time.time()

test_lines = [
    "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
    "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."
]

class GeodeDict(dict):
    def __lt__(self, other):
        return (self["geode robot"], self["elapsed"]) > (other["geode robot"], other["elapsed"])

def predicted_score(state):
    return sum([
        1* ((-state["elapsed"] * state["geode robot"]) + state["geode"]),
        0* ((-state["elapsed"] * state["obsidian robot"]) + state["obsidian"]),
        0* ((-state["elapsed"] * state["clay robot"]) + state["clay"]),
        0* ((-state["elapsed"] * state["ore robot"]) + state["ore"]),
    ])

def find_options(blueprint, resources):
    # result has tuples of (consume, produce)
    result = [({}, {"elapsed": 1})] # consume nothing, produce nothing
    max_ore_robots = max(
        reqs.get("ore", 0) for reqs in blueprint.values())
    max_clay_robots = max(
        reqs.get("clay", 0) for reqs in blueprint.values())
    max_obsidian_robots = max(
        reqs.get("obsidian", 0) for reqs in blueprint.values())
    for product, reqs in blueprint.items():
        if (product == "ore robot"
                and resources["ore robot"] >= max_ore_robots):
            continue
        if (product == "clay robot"
                and resources["clay robot"] >= max_clay_robots):
            continue
        if (product == "obsidian robot"
                and resources["obsidian robot"] >= max_obsidian_robots):
            continue
        # assume making geode robots is always the best choice
        if all(resources[req_type] >= req_amount
                    for req_type, req_amount in reqs.items()):
            if product == "geode robot":
                return [(reqs, {product: 1, "elapsed": 1})]
            result.append((reqs, {product: 1, "elapsed": 1}))
    return result

def heap_node(state):
    return GeodeDict({k:v for k, v in state.items()})
    #return (-state["geode"], state)

def apply_option(state, option):
    #print(f"applying {option} to {state=}")
    new_state = state.copy()
    consumed, produced = option
    for item, amount in consumed.items():
        new_state[item] -= amount
    for item, amount in produced.items():
        new_state[item] += amount
    #print(f"{new_state=}")
    return new_state

def do_production(init_state):
    state = {k:v for k, v in init_state.items()}
    for producer in ["ore robot", "clay robot", "obsidian robot", "geode robot"]:
        product = producer.split()[0]
        state[product] = state[product] + state[producer]
    return state

def signature(state):
    temp = state.copy()
    del temp["elapsed"]
    return tuple(temp[k] for k in sorted(temp.keys()))

def sig2state(sig):
    keys = [
        "ore",
        "clay",
        "obsidian",
        "geode",
        "ore robot",
        "clay robot",
        "obsidian robot",
        "geode robot",
    ]
    return {k:v for k, v in zip(sorted(keys), sig)}

def best_possible(blueprint, time_limit):
    # maximise number of geodes
    init_state = {
        "ore": 0,
        "clay": 0,
        "obsidian": 0,
        "geode": 0,
        "ore robot": 1,
        "clay robot": 0,
        "obsidian robot": 0,
        "geode robot": 0,
        "elapsed": 0
    }
    search_nodes = []
    heapq.heapify(search_nodes)
    heapq.heappush(search_nodes, heap_node(init_state))
    counter = 0
    best_times = {} # {(state): time}
    geode_robot_benchmarks = {} # {time: geode robots}
    best_geodes = 0
    while search_nodes:
        state = heapq.heappop(search_nodes)

        counter += 1
        if counter % 1000000 == 0:
            print(f"{counter=} {len(search_nodes)=} t={state['elapsed']} timer={time.time() - START}")
            #print(state)
            #if len(search_nodes) > 9000000:
                #break
            pass

        if len(search_nodes) > 4000000:
            search_nodes = sorted(search_nodes)[:3000000]
            heapq.heapify(search_nodes)

        #print(signature(state))
        if signature(state) in best_times:
            if best_times[signature(state)] < state["elapsed"]:
                continue

        if state["elapsed"] in geode_robot_benchmarks:
            if state["geode robot"] < geode_robot_benchmarks[state["elapsed"]]:
                continue
        geode_robot_benchmarks[state["elapsed"]] = state["geode robot"]

        if state["elapsed"] == time_limit:
            if state["geode"] > best_geodes:
                best_geodes = state["geode"]
                print(f"{best_geodes=}")
            continue
        else:
            # if we built one geode robot every step, would we get there?
            t = time_limit - state["elapsed"]
            best_possible = (
                state["geode"] + (t * state["geode robot"]) + (t * (t + 1) // 2)
            )
            if best_possible <= best_geodes:
                continue

        best_times[signature(state)] = state["elapsed"]
        new_state = do_production(state)
        for option in find_options(blueprint, state):
            next_state = apply_option(new_state, option)
            heapq.heappush(
                search_nodes,
                heap_node(next_state))
    #final_states = [
        #sig2state(sig)
        #for sig, time in best_times.items()
        #if time == time_limit
    #]
    #if final_states:
        #return max([state["geode"] for state in final_states])
    #else:
        #return 0
    return best_geodes

def find_quality_level(index, blueprint):
    print(f"blueprint {index + 1}")
    res = best_possible(blueprint, 24)
    print(f"{res=} {((index + 1) * res)=}")
    return (index + 1) * res

blueprints = []
with open("input19.txt") as f:
    for line in f:
    #for line in test_lines:
        words = line.split()
        blueprints.append({
            #"number": int(words[1].strip(":")),
            "ore robot": {"ore": int(words[6])},
            "clay robot": {"ore": int(words[12])},
            "obsidian robot": {"ore": int(words[18]), "clay": int(words[21])},
            "geode robot": {"ore": int(words[27]), "obsidian": int(words[30])}
        })

#print(best_possible(blueprints[0], 24))
#print(best_possible(blueprints[1], 24))

# takes ~3h and gets the wrong answer
results = []
for index, bp in enumerate(blueprints):
    results.append(find_quality_level(index, bp))
print(sum(results))

# 1520 is too low
