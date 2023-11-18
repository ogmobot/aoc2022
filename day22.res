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
    (1000 * (row + 1)) + (4 * (col + 1)) + facing;
};

let turnright = (locHash) => {
    let mod4 = mod(locHash, 4);
    locHash - mod4 + mod(mod4 + 1, 4);
};
let turnleft = (locHash) => {
    let mod4 = mod(locHash, 4);
    locHash - mod4 + mod(mod4 + 3, 4);
};

let forwardOne = (row, col, facing) => {
    switch facing {
    | 0 => (row, col + 1);
    | 1 => (row + 1, col);
    | 2 => (row, col - 1);
    | 3 => (row - 1, col);
    // impossible
    | _ => {
        Js.Console.log("Attempted to turn in invalid direction!");
        (row, col);
    };
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
    let (finalR, finalC) = forwardOne(resR.contents, resC.contents, facing);
    switch lookup(lines, finalR, finalC) {
    | '.' => (locationHash(r, c, facing),
              locationHash(finalR, finalC, facing));
    |  _  => (locationHash(r, c, facing),
              locationHash(r, c, facing));
    };
};

let part2BlankCase = (lines, r, c, facing) => {
    // Oh boy, here we go...
    // .AB
    //  C
    // DE    bug going from 3250 -> +14 -> to 148012
    // F                     (arrives instead at 103012)
    let blocked = (locationHash(r, c, facing), locationHash(r, c, facing));
    let doPortal = (toR, toC, toF) => switch lookup(lines, toR, toC) {
    | '.' => (locationHash(r, c, facing),
              locationHash(toR, toC, toF));
    |  _  => blocked;
    };
    switch facing {
    | 0 => { // Right
        switch c {
        | 49 => { // face F (maps to bottom of face E)
            let toR = 149;
            let toC = (r - 150) + 50;
            doPortal(toR, toC, 3);
        };
        | 99 => { // faces C and E
            if r <= 99 { // face C (maps to bottom of face B)
                let toR = 49;
                let toC = (r - 50) + 100;
                doPortal(toR, toC, 3);
            } else {     // face E (maps to right of face B)
                let toC = 149;
                let toR = 49 - (r - 100);
                doPortal(toR, toC, 2);
            };
        };
        | 149 => { // face B (maps to right of face E)
            let toR = 149 - (r - 0);
            let toC = 99;
            doPortal(toR, toC, 2);
        };
        | _ => (0, 0); // Impossible
        };
    };
    | 1 => { // Down
        switch r {
        | 49 => { // face B (maps to right of face C)
            let toR = (c - 100) + 50;
            let toC = 99;
            doPortal(toR, toC, 2);
        };
        | 149 => { // face E (maps to right of face F)
            let toR = (c - 50) + 150;
            let toC = 49;
            doPortal(toR, toC, 2);
        };
        | 199 => { // face F (maps to top of face B)
            let toR = 0;
            let toC = (c - 0) + 100;
            doPortal(toR, toC, 1);
        };
        | _ => (0, 0); // Impossible
        };
    };
    | 2 => { // Left
        switch c {
        | 0 => { // face D or face F
            if r <= 149 { // face D (maps to left of face A)
                let toR = 49 - (r - 100);
                let toC = 50;
                doPortal(toR, toC, 0);
            } else {      // face F (maps to top of face A)
                let toR = 0;
                let toC = (r - 150) + 50;
                doPortal(toR, toC, 1);
            };
        };
        | 50 => { // face A or face C
            if r <= 49 { // face A (maps to left of face D)
                let toR = 149 - (r - 0);
                let toC = 0;
                doPortal(toR, toC, 0);
            } else {     // face C (maps to top of face D)
                let toR = 100;
                let toC = (r - 50) + 0;
                doPortal(toR, toC, 1);
            };
        };
        | _ => (0, 0); // Impossible
        };
    };
    | 3 => { // Up
        switch r {
        | 0 => { // face A or face B
            if c <= 99 { // face A (maps to left of face F)
                let toR = (c - 50) + 150;
                let toC = 0;
                doPortal(toR, toC, 0);
            } else {     // face B (maps to bottom of face F)
                let toR = 199;
                let toC = (c - 100) + 0;
                doPortal(toR, toC, 3);
            };
        };
        | 100 => { // face D (maps to left of face C)
            let toR = (c - 0) + 50;
            let toC = 50;
            doPortal(toR, toC, 0);
        };
        | _ => (0, 0); // Impossible
        };
    };
    | _ => (0, 0); // Impossible
    };
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

let rec splitInstructions = (longString) => {
    // There's probably a better way to do this!
    let res = %re("/(R|L|\d+)/g") -> Js.Re.exec_(longString);
    switch res {
    | Some(x) => {
        let captured = Js.Nullable.toOption(Js.Re.captures(x)[1]);
        let element = Js.Option.getWithDefault("X", captured);
        let remaining = Js.String2.substringToEnd(
            longString,
            ~from = Js.String.length(element)
        );
        Js.List.cons(
            element,
            splitInstructions(remaining)
        );
    }
    | None => list{};
    };
};

let followInstructions = (mazeMap, instructions) => {
    let c = ref(0);
    while !(mazeMap -> Belt.Map.Int.has(
            locationHash(0, c.contents, 0)
    )) {
        c := c.contents + 1;
    }
    let loc = ref(locationHash(0, c.contents, 0));
    Belt.List.forEach(instructions, (instr) => {
        switch instr {
        | "R" => {
            loc := turnright(loc.contents);
            //Js.Console.log("Turned R, arrived at " ++ Belt.Int.toString(loc.contents));
        };
        | "L" => {
            loc := turnleft(loc.contents);
            //Js.Console.log("Turned L, arrived at " ++ Belt.Int.toString(loc.contents));
        };
        | x   => {
            let dist = Belt.Int.fromString(x) -> Js.Option.getWithDefault(0, _);
            if dist == 0 {
                Js.Console.log("Failed to parse integer!");
            };
            for _ in 1 to dist {
                loc := Belt.Map.Int.get(mazeMap, loc.contents) -> Js.Option.getWithDefault(0, _);
                //if loc.contents == 0 {
                    //Js.Console.log("Failed table lookup!");
                //};
            };
            //Js.Console.log("Moved " ++ Belt.Int.toString(dist) ++ ", arrived at " ++ Belt.Int.toString(loc.contents));
        };
        };
    });
    loc.contents;
};

let parseInput = (bigString) => {
    // Last line is blank
    let lines = Js.String.split("\n", bigString);
    let numLines = Array.length(lines);
    let mazeLines = Belt.Array.slice(lines, ~offset = 0, ~len = (numLines - 2));
    // return value
    {
        lines: mazeLines,
        instr: lines[numLines - 2],
    };
}

let theInput = parseInput(readFileSync(~name = "input22.txt", #utf8));
let theInstructions = splitInstructions(theInput.instr);
let p1Maze = mazeMap(theInput.lines, part1BlankCase);
Js.Console.log(followInstructions(p1Maze, theInstructions));
let p2Maze = mazeMap(theInput.lines, part2BlankCase);
Js.Console.log(followInstructions(p2Maze, theInstructions));
