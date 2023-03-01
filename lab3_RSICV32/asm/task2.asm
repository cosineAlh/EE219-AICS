; =======================================
; task2
; =======================================

lui     x1,     2148532224    ; x1 = 0x80100000
lui     x3,     2150629376    ; x3 = 0x80300000
lui     x5,     2152726528    ; x5 = 0x80500000
lui     x7,     2154823680    ; x7 = 0x80700000

addi    x9 ,    x1,     0     ; addr_A = A_baseaddr
addi    x10,    x3,     0     ; addr_B = B_baseaddr
addi    x11,    x5,     0     ; addr_C = C_baseaddr
addi    x12,    x7,     0     ; addr_D = D_baseaddr

addi    x13,    zero,   8     ; loop = 8
addi    x14,    zero,   0     ; first loop
loop1:  

addi    x15,    zero,   0     ; second loop
loop2:  

addi    x16,    zero,   0     ; third loop
addi    x22,    x10,    0     ; addr_B = reg[x10]
addi    x20,    zero,   0     ; clear reg[20]
loop3:  

lw      x17,    0(x9)         ; load data_A
lw      x18,    0(x22)        ; load data_B
mul     x19,    x17,    x18   ; reg[x19] = data_A * data_B
add     x20,    x20,    x19   ; accumulation result 
addi    x9,     x9,     4     ; addr_A = addr_A + 4
addi    x22,    x22,    32    ; addr_B = addr_B + 32  // addr_col(B) + 1
addi    x16,    x16,    1   
blt     x16,    x13 ,   loop3 ; thrid loop end

lw      x21,    0(x11)        ; load data_C
add     x20,    x21,    x20   ; reg[20] = row(A)*col(B) + C
sw      x20,    0(x12)        ; save x20 into mem[x12] 
addi    x20,    zero,   0     ; clear reg[20]
addi    x11,    x11,    4     ; addr_C = addr_C + 4
addi    x12,    x12,    4     ; addr_D = addr_D + 4
addi    x15,    x15,    1 
addi    x9,     x9,     -32   ; addr_A = addr_A - 32
addi    x10,    x10,    4     ; reg[x10] = reg[x10] + 4
blt     x15,    x13,    loop2 ; second loop end

addi    x9,     x9,     32    ; addr_A = addr_A + 32
addi    x10,    x10,    -32   ; reg[x10] = reg[x10] - 32
addi    x14,    x14,    1   
blt     x14,    x13,    loop1 ; first loop end