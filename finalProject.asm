# Bitmap display starter code
#
# Bitmap Display Configuration:
# -Unit width in pixels: 8
# -Unit height in pixels: 8
# -Display width in pixels: 256
# -Display height in pixels: 256
# -Base Address for Display: 0x10008000 ($gp)
#
.eqv BASE_ADDRESS 0x10008000
.eqv SHIPCOLOR 0x964B00

.eqv LEFT 97
.eqv RIGHT 100
.eqv UP 119
.eqv DOWN 115

.data
	SPACESHIP: .word 260 384 388 392
	ENEMIES: .word 128 256 384

.text

.globl main	

# Put main loop in here
main:
	li $t0, BASE_ADDRESS
	li $t1, 0x000000
	li $t4, SHIPCOLOR			
	sw $t1, 0($t0)
	sw $t2, 4($t0)
	# Let this be a temporary ship
	# This is the spaceship initial value
	sw $t4,	260($t0)
	sw $t4, 388($t0)
	sw $t4, 392($t0)
	sw $t4, 384($t0)

	
	j constantLoop
	li $v0, 10
	syscall

constantLoop:
	
	li $t9, 0xffff0000 # Set the default address
	lw $t8, 0($t9)
	# Check if ANY key was pressed
	beq $t8, 1, keyPressed

	j constantLoop


keyPressed:
	lw $t2, 4($t9)
	beq $t2, LEFT, leftIsPressed
	beq $t2, RIGHT, rightIsPressed
	beq $t2, UP, upIsPressed
	beq $t2, DOWN, downIsPressed
	
	j keyPressed
	
	



downIsPressed:
	la $t5, SPACESHIP
	# lw is used to get the value from array
	# sw is used to save the value onto the array
	
	
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# First save ones need to change back to black
	
	add $t3, $a1, $t0
	sw $t1, 0($t3)
	add $t3, $a2, $t0
	sw $t1, 0($t3)
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	
	addi $a1, $a1, 128
	addi $a2, $a2, 128
	addi $a3, $a3, 128
	addi $t7, $t7, 128

	j rePlaceShip	

upIsPressed:
	la $t5, SPACESHIP
	# lw is used to get the value from array
	# sw is used to save the value onto the array
	
	
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# First save ones need to change back to black
	
	add $t3, $a2, $t0
	sw $t1, 0($t3)
	add $t3, $a3, $t0
	sw $t1, 0($t3)
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	
	addi $a1, $a1, -128
	addi $a2, $a2, -128
	addi $a3, $a3, -128
	addi $t7, $t7, -128

	j rePlaceShip	
	
leftIsPressed:
	la $t5, SPACESHIP
	# lw is used to get the value from array
	# sw is used to save the value onto the array
	
	
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# First save ones need to change back to black
	
	add $t3, $a1, $t0
	sw $t1, 0($t3)
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	
	addi $a1, $a1, -4
	addi $a2, $a2, -4
	addi $a3, $a3, -4
	addi $t7, $t7, -4

	
	j rePlaceShip


rightIsPressed:
	la $t5, SPACESHIP
	# lw is used to get the value from array
	# sw is used to save the value onto the array
	
	
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# First save ones need to change back to black

	
	
	
	add $t3, $a1, $t0
	sw $t1, 0($t3)
	add $t3, $a2, $t0
	sw $t1, 0($t3)
	
	addi $a1, $a1, 4
	addi $a2, $a2, 4
	addi $a3, $a3, 4
	addi $t7, $t7, 4

	
	j rePlaceShip
	
	

rePlaceShip:

	# Save the values on the array back first 
	sw $a1, 0($t5)
	sw $a2, 4($t5)
	sw $a3, 8($t5)
	sw $t7, 12($t5)
	
	
	la $t5, SPACESHIP
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	add $a1, $a1, $t0
	add $a2, $a2, $t0
	add $a3, $a3, $t0
	add $t7, $t7, $t0
	
	sw $t4,	0($a1)
	sw $t4, 0($a2)
	sw $t4, 0($a3)
	sw $t4, 0($t7)
	j constantLoop
	
	
# $t0 stores the base address for displayli $t1, 0xff0000
# $t1 stores the red colour codeli $t2, 0x00ff00
# $t2 stores the green colour codeli $t3, 0x0000ff
# $t3 stores the blue colour codesw $t1, 0($t0)
# paint the first (top-left) unit red. sw $t2, 4($t0)
# paint the second unit on the first row green. Why $t0+4?sw $t3, 128($t0)
# paint the first unit on the second row blue. Why +128?li $v0, 10 
# terminate the program gracefully
syscall
