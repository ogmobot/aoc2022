import std/os/path
import std/os/file

val g-test-data = [
    "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
    "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."
]
/*
    Blueprint 1 should build *at most* 3 ore robots;
                                      14 clay robots;
                                       7 obsidian robots.
        It ought to go thru states...
            0.0.0.0|1.0.0.0 remaining=23
            1.0.0.0|1.1.0.0 remaining=20
            1.2.0.0|1.2.0.0 remaining=18
            1.6.0.0|1.3.0.0 remaining=16
            2.4.0.0|1.3.1.0 remaining=12
            1.7.1.0|1.4.1.0 remaining=11
            1.5.4.0|1.4.2.0 remaining=8
            2.17.3.0|1.4.2.1 remaining=5
            3.29.2.3|1.4.2.2 remaining=2
    Blueprint 2 should build *at most* 3 ore robots;
                                       8 clay robots;
                                      12 obsidian robots.
*/
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
    var res : bool := False
    match resource
        // ore is used for every robot
        0 -> res := (initial-state.d-ore < bp.ore-robot.ore
         && initial-state.d-ore < bp.cla-robot.ore
         && initial-state.d-ore < bp.obs-robot.ore
         && initial-state.d-ore < bp.geo-robot.ore
        )
        // clay is used only for obsidian robots
        1 -> res := (initial-state.d-cla < bp.obs-robot.cla)
        // obsidian is used only for geode robots
        2 -> res := (initial-state.d-obs < bp.geo-robot.obs)
        3 -> res := True
    return res

fun continuous-production(bp : blueprint, st : state)
    return st.d-ore >= bp.geo-robot.ore && st.d-obs >= bp.geo-robot.obs

fun best-geodes(
    bp : blueprint ,
    initial-state : state ,
    remaining-time : int
)
    // Wonder if we can just DFS this...
    if remaining-time < 0 then
        return -1
    
    print("best-geodes with initialstate as ")
    print(initial-state.ore) ; print(".") ;
    print(initial-state.cla) ; print(".") ;
    print(initial-state.obs) ; print(".") ;
    print(initial-state.geo) ; print("|") ;
    print(initial-state.d-ore) ; print(".") ;
    print(initial-state.d-cla) ; print(".") ;
    print(initial-state.d-obs) ; print(".") ;
    print(initial-state.d-geo) ;
    print(" remaining=") ; println(remaining-time)
    
    if continuous-production(bp, initial-state) then
        // Enough resources to build a geode robot every minute
        // TODO triangular numbers formula?
        return max(
            initial-state.geo,
            best-geodes(
                bp,
                build-state(bp, initial-state, 3, 0),
                remaining-time - 1
            )
        )
    Cons(
        initial-state.geo + (remaining-time * initial-state.d-geo),
        [3, 2, 1, 0].filter-map(fn(i)
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
    println(
        zipwith(blueprints, list(1, length(blueprints)), fn(x, i)
            print("Testing blueprint ") ; println(i)
            val res = best-geodes(
                x,
                State(0, 0, 0, 0,
                      1, 0, 0, 0),
                24
            )
            println(res)
            return res * i
        ).sum
    )
    return ()
