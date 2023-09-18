; compile with
;   beebasm -i <program source> -o <rom>
; run with
;   cat <input file> | \
;   run6502 -l 8000 <rom>   \ # rom load location
;           -R 8000 -X    0 \ # reset and exit vectors
;           -G FFE0 -P FFEE   # getchar and putchar locations

charcount = &10
intbuffer = &30
putchar   = &FFEE
getchar   = &FFE0

    ORG &8000

.start
    LDA #00
    TAY     ; cycle count
    TAX     ; sprite index (addx changes this)
    STA charcount
.mainloop
    LDA #108
    JSR putchar
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
    LDA #110
    JSR putchar

    JSR getchar ; o
    JSR getchar ; o
    JSR getchar ; p
    JSR getchar ;\n

    JSR docycle
    LDA #0
    BEQ mainloop
.gota
    LDA #97
    JSR putchar

    JSR getchar ; d
    JSR getchar ; d
    JSR getchar ; x
    JSR getchar ; _

    JSR docycle
    JSR docycle

    STX &20
    JSR getint
    ADC &20
    TAX
    LDA #0
    BEQ mainloop
.maindone
    JMP final

.getint
    LDA #0
    STA &40
    TAX
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
    CMP #45
    BEQ getintminus
    SBC #30
    STA &50
    ; multiply by ten, lol
    LDA &40
    ADC &40
    ADC &40
    ADC &40
    ADC &40
    ADC &40
    ADC &40
    ADC &40
    ADC &40
    ADC &40

    ADC &50
    STA &40
    BNE getintnext
.getintminus
    EOR #255
    CLC
    ADC #1
.getintreturn
    RTS

.docycle
    LDA #68
    JSR putchar
    TXA
    CMP charcount
    BEQ cycletrue
    ADC #1
    CMP charcount
    BEQ cycletrue
    ADC #1
    CMP charcount
    BEQ cycletrue
    BNE cyclefalse
.cycletrue
    LDA #64
    BNE cycleskip
.cyclefalse
    LDA #46
.cycleskip
    JSR putchar

    LDA charcount
    ADC #1
    CMP #40
    BNE cyclenonewline
    LDA #10
    JSR putchar
    LDA #0
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
