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
    ore : int ; d-ore : int ;
    cla : int ; d-cla : int ;
    obs : int ; d-obs : int ;
    geo : int ; d-geo : int ;

// Parsing
fun parse-it( s : maybe<string> ) : int
    s.default("").parse-int.mbint

fun str-to-blueprint( s : string )
    val words = split(s, " ")
    return Blueprint(
        ore-robot = Reqs(words[6].parse-it, 0, 0, 0),
        cla-robot = Reqs(words[12].parse-it, 0, 0, 0),
        obs-robot = Reqs(words[18].parse-it, words[21].parse-it, 0, 0),
        geo-robot = Reqs(words[27].parse-it, 0, words[30].parse-it, 0)
    )

// Main
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
    return State(
        initial-state.ore + (initial-state.d-ore * (d-t + 1)) - rqs.ore,
        initial-state.cla + (initial-state.d-cla * (d-t + 1)) - rqs.cla,
        initial-state.obs + (initial-state.d-obs * (d-t + 1)) - rqs.obs,
        initial-state.geo + (initial-state.d-geo * (d-t + 1)) - rqs.geo,

        initial-state.d-ore + int(resource == 0),
        initial-state.d-cla + int(resource == 1),
        initial-state.d-obs + int(resource == 2),
        initial-state.d-geo + int(resource == 3)
    )

fun worth-building(bp : blueprint , initial-state : state, resource : int)
    // Don't build an ore robot if you already have enough ore per minute
    // to build whatever you want
    match resource
        0 -> (
            // ore is used for every robot
            initial-state.d-ore < bp.ore-robot.ore
         && initial-state.d-ore < bp.cla-robot.ore
         && initial-state.d-ore < bp.obs-robot.ore
         && initial-state.d-ore < bp.geo-robot.ore
        )
        1 -> (
            // clay is used only for obsidian robots
            initial-state.d-cla < bp.obs-robot.ore
        )
        2 -> (
            // obsidian is used only for geode robots
            initial-state.d-cla < bp.geo-robot.ore
        )
        3 -> True
    return True

fun best-geodes(
    bp : blueprint ,
    initial-state : state ,
    remaining-time : int
)
    // Wonder if we can just DFS this...
    if remaining-time < 0 then
        return -1
    Cons(
        initial-state.geo,
        [0, 1, 2, 3].filter-map(fn(i)
            if worth-building(bp, initial-state, i) then
                val t = get-time-req(bp, initial-state, i)
                if t != g-big-number then
                    return Just(best-geodes(
                        bp,
                        build-state(bp, initial-state, i, t),
                        remaining-time - t - 1
                    ))
            // else
            return Nothing
        )
    ).maximum

fun main()
    //val input_lines = read-text-file(path("input19.txt")).lines
    val input_lines = g-test-data
    val blueprints = input_lines.filter-map( fn(s)
        if (s == "") then Nothing else Just(str-to-blueprint(s))
    )
    blueprints.map(fn(x) println(x.ore-robot.ore))
    blueprints.map(fn(x) println(best-geodes(
        x,
        State(0, 0, 0, 0,
              1, 0, 0, 0),
        23
    )))
    return ()
