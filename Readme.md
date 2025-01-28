# Operating System in 1000 lines of zig code!

## memory Access
lw a0, (a1)
sw a0, (a1) // dest, source

## branch instructions
bnez a0, <label>
<label>
// beq (branch if equal)
// blt (branch if less than)

## function calls
// jal (jump and link)
jal ra, <label>
// ret (return)
ret

## stack
// addi
addi sp, sp, -4 // push
addi sp, sp, 4 // pop // assignment, operand, operation

## Priviledged Instructions
csrr rd, csr
csrw csr, rs
csrrw rd, csr, rs

sret
sfence.vma
