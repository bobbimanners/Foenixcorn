* MAINMEM.INIT.S
* (c) Bobbi 2021 GPLv3
*
* Initialization, interrupt handling and reset handling code
* that resides in main memory.

* 14-Nov-2021 If started from CSD, gets prefix to CMDBUF.

AUDIOCARD    DB   $00                ; $00 = Mockingboard, $01 = Ensoniq


* Trampoline in main memory used by aux memory IRQ handler
* to invoke Apple II / ProDOS IRQs in main memory
A2IRQ        >>>   IENTMAIN          ; IENTMAIN does not do CLI
             LDA   #>A2IRQRET
             PHA
             LDA   #<A2IRQRET
             PHA
             PHP                     ; Fake things to look like IRQ
             JMP   (A2IRQV)          ; Call Apple II ProDOS ISR
A2IRQRET     >>>   XF2AUX,IRQBRKRET


* BRK handler in main memory. Used on Apple IIgs only.
GSBRK        >>>   XF2AUX,GSBRKAUX


* Reset handler - invoked on Ctrl-Reset
* XFER to AUXMOS ($D000) in aux, AuxZP on, LC on
RESET        TSX
             STX   $0100
             LDA   AN0OFF            ; AN0 off
             LDA   AN1OFF            ; AN1 off
             LDA   AN2ON             ; AN2 on
             LDA   AN3ON             ; AN3 on
             JSR   RESETHW           ; Reset hardware
             >>>   XF2AUX,AUXMOS


* Reset hardware
RESETHW      SEC
             STZ   AUDIOCARD
             JSR   IDROUTINE         ; See if this is a GS
             BCS   :NOTGS
*            JSR   ENSQINIT          ; Initialize Ensoniq
             INC   AUDIOCARD
             RTS                     ; AUDIOCARD=1
:NOTGS
*            JSR   MOCKINIT          ; Initialize Mockingboard (sl4)
RTSINSTR     RTS                     ; AUDIOCARD=0

