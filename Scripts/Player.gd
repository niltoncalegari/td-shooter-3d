extends CharacterBody3D

@onready var camera = $Camera3D

var rayOrigin = Vector3()
var rayEnd = Vector3()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	$Body.look_at(ScreenPointToRay(), Vector3(0,1,0))
	move_and_slide()

func ScreenPointToRay():
	var spaceState = get_world_3d().direct_space_state
	var mousePosition = get_viewport().get_mouse_position()
	var rayLength = 2000
	
	rayOrigin = camera.project_ray_origin(mousePosition)
	rayEnd = rayOrigin + camera.project_ray_normal(mousePosition) * rayLength
	
	var intersection = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd))
	
	if not intersection.is_empty():
		var pos = intersection.position
		print(Vector3(pos.x, 1, pos.z))
		return Vector3(pos.x, 1, pos.z)
	
	return Vector3(0,1,0)
