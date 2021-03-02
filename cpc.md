# Communication with an Amstrad CPC (mainly from a microcontroller, ESP8266???)

![imagen](https://user-images.githubusercontent.com/7136948/109623183-28a42680-7b3d-11eb-9a4c-ee2bc75d718d.png)

(Got it from http://www.cpcwiki.eu/index.php/Connector:Expansion_port)

- REQUIREMENT #0: To understand the way they exchange bytes through expansion port.
  - http://magic-cookie.co.uk/CPC/expport.html
  - How the hardware responds to I/O commands
    - When you issue an IN/INP or OUT command (from BASIC or machine code), the following things happen:    
    - The IORQ (IO ReQuest) line goes low. This distinguishes it from an attempt to access RAM, for which the MREQ line would go low.    
    - WR goes low if it's a write request, RD goes low if it's a read request.
    - The value of the BC register gets put on the address bus. 
    - For an OUT command, the value of the appropriate register gets put on the data bus.

So, to give an example, if you made a device that would ignore all IN or OUT commands except those to address &F8F0, you could send a byte to it by doing something like OUT &F8F0, &FF (or the machine code equivalent). The IORQ and WR lines would go low, the value &F8F0 would be put on the address bus, and the value &FF would be put on the data bus. The address decoding logic on your expansion device would recognise that this I/O operation was directed at it, and the device would then do whatever it was supposed to with the data on the data bus.

- USIFAC2 is similar but sources are closed.
  - Communication with the device is accomplished using only two ports: 
    - &FBD1: The control port 
    - &FBD0: The data port
    - And the two BASIC commands INP() for receive and OUT for send.
   
- CPC Printer Emulator converts from parallel (printer port) to serial https://github.com/dasta400/ACPCPE
  - uses Teensy, reads all bits at a time
  
- Expansion card with arduino https://hackaday.io/project/169565-arduino-io-card-for-amstrad-cpc-6128  
  - Uses port for reading values.
  - Circuit
  
- Misc Documentation
  - The ins and outs of Amstrad CPC https://acpc.me/ACME/LIVRES/[ENG]ENGLISH/MELBOURNE_HOUSE/The_Ins_and_Outs_of_the_AMSTRAD_CPC464(Don_THOMSON)(acme).pdf
  - CPC Firmware Guide https://acpc.me/ACME/DOCS_TECHNIQUES/The_AMSTRAD_CPC_Firmware_Guide(Bob_TAYLOR_Thomas_DEFOE_1994)(ENG).pdf
  - Big boys talk about communication https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/amstrad-cpc-expansion-port-raiser-with-multiple-edge-connectors-any-interest/25
    - Reported problems with interrupts, ie., if using ESP8266 an interrupt can arrive from Wifi and loose IOREQ

  - https://www.cpcwiki.eu/forum/amstrad-cpc-hardware/albireo-usbsdserial-interface-for-cpc/475/
    - Schematics http://pulkomandy.tk/drop/albireo/Albireo1.0.pdf
    - kicad http://pulkomandy.tk/projects/avrstuff/browser/CPC%20stuff/ch376

- Commodore Wifi adapter http://retropcb.com/2018/10/31/commodore-64-9600-baud-wifi-adapter/
  -  Maybe we can ger sth from here

- Arduino-CPC https://gist.github.com/nicf82/18eced4ebf9648cb47963bdf6f21a345#file-address_decoder-png

```
Signaling part (left part)
```
49 GND  47 LPEN 45 RAMDIS 43 ROMDIS 41 *RSET  39 READY 37 *BUSRQ 35 *INT 33 *WR   31 *IORQ 29 *M1   27 VCC  
50 CLK4 48 *EXP 46 CURSOR 44 *RAMRD 42 *ROMEN 40 *BRST 38 *BUSAK 36 *NMI 34 *HALT 32 *RD   30 *RFSH 28 *MREQ
```
Data part (right part)
```
25 D1  23 D3  21 D5  19 D7  17 A1  15 A3  13 A5  11 A7   9 A9  7 A11  5 A13  3 A15  1 Sound
26 D0  24 D2  22 D4  20 D6  18 A0  16 A2  14 A4  12 A6  10 A8  8 A10  6 A12  4 A14  2 GND
```
- A15-A0 (Address bus; Output from CPU). A15-A0 form a 16-bit address. A15-A0 are used to specify a memory address or an I/O address.
- /BUSAK (Bus Acknowledge; Output from CPU). When /BUSAK="0" the CPU is signalling that control of the address bus, data bus and output signals has been released, and the device can take control.
- /BUS RESET (Bus Reset; Input to PIO/CPU) Acts similarly to /RESET but also resets the PIO chip.
- /BUSRQ (Bus Request; Input to CPU). When /BUSRQ="0" a device is requesting control of the address bus, data bus and the CPU's output signals. At the end of the current instruction cycle, the CPU will issue a Bus Acknowledge.
- D7-D0 (Data bus; Input to CPU/Output from CPU). D7-D0 form 8-bit data. In a I/O operation, D7-D0 are used to transfer data to/from a I/O device. In a memory operation, D7-D0 are used to transfer data to/from memory. In an interrupt request operation, D7-D0 are used to specify part of an interrupt response vector.

- /IORQ (Input/Output Request; Output from CPU). When /IORQ="0" there are two possible functions:
  - Interrupt acknowledge: /M1="0". The interrupt acknowledge function is used to indicate that the interrupting device can put a interrupt vector into D7-D0.
  - I/O operation (read or write): /M1="1", /WR="0" OR /RD="0". The I/O operation is used to read from/write to a I/O device. When the CPU is performing a I/O operation, A15-A0 will contain the I/O address.
       - If /RD is "0" then the operation is reading from a I/O device. D7-D0 will contain data read from the selected device.
       - If /WR is "0" then the operation is writing to a I/O device. D7-D0 contain data to write to the selected device.
        
- /WR (Write; Output from CPU). When /WR="0" the CPU is performing a write operation. The operations are:
    - Writing to a I/O device: (/IORQ="0", A15-A0 contain I/O address)
    - Writing to memory (/MREQ="0", A15-A0 contain memory address)
