extends Area

signal player_entered

var jogador_dentro = false

func _on_Area_body_entered(body):
	if body.name == "Player" and not jogador_dentro:
		jogador_dentro = true
		emit_signal("player_entered")
