import std/os/path
import std/os/file

val g-test-data = [
    "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
    "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."
]

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

ref type state-node
    Nil
    State-Node
        // heap sorts by time
        state : state
        time  : int
        left  : state-node
        right : state-node

// Priority Queue functions
// TODO

// Lookup Tree functions
// TODO

// Parsing
fun parse-it( s : maybe<string> )
    s.default("").parse-int.default(0)

fun str-to-blueprint( s : string )
    val words = split(s, " ")
    return Blueprint(
        ore-robot = Reqs(words[6].parse-it, 0, 0, 0),
        cla-robot = Reqs(words[12].parse-it, 0, 0, 0),
        obs-robot = Reqs(words[18].parse-it, words[21].parse-it, 0, 0),
        geo-robot = Reqs(words[27].parse-it, 0, words[30].parse-it, 0)
    )

// Main
fun best-geodes( bp : blueprint )
    var nodes := State-Node(Nil)
    return 0

fun main()
    //val input_lines = read-text-file(path("input19.txt")).lines
    val input_lines = g-test-data
    val blueprints = input_lines.filter-map( fn(s)
        if (s == "") then Nothing else Just(str-to-blueprint(s))
    )
    blueprints.map(fn(x) println(x.ore-robot.ore))
    println([1, 2, 3].foldl(0, fn (x, y) {x + y}))
    return ()
