################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: (Alyssa)Mengyuan Li, 1008583855
# Student 2: Hongshuo Zhou, 1007106178
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
MY_COLOURS:
    .word 0xff0000  # red
    .word 0xffa500  # orange
    .word 0xffff00  # yellow
    .word 0x008000  # green
    .word 0x0000ff  # blue
    .word 0xe1c699  # beige
    .word 0xffffff  # white (ball)
    .word 0xd3d3d3  # grey (wall)
    .word 0x000000  # black

##############################################################################
# Mutable Data
##############################################################################
PADDLE_DATA:
    .word 10        # x coordinate 
    .word 22	    # y coordinate

BALL_DATA:
    .word 1         # x move direction (1 = right, 0 = left)
    .word 1         # y move direction (1 = up, 0 = down)
    .word 14        # x coordinate
    .word 21        # y coordinate 
    
COLLISION_FLAGS: # 1 is no collision, 0 is having collision
    .word 1 # up/down collision
    .word 1 # left/right collision
    .word 1 # corner collision
    
HANDLE_COLLISION_FLAGS:
    .word 1 # up collision (1 means nothing being handled)
    .word 1 # down collision
    .word 1 # left collision
    .word 1 # right collision
    .word 1 # top left corner collision
    .word 1 # top right corner collision
    .word 1 # bottom left corner collision
    .word 1 # bottom right corner collision

LIVES_LEFT:
    .word 3 #how many lives are left
    
SLEEP_TIME:
    .word 800 ## sleep time of each cycle
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    
    # draw the three walls
	la $t0, ADDR_DSPL # t0 = &ADDR_DSPL
	lw $t0, 0($t0)    # t0 = ADDR_DSPL
	li $t1, 32        # t1 = unit_count = 32
	li $t2, 0         # t2 = i = 0
	la $t4, MY_COLOURS # t4 = &MY_COLOURS
	lw $t4, 28($t4)    # t4 = rgb of grey
    
draw_top_wall_loop:
	slt $t3, $t2, $t1 # i < unit_count ?
	beq $t3, $0, end_draw_top_wall
		sw $t4, 0($t0)
		addi $t0, $t0, 4
	addi $t2, $t2, 1
	b draw_top_wall_loop
	
end_draw_top_wall:
	li $t2, 0         # t2 = i = 0
	la $t0, ADDR_DSPL # t0 = &ADDR_DSPL
	lw $t0, 0($t0)    # t0 = ADDR_DSPL
	
draw_left_wall:
	slt $t3, $t2, $t1 # i < unit_count ?
	beq $t3, $0, end_draw_left_wall
		sw $t4, 0($t0)
		addi $t0, $t0, 128
	addi $t2, $t2, 1
	b draw_left_wall
    
end_draw_left_wall:
	li $t2, 0     # i = 0
	la $t0, ADDR_DSPL # t0 = &ADDR_DSPL
	lw $t0, 0($t0) # t0 = ADDR_DSPL
	addi $t0, $t0, 124 # t0 = address of the top right corner
	
draw_right_wall:
	slt $t3, $t2, $t1 # i < unit_count ?
	beq $t3, $0, end_draw_right_wall
        	sw $t4, 0($t0)
        	addi $t0, $t0, 128
	addi $t2, $t2, 1
	b draw_right_wall
	
end_draw_right_wall:
	## all three walls are being drawed


    #draw the bricks
	li $a0, 1
	li $a1, 5
	jal get_location_address    # get start address of red line

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS          
	li $a2, 30
	jal draw_line               # Draw red line
    
	li $a0, 1
	li $a1, 6
	jal get_location_address   # get start address of orange line

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS + 4          
	li $a2, 30
	jal draw_line               # Draw orange line
    
	li $a0, 1
	li $a1, 7
	jal get_location_address   # get start address of yellow line

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS + 8         
	li $a2, 25
	jal draw_line               # Draw yellow line
    	
    	li $a0, 26
	li $a1, 7
	jal get_location_address   # get start address of unbreakable brick

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS + 28         
	li $a2, 5                  #Draw the unbreakable brick
	jal draw_line
    	
	li $a0, 1
	li $a1, 8
	jal get_location_address    # get start address of green line

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS + 12         
	li $a2, 30
	jal draw_line               # Draw green line
    
	li $a0, 1
	li $a1, 9
	jal get_location_address    # get start address of blue line

	addi $a0, $v0,0            
	la $a1, MY_COLOURS  + 16        
	li $a2, 30
	jal draw_line               # Draw blue line
	
	# all bricks have been initialized 
    
    
	### draw the paddle
draw_paddle:	
	li $a0, 10
	li $a1, 22
	jal get_location_address

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS  + 20     
	li $a2, 9
	jal draw_line
	
end_draw_paddle:
	### draw the ball
	li $a0, 14
	li $a1, 21
	jal get_location_address

	addi $a0, $v0, 0            
	la $a1, MY_COLOURS  + 24     
	li $a2, 1
	jal draw_line            # Draw the ball at intial position using white color

game_loop:
        # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
        # 5. Go back to 1
    
    #1a. check if key has been pressed:
	lw $t0, ADDR_KBRD 
	lw $t8, 0($t0)
    
	beq $t8, 1, keyboard_input
	j end_print_new_paddle
	
    # 1b. Check which key has been pressed
    
keyboard_input:
	lw $t2, 4($t0)
	beq $t2, 0x71, respond_to_q
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x64, respond_to_d
        beq $t2, 0x70, respond_to_p
	j end_print_new_paddle

    
    # when q is pressed, quit the game
game_over:
	li $a0, 0
	li $a1, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	la $a1, MY_COLOURS + 8
	li $a2, 32      # draw the game over screen using yellow
	jal draw_square
	
restart_screen:	
	lw $t0, ADDR_KBRD 
	lw $t8, 0($t0)
	bne $t8, 1, sleep #if no input, continue sleeping

	lw $t2, 4($t0)
	beq $t2, 0x72, reset_screendata  # if we receive r for retry option, we recreate the whole screen.


sleep:	
	li $v0, 32
	li $a0, 100
	syscall
	b restart_screen


reset_screendata:
	li $t2, 10                  #reset paddle x-coord
	sw $t2, PADDLE_DATA
	li $t3, 22                  #reset paddle y-coord
	sw $t3, PADDLE_DATA + 4
	
	
	li $t4, 1                   #reset ball move direction
	sw $t4, BALL_DATA + 0
	li $t5, 1                   #reset ball move direction
	sw $t5, BALL_DATA + 4
	li $t2, 14                  #reset ball x-coord
	sw $t2, BALL_DATA + 8
	li $t3, 21                  #reset ball y-coord
	sw $t3, BALL_DATA + 12
	li $t1, 3
	sw $t1, LIVES_LEFT + 0
	
	li $a0, 0
	li $a1, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	la $a1, MY_COLOURS + 32
	li $a2, 32      # repaint screen using black
	jal draw_square
	
	li $s1, 800
	lw $s1, SLEEP_TIME
	j main

respond_to_q:  
	li $v0, 10
	syscall
    
    # when a is pressed, move left 3 units until hits the left wall
respond_to_a:

	## first detect if it is next to the wall
	la $t3, PADDLE_DATA
	lw $t3, 0($t3)      # t3 = x coordinate of paddle
	la $t4, PADDLE_DATA + 4
	lw $t4, 0($t4)      # t4 = y coordinate of paddle
	beq $t3, 1, end_respond_to_a # 1 is the x coord that the paddle hits the wall.
	 
	
	#first we erase the original pedal
	addi $a0, $t3, 0
	addi $a1, $t4, 0
	jal get_location_address
    	
	addi $a0, $v0, 0  # erase the original peddle
	#la $t0, MY_COLOURS + 32
	la $a1, MY_COLOURS + 32
	li $a2, 9
	jal draw_line
	
	addi $t3, $t3, -3   # update the new paddle start address
	sw $t3, PADDLE_DATA
	
	
end_respond_to_a:
	j end_keybroad
    
#when d is pressed, move right for 3 units, until hits the right wall
respond_to_d:
	la $t3, PADDLE_DATA
	lw $t3, 0($t3)  # t3 = x coordinate of paddle
	la $t4, PADDLE_DATA + 4
	lw $t4, 0($t4)   # t4 = y coordinate of paddle
	beq $t3, 22, end_respond_to_d # 22 is the x coord that the peddle hits the wall.
	
	#first we erase the original pedal
	addi $a0, $t3, 0
	addi $a1, $t4, 0
	jal get_location_address
    	
	addi $a0, $v0, 0  # erase the original peddle
	#la $t0, MY_COLOURS + 32
	la $a1, MY_COLOURS + 32
	li $a2, 9
	jal draw_line
    	
	addi $t3, $t3, 3
	sw $t3, PADDLE_DATA
	
    	
end_respond_to_d:
	j end_keybroad

respond_to_p:
	#check input value
	lw $t0, ADDR_KBRD 
	lw $t8, 0($t0)
	bne $t8, 1, pause_sleep #if no input, continue sleeping

	lw $t2, 4($t0)
	beq $t2, 0x70, end_keybroad  # if we receive another p button click, stop sleeping!

pause_sleep:	
	li $v0, 32
	li $a0, 100
	syscall
	b respond_to_p

end_keybroad:


	## now we draw the paddle according to the updated coordinate
print_new_paddle:
	la $t3, PADDLE_DATA
	lw $t3, 0($t3)  # t3 = x coordinate of paddle
	la $t4, PADDLE_DATA + 4
	lw $t4, 0($t4)   # t4 = y coordinate of paddle

	addi $a0, $t3, 0
	addi $a1, $t4, 0
	jal get_location_address ## get address of the new paddle coordinate
	
	addi $a0, $v0, 0  # print the new paddle
	la $a1, MY_COLOURS  + 20     
	li $a2, 9
	jal draw_line
	
end_print_new_paddle:

detect_collision:
	li $t9, 1 # t9 = 1
	
	# first get the moving direction of ball
	la $t0, BALL_DATA 
	lw $t0, 0($t0)  #t0 = left/right of movement
	
	la $t1, BALL_DATA + 4
	lw $t1, 0($t1)  #t1 = up/down of movement
	
	la $t2, BALL_DATA + 8
	lw $t2, 0($t2)  #t2 = current x coordinate of the ball
	
	la $t3, BALL_DATA + 12
	lw $t3, 0($t3)  #t3 = current y coordinate of the ball
	
	
	beq $t3, 22, check_lives # detect if we lose the game, and if we lose, check how many lives left.
	j end_check_lives
	
check_lives:
	la  $t0, LIVES_LEFT
	lw  $t0, 0($t0)
	addi $t0, $t0, -1
	sw $t0, LIVES_LEFT
	li  $t1, 0
	beq  $t1, $t0, game_over   # if no lives left, quit!
	
	
	la $t2, PADDLE_DATA  # have lives left, erase the paddle and ball
	lw $t2, 0($t2)       # t2 = x of paddle
	la $t3, PADDLE_DATA + 4
	lw $t3, 0($t3)       # t3 = y of paddle
	addi $a0, $t2, 0
	addi $a1, $t3, 0
	jal get_location_address 
	
	addi $a0, $v0, 0          # erase the paddle using black
	la $a1, MY_COLOURS  + 32     
	li $a2, 9
	jal draw_line
	
	li $t2, 10                  #reset paddle x-coord
	sw $t2, PADDLE_DATA
	li $t3,  22                 #reset paddle y-coord
	sw $t3, PADDLE_DATA + 4
	
	
	la $t2, BALL_DATA + 8 
	lw $t2, 0($t2)       
	la $t3, BALL_DATA + 12
	lw $t3, 0($t3)       
	addi $a0, $t2, 0
	addi $a1, $t3, 0
	jal get_location_address 
	
	addi $a0, $v0, 0          # erase the ball using black
	la $a1, MY_COLOURS  + 32     
	li $a2, 1
	jal draw_line
	
	li $t4, 1                  #reset ball move direction
	sw $t4, BALL_DATA + 0
	li $t5, 1                  #reset ball move direction
	sw $t5, BALL_DATA + 4

	li $t2, 14                  #reset ball x-coord
	sw $t2, BALL_DATA + 8
	li $t3, 21                  #reset ball y-coord
	sw $t3, BALL_DATA + 12
	
        j draw_paddle
        
end_check_lives:	
	
	li $t9, 1 # t9 = 1
	
	# first get the moving direction of ball
	la $t0, BALL_DATA 
	lw $t0, 0($t0)  #t0 = left/right of movement
	
	la $t1, BALL_DATA + 4
	lw $t1, 0($t1)  #t1 = up/down of movement
	
	la $t2, BALL_DATA + 8
	lw $t2, 0($t2)  #t2 = current x coordinate of the ball
	
	la $t3, BALL_DATA + 12
	lw $t3, 0($t3)  #t3 = current y coordinate of the ball 
	beq $t1, 1, up # branch if the ball is moving up
			# the ball moving down now
			
	# detect if the unit below is not empty
	addi $a0, $t2, 0
	addi $a1, $t3, 1
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit below
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS
			
	beq $t0, 1, down_right   #branch if the ball is moving right
	j down_left
	
up:
	#detect if the unit above is not empty
	addi $a0, $t2, 0
	addi $a1, $t3, -1
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS
		
	# check moving left or right
	beq $t0, 1, up_right
	j up_left
	
up_left:
	# detect if the unit on the left is not empty
	addi $a0, $t2, -1
	addi $a1, $t3, 0
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 4
	
	#detect if collision on the corner
	addi $a0, $t2, -1
	addi $a1, $t3, -1
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 8
	j end_detect_collision
	
up_right:
	# detect if the unit on the right is not empty
	addi $a0, $t2, 1
	addi $a1, $t3, 0
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 4
	
	#detect if collision on the corner
	addi $a0, $t2, 1
	addi $a1, $t3, -1
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 8
	j end_detect_collision
	
down_left:
	# detect if the unit on the left is not empty
	addi $a0, $t2, -1
	addi $a1, $t3, 0
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 4
	
	#detect if collision on the corner
	addi $a0, $t2, -1
	addi $a1, $t3, 1
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 8
	j end_detect_collision
	
down_right:
	# detect if the unit on the right is not empty
	addi $a0, $t2, 1
	addi $a1, $t3, 0
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit on the right
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 4
	
	#detect if collision on the corner
	addi $a0, $t2, 1
	addi $a1, $t3, 1
	jal get_location_address 
	lw $t4, 0($v0) # t4 = color of the unit above
	slt $t5, $t4, $t9 #t5 = if flag of collision
	sw $t5, COLLISION_FLAGS + 8
	j end_detect_collision

end_detect_collision:
### now we handle collisions

handle_up_down_collision:

	la $t0, COLLISION_FLAGS #t0 = up down collision flag
	lw $t0, 0($t0)
	beq $t0, 1, end_handle_up_down_collision # branch if no up/down collision
	
	#change moving speed
	la $t1, SLEEP_TIME
	lw $t1, 0($t1)
	li $t2, 100
	beq $t1, $t2, fast_enough
	addi $t1, $t1, -100
fast_enough:
	sw $t1, SLEEP_TIME
	
	la $t1, BALL_DATA + 4
	lw $t1, 0($t1) # t1 = up/down direction of ball
	li $t2, 1
	sub $t1, $t2, $t1
	sw $t1, BALL_DATA + 4
	
	#set collision handle flag
	la $t1, BALL_DATA + 4
	lw $t1, 0($t1) # t1 = up/down direction of ball
	beq $t1, 0, set_up_flag
	
	# now is moving down
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 4
	j end_handle_up_down_collision
	
set_up_flag:
	# now is moving up
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS
	
end_handle_up_down_collision:


handle_left_right_collision:
	la $t0, COLLISION_FLAGS + 4 #t0 = left/right collision flag
	lw $t0, 0($t0)
	beq $t0, 1, end_handle_left_right_collision # branch if no left/right collision
	
	#change moving speed
	la $t1, SLEEP_TIME
	lw $t1, 0($t1)
	li $t2, 100
	beq $t1, $t2, left_fast_enough
	addi $t1, $t1, -100
left_fast_enough:
	sw $t1, SLEEP_TIME
	
	la $t1, BALL_DATA
	lw $t1, 0($t1) # t1 = left/right direction of ball
	li $t2, 1
	sub $t1, $t2, $t1
	sw $t1, BALL_DATA
	
	#set collision handle flag
	la $t1, BALL_DATA
	lw $t1, 0($t1) # t1 = left/right direction of ball
	beq $t1, 0, set_right_flag
	
	# now is moving left
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 8
	j end_handle_left_right_collision
	
set_right_flag:
	# now is moving right
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 12

end_handle_left_right_collision:

# detect if up/down, left/right collision occurs.
	la $t0, COLLISION_FLAGS #t0 = up down collision flag
	lw $t0, 0($t0)
	beq $t0, 0, end_handle_corner_collision # branch if there is up/down collision
	
	la $t0, COLLISION_FLAGS + 4 #t0 = left/right collision flag
	lw $t0, 0($t0)
	beq $t0, 0, end_handle_corner_collision # branch if no left/right collision
	
	la $t0, COLLISION_FLAGS + 8 #t0 = corner collision flag
	lw $t0, 0($t0)
	beq $t0, 1, end_handle_corner_collision # branch if there is up/down collision
	
## we handle corner collision only if no up/down and no left/right collision
handle_corner_collision:

	#change moving speed
	la $t1, SLEEP_TIME
	lw $t1, 0($t1)
	li $t2, 100
	beq $t1, $t2, corner_enough
	addi $t1, $t1, -100
corner_enough:
	sw $t1, SLEEP_TIME
	
	# reverse up/down
	la $t1, BALL_DATA + 4
	lw $t1, 0($t1) # t1 = up/down direction of ball
	li $t2, 1
	sub $t1, $t2, $t1
	sw $t1, BALL_DATA + 4
	
	#reverse left/right
	la $t1, BALL_DATA
	lw $t1, 0($t1) # t1 = left/right direction of ball
	li $t2, 1
	sub $t1, $t2, $t1
	sw $t1, BALL_DATA
	
	###############
	#set collision handle flag
	la $t1, BALL_DATA + 4
	lw $t1, 0($t1) # t1 = up/down direction of ball
	beq $t1, 0, flag_up
	
	# now is moving down
	#check left or right
	la $t1, BALL_DATA
	lw $t1, 0($t1) # t1 = up/down direction of ball
	beq $t1, 0, flag_down_right
	
	# now is down left
flag_down_left:
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 24
	j end_handle_corner_collision
	
flag_up:
	# now is moving up
	#check left or right
	la $t1, BALL_DATA
	lw $t1, 0($t1) # t1 = up/down direction of ball
	beq $t1, 0, flag_up_right

flag_up_left:
	## now is up left
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 16
	j end_handle_corner_collision
	
flag_down_right:
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 28
	j end_handle_corner_collision

flag_up_right:
	li $t0, 0
	sw $t0, HANDLE_COLLISION_FLAGS + 20

end_handle_corner_collision:

#############################################
# detect if it is a brick, if so, break it
	lw $t0, MY_COLOURS + 28 # rgb color of grey (wall)
	lw $t1, MY_COLOURS + 20 # rgb color of  paddle
	lw $s0, MY_COLOURS # rgb color of red

# handle left right collision with bricks
	lw $t2, HANDLE_COLLISION_FLAGS + 8
	beq $t2, 0, left_brick # we have handled left collision
	
	lw $t2, HANDLE_COLLISION_FLAGS + 12
	beq $t2, 0, right_brick # we have handled right collision
	j end_left_right_brick
	
left_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, -1
	addi $a1, $t4, 0
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_left_right_brick
	
	
	# it is a brick now
	addi $t6, $v0, 0
	addi $t6, $t6, -16
	
	addi $a0, $t6, 0  # delete the brick
	
	beq $t5, $s0, change_color # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_left_right_brick
	
change_color:
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	
	j end_left_right_brick
	
right_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, 1
	addi $a1, $t4, 0
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_left_right_brick
	
	# it is a brick now
	addi $t6, $v0, 0
	#addi $t6, $t6, -20
	
	addi $a0, $t6, 0  # delete the brick
	
	
	beq $t5, $s0, right_change_color # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_left_right_brick
	
right_change_color:
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	
	j end_left_right_brick

end_left_right_brick:


# handle up_down_bricks
	lw $t2, HANDLE_COLLISION_FLAGS
	beq $t2, 0, up_brick # we have handled up collision
	
	lw $t2, HANDLE_COLLISION_FLAGS + 4
	beq $t2, 0, down_brick # we have handled down collision
	j end_up_down_brick
	
up_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, 0
	addi $a1, $t4, -1
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_up_down_brick
	
	# it is a brick now
	addi $t3, $t3, 0  # x
	addi $t4, $t4, -1 # y
	
	li $t6, 6
	slt $t7, $t3, $t6
	beq $t7, 1, one
	
	li $t6, 11
	slt $t7, $t3, $t6
	beq $t7, 1, six
	
	li $t6, 16
	slt $t7, $t3, $t6
	beq $t7, 1, eleven
	
	li $t6, 21
	slt $t7, $t3, $t6
	beq $t7, 1, sixteen
	
	li $t6, 26
	slt $t7, $t3, $t6
	beq $t7, 1, twenty_one
	
	j twenty_six

one:
	li $a0, 1
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_one # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_one:
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
six:
	li $a0, 6
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_six # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_six:
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
eleven:
	li $a0, 11
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_eleven # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_eleven:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
sixteen:
	li $a0, 16
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_sixteen # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_sixteen:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
twenty_one:
	li $a0, 21
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_twenty_one # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_twenty_one:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
twenty_six:
	li $a0, 26
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_twenty_six # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_twenty_six:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	
	j end_up_down_brick
	
down_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, 0
	addi $a1, $t4, 1
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_up_down_brick
	beq $t5, $t1, end_up_down_brick
	
	# it is a brick now
	addi $t3, $t3, 0  # x
	addi $t4, $t4, 1 # y
	
	li $t6, 6
	slt $t7, $t3, $t6
	beq $t7, 1, one_down
	
	li $t6, 11
	slt $t7, $t3, $t6
	beq $t7, 1, six_down
	
	li $t6, 16
	slt $t7, $t3, $t6
	beq $t7, 1, eleven_down
	
	li $t6, 21
	slt $t7, $t3, $t6
	beq $t7, 1, sixteen_down
	
	li $t6, 26
	slt $t7, $t3, $t6
	beq $t7, 1, twenty_one_down
	
	j twenty_six_down
one_down:
	li $a0, 1
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_1 # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_1:	
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
six_down:
	li $a0, 6
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_6 # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_6:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
eleven_down:
	li $a0, 11
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_11 # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_11:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
sixteen_down:
	li $a0, 16
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_16 # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_16:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
twenty_one_down:
	li $a0, 21
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_21 # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_21:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_up_down_brick
	
twenty_six_down:
	li $a0, 26
	addi $a1, $t4, 0
	jal get_location_address
	
	addi $a0, $v0, 0
	
	beq $t5, $s0, change_color_26 # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_up_down_brick
	
change_color_26:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	
	j end_up_down_brick


end_up_down_brick:
	lw $t2, HANDLE_COLLISION_FLAGS + 16
	beq $t2, 0, up_left_brick # we have handled up_left_brick collision
	
	lw $t2, HANDLE_COLLISION_FLAGS + 20
	beq $t2, 0, up_right_brick # we have handled up_right_brick collision
	
	lw $t2, HANDLE_COLLISION_FLAGS + 24
	beq $t2, 0, down_left_brick # we have handled down_left_brick collision
	
	lw $t2, HANDLE_COLLISION_FLAGS + 28
	beq $t2, 0, down_right_brick # we have handled down_right_brick collision
	
	j end_brick_disappear

up_left_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, -1
	addi $a1, $t4, -1
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_brick_disappear
	
	## now we have a brick
	addi $t6, $v0, 0
	addi $t6, $t6, -16
	
	addi $a0, $t6, 0  # delete the brick
	
	beq $t5, $s0, change_color_up_left # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_brick_disappear
	
change_color_up_left:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	j end_brick_disappear
	
up_right_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, 1
	addi $a1, $t4, -1
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_brick_disappear
	
	## now we have a brick
	#addi $t6, $v0, 0
	#addi $t6, $t6, -16
	
	addi $a0, $v0, 0  # delete the brick
	
	beq $t5, $s0, change_color_up_right # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_brick_disappear
	
change_color_up_right:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line

	j end_brick_disappear
	
down_left_brick:
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, -1
	addi $a1, $t4, 1
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_brick_disappear
	beq $t5, $t1, end_brick_disappear
	
	## now we have a brick
	addi $t6, $v0, 0
	addi $t6, $t6, -16
	
	addi $a0, $t6, 0  # delete the brick
	
	beq $t5, $s0, change_color_down_left # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_brick_disappear
	
change_color_down_left:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line
	
	
	j end_brick_disappear
	
down_right_brick:
	
	lw $t3, BALL_DATA + 8 # t3 = x coordinate of ball
	lw $t4, BALL_DATA + 12 # t4 = y coordinate of ball
	
	addi $a0, $t3, 1
	addi $a1, $t4, 1
	jal get_location_address
	lw $t5, 0($v0) # color at the position
	beq $t5, $t0, end_brick_disappear
	beq $t5, $t1, end_brick_disappear
	## now we have a brick
	#addi $t6, $v0, 0
	#addi $t6, $t6, -16
	
	addi $a0, $v0, 0  # delete the brick
	
	beq $t5, $s0, change_color_down_right # branch if the brick if it is red
	la $a1, MY_COLOURS 
	li $a2, 5
	jal draw_line
	j end_brick_disappear
	
change_color_down_right:
	
	la $a1, MY_COLOURS + 32 
	li $a2, 5
	jal draw_line


end_brick_disappear:

    # recover collision flags
	li $t0, 1
	sw $t0, COLLISION_FLAGS
	sw $t0, COLLISION_FLAGS + 4
	sw $t0, COLLISION_FLAGS + 8
	
    # recover handle flags
	sw $t0, HANDLE_COLLISION_FLAGS
	sw $t0, HANDLE_COLLISION_FLAGS + 4
	sw $t0, HANDLE_COLLISION_FLAGS + 8
	sw $t0, HANDLE_COLLISION_FLAGS + 12
	sw $t0, HANDLE_COLLISION_FLAGS + 16
	sw $t0, HANDLE_COLLISION_FLAGS + 20
	sw $t0, HANDLE_COLLISION_FLAGS + 24
	sw $t0, HANDLE_COLLISION_FLAGS + 28
	
	
delete_ball:
	la $t0, BALL_DATA
	lw $t0, 8($t0)
	addi $a0, $t0, 0
	la $t1, BALL_DATA
	lw $t1, 12($t1)
	addi $a1, $t1, 0 
	jal get_location_address
     
	addi $a0, $v0, 0  # delete the ball
	la $a1, MY_COLOURS + 32 
	li $a2, 1
	jal draw_line
     

# update_ball_location:
	la $t0, BALL_DATA
	lw $t0, 8($t0) # t0 = x coordinate of the ball
	la $t1, BALL_DATA
	lw $t1, 0($t1) # t1 = x movement of the ball
	beq $t1, 1, moving_right
	
	## moving left now
	addi $t0, $t0, -1 # update x coordinate
	sw $t0, BALL_DATA + 8
	j finish_update_x
	
moving_right:
	
	addi $t0, $t0, 1 # update x coordinate
	sw $t0, BALL_DATA + 8

finish_update_x:     
	la $t0, BALL_DATA
	lw $t0, 12($t0) # t0 = y coordinate of the ball
	la $t1, BALL_DATA
	lw $t1, 4($t1) # t1 = y movement of the ball
	beq $t1, 1, moving_up
	
	addi $t0, $t0, 1 # update y coordinate
	sw $t0, BALL_DATA + 12
	j end_update_y
moving_up:
	
	addi $t0, $t0, -1 # update y coordinate
	sw $t0, BALL_DATA + 12
end_update_y:
     
	# redraw_the_ball:
	la $t0, BALL_DATA
	lw $t0, 8($t0) # t0 = x coordinate of the ball
	
	la $t1, BALL_DATA
	lw $t1, 12($t1) #t1 = y coordinate of the ball
	
	addi $a0, $t0, 0
	addi $a1, $t1, 0
	jal get_location_address
	
	addi $a0, $v0, 0            
	la $a1, MY_COLOURS + 24     
	li $a2, 1
	jal draw_line
	
	
	li $v0, 32
	la $a0, SLEEP_TIME
	lw $a0, 0($a0)
	#li $a0, 100
	syscall
b game_loop
      
      
############################################################
## helper functions

# get_location_address(x, y) -> address
get_location_address:
    addi $sp, $sp, -12
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)
    
# Each unit is 4 bytes. Each row has 32 units (128 bytes)
    sll $s0, $a0, 2	        # x = x * 4
    sll $s1, $a1, 7             # y = y * 128

    # Calculate return value
    la  $s2, ADDR_DSPL 		# res = address of ADDR_DSPL
    lw  $s2, 0($s2)             # res = address of (0, 0)
    add $s2, $s2, $s0		# res = address of (x, 0)
    add $s2, $s2, $s1           # res = address of (x, y)
    addi $v0, $s2, 0
    
get_location_address_epi:
    # EPILOGUE
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12
    jr $ra


# draw_line(start, colour_address, width) -> void
draw_line:
# addi $sp, $sp, -24   # make sure we don't mutate those value
	addi $sp, $sp, -16   # make sure we don't mutate those value
	#sw   $a1, 20($sp)
	sw   $s0, 12($sp)  # s0 = address of unit being painted
	sw   $s1, 8($sp)   # s1 = rgb of color
	sw   $s2, 4($sp)   # s2 = i
	sw   $s3, 0($sp)   # 
	#sw   $a0, 0($sp)
	
	# Retrieve the colour
	lw $s1, 0($a1)              # colour = * colour_address
	addi $s0, $a0, 0

	# Iterate $a2 times, drawing each unit in the line
	li $s2, 0                   # s2 = i = 0
	
draw_line_loop:
	slt $s3, $s2, $a2           # i < width ?
	beq $s3, $0, draw_line_epi  # if not, then done

		sw $s1, 0($s0)          # Paint unit with colour
		addi $s0, $s0, 4        # Go to next unit

	addi $s2, $s2, 1            # i = i + 1
	b draw_line_loop

draw_line_epi:
	#lw $a0, 0($sp)
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	#lw $a1, 20($sp)
	addi $sp, $sp, 16
	jr $ra
draw_square:
	# PROLOGUE
	addi $sp, $sp, -20
    sw $s3, 16($sp)
    sw $s2, 12($sp)
    sw $s1, 8($sp)
    sw $s0, 4($sp)
	sw $ra, 0($sp)

    # BODY
    # Arguments are not preserved across function calls, so we
    # save them before starting the loop
    addi $s0, $a0, 0
    addi $s1, $a1, 0
    addi $s2, $a2, 0

    # Iterate size ($a2) times, drawing each line
    li $s3, 0                   # i = 0
draw_square_loop:
    slt $t0, $s3, $s2           # i < size ?
    beq $t0, $0, draw_square_epi# if not, then done

        # call draw_line
        addi $a0, $s0, 0
        addi $a1, $s1, 0
        addi $a2, $s2, 0
        jal draw_line

        addi $s0, $s0, 128      # Go to next row

    addi $s3, $s3, 1            # i = i + 1
    b draw_square_loop

draw_square_epi:
    # EPILOGUE
    lw	$ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20

    jr $ra
