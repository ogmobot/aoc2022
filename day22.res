@module("fs")
external readFileSync: (
    ~name: string,
    [#utf8],
) => string = "readFileSync";

type parseResult = {
    lines: array<string>,
    instr: string,
};

let locationHash = (row, col, facing) => {
    // 0 = right, 1 = down, 2 = left, 3 = up
    (1000 * row) + (4 * col) + facing;
};

let forwardOne = (row, col, facing) => {
    switch facing {
    | 0 => (row, col + 1);
    | 1 => (row + 1, col);
    | 2 => (row, col - 1);
    | 3 => (row - 1, col);
    // impossible
    | _ => (row, col);
    }
};

let lookup = (lines, r, c) => {
    if r < 0 || r >= Array.length(lines) {
        ' ';
    } else {
        let row = lines[r];
        if c < 0 || c >= Js.String.length(row) {
            ' ';
        } else {
            String.get(row, c);
        };
    };
};

let part1BlankCase = (lines, r, c, facing) => {
    // Step backwards until another blank is encountered
    let revFacing = mod((facing + 2), 4);
    let resR = ref(r);
    let resC = ref(c);
    while lookup(lines, resR.contents, resC.contents) != ' ' {
        let (tmpR, tmpC) = forwardOne(resR.contents, resC.contents, revFacing);
        resR := tmpR;
        resC := tmpC;
    };
    (locationHash(r, c, facing),
     locationHash(resR.contents, resC.contents, facing));
};

let mazeMap = (lines, ruleForBlank) => {
    // Given a set of lines of text, produces a mapping where
    // the hash of each location maps to the hash of the location
    // one step forward from there.
    // Parameter ruleForBlank is a function that takes
    // (lines, r, c, facing) and maps to another location.
    Belt.Array.range(0, Array.length(lines)-1) -> Belt.Array.map((r) => {
        let row = lines[r];
        Belt.Array.range(0, Js.String.length(row)-1) -> Belt.Array.map((c) => {
            let symb = String.get(row, c);
            if symb == '.' {
                [0, 1, 2, 3] -> Belt.Array.map((facing) => {
                    let (newR, newC) = forwardOne(r, c, facing);
                    let newSymb = lookup(lines, newR, newC);
                    switch newSymb {
                    | '.' => (locationHash(r, c, facing),
                              locationHash(newR, newC, facing));
                    | '#' => (locationHash(r, c, facing),
                              locationHash(r, c, facing));
                    |  _  => ruleForBlank(lines, r, c, facing);
                    }
                });
            } else {
                [];
            };
        }) -> Belt.Array.concatMany(_);
    }) -> Belt.Array.concatMany(_) -> Belt.Map.Int.fromArray(_);
};

let splitInstructions = (longString) => array<string> {
    let res = Js.Re.fromString("(\\[R|L|(1-9)*]\\)*") -> Js.Re.exec_(longString);
    switch res {
    | Some(x) => x;
    | None    => [];
    };
};

let followInstructions = (mazeMap, instructions) => {
    let r = ref(0);
    let c = ref(0);
    let facing = ref(0);
    while !(mazeMap -> Belt.Map.Int.has(
            locationHash(r.contents, c.contents, facing.contents)
    )) {
        c := c.contents + 1;
    }
    for i in 0 to Array.length(instructions) - 1 {
        // Must do this in order, hence `for` instead of `map`
        Js.Console.log(instructions[i]);
    }
};

let parseInput = (bigString) => {
    let lines = Js.String.split("\n", Js.String.trim(bigString));
    let numLines = Array.length(lines);
    let mazeLines = Belt.Array.slice(lines, ~offset=0, ~len=(numLines - 1));
    // return value
    {
        lines: mazeLines,
        instr: lines[numLines - 1],
    };
}

let theInput = parseInput(readFileSync(~name="input22.txt", #utf8));
let theInstructions = splitInstructions(theInput.instr);
//let p1Maze = mazeMap(theInput.lines, p1BlankCase);
//followInstructions(p1Maze, theInstructions);
Js.Console.log(theInstructions);
