extends Node2D

signal player_exiting(side: String, player_y: float, player_vel: Vector2)

const VIEWPORT_SIZE := 512.0
const EXIT_THRESHOLD := 3.0

var _exit_pending := false

func _physics_process(_delta: float) -> void:
	var player: CharacterBody2D = get_node_or_null("bola_2d")
	if not player:
		_exit_pending = false
		return
	if _exit_pending:
		return

	if player.position.x >= VIEWPORT_SIZE - EXIT_THRESHOLD:
		_exit_pending = true
		player_exiting.emit("right", player.position.y, player.velocity)
	elif player.position.x <= EXIT_THRESHOLD:
		_exit_pending = true
		player_exiting.emit("left", player.position.y, player.velocity)
	elif player.position.y <= EXIT_THRESHOLD:
		_exit_pending = true
		player_exiting.emit("top", player.position.x, player.velocity)
	elif player.position.y >= VIEWPORT_SIZE - EXIT_THRESHOLD:
		_exit_pending = true
		player_exiting.emit("bottom", player.position.x, player.velocity)
