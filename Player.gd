extends KinematicBody2D

const GRAVITY = 20
const PLAYER_SPEED = 500
var motion = Vector2()


func _physics_process(delta):
	
	var axis = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# <0 right, >0 left
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if axis < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
#
#	if axis != 0:
#		$AnimationPlayer.play("Run")
#	else:
#		$AnimationPlayer.play("Idle")
	
	motion.x = axis * PLAYER_SPEED
	motion.y += GRAVITY
	
	motion = move_and_slide(motion, Vector2.UP)
