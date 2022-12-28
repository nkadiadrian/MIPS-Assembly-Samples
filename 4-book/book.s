#=========================================================================
# Book Cipher Decryption
#=========================================================================
# Decrypts a given encrypted text with a given book.
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

input_text_file_name:         .asciiz  "input_book_cipher.txt"
book_file_name:               .asciiz  "book.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
book:                         .space 10001       # Maximum size of book_file + NULL
.align 4                                         # The next field will be aligned
cipher_array:                 .space 10001       # Maximum size of cipher_array
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
        
DRAW_WORD:        
        li   $s2, 0                     #first number set to 0 initially
        li   $t2, 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        
        beq  $t1, 32, new_cipher_elem
        beq  $t1, 10, new_cipher_elem
        beq  $t1, 13, READ_LOOP       #DELETE THIS LATER !!!!!!!!!!
        addi $t1, $t1, -48
        
store_array_number:
        mul  $s2, $s2, 10
        #prints number after each multiplication cycle
        #addi $a0, $s2, 0
        #li   $v0, 1
        #syscall
        #li   $a0, 32
        #li   $v0, 11
        #syscall
        
        add  $s2, $s2, $t1
        
        #prints number after new digit added
        #addi $a0, $s2, 0
        #li   $v0, 1
        #syscall        
        #li   $a0, 32
        #li   $v0, 11
        #syscall
        
        j    READ_LOOP      
        
new_cipher_elem:
        #li   $a0, 10
        #li   $v0, 11
        #syscall
        
        sw   $s2, cipher_array($t2)
        addi $t2, $t2, 4
        
        li   $s2, 0
        j    READ_LOOP     
        
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)
        
        move $t0, $0
        move $t1, $0
        
        sw   $0, cipher_array($t2)

print_match:
        
        lw   $t1, cipher_array($t0)     # load first element of array pair into reg $t1
        addi $s1, $t1, 0                # stores the line pointer into $s1
        beq  $s1, $0, end               # go to end if reached the /0 i.e. the end of the array pairs
               
        addi $t0, $t0, 4                #increment the pointer to get the second element of the array pair
        lw   $t1, cipher_array($t0)     # load second element of array pair into reg $t1
        addi $s2, $t1, 0                # stores the word pointer into $s2
        beq  $s2, $0, end               # go to end if reached the /0 i.e. the end of the array pairs
                  
        addi $t0, $t0, 4                # increment address for next element
        j    process_search             # end of iteration   
                

process_search:
# opening file for reading (book)

        li   $v0, 13                    # system call for open file
        la   $a0, book_file_name        # book file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t9, $0                    # idx = 0
        move $t1, $0
        li   $t2, 1
        li   $t3, 1
        

READ_LOOP_BOOK:                         # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # book[idx] = c_input
        la   $a1, book($t9)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(book_file);
        blez $v0, END_LOOP_BOOK             # if(feof(book_file)) { break }
        lb   $t1, book($t9)          
        beq  $t1, $0,  END_LOOP_BOOK        # if(c_input == '\0')
        addi $t9, $t9, 1                # idx += 1
        
        beq  $t1, 10, inc_line_place    # stops printing if it reaaches the end of a line
        beq  $t1, 32, inc_word_place    # stops printing if it reaches the end of the word and sees a space
        beq  $s1, $t2, check_word_index # prints if line and word index is the same
        
        j    READ_LOOP_BOOK
        
check_word_index:

        beq  $s2, $t3, print
        
        j    READ_LOOP_BOOK
        
inc_line_place:
        beq  $s1, $t2, check_enter_line
        addi $t2, $t2, 1
        li   $t3, 1
        j    READ_LOOP_BOOK 
        
check_enter_line:
        bgt  $s2, $t3, print_newline
        addi $t2, $t2, 1
        li   $t3, 1
        j    READ_LOOP_BOOK         
                      
inc_word_place:
        addi $t3, $t3, 1
        beq  $s1, $t2, check_print_space
        j    READ_LOOP_BOOK      
        
check_print_space:
        bne  $s2, $t3, READ_LOOP_BOOK
        beqz $s5, READ_LOOP_BOOK
        addi $a0, $t1, 0
        li   $v0, 11
        syscall
        j    READ_LOOP_BOOK       
        
print_newline:
        li   $t1, 10
        addi $t2, $t2, 1
        li   $t3, 1
        li   $s5, 0
        
        li   $a0, 10
        li   $v0, 11
        syscall
        j    READ_LOOP_BOOK        
       
print:
        addi $a0, $t1, 0
        li   $v0, 11
        syscall
        li   $s5, 1
        
        j READ_LOOP_BOOK     
        
END_LOOP_BOOK:
        sb   $0,  book($t9)             # book[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(book_file)------------------------------------
                
        bne   $s2, $0, print_match
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
end:
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
