#=========================================================================
# Steganography
#=========================================================================
# Retrive a secret message from a given text.
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

input_text_file_name:         .asciiz  "input_steg.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
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

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0
        
        li   $s1, 1                     # use s2 as line counter
        li   $s2, 1                     # use s2 as word counter
        li   $s3, 0                     # use s3 as checker for if you are currently on a new line and so shouldn't print the first space
        

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
        la   $a1, input_text($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP         # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        
        beq  $t1, 10, inc_line_place    #stops printing if it reaaches the end of a line
        beq  $t1, 32, inc_word_place    #stops printing if it reaches the end of the word and sees a space
        beq  $s1, $s2, print            #prints if printing is switched on
        
        j    READ_LOOP
 
inc_line_place:
        bgt  $s1, $s2, print_newline
        addi $s1, $s1, 1
        li   $s2, 1
        j    READ_LOOP        
                      
inc_word_place:
        addi $s2, $s2, 1
        beq  $s1, $s2, print            #prints if printing is switched on
        j    READ_LOOP
        
print_newline:
        addi $s1, $s1, 1 #still have to increment the line number and reset the word number
        li   $s2, 1 
        li   $s3, 1
        li   $a0, 10
        li   $v0, 11
        syscall        
        addi $t0, $t0, 1                # idx += 1               
        j    READ_LOOP
        
print: 
        bnez $s3, hold_newline_space
        addi $a0, $t1, 0
        li   $v0, 11
        syscall        
        addi $t0, $t0, 1                # idx += 1               
        j    READ_LOOP        
        
hold_newline_space:
        li   $s3, 0
        j    READ_LOOP        
        
END_LOOP:
        li   $a0, 10
        li   $v0, 11
        syscall

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
