extends CharacterBody2D
var horizontal_speed := 100
var powerUp_horizontal_speed := 200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var initialPos: Vector2 = Vector2.ZERO

var isPlayable: bool = false

var powerUp: bool = false

@onready var countdown_timer: Timer = null

const animations = {
	"run": "walk",
	"idle": "idle"
}

func _ready() -> void:
	initialPos = global_position
	$AnimatedSprite2D.play(animations.idle)
	
	var root_scene = get_tree().get_current_scene()
	if root_scene and root_scene.has_node("PowerUpTimer"):
		countdown_timer = root_scene.get_node("PowerUpTimer") as Timer

	if countdown_timer == null:
		push_error("Countdown Timer no encontrado. Asigna countdown_timer_path o ajusta la ruta.")


func _physics_process(delta: float) -> void:
	if (isPlayable == false):
		return
		
	$AnimatedSprite2D.play(animations.run)

	if (Input.is_action_just_pressed("interaction")):
		gravity = - gravity
		
	$AnimatedSprite2D.flip_v = gravity < 0

	velocity.y += gravity * delta
	velocity.x = powerUp_horizontal_speed if powerUp else horizontal_speed

	move_and_slide()


func resetPos():
	global_position = initialPos
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	$AnimatedSprite2D.play(animations.idle)

func _on_obstacle_body_entered(body: Node2D) -> void:
	resetPos()


func _on_goal_area_body_entered(body: Node2D) -> void:
	resetPos()


func _on_countdown_timer_timeout() -> void:
	isPlayable = true


func _on_power_up_timer_timeout() -> void:
	powerUp = false


func _on_power_up_body_entered(body: Node2D) -> void:
	countdown_timer.wait_time = 3.0
	countdown_timer.start()
	powerUp = true
