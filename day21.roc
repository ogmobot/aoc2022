app "day21"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.5.0/Cufzl36_SnJ4QbOoEmiJ5dIpUxBvdB3NEySvuH82Wio.tar.br" }
    imports [
        pf.File,
        pf.Path,
        pf.Stdout,
        pf.Task
    ]
    provides [main] to pf

Monkey : [
    OpMonkey Str Str Str,
    AtomicMonkey I64,
    SolverMonkey Str Str,
    UnknownMonkey
]

Expr : [
    Atom I64,
    Tree Str Expr Expr,
    Unknown
]

parseDefault : Str, I64 -> I64
parseDefault = \s, d ->
    when (Str.toI64 s) is
        Ok val -> val
        Err _  -> d

exprToInt : Expr -> I64
exprToInt = \expr ->
    when expr is
        Atom val   -> val
        Tree _ _ _ -> -1
        Unknown    -> -1

simplify : Str, Expr, Expr -> Expr
simplify = \op, left, right ->
    when left is
        Atom l ->
            when right is
                Atom r -> Atom ((strToOp op) l r)
                _      -> Tree op left right
        _ -> Tree op left right

solveEquation : Expr, Expr -> Expr
solveEquation = \left, right ->
    when left is
        Atom _ ->
            when right is
                Atom _  -> Unknown
                # left = a + b
                Tree "+" (Atom a) b -> solveEquation b (simplify "-" left (Atom a))
                Tree "+" a (Atom b) -> solveEquation a (simplify "-" left (Atom b))
                # left = a - b
                Tree "-" (Atom a) b -> solveEquation b (simplify "-" (Atom a) left)
                Tree "-" a (Atom b) -> solveEquation a (simplify "+" left (Atom b))
                # left = a * b
                Tree "*" (Atom a) b -> solveEquation b (simplify "/" left (Atom a))
                Tree "*" a (Atom b) -> solveEquation a (simplify "/" left (Atom b))
                # left = a / b
                Tree "/" (Atom a) b -> solveEquation b (simplify "/" (Atom a) left)
                Tree "/" a (Atom b) -> solveEquation a (simplify "*" left (Atom b))
                Tree _ _ _ -> Atom -1
                Unknown -> left
        Tree _ _ _ ->
            when right is
                Atom _ -> solveEquation right left
                _ -> Unknown
        Unknown -> right

evalMonkey : Str, (Dict Str Monkey) -> Expr
evalMonkey = \name, d ->
    when (Dict.get d name) is
        Ok monke ->
            when monke is
                AtomicMonkey val -> Atom val
                OpMonkey op l r  -> (simplify op (evalMonkey l d) (evalMonkey r d))
                UnknownMonkey    -> Unknown
                SolverMonkey l r -> solveEquation (evalMonkey l d) (evalMonkey r d)
        Err _ -> Atom -1

strToOp : Str -> (I64, I64 -> I64)
strToOp = \opStr ->
    when opStr is
        "+" -> Num.add
        "-" -> Num.sub
        "*" -> Num.mul
        "/" -> Num.divTrunc
        "=" -> (\a, b -> if a == b then 1 else 0)
        _   -> Num.add

strToMonkey : (Dict Str Monkey), Str -> (Dict Str Monkey)
strToMonkey = \d, s ->
    words = Str.split s " "
    when words is
        [name, val] -> (Dict.insert d
            (Str.replaceEach name ":" "")
            (AtomicMonkey (parseDefault val 0))
        )
        [name, lt, op, rt] -> (Dict.insert d
            (Str.replaceEach name ":" "")
            (OpMonkey op lt rt)
        )
        _ -> d

newRoot : (Dict Str Monkey) -> Monkey
newRoot = \d ->
    backup = AtomicMonkey -1
    root = Dict.get d "root"
    when root is
        Ok monke ->
            when monke is
                OpMonkey _ l r -> SolverMonkey l r
                _ -> backup
        Err _ -> backup

solve = \contents ->
    monkeys = Str.split (Str.trim contents) "\n"
        |> List.walk (Dict.empty {}) strToMonkey
    p1res = evalMonkey "root" monkeys |> exprToInt

    p2res = evalMonkey "root" (
        monkeys
            |> Dict.insert "root" (newRoot monkeys)
            |> Dict.insert "humn" UnknownMonkey
    ) |> exprToInt

    Str.joinWith [Num.toStr(p1res), Num.toStr(p2res)] "\n" |> Stdout.line

main =
    task =
        contents <- File.readUtf8 (Path.fromStr "input21.txt") |> Task.await
        (solve contents)
    Task.attempt task \result ->
        when result is
            Ok {} -> Stdout.write ""
            Err _ -> Stdout.line "Error!"
