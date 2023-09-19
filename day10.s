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
putchar     = &FFEE
getchar     = &FFE0

    ORG &8000

.start
    LDX #1  ; sprite index (addx changes this)
    LDA #0
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
    CPX #40
    BNE cyclenonewline
    LDA #10
    JSR putchar
    LDX #0
.cyclenonewline
    STX charcount
    LDX tempx
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
