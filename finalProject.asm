# 
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough

#Student: Samyak Mehta, 1006298542, mehtas28

# Bitmap Display Configuration:
# -Unit width in pixels: 8
# -Unit height in pixels: 8
# -Display width in pixels: 256
# -Display height in pixels: 256
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave beenreached in this submission?
# -Milestone 4 (Finished project)

# Which approved features have been implemented for milestone 4?

# 1.) Different levels of collision based on where the ship is impacted (Piazza post @300)
# 2.) Graphics (No flickering, very smooth running of game)
# 3.) Increasing difficulty over time

# Link to video demonstration for final submission:
# <INSERT YOUTUBE VIDEO HERE>!!!

# Are you OK with us sharing the video with people outside course staff?
# Yes!
# Project github link:

# Additional Info for TA:
# Hope you like my game :)

# Define my constants
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

# define our data with the elements corresponding to the positions
.data
	SPACESHIP: .word 1284 1408 1412 1416
	ENEMIES: .word 128 768 2304
	HEALTH: .word 348
.text

.globl main	

# Reset the variable after 
resetVar:
	# Load the three main data files so that we can reset those variables
	la $s1, SPACESHIP
	la $s2, ENEMIES
	la $s3, HEALTH
	
	# Reset the first value back to original ship position (offset 0)
	addi $s4, $zero, 1284
	sw $s4, 0($s1)
	
	# Reset the second value back to original ship position (offset 4)
	addi $s4, $zero, 1408
	sw $s4, 4($s1)
	
	# Reset the third value back to original ship position (offset 8)
	addi $s4, $zero, 1412
	sw $s4, 8($s1)
	
	# Reset the fourth value back to original ship position (offset 12)
	addi $s4, $zero, 1416
	sw $s4, 12($s1)
	
	# Reset the enemies we loaded earlier, first element is offset 0
	addi $s4, $zero, 128
	sw $s4, 0($s2)
	
	# Reset the enemies, second element is offset 4
	addi $s4, $zero, 768
	sw $s4, 4($s2)
	
	# Reset the enemies, third element is offset 8
	addi $s4, $zero, 2304
	sw $s4, 8($s2)
	
	# Reset the health back to its original position
	addi $s4, $zero, 348
	sw $s4, 0($s3)
	
	# Go back to the main loop 
	j main

# In a loop clear the entire screen
clear:
	# We want to compare whether we are at the last element
	# so first we subtract a1 from the original t0 value so 
	# we can get it in terms of index value
	sub $a2, $a1, $t0
	# Check if it equals the bottom right most pixel (then our loop is done)
	
	beq $a2, 4092, endScreen
	sw $t4, 0($a1)
	# Add 4 each loop iteration so we can slowly clear the whole screen
	addi $a1, $a1, 4
	j clear


clearScreen:
# Setup the starter variables needed before calling the clear function
# Let a1 have the t0 value so that we only concern ourselves with the index
        add $a1, $zero, $t0
        
# Maek sure my color register is set to black (to reset)
	li $t4, BLACK
	j clear


hitOne:
	# Make the pixels red for a second
	sw $t4, 0($a1)
	sw $t4, 128($a1)

	
	# Put wait timer here so that it stays red for a while
	li $v0, 32
        li $a0, 40 
        syscall

	# Set the color back to black
	li $t4, BLACK
	
	# Change the corresponding pixels to black
	sw $t4, 0($a1)
	sw $t4, 128($a1)

		
	# Take away the base address to compute in terms of index
	sub $a1, $a1, $t0
	#  and then add 4 [move 1 to the right]
	addi $a1, $a1, 4
	
	# Check if the health is empty, then start clearing to end game
	beq $a1, 376, clearScreen
	beq $a1, 380, clearScreen
	sw $a1, 0($t5)
	
	# Jump back to function caller
	jr $ra	
	
hitTwo:
# Make the 2 elements red to account for second type of collision
	sw $t4, 0($a1)
	sw $t4, 4($a1)
	sw $t4, 128($a1)
	sw $t4, 132($a1)
	
	# Put wait timer here to let it be red for a while
	li $v0, 32
        li $a0, 40
        syscall
      
	li $t4, BLACK
	# Change the color back to black for all 4 pixels
	sw $t4, 0($a1)
	sw $t4, 4($a1)
	sw $t4, 128($a1)
	sw $t4, 132($a1)

	# Take away the base address and then add 4 [move 1 to the right]
	sub $a1, $a1, $t0
	addi $a1, $a1, 8
	
	# Check if health is empty then you need to clear screen and start ending game
	beq $a1, 376, clearScreen
	beq $a1, 380, clearScreen
	sw $a1, 0($t5)
	
	# Jump back to caller
	jr $ra


reduceHealth: 
	li $t4, RED
	la $t5, HEALTH
	# Load the value of the health variable inside a1
	lw $a1, 0($t5)
	# Add the base register 
	add $a1, $a1, $t0
	# Check if it was hit once or twice
	beq $s5, 1, hitOne
	beq $s5, 2, hitTwo
	
	
	

generateHealth:
	# In the starter manually add every single pixel for the health bar
	# Each health value is 2 pixels (top and bottom)
	li $t4, GREEN
	
	sw $t4, 348($t0)
	sw $t4, 352($t0)
	sw $t4, 356($t0)
	sw $t4, 360($t0)
	sw $t4, 364($t0)
	sw $t4, 368($t0)
	sw $t4, 372($t0)
	
	sw $t4, 476($t0)
	sw $t4, 480($t0)
	sw $t4, 484($t0)
	sw $t4, 488($t0)
	sw $t4, 492($t0)
	sw $t4, 496($t0)
	sw $t4, 500($t0)	
	
	# Jump back to the caller	
	jr $ra


createBorder:
	# Make the grey boarder underneath the health bar
	# A loop that goes thoroughly adding a grey bar throuhgout the whole game
	beq $t5, $t6, getEnemyLocations
	# Draw the value as a grey pixel (t4 is loaded with grey color when this is called)
	sw $t4, 0($t5)
	# Add 4 and call this loop again 
	addi $t5, $t5, 4
	# Go to createBoarder
	j createBorder

main:
	# STARTER TAG!
	li $t0, BASE_ADDRESS
	li $t1, 0x000000
	li $t4, SHIPCOLOR			
	sw $t1, 0($t0)
	sw $t2, 4($t0)
	
	# This is the spaceship initial value
	sw $t4,	1284($t0)
	sw $t4, 1408($t0)
	sw $t4, 1412($t0)
	sw $t4, 1416($t0)
	sw $t1, 4($t0)
	
	# Set the values needed for generateHealth (loop function)
	addi $t6, $t0, 896
	# Make sure the value is originally initialized to 0
	add $t5, $zero, $zero
	# Add the base address to it so our function can base off index value
	add $t5, $t5, $t0
	# Add 768 because that's the first index from the leftmost side
	addi $t5, $t5, 768
	# The original speed of the game
	addi $s7, $zero, 40
	
	# Generate health and come back
	jal generateHealth
	
	# Prepare the function before making createBoarder
	li $t4, GREY
	j createBorder

# Terminate program (should never reach here)
	li $v0, 10
	syscall


finalSpeedChange:
# Make the speed slightly faster
	subi $s7, $s7, 1
	jr $ra

checkMax:
# a0 is randomized so we check if this value is one
# So every time the obstacles reach the end there is a 50% chance speed will increase by 1
	beq $a0, 1, finalSpeedChange
	jr $ra

speedIncrementRandom:
	# Generate a random value, to compare this and create a probability of whetehr or not speed will be incremented
	li $v0, 42
	li $a0, 0
	li $a1, 2
	syscall	
	# Cap this value at 20 so that it cannot reach lower (Otherwise game will be too hard)
	bne $s7, 20, checkMax
	# Jump back to caller
	jr $ra



getEnemyLocations:
	# Increment the speed change first and return
	jal speedIncrementRandom
	# Set the color to red [Tomato] and load the enemies
	li $t4, TOMATO
	la $t5, ENEMIES
	addi $a2, $zero, 128
	# Generate a random number from 0 to 8
	li $v0, 42
	li $a0, 0
	li $a1, 8
	syscall
	# Increment this value by 7 since we have 7-30 y values valid it can iterate over
	addi $a0, $a0, 7
	# Multipl this value by 128, this gives us a random value from 7-15 in terms of y axis
	mult $a0, $a2
	mflo $a0
	# Add 124 so that it starts from rightmost side
	addi $a0, $a0, 124
	# Save this value inside the obstacle array
	sw $a0, 0($t5)
	


	# Generate another random number
	li $v0, 42
	li $a0, 0
	li $a1, 8
	syscall
	# Offset is of 14, so this is responsible for generating one in the middle
	add $a0, $a0, 14
	# Multiply by 128 to get a value from 14 to 22
	mult $a0, $a2
	mflo $a0
	# Place on rightmost side
	addi $a0, $a0, 124
	# Save this as the second element
	sw $a0, 4($t5)

	# Generate a third random number
	li $v0, 42
	li $a0, 0
	li $a1, 8
	syscall
	# Makes the offset for the third one to be values from 22-30
	add $a0, $a0, 22
	# Same idea as above
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
	
	# make faster every round firsts
	jal checkCollision
	
	# Different speeds, as s7 is exclusive register for tracking speed
	li $v0, 32
	add $a0, $zero, $s7
        syscall

	j constantLoop



handleCollision:
	
	# First reduce health so that mixing black pixel can be overwritten
	jal reduceHealth
				
	li $v0, 32
        li $a0, 40 
        syscall

        # Call get enemyLocations to randomize them once again
        j getEnemyLocations
       
       
colorShip: 

	li $t4, BLACK
	# Handle stuff with objects first
	
	# This should give you the first element of array	
	la $t5, ENEMIES
	
	# Load the first 3 values of the ENEMIES array
	lw $a1, 0($t5) 
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	
	# Add the base address to all of them
	add $a1, $a1, $t0
	add $a2, $a2, $t0
	add $a3, $a3, $t0
	# Color first block of 3
	sw $t4,	0($a1)
	sw $t4, 128($a1)
	sw $t4, 256($a1)

	# Color second block of 3
	sw $t4,	0($a2)
	sw $t4, 128($a2)
	sw $t4, 256($a2)	
	
	# Color third block of 3
	sw $t4,	0($a3)
	sw $t4, 128($a3)
	sw $t4, 256($a3)


	# This loads the first 4 elements of the spaceship array
	la $t5, SPACESHIP
	lw $a1, 0($t5)	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# Add the base address to all 4 of them
	add $a1, $a1, $t0
	add $a2, $a2, $t0
	add $a3, $a3, $t0
	add $t7, $t7, $t0
	
	# Draw the new spaceship over again since the collision would have
	# Removed one of the values of the spaceship 
	sw $s4,	0($a1)
	sw $s4, 0($a2)
	sw $s4, 0($a3)
	sw $s4, 0($t7)
	# Jump to handleCollision
	j handleCollision

	
        

checkCollision:
	# Load the sapceship and enemy into registers
	la $t4, SPACESHIP
	la $t5, ENEMIES
	
	
	# Get the first element of spaceship
	lw $a1, 0($t4)
	# Get the first element of enemy object
	lw $a2, 0($t5)
	
	
	# Set it to golden because we are checking weak collision first
	li $s4, GOLDEN
	# Put 1 in s5 so we know later that this was a weak collision
	addi $s5, $zero, 1
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	
	# Now check if spaceship first hit second object
	lw $a2, 4($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip	
	
	# Now check if spaceship first hit third object
	lw $a2, 8($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip	
	
	# Load the color red inside s4
	li $s4, TOMATO
	# s5 is specifically designed for damage so we know later this was strong collision
	addi $s5, $zero, 2
	# CheckCheck if spaceship second hit first object
	lw $a1, 4($t4)
	lw  $a2, 0($t5)
	
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip	
	
	# Chcek if spaceship second hit second object
	lw $a2, 4($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip	
	
	# Check if spaceship second hit third object
	lw $a2, 8($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip	
	
	# Check if spaceship third hit first object
	lw $a1, 8($t4)
	lw  $a2, 0($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip		
	
	# Check if spaceship third hit second object
	
	lw $a2, 4($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	
	# Check if spaceship third hit third object
	lw $a2, 8($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip	
	
	# Check 4th element now
	lw $a1, 12($t4)
	lw  $a2, 0($t5)	
	# Check the 4th element with the first object
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip		
	# Same idea as above
	lw $a2, 4($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip		
	
	# Same process once again. Explanation defined above
	lw $a2, 8($t5)
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip
	addi $a2, $a2, 128
	beq $a1, $a2, colorShip		
	
	# Jump back to the function caller
	jr $ra

incrementEnemy: 
	# Load the color red and enemies array
	li $t4, TOMATO
	la $t5, ENEMIES
	# This should give you the first element of array
	lw $a1, 0($t5)
	lw $a2, 4($t5)
	lw $a3, 8($t5)	
	# Inside t3 add the base address
	add $t3, $a1, $t0
	# Make the old place black ($t1 has black stored)
	sw $t1, 0($t3)
	sw $t1, 128($t3)
	sw $t1, 256($t3)
	# For the second element of the enemies list
	add $t3, $a2, $t0
	sw $t1, 0($t3)
	sw $t1, 128($t3)
	sw $t1, 256($t3)	
	# For the third element of the enemies list
	add $t3, $a3, $t0
	sw $t1, 0($t3)
	sw $t1, 128($t3)
	sw $t1, 256($t3)
		
	# Checks that if it reaches the end u replace randomly
	addi $t6, $zero, 128
	div $a1, $t6
	mfhi $a1
	
	# If it is zero randomize once again
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
	# Draw the second obstacle items again
	sw $t4, 0($a2)
	sw $t4, 128($a2)
	sw $t4, 256($a2)
	# Draw the third obstacle items again
	sw $t4, 0($a3)
	sw $t4, 128($a3)
	sw $t4, 256($a3)
	# Jump back to function caller
	jr $ra

keyPressed:
	# Save ship color inside t4 to use later
	li $t4, SHIPCOLOR
	# From assignment, to check for key input
	lw $t2, 4($t9)
	# Check if left was pressed
	beq $t2, LEFT, leftIsPressed
	# Check if right was pressed
	beq $t2, RIGHT, rightIsPressed
	# Check if up is pressed
	beq $t2, UP, upIsPressed
	# Check if down is pressed
	beq $t2, DOWN, downIsPressed
	# Check if p is pressed
	beq $t2, P, PisPressed
	
	# Keep looping over till a key is read 
	#(Shouldn't come to this since we only come here if a value was read)
	j keyPressed

	
PisPressed:
	# If p is pressed stop everything and reset the function
        add $a1, $zero, $t0
        # Set the variable to black for resetting the board
	li $t4, BLACK
	j reset	


downIsPressed:
	la $t5, SPACESHIP
	# lw is used to get the value from array
	# sw is used to save the value onto the array
	
	# Load values of the spaceship array
	lw $a1, 0($t5) 	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# Check if it's on the border (shouldn't move then) border

	subi $t6, $a2, 3968
	bgez $t6, constantLoop	
	
	
	# First save ones need to change back to black
	
	add $t3, $a1, $t0
	sw $t1, 0($t3)
	add $t3, $a2, $t0
	sw $t1, 0($t3)
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	
	# Move all the elements by 128 since we are moving down
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
	
	# Subtract 128 since we are moving up in direction
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
	
	# Subtract 4 since we are going left
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
	
	# add 4 since we are going right
	addi $a1, $a1, 4
	addi $a2, $a2, 4
	addi $a3, $a3, 4
	addi $t7, $t7, 4

	
	j rePlaceShip
	
	

rePlaceShip:
	# General function for any of the keys above to redraw the ship once it is complete
	# Save the values on the array back first 
	sw $a1, 0($t5)
	sw $a2, 4($t5)
	sw $a3, 8($t5)
	sw $t7, 12($t5)
	
	# Load the spaceship and it's values	
	la $t5, SPACESHIP
	lw $a1, 0($t5)	
	lw $a2, 4($t5)
	lw $a3, 8($t5)
	lw $t7, 12($t5)
	
	# Add the base addresses with the offset of new ship
	add $a1, $a1, $t0
	add $a2, $a2, $t0
	add $a3, $a3, $t0
	add $t7, $t7, $t0
	
	# Draw the new values
	sw $t4,	0($a1)
	sw $t4, 0($a2)
	sw $t4, 0($a3)
	sw $t4, 0($t7)
	# Go back to looping
	j constantLoop
	
endScreen: 
	# Wait a little once the game ends, just for dramatic effect :)
	li $v0, 32
        li $a0, 1000 # 25 hertz Refresh rate
        syscall
        
        # Set the value to green
        li $t4, GREEN
        

        # Drawing the letter E
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
	
	# Drawing the letter N
	sw $t4, 432($t0
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
	sw $t4, 1488($t0)
	sw $t4, 1360($t0)
	sw $t4, 1232($t0)
	sw $t4, 1104($t0)
	sw $t4, 976($t0)
	sw $t4, 848($t0)
	sw $t4, 720($t0)
	sw $t4, 592($t0)
	sw $t4, 464($t0)
	
	# Drawing the Letter D
	
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
	
	
	# Drawing the Letter P in yellow / golden
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
	
	# Set the default address
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	# Check if ANY key was pressed (can't end program, need to check for p press)
	beq $t8, 1, keyPressed	
	
	# Loop over this tag
	j endScreen

reset:
	# Loop to reboot the game back from scratch after p is pressed
	sub $a2, $a1, $t0
	beq $a2, 4092, resetVar
	# Similar process to the clear tag
	sw $t4, 0($a1)
	addi $a1, $a1, 4
	j reset

