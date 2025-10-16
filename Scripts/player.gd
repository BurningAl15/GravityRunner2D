extends CharacterBody2D
var horizontal_speed := 100
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var initialPos: Vector2 = Vector2.ZERO

const animations = {
	"run": "walk",
	"idle": "idle"
}

func _ready() -> void:
	initialPos = global_position
	$AnimatedSprite2D.play(animations.idle)


func _physics_process(delta: float) -> void:
	$AnimatedSprite2D.play(animations.run)

	if (Input.is_action_just_pressed("interaction")):
		gravity = - gravity
		
	$AnimatedSprite2D.flip_v = gravity < 0

	velocity.y += gravity * delta
	velocity.x = horizontal_speed

	move_and_slide()


func resetPos():
	print("Colliding")
	global_position = initialPos
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	$AnimatedSprite2D.play(animations.idle)

func _on_obstacle_body_entered(body: Node2D) -> void:
	resetPos()


func _on_goal_area_body_entered(body: Node2D) -> void:
	resetPos()
