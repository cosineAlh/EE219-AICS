; =======================================
; task4
; =======================================

lui     x1,     2148532224          ; x1 = 0x80100000
lui     x4,     2151677952          ; x3 = 0x80400000
lui     x5,     2152726528          ; x5 = 0x80500000
lui     x7,     2154823680          ; x7 = 0x80700000

addi    x9 ,    x1,     0           ; addr_A = A_baseaddr
addi    x10,    x4,     0           ; addr_B = B_baseaddr
addi    x11,    x5,     0           ; addr_C = C_baseaddr
addi    x12,    x7,     0           ; addr_D = D_baseaddr

addi    x13,    zero,   8           ; loop = 8
addi    x14,    x12,    256         ; extension of addr_D
addi    x21,    zero,   0           ; loop4
addi    x16,    zero,   0           ; loop1
loop1:

addi    x17,    zero,   0           ; loop2
addi    x18,    x10,    0           ; addr_B = reg[x10]
loop2:

vle32.v vx3,    x9,     1           ; vx3 = mem[addr_A]
vle32.v vx2,    x18,    1           ; vx2 = mem[addr_B]
vmul.vv vx4,    vx3,    vx2,    0   ; vx4 = vx2 * vx3
vse32.v vx4,    x14,    1           ; mem[addr_D_ext] = vx4

addi    x15,    zero,   0           ; loop3
loop3:
lw      x19,    0(x14)              ; load data_D_ext
add     x20,    x20,    x19         ; accumulation result 
addi    x14,    x14,    4           ; addr_D_ext = addr_D_ext + 4
addi    x15,    x15,    1
blt     x15,    x13,    loop3       ; loop3 end

sw      x20,    0(x12)              ; save x20 into mem[x12] 
addi    x12,    x12,    4           ; addr_D = addr_D + 4
addi    x20,    zero,   0           ; clear reg[20]
addi    x18,    x18,    32          ; addr_B = addr_B + 32
addi    x17,    x17,    1
blt     x17,    x13,    loop2       ; loop2 end

addi    x9,     x9,     32          ; addr_A = addr_A + 32
addi    x16,    x16,    1
blt     x16,    x13,    loop1       ; loop1 end

addi    x12,    x7,     0           ; reset reg[x12]
loop4:
vle32.v vx5,    x12,    1           ; vx5 = mem[addr_D]
vle32.v vx6,    x11,    1           ; vx6 = mem[addr_C]
vadd.vv vx6,    vx6,    vx5,    0   ; vx6 = vx6 + vx5
vse32.v vx6,    x12,    1           ; mem[addr_D] = vx6
addi    x11,    x11,    32          ; addr_C = addr_C + 32
addi    x12,    x12,    32          ; addr_D = addr_D + 32
addi    x21,    x21,    1
blt     x21,    x13,    loop4       ; loop4 end