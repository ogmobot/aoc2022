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
digitbuffer = &50
putchar     = &FFEE
getchar     = &FFE0

    ORG &8000

.start
    LDA #0
    TAX     ; sprite index (addx changes this)
    LDA #1
    STA charcount
.mainloop
    ;LDA #108
    ;JSR putchar
    JSR getchar
; test for eof or empty line
    CMP #255
    BEQ maindone
    CMP #10
    BEQ maindone
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
.maindone
    JMP final

.getint
    LDA #0
    STA sumbuffer
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
    ; multiply by ten, lol
    LDA sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer
    ADC sumbuffer

    ADC digitbuffer
    STA sumbuffer
    LDA #0
    BEQ getintnext
.getintminus
    LDA sumbuffer
    EOR #255
    CLC
    ADC #1
    STA sumbuffer
.getintreturn
    LDA sumbuffer
    RTS

.docycle
    TXA
    CMP charcount
    BEQ cycletrue
    ADC #1
    CMP charcount
    BEQ cycletrue
    ADC #1
    CMP charcount
    BEQ cycletrue
    LDA #46 ; .
    BNE cycleskip
.cycletrue
    LDA #64 ; @
.cycleskip
    TXA
    ADC #48
    JSR putchar

    LDA charcount
    ADC #1
    CMP #41
    BNE cyclenonewline
    LDA #10
    JSR putchar
    LDA #1
.cyclenonewline
    STA charcount
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
