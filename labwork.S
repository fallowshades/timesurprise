  # labwork.S
  # Written 2015-2017 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1.
  # The macros PUSH and POP are in the public domain.
  # Please add your own code at the end of the file.

  #
  # Please keep the two macros PUSH and POP unchanged
  #
.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm
  #
  # Please add your own code below this line
  #


	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,0x7f000000
	jal	delay
	nop

	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr#addr
	la	$t0,mytime 
	lw	$a1,0($t0) #value
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop
	

	
  # previous assignment//note must above timeToStreing
  #
  
 letters:
 	andi $v0, $a0, 0xf #converge range between A-P
 	addi $v0, $v0, 0x40 #first letter in alphabet A = 41 (remember add from 0)
 	
 Le:
 	jr $ra
	nop
  
hexasc:
	#value
	andi $v0, $a0, 0xf #mask 4 lsb to reepresent decimal nr 0-15
	#ascii chart position
	addi $v0, $v0, 0x30 #position in ascii table representing 1st  = 48nr
	
	# <= not 0-9
	ble $v0, 0x39, L1 #if statement ´hop over addition of letter converstion
	nop
	
	#assci additional right position -> letters
	addi $v0, $v0, 7 #letters are positioned 7 additional placments to the right
			#note +1 position from decimal nr.
L1:
	jr $ra
	nop
	
  # you can write your code for subroutine "hexasc" below this line
  #but i wrote timetostring
  #
.global time2string
time2string:
  ##1st letter from the left x0:00 //bc i desided to start shifting first minute
	
	
	

checkSurprise:
	#$t4 = masked initial value to dedicate flow and and how much space string need
	#t5 = value is looking for
	
	addi $t5, $0, 9 #int flowCondition = 9
	andi $t4, $a1, 0xF #int observableLetter = value & 0xF
	beq $t4, $t5, surprise
	
	
notsurprise:


	PUSH $ra
	
	
########################Store order x0:00, 0x:00, 00:x0, 00:0x################
#note that save byte store text fromo the right, while the argument store from the left -> no need change code above

#the shift logic doesn't need cange bc it is from the 32bit from argument
#meanwhile the save byte need to change

#annother note is that the argument value for time2String is another register than in hextec

	#this is x0:00 and is the first byte to store
	PUSH $a0 #addr
	PUSH $a1 #value //!need move to $a0 for hexasc f()
	srl $a0, $a1, 12 #shift towards 1st hour digit (no dependence for hextec to decipher value)
	jal hexasc #will mask 4bit & convert
	nop
	POP $a1
	POP $a0 #the previous addr
	
	sb $v0,	0($a0)		#store at 1st string byte
	
	#this is 0x:00 and is the 2nd stored byte
	PUSH $a0
	PUSH $a1
	srl $a0, $a1, 8 	#take second digit into msb4
	jal hexasc		#convert to char
	nop
	POP $a1
	POP $a0 		#addr of string
	sb $v0,	1($a0)		#store second digit at next index
	
	#coolon
	li $t2,0x3A		# asscci code is ":"=
	sb $t2,2($t0)
	
	#this is 00:x0 which is the 3rd letter stored
	PUSH $a0
	PUSH $a1
	srl $a0, $a1, 4 	#take thrid digit into msb4
	jal hexasc		#convert to char
	nop
	POP $a1
	POP $a0
	sb $v0,	3($a0)		#store third digit
	
	#4this is 00:0x which is the 4th letter stored
	PUSH $a0		#argument a1 is unimportant now
	move $a0, $a1		#last digit such correct argument register
	jal hexasc		##convert to char
	nop
	POP $a0
	sb $v0,	4 ($a0) 		#store 5th byte
	


#null terminator
	li $t2,0x00		#null terminator
	sb $t2,5($a0)		#end of word
	
	POP $ra		#return ra
	
	jr $ra 			#back to the future
	nop

#wisdome 1st and snd letter != descriptive 
surprise:

	PUSH $ra
	#this is x0:00 and is the first byte to store
	PUSH $a0 #addr
	PUSH $a1 #value //!need move to $a0 for hexasc f()
	srl $a0, $a1, 12 #shift towards 1st hour digit (no dependence for hextec to decipher value)
	jal hexasc #will mask 4bit & convert
	nop
	POP $a1
	POP $a0 #the previous addr
	
	sb $v0,	0($a0)		#store at 1st string byte
	
	#this is 0x:00 and is the 2nd stored byte
	PUSH $a0
	PUSH $a1
	srl $a0, $a1, 8 	#take second digit into msb4
	jal hexasc		#convert to char
	nop
	POP $a1
	POP $a0 		#addr of string
	sb $v0,	1($a0)		#store second digit at next index
	
	#coolon
	li $t2,0x3A		# asscci code is ":"=
	sb $t2,2($t0)
	
	#this is 00:x0 which is the 3rd letter stored
	PUSH $a0
	PUSH $a1
	srl $a0, $a1, 4 	#take thrid digit into msb4
	jal hexasc		#convert to char
	nop
	POP $a1
	POP $a0
	sb $v0,	3($a0)		#store third digit

####################suprise change
	#4this is 00:0x which is the 4th letter stored
	PUSH $a0		#argument a1 is unimportant now
	li $a0, 14
	jal letters		##convert to char
	nop
	POP $a0
	sb $v0,	4 ($a0) 		#store 5th byte
	
	#4this is 00:0x which is the 4th letter stored
	PUSH $a0		#argument a1 is unimportant now
	li $a0, 9
	jal letters		##convert to char
	nop
	POP $a0
	sb $v0,	5 ($a0) 		#store 5th byte
	
	
	#4this is 00:0x which is the 4th letter stored
	PUSH $a0		#argument a1 is unimportant now
	li $a0, 14
	jal letters		##convert to char
	nop
	POP $a0
	sb $v0,	6 ($a0) 		#store 5th byte
	
	
	#4this is 00:0x which is the 4th letter stored
	PUSH $a0		#argument a1 is unimportant now
	li $a0, 5
	jal letters		##convert to char
	nop
	POP $a0
	sb $v0,	7 ($a0) 		#store 5th byte
###########################3	


#null terminator
	li $t2,0x00		#null terminator
	sb $t2,8($a0)		#end of word
	
	POP $ra		#return ra
	
	jr $ra 			#back to the future
	nop






###########################################################################
.global delay
delay:
	#$t0 = i
	#$t1 = conditional
	#$s1 = argumen
	move $s1, $a0
	#addi $s1, $0, -3	 #assignment // only consern outer loop
	
##outer brackets
while: 


	#whil3e( 0 < arg)git 
	sgt $t1, $0 , $s1	#0 < $a0  --> 1 if ture(the reverse statement
	bne $t1, $0, done	#t1 = conditiond-> do if not equal, ie logic 1=true
	#beq $s1, $0, done #if equal other wise 0 = rist infinite loops (-1 is counter productive)
	#beq $t1, $0, done #if state ment if less than
	nop
	#logic
	addi $s1, $s1, -1	#ms = ms - 1
	
	#nested block initialization
	addi $t0, $0, 0x0 #initiate i

	
	lui $s3, 0x0002
	ori $t3, $0, 0xcf00
##inner brackets
for:
	#i <4711#"was in mars environment"
	slt $t1, $t0, $t3  #i < delay --> 1 if ture
	beq $t1,$0, while	#back to while once i is not< constant
	nop
	
	addi $t0, $t0 ,1		#i++
	j for
	nop
##
done: 

	jr $ra
	nop
	




