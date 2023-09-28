module Main
import Data.List
import Data.String
import System.File

data NestedList  = Nil | Cons NestedList NestedList | Atom Int
data ParseResult = Parsed NestedList Nat

reducePairwise : (a -> a -> b) -> List a -> List b
reducePairwise f (x :: y :: xs) = (f x y) :: (reducePairwise f xs)
reducePairwise f _ = []

-- Easy part: the comparison function
compareList : NestedList -> NestedList -> Ordering
compareList (Atom x) (Atom y) = compare x y
compareList (Cons x xs) (Cons y ys) = case (compareList x y) of
                                        EQ        => compareList xs ys
                                        otherwise => compareList x  y
compareList (Cons _ _) Nil        = GT
compareList Nil        (Cons _ _) = LT
compareList Nil        Nil        = EQ
compareList (Atom x) ys = compareList (Cons (Atom x) Nil) ys
compareList xs (Atom y) = compareList xs (Cons (Atom y) Nil)

-- Hard part: parsing nested lists
partial -- since strIndex and strTail don't realise `s` can't be length 0
tokenise : String -> List String
tokenise "" = []
tokenise s = case (strIndex s 0) of
        '['        => "[" :: tokenise (strTail s)
        ']'        => "]" :: tokenise (strTail s)
        ','        =>        tokenise (strTail s)
        otherwise  => let (n, xs) = span isDigit s in
                        n :: tokenise xs

parseList : (List String) -> Maybe ParseResult
-- tokens should consist only of [ or ] or integers (no commas!)
-- e.g. [ 1 [ 2 3 ] 4 ]
parseList                Nil = Nothing
parseList ("[" :: "]" :: xs) = Just (Parsed Nil 2)
parseList ("[" :: xs) = case (parseList xs) of
            Nothing => Nothing
            Just (Parsed car n) => let rest = parseList ("[" :: (drop n xs)) in
                case rest of
                    Nothing => Nothing
                    Just (Parsed cdr m) => Just (Parsed (Cons car cdr) (n + m))
parseList (x :: xs) = case (parseInteger x) of
            Nothing => Nothing
            Just x' => Just (Parsed (Atom x') 1)

partial -- since tokenise is partial
loadFile : String -> (List NestedList)
loadFile s = map (\ line =>
                case parseList (tokenise line) of
                    Nothing => Nil
                    Just (Parsed list _) => list
    ) (filter (\l => (length l > 0)) (lines s) )

countLessThan : NestedList -> (List NestedList) -> Nat
countLessThan x xs = length (filter (/= LT) (map (compareList x) xs))

partial -- since loadFile is partial
doPart1 : String -> Nat
doPart1 s = let lists = loadFile s in
    foldl
        (\acc, (ord, x) => if (ord == LT) then (x + acc) else acc)
        0
        ((\x => zip x [1..(length x)]) (reducePairwise compareList lists))

partial -- since loadFile is partial
doPart2 : String -> Nat
doPart2 s = let lists = loadFile s in
    (*)
        (1 + (countLessThan (Cons (Cons (Atom 2) Nil) Nil) lists))
        (2 + (countLessThan (Cons (Cons (Atom 6) Nil) Nil) lists))

partial -- since doPart1 and doPart2 are partial
main : IO ()
main = do
    file <- readFile "input13.txt"
    case file of
        Left err   => printLn "Error"
        Right text => do
            printLn (doPart1 text)
            printLn (doPart2 text)
