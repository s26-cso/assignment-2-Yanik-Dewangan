.section .rodata
filename: .asciz "input.txt"
mode: .asciz "r"
yes_str: .asciz "Yes\n"
no_str: .asciz "No\n"

.text
.globl main
.extern fopen
.extern fseek
.extern ftell
.extern fgetc
.extern fclose
.extern printf

main:
    addi x2,x2,-48        # stack space
    sd x1,40(x2)          # save return address
    sd x18,32(x2)         # file pointer
    sd x19,24(x2)         # left index
    sd x20,16(x2)         # right index
    sd x22,8(x2)          # store left char

    la x10,filename
    la x11,mode
    call fopen
    mv x18,x10            # x18 = file pointer

    mv x10,x18
    li x11,0
    li x12,2              # SEEK_END
    call fseek

    mv x10,x18
    call ftell            # get length
    addi x20,x10,-1       # right = length-1
    li x19,0              # left = 0

    blt x20,x0,yes        # empty file → palindrome

#ignore trailing newline
    mv x10,x18
    mv x11,x20
    li x12,0              # SEEK_SET
    call fseek

    mv x10,x18
    call fgetc
    li x5,10              # '\n'
    bne x10,x5,check
    addi x20,x20,-1       # skip newline

check:
    bge x19,x20,yes       # if left >= right → palindrome

    mv x10,x18
    mv x11,x19
    li x12,0
    call fseek

    mv x10,x18
    call fgetc
    mv x22,x10            # store left char

    mv x10,x18
    mv x11,x20
    li x12,0
    call fseek

    mv x10,x18
    call fgetc

    bne x22,x10,no        # mismatch → not palindrome

    addi x19,x19,1        # left++
    addi x20,x20,-1       # right--
    j check

yes:
    la x10,yes_str
    call printf
    j finish

no:
    la x10,no_str
    call printf

finish:
    mv x10,x18
    call fclose           # close file

    ld x22,8(x2)
    ld x20,16(x2)
    ld x19,24(x2)
    ld x18,32(x2)
    ld x1,40(x2)

    addi x2,x2,48
    li x10,0
    ret