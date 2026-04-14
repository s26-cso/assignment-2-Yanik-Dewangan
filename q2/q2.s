.section .rodata
fmt: .string "%d "
newline: .string "\n"

.text
.globl main
.extern atoi
.extern printf
.extern malloc
.extern free

main:
    addi x2,x2,-64
    sd x1,56(x2)
    sd x18,48(x2)
    sd x19,40(x2)
    sd x20,32(x2)
    sd x21,24(x2)
    sd x22,16(x2)
    sd x23,8(x2)
    sd x24,0(x2)

    addi x18,x10,-1       # n = argc - 1 (number of elements)
    ble x18,x0,exit       # if no input, exit

    mv x19,x11            # x19 = argv pointer

# total memory = arr + result + stack = n * 12 bytes
    slli x10,x18,2        # n * 4
    slli x5,x10,1         # (n*4) * 2
    add x10,x10,x5        # n * 12
    call malloc
    mv x20,x10            # base pointer

    slli x5,x18,2
    add x21,x20,x5        # result array starts after arr
    add x22,x21,x5        # stack starts after result

    li x23,0              # i = 0

parse:
    bge x23,x18,start_algo

    addi x5,x23,1         # argv[i+1]
    slli x5,x5,3          # each pointer = 8 bytes
    add x5,x19,x5
    ld x10,0(x5)          # load string
    call atoi             # convert to integer

    slli x5,x23,2
    add x5,x20,x5
    sw x10,0(x5)          # arr[i] = value

    addi x23,x23,1
    j parse


start_algo:
    li x24,0              # stack size = 0
    addi x23,x18,-1       # i = n-1 (start from right)

loop:
    blt x23,x0,print      # finished processing

    slli x5,x23,2
    add x5,x20,x5
    lw x6,0(x5)           # x6 = arr[i]

# pop smaller elements
while:
    beq x24,x0,empty      # if stack empty

    addi x5,x24,-1
    slli x5,x5,2
    add x5,x22,x5
    lw x7,0(x5)           # x7 = index at top

    slli x5,x7,2
    add x5,x20,x5
    lw x5,0(x5)           # arr[top]

    bgt x5,x6,found       # if arr[top] > arr[i], stop popping

    addi x24,x24,-1       # pop stack
    j while

empty:
    li x7,-1              # no greater element

found:
    slli x5,x23,2
    add x5,x21,x5
    sw x7,0(x5)           # result[i] = index

    slli x5,x24,2
    add x5,x22,x5
    sw x23,0(x5)          # push i onto stack

    addi x24,x24,1        # stack size++
    addi x23,x23,-1       # i--
    j loop

print:
    li x23,0              # i = 0

print_loop:
    bge x23,x18,cleanup

    slli x5,x23,2
    add x5,x21,x5
    lw x11,0(x5)          # load result[i]

    la x10,fmt
    call printf           # print value

    addi x23,x23,1
    j print_loop

cleanup:
    la x10,newline
    call printf

    mv x10,x20
    call free             # free allocated memory

exit:
    li x10,0

    ld x24,0(x2)
    ld x23,8(x2)
    ld x22,16(x2)
    ld x21,24(x2)
    ld x20,32(x2)
    ld x19,40(x2)
    ld x18,48(x2)
    ld x1,56(x2)

    addi x2,x2,64
    ret