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

Day 06: uxntal
--------------
For this language, I took a break from Vim and instead wrote the program in Left, a text editor written in uxntal. Uxntal is the assembly language for the `uxn` fantasy cpu dreamt up by Devine Lu Linvega of 100 Rabbits. They've also developed Drifblim (an assembler), Uxnlin (a linter) and Beetbug (a debugger) in this language, although I didn't use them for this program.

Devine's aim (as I understand it) is to create a technology stack that uses a simple, well-defined VM to avoid the problems that 100 Rabbits had while attempting to develop iOS software -- namely high energy consumption, the constant updates and upgrades necessary to continue development, and old programs becoming unusable due to those updates. They seem to have largely achieved that goal, as many common computer applications (text processing, drawing, sprite- or hex-editing, filesystems, calculator) now exist within the Varvara ecosystem.

Uxntal feels like a cross between assembly and Forth. I kept trying to give arguments to my functions by writing them after the function's name (`JMP ,&next`), but that's not how Forths work. Weird language. I like it.

**Uxntal**: a language for the systems of post-collapse Earth.

**Syntax Highlight**: `LDA2kr` (`2`, `k` and `r` can be used to modify the meaning of a word: Load (2 bytes) (without popping from the stack) (using the return stack in place of the working stack))
