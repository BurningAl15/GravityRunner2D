extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_timer: Timer = $LifeTimer

# If you want a specific animation name:
const ANIM_NAME := "default"

func _ready() -> void:
	# Play the animation
	anim.play(ANIM_NAME)

	# Calculate duration = frame_count / fps from the SpriteFrames
	var frames: SpriteFrames = anim.sprite_frames
	var frame_count := frames.get_frame_count(ANIM_NAME)
	var fps := frames.get_animation_speed(ANIM_NAME) # frames per second
	var duration := float(frame_count) / float(fps) if fps > 0 else 0.0

	# Fallback if something is wrong
	if duration <= 0.0:
		duration = 1.0

	life_timer.wait_time = duration
	life_timer.start()

func _on_LifeTimer_timeout() -> void:
	queue_free()
