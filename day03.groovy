def getPriority(c) {
    if (c.toLowerCase() == c) {
        return ((int) c) - ((int) 'a') + 1
    } else {
        return ((int) c) - ((int) 'A') + 27
    }
}

def pairs = [];
def triples = [];

new File("input03.txt").withInputStream { stream ->
    def i = 0;
    def pair = [];
    def triple = [];
    stream.eachLine { line ->
        // part 1
        pair << line.substring(0, (line.length()/2).intValue())
        pair << line.substring((line.length()/2).intValue())
        pairs.add(pair.clone())
        pair = []
        // part 2
        i++
        triple << line
        if (i == 3) {
            i = 0
            triples.add(triple.clone())
            triple = []
        }
    }
}

println pairs.collect { pair ->
    getPriority(
        pair.get(0).toList()
            .intersect(pair.get(1).toList())
            .get(0)
    )
}.sum()

println triples.collect { triple ->
    getPriority(
        triple.collect {it.toList()}
              .inject {x, y -> x.intersect(y)}
              .get(0)
    )
}.sum()

// Huh, "collect" and "inject" instead of "map" and "reduce".
