#=========================================================================
# XOR Cipher Encryption
#=========================================================================
# Encrypts a given text with a given key.
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

input_text_file_name:         .asciiz  "input_xor.txt"
key_file_name:                .asciiz  "key_xor.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
key:                          .space 33          # Maximum size of key_file + NULL
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

# opening file for reading (key)

        li   $v0, 13                    # system call for open file
        la   $a0, key_file_name         # key file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP_KEY:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # key[idx] = c_input
        la   $a1, key($t0)              # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP_KEY             # if(feof(key_file)) { break }
        lb   $t1, key($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP_KEY        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        addi $t1, $t1, -48
        beqz $t1, set_zero
        beq  $t1, 1, set_one 
        
        j    END_LOOP_KEY
        
set_zero:
	li $t1, 0
	j set_bit   
	
set_one:
	li $t1, 1
	j set_bit 	                                                                  

set_bit:
        li   $t3, 32
        sub  $t2, $t3, $t0
        sllv $t1, $t1, $t2
        
        or  $s1, $s1, $t1        
        
        j    READ_LOOP_KEY
        
END_LOOP_KEY:
        sb   $0,  key($t0)              # key[idx] = '\0'
        div  $s2, $t0, 8                # store the number of bytes in the key in s2
        
        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)
  

# opening file for reading (text)

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0
        
set_byte_1:
        srl  $t2, $s1, 24   
        
        
set_byte_2:
        sll  $t3, $s1, 8
        srl  $t3, $t3, 24 
        
set_byte_3:
        sll  $t4, $s1, 16
        srl  $t4, $t4, 24   
        
set_byte_4:
        sll  $t5, $s1, 24
        srl  $t5, $t5, 24  
        
        li   $t9, 1                                                                                                              

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
        beq  $t1, 13, READ_LOOP        #DELETE THIS BEFOREHAND !!!!!!!!!!
        beq  $t1, 10, space_or_enter
        beq  $t1, 32, space_or_enter
        beq  $t9, 1, xor_1
        beq  $t9, 2, xor_2
        beq  $t9, 3, xor_3
        beq  $t9, 4, xor_4
        j    READ_LOOP
        
space_or_enter:
        addi $a0, $t1, 0
        li   $v0, 11
        syscall
        
        addi $t9, $t9, 1
        ble  $t9, $s2, READ_LOOP
        li   $t9, 1
        j    READ_LOOP
        
xor_1:
        addi $t8, $t2, 0
        j print_cipher       
        
xor_2:
        addi $t8, $t3, 0
        j print_cipher    
        
xor_3:
        addi $t8, $t4, 0
        j print_cipher    
        
xor_4:
        addi $t8, $t5, 0
        j print_cipher                                                            
        
print_cipher:        
        xor  $a0, $t8, $t1
        li   $v0, 11
        syscall
        
        addi $t9, $t9, 1
        ble  $t9, $s2, READ_LOOP
        li   $t9, 1
        j    READ_LOOP
        
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)




#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!


#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
