extends Node2D

@export var countdown_time := 4.0

@onready var countdown_label: Label = $CountdownPanel/CountdownLabel
@onready var countdown_audio: AudioStreamPlayer2D = $CountdownAudio
@onready var environment_audio: AudioStreamPlayer2D = $Player/EnvironmentAudio
@onready var countdown_timer: Timer = $CountdownTimer

const COUNTDOWN_SOUNDS := {
	4: preload("res://Sounds/Countdown/3.wav"),
	3: preload("res://Sounds/Countdown/2.wav"),
	2: preload("res://Sounds/Countdown/1.wav"),
	1: preload("res://Sounds/Countdown/Go.wav")
}

var last_whole_sec := -999
var env_tween: Tween # <— keep reference so we can kill/replace safely

func _ready() -> void:
	countdown_timer.wait_time = countdown_time
	countdown_timer.start()

	# ---- ENV AUDIO: start low and play
	environment_audio.volume_db = -50.0 # very low (almost silent)
	environment_audio.play()

	var first_sec_left := int(ceil(countdown_timer.time_left))
	_update_ui_and_sound(first_sec_left)

func _process(delta: float) -> void:
	var sec_left := int(ceil(countdown_timer.time_left))
	if sec_left != last_whole_sec:
		_update_ui_and_sound(sec_left)

func _update_ui_and_sound(sec_left: int) -> void:
	last_whole_sec = sec_left
	if sec_left >= 2:
		var to_show := sec_left - 1
		countdown_label.text = str(to_show)
		var stream: AudioStream = COUNTDOWN_SOUNDS.get(sec_left, null)
		play_sfx(stream)
	elif sec_left == 1:
		countdown_label.text = "Go!"
		play_sfx(COUNTDOWN_SOUNDS[1])
	else:
		countdown_label.text = ""
		$CountdownPanel.hide()

func _on_countdown_timer_timeout() -> void:
	countdown_timer.stop()
	$CountdownPanel.hide()

	if countdown_audio.playing:
		countdown_audio.stop()

	fade_env_to(-6.0, 0.6)

func play_sfx(stream: AudioStream) -> void:
	if stream:
		if countdown_audio.playing:
			countdown_audio.stop()
		countdown_audio.stream = stream
		countdown_audio.play()

func fade_env_to(target_db: float, duration: float) -> void:
	# Clamp target to sane range
	target_db = clampf(target_db, -80.0, 6.0)

	# If a previous tween is running, kill it to avoid conflicts
	if env_tween and env_tween.is_running():
		env_tween.kill()

	env_tween = create_tween()
	env_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	env_tween.tween_property(environment_audio, "volume_db", target_db, duration)
