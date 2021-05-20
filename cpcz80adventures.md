# CPC Basic and Z80 adventures

This is the documentation of my journey into learning Z80 assembly. I typed small BASIC programs back in the day and now I am spicing up with Z80 wizardry.
This is **NOT** a tutorial on Z80, just a quick start guide to mess around Z80 and CPC.

I have used Linux but on Windows you can also do it.
I will use WinAPE http://www.winape.net/downloads.jsp running under linux with WINE (sudo apt install wine).
Also I will use iDSK tools https://github.com/cpcsdk/idsk but you can use similar tools.

Binary numbers are composed of binary digits that are 0's or 1's. The conversion to decimal is done by multiplying each digit by the i-th power of two.
The rightmost bit is the least significative bit (LSB) and will have index 0, on the contrary, the leftmost bit is the most signigicative (MSB) and will have the highest index.
For example and 8bit binary number (separated in groups of 4 to be more readable) 0001 0001 corresponds to 1\*2^4+1\*2^0=16+1=17

Hexadecimal is a numbering system that uses base 16 system and offers a compact view of a long binary number. Digits are 0,1,2,3,4,5,6,7,8,9,A,B,C,D,D,E,F and yes letters are used to represent 10,11,12,13,14,15. Thus, we take our friend 0001 0001 and for each group of 4 bytes we take the conversion to hexa 0001 0001 -> 11. FF corresponds to 255 in decimal and 1111 1111 in binary.

For hexadecimal numbers I will use &,#,$,h indistinctively or any other symbol normally used for that. Locomotive BASIC uses &.

These are some of resources I used to on my way to write this.
- CPCWiki, a helpful community https://www.cpcwiki.eu/forum/programming/
- For a good Z80 tutorial you can visit https://www.chibiakumas.com/z80/index.php
- Firmware http://www.cantrell.org.uk/david/tech/cpc/cpc-firmware/
- A nice page with clearly explained Z80 instructions http://www.z80.info/z80code.htm
- Locomotive basic 1.1 disassembly http://www.cpctech.org.uk/docs/basic.asm
- CPC6128 operating system ROM http://www.cpctech.org.uk/docs/os.asm
- Z80 timings https://wiki.octoate.de/lib/exe/fetch.php/amstradcpc:z80_cpc_timings_cheat_sheet.20131019.pdf
- Markdown cheatsheet https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
- and many others ...

## Index

[BASIC](#BASIC)

[Assembly](#Assembly)

[Mixing asm and BASIC](#Mixing-asm-and-BASIC)

[Jumpblock](#Jumpblock)

[TODOs](#TODOs)

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


And now that we know some things about BASIC, and even we got down to the internal representation of a BASIC program, we are gonna play like the BIG boys, we are gonna play with **Z80 assembly**.

Simplifying, assembly is a list of statements of operation codes (mnemonics) and parameters where these parameters can be numbers or registers. If the parameter in between parentheses "()" indicates it is a memory pointer.

Labels are used to reference lines of code and the assembler will assign an address to them.

```asm
label_init:
;DO THINGS
jp label_init
```

### Registers

Registers are special internal memory of 8-bit. Internally they are in pairs forming a 16-bit register.

The important Z80 8-bit registers are A, B, C, D, E, F, H and L and can store any number from 0 to 255. A set of important 16-bit registers are AF BC DE HL, IX, IY and can store a number from 0 to 65535. Changing H will also affect HL.
There are more registers but for now is enough.

- **A** is also called the "accumulator". It is the primary register for arithmetic operations and accessing memory. It cannot be used to store information as all 8bit calculations are done against this register.

- **BC** B and C form BC pair. B is usually a good option for a 8bit loop and C is usually used for I/O ports. BC pair is usually used to store **length** of a memory block.

- **DE** D and E form DE pair. Similar to BC but it is normally used to store **destination** addresses.

- **HL** The general 16 bit register, it's used pretty much everywhere you use 16 bit registers. It's most common uses are for 16 bit arithmetic and storing the addresses of stuff (strings, pictures, labels, etc.). Note that HL usually holds the original address while DE holds the destination address.

- **SP** This is the stack pointer where CALL and PUSH store their values.

- **F** Flag register comes in the pair AF. It will be used mainly in conditional operations. Bit 7 is SF sign flag (<0 S=1), bit 6 is ZF zero flag and bit 0 is CF carry flag.

### Instructions
Regarding instructions you will encounter LD, CP, JP, JR, RET, CALL on the following examples.

- **LD**: I would seay this the main instruction, it LOADS or stores to a variable. A register will be used for one-byte numbers and for two-byte numbers, any two-byte register is fine, but HL is usually the best choice. 
    - ld a, 5 ; sets value 5 to accumulator register

- **CP**: Comparison. It compares origin value with register A and sets Z flag to 1 if same values.
    - cp 5    ; compares current value and accumulator

- **JP**: Jump Absolute. Goes to the specified  adress
    - jp 0    ; goes to 0

- **JR**: Jump Relative. Similar to JP, but faster because it takes 2 bytes instead of 3. It is used to jump to near places +-127 bytes and allows relocatable routines :)
    - jr 1    ; goes to next instruction, useless here

- **CALL**: Jumps to a subroutine and the return location is stored in the stack. Thus we can go back from RET. Remember that subroutines are called by a CALL and terminated by a RET. 
    - CALL &bb5a    ; call TXT OUTPUT
    - CALL NZ &bb5a ; call TXT OUPUT if flag Z is not activated 

- **RET**: Pops the stack and jumps to the address stored in the stack. With and argument is a conditional instruction (ret z). It is the best friend of CALL.
    - ret z   ; goes back if Z==1


### Directives
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
The following code prints the "Hello World!" string and have full explanations of what it does.

```asm
        TXT_OUTPUT      equ &bb5a 
	                        ; TXT OUTPUT Output a character or controlcode to the Text VDU
                                ; Info on firmware calls www.cpcwiki.eu/imgs/7/73/S968se14.pdf

        org      &1200          ; our code will start at &1200

main:                         
        ld      hl,message      ; load address of string in HL
        call    printString     ; print it
        ret

printString:
        ld      a,(hl)          ; load char index stored in HL into A
        cp      a               ; if 0 (last char) then Z flag will be set
        ret     z               ; returns if Z flag is set
        inc     hl              ; hl=hl+1
        call    TXT_OUTPUT      ; call TXT_OUTPUT
        jr      printString

message:
        defb    "Hello World!",0 ; String is ended with 0 and prinString will stop on 0
```

It is always safe to put defb after code (especially ret or jump), so this data will not be executed.

We can also use "or a" instead of "cp a" which is faster faster we are not in a hurry this time.

Once you have taken a look to the asm code, let's put it into WinAPE (Assembler->Show assembler), copypaste it and then assemble it (Ctrl+F9). If all was correct it should give 0 errors.

WinAPE shows the binary digits generated for this program

```asm
WinAPE Z80 Assembler V1.0.13

000001  0000  (BB5A)                TXT_OUTPUT      equ &bb5a 
000002  0000                	                        ; TXT OUTPUT Output a character or controlcode to the Text VDU
000003  0000                                                ; Info on firmware calls www.cpcwiki.eu/imgs/7/73/S968se14.pdf
000005  0000  (1200)                org      &1200          ; our code will start at &1200
000007  1200                main
000008  1200  21 10 12              ld      hl,message      ; load address of string in HL
000009  1203  CD 07 12              call    printString     ; print it
000010  1206  C9                    ret
000012  1207                printString
000013  1207  7E                    ld      a,(hl)          ; load char index stored in HL into A
000014  1208  BF                    cp      a               ; if 0 then Z flag will be set
000015  1209  C8                    ret     z               ; returns if Z flag is set
000016  120A  23                    inc     hl              ; hl=hl+1
000017  120B  CD 5A BB              call    TXT_OUTPUT      ; call TXT_OUTPUT
000018  120E  18 F7                 jr      printString
000020  1210                message
000021  1210  48 65 6C 6C           defb    "Hello World!",0 ; String is ended with 0 and prinString will stop on 0
        1214  6F 20 57 6F 
        1218  72 6C 64 21 
        121C  00 
```

The generated code goes from &1200 to &121C, having a size of &1D (20 in decimal) bytes.
The first instruction at address &1200 is 21 10 12 that corresponds to LD HL,nn instruction (code &21) and address 1210 (first byte after operation code 10 is least significant one). You can check instruction codes at http://map.grauw.nl/resources/z80instr.php

And to run it call starting address (&1200) from BASIC as we set org &1200 in the asm code.
```basic
call &1200
```
If everything was fine, now you are seeing "Hello world!" on the screen.

Now save as a binary file starting at &1200 and size &1D (29).
save "hello.bin",b,&1200,&1D

But an easier wat is to tell the assembler to write it for us. Then, we can add it to a dsk file with WinAPE or iDSK.

```asm
write "hello.bin"
```

iDSK can disassemble the program but it does not know that there is a string starting at &1200, so it will interprete these bytes as Z80 instructions :) Take into account that these defb regions sholud not be executed. In this example there is a jump just before the defb and this help us to keep things right.

```
iDSK hello.dsk -z hello.bin
DSK : hello.dsk
Amsdos file : hello.bin
Taille du fichier : 29
1200 21 10 12       LD HL,1210
1203 CD 07 12       CALL 1207
1206 C9             RET
1207 7E             LD A,(HL)
1208 BF             CP A
1209 C8             RET Z
120A 23             INC HL
120B CD 5A BB       CALL BB5A    ; TXT_OUTPUT
120E 18 F7          JR 1207      ; This jump prevents going into defb area
1210 48             LD C,B       ; This is a string but iDSK does not know it
1211 65             LD H,L       ; and interprets it as instructions
1212 6C             LD L,H
1213 6C             LD L,H
1214 6F             LD L,A
1215 20 57          JR NZ,126E
1217 6F             LD L,A
1218 72             LD (HL),D
1219 6C             LD L,H
121A 64             LD H,H
121B 21 00 1A       LD HL,1A00

```
iDSK can also show and hexadecimal view of the file that can be also pasted on  https://onlinedisassembler.com

```
iDSK hello.dsk -h hello.bin
DSK : hello.dsk
Amsdos file : hello.bin
#0000 21 10 12 CD 07 12 C9 7E BF C8 23 CD 5A BB 18 F7 | !.........#.Z...
#0010 48 65 6C 6C 6F 20 57 6F 72 6C 64 21 00 1A 00 00 | Hello.World!....
```

Ok, we saved the file, switch off the computer, but next day we want to load it.
First, we need reserve memory and as we will be using the program at &1200, the last BASIC memory will be one bye less, i.e. &11FF. Then we LOAD an CALL.

```basic
MEMORY &11FF
LOAD "hello.bin", &1200
CALL &1200
```
If MEMORY is not set, we will get "Memory full" message.

### Memory
We have already used memory address &1200 which is in the area of BASIC (0170-HIMEM) and later we will use functions from the jumpblock (bb5a) and RST routines (0008). This table shows you the memory layout.

| RAM | ROM | External |
|-|-|-|
| FFFF-C000 Screen memory (16k) | 16k Upper ROM (BASIC) | 16k max. 252 ext ROMS |
| BFFF-B100 Stack, firmware and jumblock | 3FFF-0000 16k firmware ROM |  |
| B0FF-AC00 BASIC Workspace |  |  |
| -ABFF Background data (&500 bytes used by AMSDOS if present) |  |  |
| -     User defined graphics |  |  |
| -     Space for machine code routines |  |  |
| - HIMEM Strings area |  |  |
| -     FREE SPACE (used by AMSDOS for loading and saving) |  |  |
| -     Arrays area |  |  |
| -     Variables and DEF FNs area |  |  |
| -0170 Program area |  |  |
| 016F-0040 Foreground workspace |  |  |
| 003F-0000 RST routines |  |  |

## Mixing asm and BASIC

Now we know a little bit of assembly and we have also seen how a BASIC code is stored in memory.

So the next question is, could it be possible to "write" BASIC code from asm?
Yes, it is.

For this example I will use code borrowed from USIFAC card and we will write our HELLO.BAS directly from asm. (USIFAC is a Serial interface board and much more. Take a look at https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/usifac-iimake-your-pc-or-usb-stick-an-hdd-for-amstrad-access-dsk-and-many-more!/)

It is important to remember that BASIC programs start at &170 (see memory table above). The following program takes a bytes representing a BASIC program and copies them on 170. We have already shoewn that these bytes can be extracted with iDSK hello.dsk -h hello.bas

Before we commented that HL register is normally used for general purpose or **source**, DE for **DEstination** and BC for **length**. Here we have an example.

```asm
data_size equ 39                                ; size of BASIC file, we know it is 39 bytes
addr    equ &170                                ; BASIC files normally start at 170, let's write in this area
org	&1200                                   ; and store our program in &1200

main:
                                                ; we will use 16-bit registers (hl, de, ... to deal with memory addresses that take 2 bytes &AABB)
	ld	hl, basic_code                  ; hl = address where basic_code is starts, i.e. org + something but the assembler does it for us
	ld 	de, addr                        ; de = &170
	ld	bc, data_size                   ; bc = data size
	ldir                                    ; ldir copies a block from hl address to de address of length bc (i.e. memcpy)
        ret                                     ; do not forget to go back from call
	
basic_code:
defb &0c,&00,&0a,&00,&c5,&20,&48,&65,&6c,&6c,&6f,&00,&15,&00,&14,&00,&bf
defb &20,&22,&48,&65,&6c,&6c,&6f,&20,&57,&6f,&72,&6c,&64,&21,&22,&00,&00,&00 
```

Now compile it, execute it with CALL, type LIST command and our Hello World! code will appear. Of course you can also RUN it.

```
list
Ready
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

## Jumpblock

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


## TODOs
Things I want to include soon: RSX calls, ROMs (a good example is https://github.com/llopis/amstrad-diagnostics), USIFAC programming, etc, ...

To be continued.

**WARNING: THIS AREA IS STILL A DRAFT*


## ROMs

Roms can be Foreground of Background. Foreground are in overall control, while background might provide additional facilities in response to a call from the current foreground program but would not be able to run a complete program on its own.

A resident system extension (RSX) is similar in use to a background ROM, but it must be loaded into RAM before it can be used.

A foreground ROM contains one or more programs. The on-board BASIC is the default foreground program.


In the CPC 464 it is possible to have up to seven background ROMs and 16 in the CPC 6128 that will have reference numbers in the range 0 to 251. ROM numbers must be consecutive from 0 or 1 upwards. In the case that reference 0 is used, the on.board ROM will be available at the first reference number not used by external ROMs. A foreground program may use up to **four** ROMs.



A given ROM will take addresses C000 to FFFF and maybe up to 16K. The first six bytes will be the following:
- ROM type: 0 for foreground, 1 for background, 2 for extension (onboard ROM is type &80)
- ROM Mark number
- ROM Version number
- ROM Modification level
- Address of external command table (2 bytes)

Then there will be a jumplock beginning with the entry to the initialisation routing and then jumps that match the external command words. The last byte of these words will have the bit 7 set to 1 (&80).

- Address of command name table
- Jumpblock entry 0
- Jumpblock entry 1
- ...



KL FIND COMMAND 

References:
[968] Soft968, Chapter 10. Expansion ROMs, Resident System Extensions and RAM Programs http://www.cpcwiki.eu/imgs/f/f6/S968se10.pdf
[INS] The Ins and Outs of the AMSTRAD CPC464 https://acpc.me/ACME/LIVRES/[ENG]ENGLISH/MELBOURNE_HOUSE/The_Ins_and_Outs_of_the_AMSTRAD_CPC464(Don_THOMSON)(acme).pdf


## RSX

10 Expansion ROMs, Resident System Extensions and RAM Programs
https://www.cpcwiki.eu/imgs/f/f6/S968se10.pdf
https://www.cpcwiki.eu/index.php/Programming:An_example_to_define_a_RSX

An RSX is similar to a background ROM. Responsibility for loading an RSX and providing it  with  memory  lies  with  the  foreground  program. 

To  fit  in  with  the  dynamic  allocation  of  memory to background ROMs it is recommended that RSXs should be position independent or  relocated  when  loaded.  An  RSX  could  be  relocated  by  writing  a  short  BASIC  'loader' program  which  reads  the  RSX  in  a  format  which  may  be  relocated  easily  and  POKEs  into  store.

Once an RSX is load it may be placed on the list of possible handlers of external commands (see  following  page)  by  calling  KL  LOG  EXT,  passing  it  the  address  of the RSXs external command  table  and  a  four  byte  block  of  memory  (in  the  central  32K  of  RAM)  for  the  Kernel's  use.  

The  format  of  the  table  is  exactly  the  same  as  for  a  background  ROM  (see  section  10.2).  
The  only  difference  is  in  the  interpretation  of  the  table - the first entry in the jumpblock  is  not  called  automatically  by  the  Kernel  and  thus  need  not  be  the  RSX's  initialization routin


