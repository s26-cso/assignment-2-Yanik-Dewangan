.globl make_node
.globl insert
.globl get
.globl getAtMost

.extern malloc

make_node:
    addi x2,x2,-16        # make stack space
    sd x1,8(x2)           # save return address
    sd x10,0(x2)          # save value

    li x10,24             # size of struct Node = 24 bytes
    call malloc           # allocate memory

    ld x5,0(x2)           # get original value
    sw x5,0(x10)          # store val

    sd x0,8(x10)          # left = NULL
    sd x0,16(x10)         # right = NULL

    ld x1,8(x2)           # restore return address
    addi x2,x2,16         # restore stack
    ret


insert:
    beq x10,x0,create     # if root == NULL

    addi x2,x2,-32
    sd x1,24(x2)
    sd x10,16(x2)         # save root
    sd x11,8(x2)          # save value

    lw x5,0(x10)          # root->val

    beq x11,x5,done       # if equal, do nothing
    blt x11,x5,left       # if val < root

right:
    ld x10,16(x10)        # root->right
    call insert

    ld x6,16(x2)          # original root
    sd x10,16(x6)         # root->right = returned node
    j done

left:
    ld x10,8(x10)         # root->left
    call insert

    ld x6,16(x2)
    sd x10,8(x6)          # root->left = returned node

done:
    ld x10,16(x2)         # return original root
    ld x1,24(x2)
    addi x2,x2,32
    ret

create:
    mv x10,x11            # pass value
    j make_node           # jump to make_node and let IT return to the caller


get:
    beq x10,x0,ret_get    # if root == NULL

    lw x5,0(x10)          # root->val

    beq x11,x5,ret_get    # found
    blt x11,x5,go_left

    ld x10,16(x10)        # go right
    j get

go_left:
    ld x10,8(x10)         # go left
    j get

ret_get:
    ret


getAtMost:
    li x12,-1             # answer = -1

loop:
    beq x11,x0,finish     # if root == NULL
    lw x5,0(x11)          # root->val
    beq x10,x5,exact      # exact match
    blt x10,x5,go_left2   # if val < root->val
    mv x12,x5             # possible answer
    ld x11,16(x11)        # move right
    j loop

go_left2:
    ld x11,8(x11)         # move left
    j loop

exact:
    mv x12,x5             # exact answer

finish:
    mv x10,x12            # return value
    ret