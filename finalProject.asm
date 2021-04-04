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
.eqv SHIPCOLOR 0x1F75FE
.eqv TOMATO 0xFF6347
.eqv RED 0xFF0000
.eqv GREEN 0x00FF00
.eqv LEFT 97
.eqv RIGHT 100
.eqv UP 119
.eqv DOWN 115
.eqv P 112
.eqv GREY 0xC0C0C0
.eqv BLACK 0x000000
.eqv GOLDEN 0xFFC107

.data
	SPACESHIP: .word 1284 1408 1412 1416
	ENEMIES: .word 128 768 2304
	HEALTH: .word 348
.text

.globl main	

# Put main loop in here


resetVar:
	la $s1, SPACESHIP
	la $s2, ENEMIES
	la $s3, HEALTH
	
	addi $s4, $zero, 1284
	sw $s4, 0($s1)
	

	addi $s4, $zero, 1408
	sw $s4, 4($s1)
	
	addi $s4, $zero, 1412
	sw $s4, 8($s1)
	
	addi $s4, $zero, 1416
	sw $s4, 12($s1)
	
	# Reset the enemies now
	addi $s4, $zero, 128
	sw $s4, 0($s2)
	
	addi $s4, $zero, 768
	sw $s4, 4($s2)
	
	addi $s4, $zero, 2304
	sw $s4, 8($s2)
	
	# Reset the health
	addi $s4, $zero, 348
	sw $s4, 0($s3)
	
	j main

clear:
	sub $a2, $a1, $t0
	beq $a2, 4092, endScreen
	sw $t4, 0($a1)
	addi $a1, $a1, 4
	j clear

reset:
	sub $a2, $a1, $t0
	beq $a2, 4092, resetVar
	sw $t4, 0($a1)
	addi $a1, $a1, 4
	j reset
clearScreen:
        add $a1, $zero, $t0
	li $t4, BLACK
	j clear

reduceHealth: 
	li $t4, RED
	la $t5, HEALTH
	# Load the value of t5
	lw $a1, 0($t5)
	
	add $a1, $a1, $t0
	
	# Make the pixels red for a second
	sw $t4, 0($a1)
	sw $t4, 128($a1)
	sw $t4, 4($a1)
	sw $t4, 132($a1)
	
	# Put wait timer here
	li $v0, 32
        li $a0, 40 # 25 hertz Refresh rate
        syscall
        
	li $t4, BLACK
	
	sw $t4, 0($a1)
	sw $t4, 128($a1)
	sw $t4, 4($a1)
	sw $t4, 132($a1)
		
	# Take away the base address and then add 8 [move 2 to the right]
	sub $a1, $a1, $t0
	addi $a1, $a1, 8
	
	beq $a1, 372, clearScreen
	sw $a1, 0($t5)
	
	
	jr $ra

generateHealth:

	li $t4, GREEN
	
	sw $t4, 348($t0)
	sw $t4, 352($t0)
	sw $t4, 356($t0)
	sw $t4, 360($t0)
	sw $t4, 364($t0)
	sw $t4, 368($t0)
	
	sw $t4, 476($t0)
	sw $t4, 480($t0)
	sw $t4, 484($t0)
	sw $t4, 488($t0)
	sw $t4, 492($t0)
	sw $t4, 496($t0)		
	jr $ra

createBorder:
	beq $t5, $t6, getEnemyLocations
	sw $t4, 0($t5)
	addi $t5, $t5, 4
	j createBorder
main:
	li $t0, BASE_ADDRESS
	li $t1, 0x000000
	li $t4, SHIPCOLOR			
	sw $t1, 0($t0)
	sw $t2, 4($t0)
	# Let this be a temporary ship
	# This is the spaceship initial value
	sw $t4,	1284($t0)
	sw $t4, 1408($t0)
	sw $t4, 1412($t0)
	sw $t4, 1416($t0)
	
	addi $t6, $t0, 896
	add $t5, $zero, $zero
	add $t5, $t5, $t0
	addi $t5, $t5, 768
	
	jal generateHealth
	li $t4, GREY
	j createBorder

	li $v0, 10
	syscall




getEnemyLocations:
	li $t4, TOMATO
	la $t5, ENEMIES
	addi $a2, $zero, 128
	# Generate another random number
	li $v0, 42
	li $a0, 0
	li $a1, 8
	syscall
	addi $a0, $a0, 7
	mult $a0, $a2
	mflo $a0
	addi $a0, $a0, 124
	sw $a0, 0($t5)
	


	# Generate another random number
	li $v0, 42
	li $a0, 0
	li $a1, 8
	syscall
	add $a0, $a0, 14
	mult $a0, $a2
	mflo $a0
	addi $a0, $a0, 124
	sw $a0, 4($t5)

	# Generate a third random number
	li $v0, 42
	li $a0, 0
	li $a1, 8
	syscall
	add $a0, $a0, 22
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
	
	
	jal checkCollision
	li $v0, 32
        li $a0, 40 # 25 hertz Refresh rate
        syscall

	j constantLoop



handleCollision:
	
	# First reduce health so that mixing black pixel can be overwritten
	jal reduceHealth
	li $t4, BLACK
	# Handle stuff with objects first
	
	la $t5, ENEMIES
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	
	add $a1, $a1, $t0
	add $a2, $a2, $t0
	add $a3, $a3, $t0
	# First block of 3
	sw $t4,	0($a1)
	sw $t4, 128($a1)
	sw $t4, 256($a1)

	# Second block of 3
	sw $t4,	0($a2)
	sw $t4, 128($a2)
	sw $t4, 256($a2)	
	
	# Third block of 3
	sw $t4,	0($a3)
	sw $t4, 128($a3)
	sw $t4, 256($a3)				
	# Now handle stuff with spaceship
	li $t4, RED
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
	
	
	
	li $v0, 32
        li $a0, 40 # 25 hertz Refresh rate
        syscall

        
        j getEnemyLocations
        
        

checkCollision:
	la $t4, SPACESHIP
	la $t5, ENEMIES
	
	
	# Get the first element of spaceship
	lw $a1, 0($t4)
	# Get the first element of enemy object
	lw $a2, 0($t5)
	
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	
	# Now check if spaceship first hit second object
	lw $a2, 4($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision	
	
	# Now check if spaceship first hit third object
	lw $a2, 8($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision	
	
	# CheckCheck if spaceship second hit first object
	lw $a1, 4($t4)
	lw  $a2, 0($t5)
	
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision	
	
	# Chcek if spaceship second hit second object
	lw $a2, 4($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision	
	
	# Check if spaceship second hit third object
	lw $a2, 8($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision	
	
	# Check if spaceship third hit first object
	lw $a1, 8($t4)
	lw  $a2, 0($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision		
	
	# Check if spaceship third hit second object
	
	lw $a2, 4($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	
	# Check if spaceship third hit third object
	lw $a2, 8($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision	
	
	# Check 4th element now
	lw $a1, 12($t4)
	lw  $a2, 0($t5)	
	# Check the 4th element with the first object
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision		
	
	lw $a2, 4($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision		
	
	lw $a2, 8($t5)
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision
	addi $a2, $a2, 128
	beq $a1, $a2, handleCollision		
	
	jr $ra

incrementEnemy: 
	li $t4, TOMATO
	la $t5, ENEMIES
	lw $a1, 0($t5) # This should give you the first element of array	
	lw $a2, 4($t5)
	lw $a3, 8($t5)


		
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
		
	# Checks that if it reaches the end u replace randomly
	addi $t6, $zero, 128
	div $a1, $t6
	mfhi $a1
	
	beq $a1, $zero, getEnemyLocations		
		
	lw $a1, 0($t5)
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
	li $t4, SHIPCOLOR
	lw $t2, 4($t9)
	beq $t2, LEFT, leftIsPressed
	beq $t2, RIGHT, rightIsPressed
	beq $t2, UP, upIsPressed
	beq $t2, DOWN, downIsPressed
	beq $t2, P, PisPressed
	
	
	j keyPressed
	
PisPressed:
        add $a1, $zero, $t0
	li $t4, BLACK
	j reset	



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
	
	subi $t6, $a1, 1025
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
	
endScreen: 
	li $v0, 32
        li $a0, 1000 # 25 hertz Refresh rate
        syscall
        
        li $t4, GREEN
        

        # Top of E
        sw $t4, 400($t0)
        sw $t4, 404($t0)
        sw $t4, 408($t0)
        sw $t4, 412($t0)
        sw $t4, 416($t0)
        sw $t4, 420($t0)
	
	sw $t4, 528($t0)
	sw $t4, 656($t0)
	sw $t4, 784($t0)
	sw $t4, 912($t0)
	
	sw $t4, 916($t0)
	sw $t4, 920($t0)
	sw $t4, 924($t0)
	sw $t4, 928($t0)
	sw $t4, 932($t0)
	
	
	sw $t4, 1040($t0)
	sw $t4, 1168($t0)
	sw $t4, 1296($t0)
	sw $t4, 1424($t0)
	
	sw $t4, 1428($t0)
	sw $t4, 1432($t0)
	sw $t4, 1436($t0)
	sw $t4, 1440($t0)		
	sw $t4, 1444($t0)	
	
	# Letter N
	sw $t4, 432($t0)
	sw $t4, 560($t0)
	
	sw $t4, 564($t0)
	
	sw $t4, 688($t0)
	
	sw $t4, 696($t0)
	
	sw $t4, 816($t0)	
	
	sw $t4, 828($t0)
	
	sw $t4, 944($t0)
	
	sw $t4, 960($t0)
	
	sw $t4, 1072($t0)
	
	sw $t4, 1092($t0)
	
	sw $t4, 1200($t0)
	
	sw $t4, 1224($t0)
	
	sw $t4, 1328($t0)
	
	sw $t4, 1356($t0)
	
	sw $t4, 1456($t0)
	


# going up starts
	sw $t4, 1488($t0)
	
	sw $t4, 1360($t0)
	
	sw $t4, 1232($t0)
	
	sw $t4, 1104($t0)
	
	sw $t4, 976($t0)
	
	sw $t4, 848($t0)
	
	sw $t4, 720($t0)
	
	sw $t4, 592($t0)
	
	sw $t4, 464($t0)
	
	# Letter D
	
	sw $t4, 476($t0)
	sw $t4, 480($t0)
	sw $t4, 484($t0)
	
	sw $t4, 616($t0)
	sw $t4, 748($t0)
	sw $t4, 880($t0)
	sw $t4, 1008($t0)
	sw $t4, 1136($t0)
	sw $t4, 1260($t0)
	sw $t4, 1384($t0)
	sw $t4, 1384($t0)
	sw $t4, 1508($t0)
	sw $t4, 1504($t0)
	sw $t4, 1500($t0)

	sw $t4, 1372($t0)
	sw $t4, 1244($t0)
	sw $t4, 1116($t0)
	sw $t4, 988($t0)
	sw $t4, 860($t0)
	sw $t4, 732($t0)
	sw $t4, 604($t0)
	
	
	# Letter P
	li $t4, GOLDEN
	sw $t4, 1972($t0)
	sw $t4, 1976($t0)
	sw $t4, 1980($t0)
	sw $t4, 1984($t0)
	sw $t4, 1988($t0)
	sw $t4, 1972($t0)
	sw $t4, 2120($t0)
	sw $t4, 2252($t0)
	sw $t4, 2380($t0)
	sw $t4, 2508($t0)
	sw $t4, 2636($t0)
	sw $t4, 2760($t0)
	sw $t4, 2884($t0)
	sw $t4, 2880($t0)
	sw $t4, 2876($t0)
	sw $t4, 2872($t0)
	
	sw $t4, 2100($t0)
	sw $t4, 2228($t0)
	sw $t4, 2356($t0)
	sw $t4, 2484($t0)
	sw $t4, 2612($t0)
	sw $t4, 2740($t0)
	sw $t4, 2868($t0)
	sw $t4, 2996($t0)
	sw $t4, 3124($t0)
	sw $t4, 3252($t0)
	sw $t4, 3380($t0)
	
	sw $t4, 3508($t0)
	
	
	li $t9, 0xffff0000 # Set the default address
	lw $t8, 0($t9)
	# Check if ANY key was pressed
	beq $t8, 1, keyPressed	
	
	
	j endScreen
# $t0 stores the base address for displayli $t1, 0xff0000
# $t1 stores the red colour codeli $t2, 0x00ff00
# $t2 stores the green colour codeli $t3, 0x0000ff
# $t3 stores the blue colour codesw $t1, 0($t0)
# paint the first (top-left) unit red. sw $t2, 4($t0)
# paint the second unit on the first row green. Why $t0+4?sw $t3, 128($t0)
# paint the first unit on the second row blue. Why +128?li $v0, 10 
# terminate the program gracefully
syscall
