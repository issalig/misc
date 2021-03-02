#Communication with an Amstrad CPC (mainly from a microcontroller, ESP8266?)

![imagen](https://user-images.githubusercontent.com/7136948/109623183-28a42680-7b3d-11eb-9a4c-ee2bc75d718d.png)
(Got it from http://www.cpcwiki.eu/index.php/Connector:Expansion_port)

- To understand the way they exchange bytes.
- USIFAC2 is similar but sources are closed.
  - Communication with the device is accomplished using only two ports: 
    - &FBD1: The control port 
    - &FBD0: The data port
    - And the two BASIC commands INP() for receive and OUT for send.
   
- CPC Printer Emulator converts from parallel to serial https://github.com/dasta400/ACPCPE
- Commodore Wifi adapter http://retropcb.com/2018/10/31/commodore-64-9600-baud-wifi-adapter/
- Documentation
  - The ins and outs of Amstrad CPC https://acpc.me/ACME/LIVRES/[ENG]ENGLISH/MELBOURNE_HOUSE/The_Ins_and_Outs_of_the_AMSTRAD_CPC464(Don_THOMSON)(acme).pdf
  - CPC Firmware Guide https://acpc.me/ACME/DOCS_TECHNIQUES/The_AMSTRAD_CPC_Firmware_Guide(Bob_TAYLOR_Thomas_DEFOE_1994)(ENG).pdf

EXPANSION: 50 way Delta range.
```
1  Sound     2  GND
3  A15       4  A14
5  A13       6  A12
7  A11       8  A10
9  A9        10 A8
11 A7        12 A6
13 A5        14 A4
15 A3        16 A2
17 A1        18 A0
19 D7        20 D6
21 D5        22 D4
23 D3        24 D2
25 D1        26 D0
27 VCC       28 *MREQ
29 *M1       30 *RFSH
31 *IORQ     32 *RD
33 *WR       34 *HALT
35 *INT      36 *NMI
37 *BUSRQ    38 *BUSAK
39 READY     40 *BRST
41 *RSET     42 *ROMEN
43 ROMDIS    44 *RAMRD
45 RAMDIS    46 CURSOR
47 LPEN      48 *EXP
49 GND       50 CLK4
```
