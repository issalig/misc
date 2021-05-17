# CPC Basic and Z80 adventures

This is the documentation of my journey into learning Z80 assembly. I typed small BASIC programs back in the day and now I am spicing up with Z80 wizardry.
This is **NOT** a tutorial on Z80, just a quick start guide to mess around Z80 and CPC.

I have used Linux but on Windows you can also do it.
I will use WinAPE http://www.winape.net/downloads.jsp running under linux with WINE (sudo apt install wine).
Also I will use iDSK tools https://github.com/cpcsdk/idsk but you can use similar tools.

For hexadecimal numbers I will use &,#,$,h indistinctively or any other symbol normally used for that.

These are some of resources I used to on my way to write this.
- For a good Z80 tutorial you can visit https://www.chibiakumas.com/z80/index.php
- Firmware http://www.cantrell.org.uk/david/tech/cpc/cpc-firmware/
- A nice page with clearly explained Z80 instructions http://www.z80.info/z80code.htm
- Locomotive basic 1.1 disassembly http://www.cpctech.org.uk/docs/basic.asm
- CPC6128 operating system ROM http://www.cpctech.org.uk/docs/os.asm
- Markdown cheatsheet https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
- and many others ...

## BASIC

Now let's start and go back to your good old BASIC days and type the following code on WinAPE. If you are new to CPC world, welcome aboard!

```basic
10 REM Hello
20 PRINT "Hello World!"
```

Create a disk on WinAPE (File->Drive A->New blank disk  and set **hello.dsk** as name and format it) if you have not done it or use and existing one (File->Drive A->Insert Disc Image) and save the program with 
```basic
SAVE "hello.bas"
```

This will create a file with AMSDOS header (http://www.cpcwiki.eu/index.php/AMSDOS_Header) with the bytecodes for the BASIC program (https://cpctech.cpcwiki.de/docs/bastech.html)

If you want to save it as ascii (and without AMSDOS header) use
```basic
SAVE "hello.txt",a
```
Now, on WinAPE you can remove the disc with File->Drive A->Remove disk

And go to the command line to use iDSK tool to list the contents of the disk.
```bash
iDSK hello.dsk -l
 
DSK : hello.dsk
HELLO   .BAS 0
HELLO   .TXT 0
------------------------------------
```

Now, we can take a look inside a .BAS file and will report the size of the code in ascii

```
iDSK hello.dsk -b hello.bas

DSK : hello.dsk
Amsdos file : hello.bas
Taille du fichier : 35
10 REM Hello
20 PRINT "Hello World!"
```

Or just
```
iDSK hello.dsk -a hello.txt
DSK : hello.dsk
Amsdos file : hello.txt
Taille du fichier : 1024
10 REM Hello
20 PRINT "Hello World!"

------------------------------------
```

Of course we can also open it with our favourite text editor.

If you load a txt file it will be interpreted as BASIC

```basic
LOAD "hello.txt"
LIST
10 REM Hello
20 PRINT "Hello World!"
```

ASCII is nice and human readable but let's dive into the .BAS file which is much more interesting (Reference on  https://cpctech.cpcwiki.de/docs/bastech.html)

Again, I will use iDSK to extract the bytes
```
iDSK hello.dsk -h hello.bas
```

This command will remove the first 128 bytes (AMSDOS headers) and we have the following bytes:

```
0c 00                          ; length of data 12 (&0c) bytes
0a 00                          ; line number 10 (&0a)
c5                             ; c5 is REM code
20 48 65 6c 6c 6f              ; string ' Hello' , 20 is blank char and so on
00                             ; end of line marker

15 00                          ; length of data 21 (&15) bytes
14 00                          ; line number 20 (&14)
bf                             ; bf is PRINT code
20 22 48 65 6c 6c 6f           ; string ' "Hello'
20 57 6f 72 6c 64 21 22        ; string ' World!"'
00                             ; end of line marker
00 00                          ; length of line 0 is end of basic program

```


## Assembly


And now that we know some things about BASIC, even we get down to the internal representation of a BASIC program, we are gonna play like the BIG boys, we are gonna play with **Z80 assembly**.

Simplifying, assembly is a list of operation codes (mnemonics) and parameters where these parameters can be numbers or registers.

### Registers

The important Z80 8-bit registers are A, B, C, D, E, F, H and L and can store any number from 0 to 255. A set of important 16-bit registers are AF BC DE HL, IX, IY and can store a number from 0 to 65535.
There are more registers but for now is enough.

- **A** is also called the "accumulator". It is the primary register for arithmetic operations and accessing memory.


- **HL** The general 16 bit register, it's used pretty much everywhere you use 16 bit registers. It's most common uses are for 16 bit arithmetic and storing the addresses of stuff (strings, pictures, labels, etc.). Note that HL usually holds the original address while DE holds the destination address.

### Instructions
Regarding instructions you will encounter LD, CP, JP, JR, RET, CALL on the following example


- **LD**: I would seay this the main instruction, it LOADS or stores to a variable. A register will be used for one-byte numbers and for two-byte numbers, any two-byte register is fine, but HL is usually the best choice. 
    - ld a, 5 ; sets value 5 to accumulator register


- **CP**: Comparison. It compares origin value with register A and sets Z flag to 1 if same values.
    - cp 5    ; compares current value and accumulator

- **RET**: Pops the stack and jumps to the address stored in the stack. With and argument is a conditional instruction (ret z)
    - ret z   ; goes back if Z==1

- **JP**: Jump Absolute. Goes to the specified  adress
    - jp 0    ; goes to 0

- **JR**: Jump Relative. Similar to JP, but faster because it takes 2 bytes instead of 3. It is used to jump to near places +-127 bytes and allows relocatable routines :)
    - jr 1    ; goes to next instruction, useless here

- **org**: Defines where the code starts. References to addresses will change according to this. As seen , JR will not be affected by this value.
    - org &1200
    
- **equ**: Sets a value to a label. Think of it as a constant.
    - five equ 5
    
- **defb**: Sets memory to specified values.
    - defb 20              ; it will store one byte
    - defb "defb example"  ; it will store a sequence of bytes

### Comments
Comments are placed after **;** and I **encourage** you to use them now that you are starting to learn and later when you get experience so you annotate all the dark magic you write. Failing to do so, will get you **exciting** moments trying to guess what you wrote.


For more information on Z80 instructions I find this link extremely clear http://www.z80.info/z80code.htm

### Hello world from the assembly side
The following code is borrowed from the great http://www.chibiakumas.com prints the "Hello World!" string. I annotated this in order to better understand what it does and I think it will also help you.

```asm
; Got it from www.chibiakumas.com/z80/helloworld.php#LessonH1
; and completed with explanations for noobs like me

org &1200                ; our code will start at &1200

PrintChar   equ &bb5a    ; TXT OUTPUT Output a character or controlcode to the Text VDU
                         ; Info on firmware calls www.cpcwiki.eu/imgs/7/73/S968se14.pdf

ld hl, Message           ; load address of string in HL
call PrintString         ; print it

; print CR+LF
Newline:
	ld a,13              ; CR
	call Printchar
	ld a,10	             ; LF
	jp Printchar

; loop until last char (255) and print char
PrintString:
	ld a,(hl)            ; load char index stored in HL into A
	cp 255               ; A-255  if equal Z flag will be set
	ret z                ; returns if Z flag is set
	inc hl	             ; hl=hl+1
	call PrintChar       ; call BB5A
	jr PrintString

; it is always safe to put defb after code (especially ret or jump), so this data will not be executed
Message: db 'Hello World!',255   ;string is ended with 255 as end of string

```

Once you have taken a look to the asm code, let's put it into WinAPE (Assembler->Show assembler), copypaste it and then assemble it (Ctrl+F9). If all was correct it should give 0 errors.

WinAPE shows the binary digits generated for this program

```asm
WinAPE Z80 Assembler V1.0.13

000001  0000                ; Got it from www.chibiakumas.com/z80/helloworld.php#LessonH1
000002  0000                ; and completed with explanations for noobs like me
000004  0000  (1200)        org &1200                ; our code will start at &1200
000006  1200  (BB5A)        PrintChar   equ &bb5a    ; TXT OUTPUT Output a character or controlcode to the Text VDU
000007  1200                                         ; Info on firmware calls www.cpcwiki.eu/imgs/7/73/S968se14.pdf
000009  1200  21 1A 12      ld hl, Message           ; load address of string in HL
000010  1203  CD 10 12      call PrintString         ; print it
000012  1206                ; print CR+LF
000013  1206                Newline
000014  1206  3E 0D         	ld a,13              ; CR
000015  1208  CD 5A BB      	call Printchar
000016  120B  3E 0A         	ld a,10	             ; LF
000017  120D  C3 5A BB      	jp Printchar
000019  1210                ; loop until last char (255) and print char
000020  1210                PrintString
000021  1210  7E            	ld a,(hl)            ; load char index stored in HL into A
000022  1211  FE FF         	cp 255               ; A-255  if equal Z flag will be set
000023  1213  C8            	ret z                ; returns if Z flag is set
000024  1214  23            	inc hl	             ; hl=hl+1
000025  1215  CD 5A BB      	call PrintChar       ; call BB5A
000026  1218  18 F6         	jr PrintString
000028  121A                ; it is always safe to put defb after code (especially ret or jump), so this data will not be executed
000029  121A                Message
000029  121A  48 65 6C 6C    db 'Hello World!',255   ;string is ended with 255 as end of string
        121E  6F 20 57 6F 
        1222  72 6C 64 21 
        1226  FF 
```

The generated code goes from &1200 to &1226, having a size of &27 (39 in decimal) bytes.
The first instruction at address &1200 is 21 1A 12 that corresponds to LD HL,nn instruction (code &21) and address 121A. You can check codes at http://map.grauw.nl/resources/z80instr.php

And to run it call starting address (&1200) from BASIC as we set org &1200 in the asm code.
```basic
call &1200
```
If everything was fine, now you are seeing "Hello world!" on the screen.

Now save it with (size of the program is 39 (&27) bytes as commented before)
save "hello.bin",b,&1200,&27

Eject disc if necessary and ask iDSK what is this file about.

iDSK can disassemble the program but it does not know that there is a string starting at &1200, so it will interprete these bytes as Z80 instructions :) Take into account that these defb regions sholud not be executed. In this example there is a jump just before the defb and this help us to keep things right.


```
iDSK hello.dsk -z hello.bin
DSK : hello.dsk
Amsdos file : hello.bin
Taille du fichier : 39
1200 21 1A 12       LD HL,121A
1203 CD 10 12       CALL 1210
1206 3E 0D          LD A,0D
1208 CD 5A BB       CALL BB5A    ; TXT_OUTPUT
120B 3E 0A          LD A,0A
120D C3 5A BB       JP BB5A
1210 7E             LD A,(HL)
1211 FE FF          CP FF
1213 C8             RET Z
1214 23             INC HL
1215 CD 5A BB       CALL BB5A    ; TXT_OUTPUT
1218 18 F6          JR 1210
121A 48             LD C,B       ; This is a string but iDSK does not know it
121B 65             LD H,L       ; and interpret it as Z80 instructions
121C 6C             LD L,H
121D 6C             LD L,H       ; That's why it is recommended to place the defb
121E 6F             LD L,A       ; after the code or in a place where it cannot be 
121F 20 57          JR NZ,1278   ; reached. Look at the previous instruction &1218
1221 6F             LD L,A       ; It is a jump to &1210!
1222 72             LD (HL),D
1223 6C             LD L,H
1224 64             LD H,H
1225 21 FF 1A       LD HL,1AFF
```

If you want an easier way of having the binary. You can get it from iDSK and paste it in https://onlinedisassembler.com

```
iDSK hello.dsk -h hello.bin
DSK : hello.dsk
Amsdos file : hello.bin
#0000 21 1A 12 CD 10 12 3E 0D CD 5A BB 3E 0A C3 5A BB | !.....>..Z.>..Z.
#0010 7E FE FF C8 23 CD 5A BB 18 F6 48 65 6C 6C 6F 20 | ....#.Z...Hello.
#0020 57 6F 72 6C 64 21 FF 00 00 00 00 00 00 00 00 00 | World!..........
#0030 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
#0040 1A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 | ................
```

We save the file, but we want to load it
http://www.cpcwiki.eu/forum/programming/load-address-problem/
https://www.cpcwiki.eu/forum/programming/memory-limit-on-loading-programs/

http://www.cpcwiki.eu/forum/programming/reading-a-binary-file-into-memory-using-basic/

Now we need to reserve memory, as we will be using the program at &1200, the last BASIC memory will be one bye less, i.e. &11FF

```basic
MEMORY &11FF
LOAD "hello.bin", &1200
call &1200
```
If MEMORY is not set, we will get "Memory full" message.


### Mixing asm and BASIC

Now we know a little bit of assembly and that we have also seen how a BASIC code is stored in memory.

So the next question is, could it be possible to "write" BASIC code from asm?
Yes, it is.

For this example I will use code borrowed from USIFAC card and we will write our HELLO.BAS directly from asm.

BASIC program start at &170 

```asm
data_size equ 39                            ; size of BASIC file, we know it is 39 bytes
addr equ &170                               ; BASIC files normally start at 170, let's write in this area
org	&1200                                   ; and store our program in &1200

                                            ; we will use 16-bit registers (hl, de, ... to deal with memory addresses that take 2 bytes &AABB)
	ld	hl, basic_code                      ; hl = address where the basic code is stored, i.e. org + something but the assembler does it for us
	ld 	de, addr                            ; de = &170
	ld	bc, data_size                       ; bc = the data size
	ldir                                    ; ldir copies a block from hl address to de address of length bc (i.e. memcpy)
    
basic_code:
defb &0c,&00,&0a,&00,&c5,&20,&48,&65,&6c,&6c,&6f,&00,&15,&00,&14,&00,&bf
defb &20,&22,&48,&65,&6c,&6c,&6f,&20,&57,&6f,&72,&6c,&64,&21,&22,&00,&00,&00    
    
```

Now compile it, execute it with CALL, type LIST command and our Hello World! code will appear. Of course you can also RUN it.

```
CALL &1200
Ready
list
10 REM Hello
20 PRINT "Hello World!"
Ready
RUN
Hello World!
Ready
```

And what about running the BASIC program from asm? Well, we will do this later.

##Jumpblock

In the examples above you have noticed that we have used CALL &XXXX. These are calls to utilities provided by the firmware such as printing a char in screen. In particular, this function is called from &BB5A and is known as TXT OUTPUT. Different computers can have different addresses for the firmware function but a solution to have a common entry point is to share a common address and then jump from there to the routine code. This set of jumps is known as jumpblock.

Jumpblock is located at B100-BFFF. For more info check Soft968 Chapter 2. ROMs, RAM and the Restart Instructions (http://www.cpcwiki.eu/imgs/f/f6/S968se02.pdf)
 Chapter 14. Firmware jumpblocks https://cpctech.cpcwiki.de/docs/manual/s968se14.pdf and Chapter 18 The Low Kernel Jumpblock .https://cpctech.cpcwiki.de/docs/manual/s968se18.pdf

With this BASIC code we get the instructions executed when calling &bb5a (or you can "Pause" WinAPE and go to address &bb5a).

```basic
10 a=PEEK(&bb5a)
20 b=PEEK(&bb5b)
30 c=PEEK(&bb5c)
40 print hex$(a),hex$(b),hex$(c)
CF FE 93
```

So the jumpblock call for bb5a is CF FE 93 where CF corresponds to RST 1 instruction that jumps to &0008 where resides LOW JUMP. The next two bytes (FE 93) are interpreted as the destination address where the last significant byte is first (see http://www.cantrell.org.uk/david/tech/cpc/cpc-firmware/firmware.pdf pg.38). RST instruction is used to jump to an address in just 1 cycle and is equivalent to CALL &00XX. 

```
001   &0008   LOW JUMP (RST 1)
      Action: Jumps to a routine in either the lower ROM or low RAM
      Entry:  No entry conditions - all  the  registers are passed to
              the destination routine unchanged
      Exit:   The registers are as set  by  the  routine in the lower
              ROM or RAM or are returned unaltered
      Notes:  The RST 1 instruction  is  followed  by  a two byte low
              address, which is defmed as follows:
                if bit 15 is set, then the upper ROM is disabled
                if bit 14 is set, then the lower ROM is disabled
                bits 13 to 0 contain the address of the routine to
                  jump to
              This command is used by the  majority of entries in the
              main firmware jumpblock
```

Thus, 93 fe corresponds to value 93fe that after removing bit15 and bit14 results in address 13fe. If you are interested in the TXT OUTPUT routine check firmware disassembly at &13fe http://cpctech.cpc-live.com/docs/os.asm

```
      93       FE
-> 1001 0011 1111 1110
   ||      
   |-lower ROM enabled
   -upper ROM disabled
```

Now image that we want to print only uppercase characters, so we will need to modify the jumblock for &bb5a, then subtract 32 to any character between 'a' and 'z' and call the original routine. Take into account that we have not to corrupt any register that could be in use. From the documentation of bb5a we know takes register A as input and preserves other registers at output, thus, we should behave in the same way and we will use push and pop instructions.

The code for our uppercase function will be:
	      
``` asm	      
org &1200

;overwrite jumbplock at bb5a
;we should preserve all registers
push hl
ld l, &c3                       ; jp code 
ld (&bb5a), hl
ld hl, uppercase_txt_output     ; address of new code
ld (&bb5b), hl
pop hl

; A-Z chars range from 65 to 90
; a-z chars range from 97 to 122
;there is an offset of 32 for upper-lower

uppercase_txt_output:
cp 'a'                 ; A-'a'   C=1 if A<'a'
jr c, not_lowercase    ; if character < 'a' is not a lowercase
cp 'z'+1               ; A-'z'+1 C=0 if A>'z'  
jr nc, not_lowercase   ; if character > 'z' is not a lowercase
sub 32                 ; sub 32 to convert it to UPPER case

not_lowercase:
defb &cf,&fe,&93 ; call original jumpblock for TXT OUTPUT

ret
```

Call it from BASIC and you will see messages uppercased 
```
call &1200
READY
10 print "hello"
run
HELLO
READY
```
but if you Pause on WinAPE and look for "hello" (F7) it will in lowercase.


We can also use parameters in CALL and for example CALL &1200,0 to restore the original function. Register A has the number of parameters, and IX has the list of parameters. The first parameter is stored in IX(0) and IX(1), the second in IX(2) and IX(3) and so on.  (See more info on CALL parameters http://www.cpcwiki.eu/index.php?title=Technical_information_about_Locomotive_BASIC&mobileaction=toggle_view_desktop)

``` asm	      
org &1200

cp 1                            ; check number of parameters of external call
jp nz, install                  ; if no params install
ld a,(ix+0)                     ; our param value is 8bit, so here ix+1 is not needed
cp 0
jc nc, restore                  ; if param1 == 0 then restore

restore:
push hl
ld l, &cf                       ; rst
ld (&bb5a), hl
ld hl, &93fe                    ; original bytes
ld (&bb5b), hl
pop hl
ret                             ; all done

install:
;overwrite jumbplock at bb5a
;we should preserve all registers
push hl
ld l, &c3                       ; jp code 
ld (&bb5a), hl
ld hl, uppercase_txt_output     ; address of new code
ld (&bb5b), hl
pop hl

; A-Z chars range from 65 to 90
; a-z chars range from 97 to 122
;there is an offset of 32 for upper-lower

uppercase_txt_output:
cp 'a'                 ; A-'a'   C=1 if A<'a'
jr c, not_lowercase    ; if character < 'a' is not a lowercase
cp 'z'+1               ; A-'z'+1 C=0 if A>'z'  
jr nc, not_lowercase   ; if character > 'z' is not a lowercase
sub 32                 ; sub 32 to convert it to UPPER case

not_lowercase:
defb &cf,&fe,&93 ; call original jumpblock for TXT OUTPUT

;defb &cf,&c5,&9b ; call original jumpblock for KM READ CHAR   BB09
;defb &cf,&e1,&9c ; call original jumpblock for KM READ KEY   BB1B

ret
```

To be continued.
