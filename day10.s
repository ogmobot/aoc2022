; compile with
;   beebasm -i <program source> -o <rom>
; run with
;   cat <input file> | \
;   run6502 -l 8000 <rom>   \ # rom load location
;           -R 8000 -X    0 \ # reset and exit vectors
;           -G FFE0 -P FFEE   # getchar and putchar locations

charcount   = &10
tempx       = &20
intbuffer   = &30
sumbuffer   = &40
digitbuffer = &41
tensflag    = &42
xvector     = &50
cvector     = &60
prodlo      = &50
prodhi      = &60
vecsumlo    = &70
vecsumhi    = &71
putchar     = &FFEE
getchar     = &FFE0

    ORG &8000

.start
    CLD
    LDX #1  ; sprite index (addx changes this)
    LDY #0  ; vector index (increment every 40 cycles)
    ; set up cycle vector for later multiplication
    LDA #20
    STA &60
    LDA #60
    STA &61
    LDA #100
    STA &62
    LDA #140
    STA &63
    LDA #180
    STA &64
    LDA #220
    STA &65

    LDA #0
    STA charcount
.mainloop
    ;LDA #108
    ;JSR putchar
    JSR getchar
; test for eof or empty line
    CMP #255
    BEQ p2done
    CMP #10
    BEQ p2done
; test for 'n' (noop instruction)
    CMP #110
    BEQ gotn
; test for 'a' (addx instruction)
    CMP #97
    BEQ gota
; unrecognised value!
    JSR crash
.gotn
    ;LDA #110
    ;JSR putchar

    JSR getchar ; o
    JSR getchar ; o
    JSR getchar ; p
    JSR getchar ;\n

    JSR docycle
    LDA #0
    BEQ mainloop
.gota
    ;LDA #97
    ;JSR putchar

    JSR getchar ; d
    JSR getchar ; d
    JSR getchar ; x
    JSR getchar ; _

    JSR docycle
    JSR docycle

    STX tempx
    JSR getint
    ADC tempx
    TAX
    LDA #0
    BEQ mainloop
.p2done
    JSR vectormultiply
    JSR printshort
    JMP final

.getint
    LDA #0
    STA sumbuffer
    STA tensflag ; lucky there are no 3-digit nums
    TAX
    INX
.getintloop
    JSR getchar
    CMP #10
    BEQ getintnext
    STA intbuffer,X
    INX
    BNE getintloop
.getintnext
    DEX
    BEQ getintreturn
    LDA intbuffer,X
    CMP #45 ; -
    BEQ getintminus
    SBC #48 ; 0
    STA digitbuffer
    CLC
    LDA tensflag
    BEQ onescolumn
    ; multiply by ten
    CLC
    LDA digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    ADC digitbuffer
    STA digitbuffer

.onescolumn
    LDA #1
    STA tensflag
    LDA digitbuffer
    ADC sumbuffer
    STA sumbuffer

    BVC getintnext
.getintminus
    LDA sumbuffer
    EOR #255    ; negate
    CLC
    ADC #1
    STA sumbuffer
.getintreturn
    LDA sumbuffer
    RTS

.docycle
    STX tempx
    DEX
    CPX charcount
    BEQ cycletrue
    INX
    CPX charcount
    BEQ cycletrue
    INX
    CPX charcount
    BEQ cycletrue
    LDA #46 ; .
    BNE cycleskip
.cycletrue
    LDA #64 ; @
.cycleskip
    ;LDA tempx
    ;CLC
    ;ADC #48
    JSR putchar

    LDX charcount
    INX
    CPX #20
    BNE cyclenovector
    LDA tempx
    STA xvector,Y
    INY
.cyclenovector
    CPX #40
    BNE cyclenonewline
    LDA #10
    JSR putchar
    LDX #0
.cyclenonewline
    STX charcount
    LDX tempx
    RTS

.vectormultiply
    ; I am indebted to Leif Stensson and Niels Moeller for
    ; this multiplication routine.
    ; www.lysator.liu.se/~nisse/
    LDX #5
.mulstart
    LDA #0
    LDY #8 ; shifts needed
    LSR xvector,X
.mulloop
    BCC mulskipadd
    CLC
    ADC cvector,X
.mulskipadd
    ROR A
    ROR xvector,X
    DEY
    BNE mulloop
    STA cvector,X
    DEX
    BNE mulstart
    ; now add them up...
    LDX #5
.addstart
    CLC
    LDA xvector,X
    ADC prodlo
    STA prodlo
    LDA cvector,X
    ADC prodhi
    STA prodhi

    DEX
    BNE addstart
    RTS

.printshort
    ; specifically, the short located at &70-&71
    LDA prodlo
    JSR putchar
    LDA prodhi
    JSR putchar
    LDA #10
    JSR putchar
    RTS

.crash
    LDA #120
    JSR putchar
    LDA #95
    JSR putchar
    LDA #120
    JSR putchar ; x_x
.final
    LDA #10
    JSR putchar

    BRK

.end

    SAVE "day10.out", start, end
