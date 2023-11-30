// Types
type Coord     = { row: int; col: int }
type TimeCoord = { r: int; c: int; t: int }
type Blizzard  = { coord: Coord; facing: Coord }
// Treat walls as blizzards with facing {0, 0}
type Limits    = { minR: int; maxR: int; minC: int; maxC: int }

// Parsing
let loadBlizzards lines =
    lines |> List.mapi (fun r line ->
        line |> List.ofSeq |> List.mapi (fun c ch ->
            let pos = { row = r - 1; col = c - 1 }
            match ch with
            | '^' -> Some { coord = pos; facing = { row = -1; col =  0} }
            | 'v' -> Some { coord = pos; facing = { row =  1; col =  0} }
            | '<' -> Some { coord = pos; facing = { row =  0; col = -1} }
            | '>' -> Some { coord = pos; facing = { row =  0; col =  1} }
            | '#' -> Some { coord = pos; facing = { row =  0; col =  0} }
            |  _  -> None
        )
    ) |> List.concat |> List.collect Option.toList

// Dealing with blizzards
let rec gcd a b =
    if b = 0 then a
    else gcd b (a % b)

let simulateBlizzards blizzards maxRow maxCol =
    blizzards |> List.map (fun bliz ->
        let newRow = (bliz.coord.row + maxRow + bliz.facing.row) % maxRow
        let newCol = (bliz.coord.col + maxCol + bliz.facing.col) % maxCol
        { coord = { row = newRow; col = newCol }; facing = bliz.facing })

let calculateBlizzards blizzards maxRow maxCol =
    let period = gcd maxRow maxCol
    let mutable sim = blizzards
    let mutable res = Set.empty<TimeCoord>
    for t = 0 to period - 1 do
        for b in blizzards do
            res <- Set.add { r = b.coord.row; c = b.coord.col; t = t } res
        sim <- (simulateBlizzards sim maxRow maxCol)
    // returns a function
    fun tCoord ->
        res |> Set.contains { tCoord with t = (tCoord.t % period) }

// Pathfinding

let inBounds limits tc =
    (tc.r >= limits.minR
  && tc.r <  limits.maxR
  && tc.c >= limits.minC
  && tc.c <  limits.maxC)

let adjacent obstacles limits tCoord =
    let newT = tCoord.t + 1
    [
        { tCoord with t = newT };
        { tCoord with r = tCoord.r - 1; t = newT };
        { tCoord with r = tCoord.r + 1; t = newT };
        { tCoord with c = tCoord.c - 1; t = newT };
        { tCoord with c = tCoord.c + 1; t = newT };
    ] |> List.filter (fun tc -> (not (obstacles tc)) && (inBounds limits tc))

let findPath obstacles (imCheckpoints: Coord list) limits =
    let start = imCheckpoints.Head
    let mutable checkpoints = imCheckpoints.Tail
    let mutable fronts = 
        adjacent obstacles limits { r = start.row; c = start.col; t = 0 }
    let mutable visited = Set.empty<TimeCoord>
    while checkpoints.Length > 0 do
        let current = fronts.Head
        printfn "%A" fronts
        fronts <- fronts.Tail
        if not (Set.contains current visited) then
            visited <- Set.add current visited
            if { row = current.r; col = current.c } = checkpoints.Head then
                fronts <- []
                checkpoints <- checkpoints.Tail
                printfn "%d" current.t
            fronts <- List.concat [
                fronts ; (adjacent obstacles limits current)]

// Main
let main () =
    //      col
    //      0123M
    //     #.####
    // row0#....#
    //    1#....#
    // Start position is (row = -1, col = 0)
    // Goal position is (row = maxRow, col = maxCol - 1)
    let lines = List.ofSeq (System.IO.File.ReadLines "input24.txt")
    let maxRow = lines.Length - 2
    let maxCol = lines.Head.Length - 2
    let blizzards = loadBlizzards lines
    let blizzardNoJutsu = calculateBlizzards blizzards maxRow maxCol
    findPath blizzardNoJutsu [
        { row = -1; col = 0 };
        { row = maxRow; col = maxCol + 1 }; // There ...
        { row = -1; col = 0 }               // ... and back ...
        { row = maxRow; col = maxCol + 1 }; // ... and back again
    ] { minR = -1; maxR = maxRow + 1; minC = 0; maxC = maxCol }
    printfn "Done."

main()
// expected 232 715
