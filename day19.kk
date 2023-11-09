import std/os/path
import std/os/file

val g-test-data = [
    "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
    "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."
]

val g-big-number = 999999

// TODO: convert these to arrays of four elements each?
value struct reqs
    ore : int
    cla : int
    obs : int
    geo : int

struct blueprint
    ore-robot : reqs
    cla-robot : reqs
    obs-robot : reqs
    geo-robot : reqs

struct state
    ore : int ;
    cla : int ;
    obs : int ;
    geo : int ;
    d-ore : int ;
    d-cla : int ;
    d-obs : int ;
    d-geo : int ;
    time-left : int;

// Parsing
fun parse-it( s : maybe<string> ) : int
    s.default("").parse-int.mbint

fun str-to-blueprint( s : string )
    val words = split(s, " ")
    if words.length == 32 then
        return Just(Blueprint(
            ore-robot = Reqs(words[6].parse-it, 0, 0, 0),
            cla-robot = Reqs(words[12].parse-it, 0, 0, 0),
            obs-robot = Reqs(words[18].parse-it, words[21].parse-it, 0, 0),
            geo-robot = Reqs(words[27].parse-it, 0, words[30].parse-it, 0)
        ))
    else
        return Nothing

// Searching
fun figure-time(reqd : int, stockd : int, prod : int)
    val amount = reqd - stockd
    if amount <= 0 then
        return 0
    if prod == 0 then
        return g-big-number
    val quot : int = amount / prod
    return quot + int(not (prod * quot == amount))

fun get-time-req(bp : blueprint, st : state , resource : int)
    val rqs = match resource
        0 -> bp.ore-robot
        1 -> bp.cla-robot
        2 -> bp.obs-robot
        3 -> bp.geo-robot
    [
        figure-time(rqs.ore, st.ore, st.d-ore),
        figure-time(rqs.cla, st.cla, st.d-cla),
        figure-time(rqs.obs, st.obs, st.d-obs),
        figure-time(rqs.geo, st.geo, st.d-geo),
    ].maximum

// build-state... is this nation-building?
fun build-state(
    bp : blueprint ,
    initial-state : state ,
    resource : int ,
    d-t : int
)
    // construct a robot of type-i.
    val rqs = match resource
        0 -> bp.ore-robot
        1 -> bp.cla-robot
        2 -> bp.obs-robot
        3 -> bp.geo-robot
    // This triggers a compiler error...
    return State(
        initial-state.ore + (initial-state.d-ore * (d-t + 1)) - rqs.ore,
        initial-state.cla + (initial-state.d-cla * (d-t + 1)) - rqs.cla,
        initial-state.obs + (initial-state.d-obs * (d-t + 1)) - rqs.obs,
        initial-state.geo + (initial-state.d-geo * (d-t + 1)) - rqs.geo,

        initial-state.d-ore + int(resource == 0),
        initial-state.d-cla + int(resource == 1),
        initial-state.d-obs + int(resource == 2),
        initial-state.d-geo + int(resource == 3),

        initial-state.time-left - d-t - 1
    )

fun worth-building(bp : blueprint , initial-state : state, resource : int)
    // Don't build an ore robot if you already have enough ore per minute
    // to build whatever you want
    var res : bool := False
    match resource
        // ore is used for every robot
        0 -> res := (initial-state.d-ore < bp.ore-robot.ore
         || initial-state.d-ore < bp.cla-robot.ore
         || initial-state.d-ore < bp.obs-robot.ore
         || initial-state.d-ore < bp.geo-robot.ore
        )
        // clay is used only for obsidian robots
        1 -> res := (initial-state.d-cla < bp.obs-robot.cla)
        // obsidian is used only for geode robots
        2 -> res := (initial-state.d-obs < bp.geo-robot.obs)
        3 -> res := True
    return res

fun continuous-production(bp : blueprint, st : state)
    return (
           st.ore   >= bp.geo-robot.ore && st.obs   >= bp.geo-robot.obs
        && st.d-ore >= bp.geo-robot.ore && st.d-obs >= bp.geo-robot.obs
    )

fun best-geodes(
    bp : blueprint ,
    initial-state : state
)
    // Wonder if we can just DFS this...
    // Edit: afraid it's not that simple.

    val best = ref(0)
    val search-front = ref([initial-state])
    // Geode-robot minimum remaining time:
    // Let n be the number of geode-robots in a state with time t.
    // If (you have less time left than geode-min-t-left[n+1] left),
    //      abandon this path.
    val geo-min-t-left = ref(vector(256, 0).vlist) // Optimistic perhaps
    while { (!search-front).length > 0 } {
        val current = (!search-front).head.default(initial-state)
        search-front := (!search-front).tail
        if current.time-left >= 0 then

            if current.geo > !best then
                best := current.geo

            val limit = (!geo-min-t-left)[current.d-geo + 1].mbint
            if current.time-left >= limit then
                if current.time-left > (!geo-min-t-left)[current.d-geo].mbint then
                    // Scuffed assignment to list index
                    geo-min-t-left := (
                        (!geo-min-t-left).take(current.d-geo)
                        ++ [current.time-left]
                        ++ (!geo-min-t-left).drop(current.d-geo + 1)
                    )

                search-front := (
                    [3, 2, 1, 0].filter-map(fn(i)
                        if worth-building(bp, current, i) then
                            val t = get-time-req(bp, current, i)
                            if t != g-big-number then
                                return Just(
                                    build-state(bp, initial-state, i, t)
                                )
                        // else
                        return Nothing
                    )
                ) ++ (!search-front)

            // else
            // (abandon this path)
    }
    return !best

// Main
fun main()
    val input_lines = read-text-file(path("input19.txt")).lines
    //val input_lines = g-test-data
    val blueprints = input_lines.filter-map(str-to-blueprint)
    // Part 1
    // Takes ~45 seconds (with -O3)
    println(
        zipwith(blueprints, list(1, length(blueprints)), fn(bp, i)
            print("Testing blueprint ") ; print(i) ; print(" -> ")
            val res = best-geodes(
                bp,
                State(0, 0, 0, 0,
                      1, 0, 0, 0,
                      24)
            )
            println(res)
            return res * i
        ).sum
    )
    // Part 2
    /*
    println(
        zipwith(blueprints, list(1, 3), fn(bp, i)
            print("Testing blueprint ") ; print(i) ; print(" => ")
            val res = best-geodes(
                bp,
                State(0, 0, 0, 0,
                      1, 0, 0, 0,
                      32),
            )
            println(res)
            return res
        ).foldl(1, (*))
    )
    */
    return ()

