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
	ENEMIES: .word 124 252 380

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


	j getEnemyLocations
	

#	sw $t4, 3968($t0)
	
	j constantLoop
	li $v0, 10
	syscall


getEnemyLocations:
	la $t5, ENEMIES
	# Generate a random number
	li $v0, 42
	li $a0, 0
	li $a1, 31
	syscall
	
	addi $a2, $zero, 128
	mult $a0, $a2
	mflo $a0
	addi $a0, $a0, 124
	
	
	# Save onto the enemy array
	sw $a0, 0($t5)
	
	# Generate another random number
	li $v0, 42
	li $a0, 0
	li $a1, 30
	syscall
	
	mult $a0, $a2
	mflo $a0
	addi $a0, $a0, 124
	
	
	sw $a0, 4($t5)
	
	# Generate a third random number
	li $v0, 42
	li $a0, 0
	li $a1, 30
	syscall
	
	mult $a0, $a2
	mflo $a0
	addi $a0, $a0, 124	
	
	sw $a0, 8($t5)
	
	j constantLoop
	
constantLoop:
	
	li $t9, 0xffff0000 # Set the default address
	lw $t8, 0($t9)
	# Check if ANY key was pressed
	beq $t8, 1, keyPressed
	
	
	# increment enemy ships to move
	jal incrementEnemy

	li $v0, 32
        li $a0, 40 # 25 hertz Refresh rate
        syscall
	j constantLoop



incrementEnemy: 
	la $t5, ENEMIES
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)

	# Checks that if it reaches the end u replace randomly
	
	
	
	# Make the old place black
	add $t3, $a1, $t0
	sw $t1, 0($t3)
	sw $t1, 128($t3)
	sw $t1, 256($t3)
	
	add $t3, $a2, $t0
	sw $t1, 0($t3)
	sw $t1, 128($t3)
	sw $t1, 256($t3)	
	
	add $t3, $a3, $t0
	sw $t1, 0($t3)
	sw $t1, 128($t3)
	sw $t1, 256($t3)
		
	# Subtract each one by 4
	subi $a1, $a1, 4
	subi $a2, $a2, 4
	subi $a3, $a3, 4
	
	# Save the values back onto the array
	sw $a1, 0($t5)
	sw $a2, 4($t5)
	sw $a3, 8($t5)
	
	# Calculate new location to be placed on screen
	add $a1, $a1, $t0
	add $a2, $a2, $t0
	add $a3, $a3, $t0

	# Draw those corresponding values
	sw $t4,	0($a1)
	sw $t4,	128($a1)
	sw $t4,	256($a1)
	
	
	sw $t4, 0($a2)
	sw $t4, 128($a2)
	sw $t4, 256($a2)
	
	sw $t4, 0($a3)
	sw $t4, 128($a3)
	sw $t4, 256($a3)
						
	jr $ra

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
	
	# Check if it's border
	subi $t6, $a2, 3968
	bgez $t6, constantLoop	
	
	
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
	
	# Check if it's border
	
	subi $t6, $a1, 125
	blez $t6, constantLoop	
	
	
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
	
	# Check if it's border
	addi $t6, $zero, 128
	div $a2, $t6
	mfhi $t6
	
	beq $t6, $zero, constantLoop	
	
	
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
	
	
	# Load the right most element early so we can check with it
	lw $t7, 12($t5)


	# Check if it's border
	addi $t6, $zero, 128
	
	subi $a1, $t7, 124
	
	div $a1, $t6
	mfhi $a1
	
	beq $a1, $zero, constantLoop	
	
	# Load the remaining 3 values afterwards (overwrite a1)
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)


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
