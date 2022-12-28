#=========================================================================
# XOR Cipher Cracking
#=========================================================================
# Finds the secret key for a given encrypted text with a given hint.
# 
# Inf2C Computer Systems
# 
# Dmitrii Ustiugov
# 9 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_xor_crack.txt"
hint_file_name:                .asciiz  "hint.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
hint:                         .space 101         # Maximum size of key_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading (text)

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)
       
# opening file for reading (hint)

        li   $v0, 13                    # system call for open file
        la   $a0, hint_file_name        # hint file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # hint[idx] = c_input
        la   $a1, hint($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, hint($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  hint($t0)             # hint[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)
        
        beqz  $t0, FAIL_FIND

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
move $t0, $0                    # register for input index
move $t1, $0                    # register for hint index
move $s0, $0                    # register for key being tested byte
move $s1, $0                    # register for input byte
move $s2, $0                    # register for hint byte
        
TRANSLATE_LOOP:
        bgt  $s0, 255, FAIL_FIND
        add  $t9, $t0, $t8
        lb   $s1, input_text($t9)
        beq  $s1, 13, SKIP_INPUT_CARRY
        beq  $s1, 10, ENTER_IS_SPACE
        j    TRANSLATE_CONTINUE_TO_HINT
        
ENTER_IS_SPACE:
        li   $s1, 32

TRANSLATE_CONTINUE_TO_HINT:
        lb   $s2, hint($t1)
        beq  $s2, $0, SEARCH_COMPLETE
        beq  $s2, 13, SKIP_HINT_CARRY
        beq  $s2, 10, CHECK_HINT_ENTER
                
        j    XOR_CHECK
        
SKIP_HINT_CARRY:
        addi $t1, $t1, 1
        j    TRANSLATE_CONTINUE_TO_HINT
                
CHECK_HINT_ENTER:
        addi $t5, $t1, 1
        lb   $t6, hint($t5)
        beq  $t6, $0, SEARCH_COMPLETE

XOR_CHECK:
        beq  $s1, $0, XOR_ROUND_FAIL
        beq  $s1, 32, SKIP_SPACE
        j    DO_XOR
        
SKIP_SPACE:
        li   $t2, 32
        j    COMPARE_XOR
        
DO_XOR:
        xor  $t2, $s0, $s1
        
COMPARE_XOR:
        beq  $t2, $s2, XOR_CHAR_GOOD
        li   $t1, 0
        addi $t0, $t0, 1
        li   $t8, 0
        j    TRANSLATE_LOOP
        
SKIP_INPUT_CARRY:
        addi $t0, $t0, 1
        j TRANSLATE_LOOP

XOR_CHAR_GOOD:
        addi $t8, $t8, 1 #temporary adder for input index
        addi $t1, $t1, 1
        
        j    TRANSLATE_LOOP
        
XOR_ROUND_FAIL:
        li   $t0, 0
        li   $t1, 0
        addi $s0, $s0, 1
        j    TRANSLATE_LOOP

FAIL_FIND:
        li   $a0, -1
        li   $v0, 1
        syscall
        j    main_end
        
SEARCH_COMPLETE:
        sll  $s0, $s0, 24
	move $t4, $0
	
COMPLETE_PRINT:
        sllv $a0, $s0, $t4
        srl  $a0, $a0, 31
        li   $v0, 1
        syscall
        
        addi $t4, $t4, 1
        blt  $t4, 8, COMPLETE_PRINT
        
        li   $a0, 10
        li   $v0, 11
        syscall
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
