Advent of Code 2022
===================
Another year, another 25 languages. This time around, I solved them first in Python before attempting a language I was less familiar with. (That program was often not written on the same day.) In 2021, I spent some time prior to the event setting up basic programs in the languages I was attempting, but I was less organised this year and would often need to download a language implementation on the day I wrote the program.

Day 01: INTCODE
---------------
I've implemented an Intcode VM three times now, by my count; once in Python, during the 2019 challenge; once in Common Lisp, when revisiting the Intcode challenges the following year, and after losing my Python version; and once in C, earlier in 2022, as part of collecting every Advent of Code star.

Rather than writing an INTCODE program to operate in ASCII mode, I took the simpler path of having the program accept numeric data (although this required me to modify the input data).

`cat input01.orig | awk '{ if (NF == 0) { print 0 } else { print $1 } } END { print "0\n0" }' > input01.txt`

I think my design for the assembly language was inspired by `uxntal`, which uses the `@` glyph for labels. I don't have a compiler or assembly for this language -- instead, I assembled all 29 opcodes of the program by hand.

**INTCODE**: not a language designed for scripting.

**Syntax Highlight**: writing a syntax that allowed for using label values in immediate mode `$(label)` felt pretty nice

Day 02: Forth
-------------
Last year I tried Factor, this year the more "traditional" GForth. I solved the puzzle in a pretty braindead way, but that gave me headspace to figure out stuff like memory allocation for line buffers. In that sense, at least, Forth is a lower-level language than I'd usually use for puzzles like this. The nature of Forth-word compilation means the language is very fast, and it's a lot easier to handle than languages that translate direction to e.g. x86 instructions. (I know because I tried Day 1's puzzle in x86 assembly before I settled on Intcode.)

**Forth**: stash your preconceived notions of structure and get your head into the stack.

**Syntax Highlight**: `cr` (print a carriage return -- i.e. a newline -- to stdout)

Day 03: Groovy
--------------
Oh hey, a JVM language. Feels a little like Java, but a lot more functional and with type inferrence. The built-in `intersect` method was super useful in this puzzle. One thing that I found odd (and required some Googling to figure out) was the language's use of `collect` and `inject` to describe the higher-order functions that I know as `map` and `reduce`.

**Groovy**: it ain't Scala, Clojure or Kotlin... but at least it ain't Java.

**Syntax Highlight**: `<<` (append to list)

Day 04: AWK
-----------
I regret that I never spent the time to look at this language in more detail before. It's a beautiful little tool for processing text files -- imagine an entire program wrapped in `while (line := read stdin) { ... }` by default. (See the Day 01 entry above for a typical `AWK` script!)

The nature of AWK's straightforward text processing made writing this program a cinch.

**AWK**: the perfect tool for line-by-line file processing.

**Syntax Highlight**: `$1` (the first word in the current line)

Day 05: C#
----------
I Find Writing Programs In This Language Kind Of Bothersome. Did Microsoft Really Need To Capitalise *Method Names* In All Of Their Standard Libraries? Attempting To Call `.length` Or `.add` Instead Of `.Length` And `.Add` Tripped Me Up So Many Times.

I Solved This Puzzle By Hardcoding The Size Of The Expected Input, As Well As Using The *First* Element Of Each List As The Top Of A Stack. This Is Probably An Inefficient Way To Manipulate Lists, But It Was Easier To Code And More Closely Matched My (Admittedly Hacky) Fast Python Implementation.

Besides The Capital Letters, It Feels Almost Indistinguishable From Java.

**C#**: I Can't Believe It's Not Java!

**Syntax Highlight**: `using` (Many Important Functions, Like Printing To Stdout, Are Imported From Modules, Just Like C/C++/Java/Go/Etc.)

Day 06: [uxntal](https://git.sr.ht/~rabbits/uxn)
------------------------------------------------
For this language, I took a break from Vim and instead wrote the program in Left, a text editor written in uxntal. Uxntal is the assembly language for the `uxn` fantasy cpu dreamt up by Devine Lu Linvega of 100 Rabbits. They've also developed Drifblim (an assembler), Uxnlin (a linter) and Beetbug (a debugger) in this language, although I didn't use them for this program.

100 Rabbits' aim (as I understand it) is to create a technology stack that uses a simple, well-defined VM to avoid the problems that the studio had while attempting to develop iOS software -- namely high energy consumption, the constant mandatory updates, and old programs becoming unusable due to those updates. They seem to have largely achieved that goal, as many common computer applications (text processing, drawing, sprite- or hex-editing, filesystems, calculator, rudimentary OS) now exist within the Varvara ecosystem.

Uxntal feels like a cross between assembly and Forth. I kept trying to give arguments to my functions by writing them after the function's name (`JMP ,&next`), but that's not how Forths work. Weird language. I like it.

**Uxntal**: a language for the systems of post-collapse Earth.

**Syntax Highlight**: `LDA2kr` (`2`, `k` and `r` can be used to modify the meaning of a word: Load (**2** bytes) (**k**eeping the argument on the stack) (using **r**eturn stack, not working stack))

Day 07: JavaScript
------------------
This was a pretty straightforward translation of my Python solution, although a few bits were tidied up. I think I prefer the relative safety of TypeScript (although if you ignore the static type-checking, the languages are just about identical). Notable differences from Python are the C-like ternary operator and the anonymous function syntax.

**JavaScript**: not just for web pages.

**Syntax Highlight**: `x => f(x)` (anonymous functions are very comfy)

Day 08: Chapel
--------------
After a long break, I've decided to use the Chapel language for this task. Most of the syntax seems fairly straightforward, but the syntax for designating the intent of a set of parallel tasks (for example, in the `forall` loops in this solution) was not something I've seen before.

I had a lot of difficulty trying to put together the Chapel compiler. Eventually I gave up and used an online implementation. Unfortunately, this means I wasn't able to test reading from files other than standard input.

**Chapel**: run everything in parallel (if you can run it at all).

**Syntax Highlight**: `coforall` (just like `for`, but spawns a separate thread for each loop iteration)

Day 09: [Noulith](https://github.com/betaveros/noulith)
-------------------------------------------------------
Noulith is still in active-ish development, so for reference's sake, this is the language as it existed in mid-September 2023. Its creator, betaveros (Brian Chen), had in mind a language for "quick-and-dirty scripts" and it seems to fit that kind of program pretty well. The language passes all function arguments by value, which I think is a good idea. In a sense, though, that makes it a poor fit for the method I used to solve this problem (i.e. dumping thousands of coordinate pairs into a hash table). Values can still be passed by reference, in a sense, by first setting up a closure.

My solution for this program uses LISP-style linked lists and functions. I could have set up an ordinary list instead (as I did in the Python version of this solution), but the immutability of Noulith made this seem like a neater solution. I suppose I could have solved it with a single monolithic function, since data structures can be mutated within a single scope, but I find smaller functions easier to deal with.

The relatively slow speed of the language definitely feels like it was set up to write little scripts, rather than tracking the locations of ten moving objects across thousands of steps. Still, better to use Noulith for this task rather than an even more computationally-intensive one.

P.S. betaveros himself also used this language to solve this task. His code can be found [here](https://github.com/betaveros/advent-of-code-2022/blob/main/p9-post.noul) and is a lot cleaner than mine!

**Noulith**: a neat little language for neat little tasks.

**Syntax Highlight**: `f := \ x -> ...` (like in Scala, functions are defined by assigning an anonymous function to a variable; and like in Haskell, anonymous functions are defined with \\)

Day 10: 6502 Assembly
---------------------
Phew, this was a tough one. I thought it'd be appropriate to solve the task inspired by "racing the beam" in a language contemporaneous with that problem, but the machine language designed for an eight-bit processor came with a fair few challenges.

The first was parsing input. Lacking a primitive multiplication operation, I elected to parse two-digit numbers by adding the tens digit to the total ten times. (I initially did this to the units digit by mistake, leading to '32', for instance, being parsed as `23`.) If a `-` appeared, it the number was negated with two's complement.

Another hurdle was debugging -- as it turns out, my usual method of adding more `print` statements isn't great when converting a value to printable characters has its own subroutine. Instead, I would call putchar on the value itself, then run the program output through hexdump. (I used this method to discover a bunch of off-by-one memory errors, but it was a fair bit of hassle.)

Finally, the program needed to deal with a fair few 16-bit values: multipling pairs of 8-bit values to make 16-bit values, summing those values, and printing the result. Luckily, because the 6502 is so well known (and remembered), a wide variety routines for dealing with 16-bit (or 24-bit, 32-bit) values is available online. I needed to cobble a fair few of them together to get this program working.

Many thanks to Rich Talbot-Watkins and Ian Piumarta, the authors of *Beebasm* and *run6502* respectively, without which I would have had a much harder time.

**6502 Assembly**: it's easier to write than x86.

**Syntax Highlight**: `EQU` (sets the value at this memory location to a literal value -- so you would use this to write a program by writing out the numeric value of every opcode by hand, instead of using mnemonics)

Day 11: Hare
------------
*The Hare and the Monkeys*... wasn't that one of Aesop's fables?

Hare is a language that reminds me a lot of Zig, in that it allows very fine control of memory allocation and has features designed to interoperate with C. I spent a lot of time ensuring the program didn't leak memory, implicitly cast to potentially incompatible types, didn't implicitly ignore possible errors, etc. (just as I would have in Zig, or Rust). As to which I prefer out of Zig and Hare, I'm not yet sure. Hare's automatic pointer dereferencing is nice, but I prefer Zig's approach for the syntax of structure literals. Both languages are still in development, but I don't think either one will clearly win out over the other. Right now, I'm more familiar with Zig, so if I was forced to choose between the two, I suppose that would be the deciding factor.

While writing this program I discovered a bug in my original Python implementation -- I had modified it after writing Part 2 in a way that stopped my Part 1 solution from working. (I was trying to work out why my Hare program produced the "wrong" answer compared to the Python one -- but it turns out the Hare program wasn't the one with the issue!)

**Hare**: yet another better C.

**Syntax Highlight**: `assert((*p).x == p.x)` (auto-dereferencing)

Day 12: Femtolisp
-----------------
Ah, I love writing that `(cons new-coord old-path)` that you get when pathfinding in Lisp. Femtolisp wasn't a very surprising language, and most of this program could run without modification in any other Scheme interpreter. For some reason, my Femtolisp interpreter doesn't like writing to the standard output stream when running code from a file, so I wrote the output to the standard error stream instead. It also had trouble understanding functions like `with-input-from-file`.

**Femtolisp**: it's just LISP (but small).

**Syntax Highlight**: `integer?` (functions that test a predicate typically end with `?` to indicate this)

Day 13: Idris
-------------
Idris is a language very similar to Haskell: it's a language with a focus on types and pure functions. Just like last year's Haskell program, the toughest part of the Idris program was dealing with input and output (and just like last year's Haskell program, everything instantly worked correctly as soon as the IO got off the ground). Idris makes a small concession on completeness compared to Haskell -- it allows the modifier `partial` to indicate a function doesn't handle all possible input values. Other than that, I couldn't really tell the difference between the languages (although part of that is definitely due to my unfamiliarity with both languages).

The main difference between the Python and Idris implementations of this task is that Python "parses" the input file with `eval`. *This is a terrible idea!* In Idris, I took the time to write an actual parser. I also set up a LISP-inspired "NestedList" type for Idris, since I couldn't work out how to make a List type that could contain elements of its own type. Again, someone more familiar with Idris (or Haskell) could likely do a much better job.

**Idris**: just like Haskell, but different(?).

**Syntax Highlight**: `partial` (by default, functions are `covering`, and must account for all possible input values -- but this behaviour can be overridden)

Day 14: MoonScript
------------------
MoonScript is a layer of syntactic sugar on top of Lua. It's a nicer language to write in compared to Lua -- shortcuts like `i += 1` and `continue` that aren't present in Lua work just as you'd expect in MoonScript. (The local-by-default variables are nice, too.) Its developer describes it as "CoffeeScript for Lua", which makes me suspect I'd enjoy CoffeeScript as well.

My solution for this problem is essentially the same as the Python version, but with integer keys for the hashtable used to compute the solution. Compiling and printing the code in Lua with `moonc -p day14.moon` was useful on a few occasions. MoonScript has a lot of support for object-oriented programming that I didn't take advantage of here.

**MoonScript**: Lua with added sugar.

**Syntax Highlight**: `[i for i in iter when i > 0]` (list comprehensions)

Day 15: Prolog
--------------
What a weird language. Prolog is a language in which the order of statements (in theory) makes little difference to the output of a program, except perhaps the order of I/O side-effects. In practice, the order of statements can make a big difference to the program's performance. My Prolog implementation runs more slowly than my Python one -- which was not entirely unexpected -- but I'm sure someone more familiar with the language would be able to improve the run time by a fair amount.

Prolog's a very good language for solving problems that have multiple constraints or solutions. To learn the basics of the language, I wrote a program to solve a specific instance of the kind of puzzle that runs, "Five men live in five houses, with their five pets and five favourite drinks. Given the following set of restrictions, determine who owns the zebra..." Prolog makes solving problems of this kind extraordinarily straightforward.

For part 2, I could have written a more succinct program along these lines:

`part2(Probes) :- between(0, 4M, X), between(0, 4M, Y), not_covered((X, Y), Probes).`

This program, although very easy to read, would not terminate in a reasonable amount of time.

**Prolog**: it's the most declarative there is.

**Syntax Highlight**: `!` ("cut", the instruction to cease seeking solutions)

Day 16: Terra
-------------
I find it fascinating that programs written in this language are necessarily "bilingual": all top-level code is Lua! Writing Terra feels a lot like writing C -- indeed, it can call C libraries directly -- except that it has all the trimmings of a much more modern language (like `defer` and automatically dereferencing pointers). The syntax, fittingly, is just like Lua's; with a few extensions like static typing that make compilation easier. Using Terra alongside both Lua (top-level or inline) and the C standard library functions makes it feel almost like writing in three languages at once.

The language (like C!) does not have a built-in priority queue structure, nor queues, nor hash tables, etc. I implemented a few hash tables by hiding them within Lua functions, but wrote the priority queue and queue implementations myself (not generically, either, since I only had to use them this one time). What a headache! I'm glad this language exists, and I think it's easier to embed Lua into a Terra project than into a C project (in fact, that happens automatically), but in a task like this which gets easier with a bit of abstraction, Terra didn't feel like the ideal language.

Although this program finds the solution to this problem in about 10 minutes, it takes longer than an hour afterwards to terminate (I didn't actually wait for it in the end). A few ways to speed it up can be found in the comments at the end of the program file, but I think I'm done with this task for now.

**Terra**: for when you need Lua to go faster.

**Syntax Highlight**: `terra` (defines a Terra function -- as opposed to `function` which defines a Lua function)

Day 17: Tcl
-----------
What a bizzare language. Everything is a string! No need for quotes around string literals -- `open input17.txt` is perfectly fine. No need to join list elements into a string -- the list already *is* a string (space-separated). Thus, no need to concatenate lists `a` and `b` -- the string `"$a $b"` (interpolating those variables) does just as well. The one thing that doesn't seem to be a string is Tcl's "array" (which is a hash table -- go figure).

Tcl's way of handling common string and array functions is another thing that I find a bit unusual. While other languages might have something like `Array.size(x)`, Tcl has `array size x` -- which, of course, passes the strings `"size"` and `"x"` to the `array` function. The string passed in selects the routine that the function carries out.

**Tcl**: it's stringly-typed.

**Syntax Highlight**: `upvar` (pulls a variable into a scope from one scope up)

Day 18: [Uiua](https://uiua.org)
--------------------------------
Uiua was a language I wanted to like, but the process of actually writing a program ended up being frustrating. The greatest annoyance was writing function applications in reverse order of many other languages; programs are read right-to-left, top-to-bottom. The author has been asked about this design choice enough times that its justification now has a dedicated web page. (It didn't lessen the annoyance.)

An example: To evaluate `f(g(h(x)))`, another language might use something like `x.h().g().f()` (like Rust), or `(->> x h g f)` (like Clojure), or `x |> h |> g |> f` (like OCaML), or even just `X H G F` (like Forth). Uiua, by contrast, writes this as `f g h x`. The only other language that follows this sort of pattern is LISP, but that language's brackets make it easier to parse: `(f (g (h x)))`. I suppose I could have avoided this annoyance by writing each word on its own line, or perhaps writing a pre-processor that reversed the order of words on each line.

Rather than learning the meaning of each glyph used by the language, I elected to spell out the name of each function with letters.

> *"Get used to it, honey -- from now on, we'll be spelling *everything* with letters!" -- Homer Simpson*

I suspect there is a neater way to write a lot of this program by using more combinators (e.g. fork, bracket, both).

**Uiua**: the backward child of Forth and APL.

**Syntax Highlight**: `⊃` (or `fork` -- applies two different functions to the same argument)

Day 19: Koka
------------
Koka, like Scala, is a language that seems like a collage of good ideas. Immutable data structures with sugary-sweet syntax for "altering" them (i.e. making a copy with changed values), first-class functions, pattern matching, brace and semicolon elision... I like the language.

That said, it's not all sunshine and daisies. The insistence of the language on identifiers starting with lowercase letters meant that I couldn't name global constants in all uppercase. The by-default immutability of data makes it a real pain to deal with data you *do* want to mutate. The language is still a work-in-progress, so the standard library is practically non-existent and one of the issues I had to contend with was *compiler bugs*. When the language matures, I think it'll be very comfy.

**Koka**: it'll be good one day!

**Syntax Highlight**: `node( data = 0 )` (creates a copy of `node`, but with the `data` field changed to `0`)

Day 20: BASIC
-------------
(Specifically, this is the *FreeBASIC* implementation of the language.) Wow, it's been a long time since I wrote anything in this language. For a language designed to be easy for beginners, it feels very... is "low-level" the term I'm looking for? Parameters can be passed by reference or by value, you have control over alignment of bytes within a user-defined structure, variables must be declared before they're used, etc.

There are a lot of idiosyncrasies to the language that seem to have been (almost) "evolutionary dead-ends". `Rem` for comments (or the alternative `'`, which I used here); `Next i` to proceed to the next iteration of a `For` loop; the use of English-language words to define ranges and types (`1 To 10`, `x As Integer`). Amusingly -- but not entirely unexpectedly -- every one of these unusual choices are present in the "generic pseudo-code" being used in the high school syllabus I'm currently teaching. I'm glad the syllabus is finally being updated next year.

Aspects of BASIC are not entirely absent from modern languages. I'm pretty sure some languages still define ranges with `1 to 10` (although `1..10` seems to be a more popular choice); others distinguish between subroutines and functions (although it tends to be a distinction between whether or not the process has side-effects, rather than whether it has a return value); the J language denotes comments with `NB.` rather than non-alphanmueric characters. Plus, I Think I've Learned Where C# Learned Its Capitalisation Habit From.

**BASIC**: living proof that the definition of "high-level language" drifts over time.

**Syntax Highlight**: `Next` (jumps to the start of the loop body and increments the loop variable -- usually used to conclude a `For` loop)

Day 21: Roc
-----------
Another language with Haskell-like purity (and pedantry); another hour of fiddling with IO routines; and another program that operated correctly when it (at last) got off the ground. This language descends from Haskell via Elm.

Roc certainly seems more different to Haskell than Idris. For instance, it's possible to run a Roc file even if warnings are present, and expressions seem to be evaluated eagerly (or perhaps that's just the `Task` module). The program's preamble is one of the strangest I've encountered: it specifies a platform for the program by naming a package file at a remote URL, then downloads files from that package at compile time. The modules imported in this program are `Task` (allows the program to produce effects), `File` (allows the program to open files), `Path` (converts a String to a Path, the only type of parameter the `File` module accepts) and `Stdout` (to write to standard output). Now, you might *think* that it would be easier to have the `File` module accept a String, rather than a Path that requires importing another module. And you'd be right. But requiring the `Path` module helps to ensure the code won't break on some other platform with different conventions for file paths, *I guess*.

I over-used pattern matching in this solution. There's almost certainly a cleaner way of writing a lot of this code. But it works, so in this state it shall stay.

**Roc**: what Haskell would be if it wasn't so lazy.

**Syntax Highlight**: `app` (part of a program's opening Module Header -- this keyword specifies it's an application module)

Day 22: ReScript
----------------
You've heard of the "better C" languages, now get ready for another "better JavaScript" language. In many ways, ReScript is what I wanted TypeScript to be. It infers and then strictly reinforces the types of data used in the program to ensure things don't get out of hand. (TypeScript, by contrast, requires the programmer to annotate types, and doesn't reinforce anything that's not annotated.) The language's `getWithDefault`, used to unwrap optional types, seemed a little verbose to me; but on the whole, the language seems pretty solid. If I had to develop an actual program in JavaScript, I think this would be my preferred way to do it.

I solved the problem in a quite different way to the Python program. Rather than keeping track of row, column and direction, I set up a mapping that indicated where each possible coordinate/facing would land after moving forward a single step. The function that carried out this task accepted an auxiliary function as a parameter which handled attempting to move off the grid. I think this made the ReScript solution a bit neater. That said, I still hard-coded each edge connection for part 2 to "fold" the cube together. I doubt I'll ever revisit this to make a general cube-folding algorithm.

**ReScript**: the best way to write solid JavaScript.

**Syntax Highlight**: ` ` (there's no `return` keyword -- the result of a function is the value of the last expression within it)

Day 23: Grain
-------------
The language ain't bad, but the compiler takes too long. Grain compiles to WebAssembly, which is a cool idea (especially for web applications), but the compiler I downloaded seems to be doing something to the entire standard library when I run it -- compiling, or transpiling, or linking, or something. This made it very frustrating to test and iterate on my program.

The language is definitely functional (har har). It seems to take a fair bit of inspiration (not to mention libraries) from OCaml. I couldn't find anything in the documentation about the `|>` operator, so I didn't use it in this solution, but the language certainly feels like it *should* be available. 

I wrote this program in a way that I'm pretty sure is O(n) per simulation step, but it still takes a very long time to run. I'm not sure whether this is the fault of Grain, WebAssembly, or me. (Each step, convert the elf-list to a hash set [O(n)], have each elf make a proposal [O(n), using hash set to check occupancy], build a frequency table of proposals [O(n)], and move each elf if the frequency of its proposal was 1 [O(n)].)

**Grain**: OCaml for WebAssembly.

**Syntax Highlight**: `File.pwdfd` (a library function that returns the program's working directory, as a String like `"."` is not a directory)

Day 25: Scratch
---------------
(I did this one out-of-order, between days 16 and 17.) Scratch is a great language -- for learning -- but it has its flaws. For instance, subroutines don't return values. There's probably some actor-based message-sending workaround, but I just had the subroutines modify global variables. I read somewhere that the language was to some extent inspired by LISP (mostly via Smalltalk). After setting up the arithmetic in this program, and always selecting the operator first, I can see some of that influence. I was also happy to learn that the language supports recursion, another rather LISPy idea.

Rather than provide the `.sb3` save file, I've provided a `.png` image of the code and a `.scratchblocks` textual representation. Scratch can't load external files, so to load the problem's input, first create a list variable named `text_input`; then right-click on that variable, select "Import", and navigate to the input file. This loads the file line-by-line into the list variable. The file `day25-example.png` shows an example of what the list looks like once loaded into Scratch.

**Scratch**: it may be for kids, but you can [run Linux on top of it](https://scratch.mit.edu/users/bilman66/)!

**Syntax Highlight**: `When I receive [...]` (event-based program flow)
