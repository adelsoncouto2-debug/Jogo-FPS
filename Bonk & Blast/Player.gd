extends KinematicBody

export var speed = 8.0
export var jump_force = 8.5
export var gravity = 24.0
export var mouse_sensitivity = 0.15
var velocity = Vector3()

onready var head = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):

	if event is InputEventMouseMotion:

		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))

		head.rotation_degrees.x = clamp(
			head.rotation_degrees.x,
			-90,
			90
			
		)
	
func _physics_process(delta):
	var direction = Vector3()

	var forward = -transform.basis.z
	var right = transform.basis.x

	if Input.is_action_pressed("move_forward"):
		direction += forward

	if Input.is_action_pressed("move_backward"):
		direction -= forward

	if Input.is_action_pressed("move_right"):
		direction += right

	if Input.is_action_pressed("move_left"):
		direction -= right

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force

	velocity = move_and_slide(velocity, Vector3.UP)
