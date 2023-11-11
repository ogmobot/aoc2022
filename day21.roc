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
    OpMonkey (I64, I64 -> I64) Str Str,
    AtomicMonkey I64,
    UnknownMonkey
]

parseDefault : Str, I64 -> I64
parseDefault = \s, d ->
    when (Str.toI64 s) is
        Ok val -> val
        Err _  -> d

evalMonkey : Str, (Dict Str Monkey) -> I64
evalMonkey = \name, d ->
    when (Dict.get d name) is
        Ok monke ->
            when monke is
                AtomicMonkey val -> val
                OpMonkey op l r  -> op (evalMonkey l d) (evalMonkey r d)
                UnknownMonkey    -> 0
        Err _ -> -1

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
            (OpMonkey (strToOp op) lt rt)
        )
        _ -> d

solve = \contents ->
    monkeys = Str.split (Str.trim contents) "\n"
        |> List.walk (Dict.empty {}) strToMonkey
    evalMonkey "root" monkeys
        |> Num.toStr |> Stdout.line

main =
    task =
        contents <- File.readUtf8 (Path.fromStr "input21.txt") |> Task.await
        (solve contents)
    Task.attempt task \result ->
        when result is
            Ok {} -> Stdout.write ""
            Err _ -> Stdout.line "Error!"
