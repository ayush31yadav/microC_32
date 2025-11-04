# microC_32
A small 32-bit micro controller created entirely in Verilog with gate level programming.
A detailed explanation of Register file and ALU is given in the attached PDF while the overall structure is present in the `main32` module in `main32.v`

- The architecture does not include a `HALT` mechanism thus the processor continues to keep executing and upon overflow it will roll back to address `0`, in order to make it stop some sort of infinite loop can be created or custom circuit can be added
- `opCode = 011` has 7 empty slots which can be used to implement additional functionality

> NOTE : This was a learning project and thus is bound to contain mistakes

# Structure


```
000 / 000 / 00 / 0000 / 0000 / 0000 - 0000 0000 0000

|     |     i/p  R0     R1     R2

|     spCode                   |---8bit--| |---8bit--|

opCode                         |--------16bit--------|
```




### opcode    i/p


```
000 = B0          | 00 = R  R  : R1 and R2 as INPUT

001 = B1          | 01 = R  16 : R1 and 16bit as INPUT

010 = CMP         | 10 = 16 R  : 16bit and R1 as INPUT

011 = N/A         | 11 = 8  8  : 8bit and 8bit as INPUT

100 = Arithmetic  |

101 = Load/Store  |

110 = Write       |

111 = JMP         |
```


## B0 - 000 


```
spCode         | i/p as needed



000 = AND

100 = NAND

001 = OR

101 = NOR

010 = XOR

110 = XNOR

011 = NEGATE

111 = NOT
```


# B1 - 001 


```
spCode         | i/p = as needed second is shift/rot Amt

L/R S/R L/A



00X = LEFT SHIFT

100 = LOGICAL RIGHT SHIFT

101 = ARITHMETIC RIGHT SHIFT

01X = ROTATE LEFT

11X = ROTATE RIGHT
```


# CMP - 010


```
spCode         | i/p as needed, Rd (R0) is not needed



XX0 = SIGNED COMPARISON

XX1 = UNSIGNED COMPARISON
```


# MISC - 011


```
000 = unconditional JUMP to value in R2 / 16bit (i/p)
```


# ARITHMETIC - 100 


```
spCode         | i/p as needed



u/s (op)



000 = UNSIGNED ADD

001 = UNSIGNED SUB

010 = UNSIGNED MUL

011 = UNSIGNED DIV

100 = SIGNED ADD

101 = SIGNED SUB

110 = SIGNED MUL

111 = SIGNED DIV
```


# LOAD / STORE - 101


```
spCode



L/S accessCode



0XX = LOAD value from memory to register

1XX = STORE value from register to memory
```


memory location = R2 / 16bit depending on i/p\[0]

register to load to = R0

register to store from = R1



# WRITES - 110


```
spCode



XX0 = write lower 16bit

XX1 = write upper 16bit
```


# JUMP - 111


```
spCode



000 = JZ

001 = JNZ

010 = JE

011 = JNE

100 = JG

101 = JGE

110 = JL

111 = JLE
```
