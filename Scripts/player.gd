extends CharacterBody2D
var horizontal_speed := 100
var powerUp_horizontal_speed := 200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var initialPos: Vector2 = Vector2.ZERO

var isPlayable: bool = false

var powerUp: bool = false

@onready var countdown_timer: Timer = null
@onready var sfx_sound: AudioStreamPlayer2D = $sfx_sound

const PowerUpEffect = preload("res://Scenes/CollectedEffect.tscn")

const SOUND_STATES = {
	"changeGravity_down": preload("res://Sounds/SFX/ChangeGravity_a.wav"),
	"changeGravity_up": preload("res://Sounds/SFX/ChangeGravity_b.wav"),
	"powerUp": preload("res://Sounds/SFX/PowerUp.wav"),
	"powerUpEnd": preload("res://Sounds/SFX/PowerUpEnd.wav"),
	"hurt": preload("res://Sounds/SFX/Hurt.wav"),
	"goal": preload("res://Sounds/SFX/Goal.wav")
}

const ANIMATION_STATES = {
	"run": "walk",
	"idle": "idle"
}

func _ready() -> void:
	initialPos = global_position
	$AnimatedSprite2D.play(ANIMATION_STATES["idle"])
	
	var root_scene = get_tree().get_current_scene()
	if root_scene and root_scene.has_node("PowerUpTimer"):
		countdown_timer = root_scene.get_node("PowerUpTimer") as Timer

	if countdown_timer == null:
		push_error("Countdown Timer no encontrado. Asigna countdown_timer_path o ajusta la ruta.")

	sfx_sound.volume_db = -6
	sfx_sound.pitch_scale = 1.2
	sfx_sound.max_distance = 300

func _physics_process(delta: float) -> void:
	if (isPlayable == false):
		return
		
	$AnimatedSprite2D.play(ANIMATION_STATES["run"])

	if (Input.is_action_just_pressed("interaction")):
		play_sfx(SOUND_STATES["changeGravity_down"])
		gravity = - gravity
		# play_sfx(SOUND_STATES["changeGravity_down"] if gravity > 0 else SOUND_STATES["changeGravity_up"])
		
	$AnimatedSprite2D.flip_v = gravity < 0

	velocity.y += gravity * delta
	velocity.x = powerUp_horizontal_speed if powerUp else horizontal_speed

	move_and_slide()


func resetPos():
	global_position = initialPos
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	$AnimatedSprite2D.play(ANIMATION_STATES["idle"])


func play_sfx(stream: AudioStream) -> void:
	if stream:
		sfx_sound.stream = stream
		sfx_sound.play()
	else:
		push_warning("SFX key not found")

func collect_powerup(at_pos: Vector2) -> void:
	var fx = PowerUpEffect.instantiate()
	fx.global_position = at_pos
	get_tree().current_scene.add_child(fx)


func _on_obstacle_body_entered(body: Node2D) -> void:
	play_sfx(SOUND_STATES["hurt"])
	resetPos()

func _on_goal_area_body_entered(body: Node2D) -> void:
	play_sfx(SOUND_STATES["goal"])
	resetPos()


func _on_countdown_timer_timeout() -> void:
	isPlayable = true


func _on_power_up_timer_timeout() -> void:
	play_sfx(SOUND_STATES["powerUpEnd"])
	powerUp = false


func _on_power_up_body_entered(body: Node2D) -> void:
	play_sfx(SOUND_STATES["powerUp"])
	collect_powerup(global_position)
	countdown_timer.wait_time = 3.0
	countdown_timer.start()
	powerUp = true
