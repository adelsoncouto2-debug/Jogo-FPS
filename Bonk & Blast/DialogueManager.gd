extends Spatial

onready var player_camera = $"../player/Player/Head/Camera"
onready var dialogue_camera = $DialogueCamera
onready var tween = $Tween
onready var ui = $UI/DialoguePanel
onready var label = $UI/DialoguePanel/Label
onready var btn_sim = $UI/DialoguePanel/ButtonSim
onready var btn_nao = $UI/DialoguePanel/ButtonNao
onready var loading_screen = $UI/ColorRect
onready var area = $Area

var falas_intro = [
	"Olá, viajante... eu sou o guardião desta torre.",
	"Poucos chegam tão longe quanto você."
]
var pergunta = "Deseja entrar na torre?"

var indice_fala = 0
var em_dialogo = false
var fase = "intro" # "intro", "pergunta", "zoom", "transicao"

const DURACAO_ZOOM = 1.0
const DURACAO_FADE = 0.6

func _ready():
	ui.visible = false
	btn_sim.visible = false
	btn_nao.visible = false
	loading_screen.visible = false
	loading_screen.modulate.a = 0.0

	area.connect("player_entered", self, "_iniciar_dialogo")
	btn_sim.connect("pressed", self, "_on_sim_pressed")
	btn_nao.connect("pressed", self, "_on_nao_pressed")
	tween.connect("tween_all_completed", self, "_on_tween_completed")

	pause_mode = Node.PAUSE_MODE_PROCESS
	_travar_arvore_para_pausar(ui)
	tween.pause_mode = Node.PAUSE_MODE_PROCESS

func _travar_arvore_para_pausar(no):
	no.pause_mode = Node.PAUSE_MODE_PROCESS
	for filho in no.get_children():
		_travar_arvore_para_pausar(filho)

func _iniciar_dialogo():
	em_dialogo = true
	fase = "zoom"
	indice_fala = 0

	get_tree().paused = true

	# Tween suave da câmera do jogador até a posição da câmera de diálogo
	dialogue_camera.current = false
	player_camera.current = true # ainda ativa, vamos mover ela

	var origem = player_camera.global_transform
	var destino = dialogue_camera.global_transform

	tween.interpolate_method(self, "_atualizar_camera_zoom",
		0.0, 1.0, DURACAO_ZOOM,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_callback(self, DURACAO_ZOOM, "_finalizar_zoom")
	_camera_origem = origem
	_camera_destino = destino
	tween.start()

var _camera_origem: Transform
var _camera_destino: Transform

func _atualizar_camera_zoom(t):
	player_camera.global_transform = _camera_origem.interpolate_with(_camera_destino, t)

func _finalizar_zoom():
	fase = "intro"
	ui.visible = true
	btn_sim.visible = false
	btn_nao.visible = false
	label.text = falas_intro[indice_fala]

func _unhandled_input(event):
	if not em_dialogo or fase != "intro":
		return
	if (event is InputEventMouseButton and event.pressed) \
	or (event is InputEventKey and event.pressed and event.scancode == KEY_SPACE):
		_avancar_intro()

func _avancar_intro():
	indice_fala += 1
	if indice_fala < falas_intro.size():
		label.text = falas_intro[indice_fala]
	else:
		_mostrar_pergunta()

func _mostrar_pergunta():
	fase = "pergunta"
	label.text = pergunta
	btn_sim.visible = true
	btn_nao.visible = true

func _on_sim_pressed():
	_iniciar_transicao(true)

func _on_nao_pressed():
	_iniciar_transicao(false)

func _iniciar_transicao(vai_para_proxima_fase):
	fase = "transicao"
	ui.visible = false

	loading_screen.visible = true
	loading_screen.modulate.a = 0.0
	tween.interpolate_property(loading_screen, "modulate:a",
		0.0, 1.0, DURACAO_FADE,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	yield(get_tree().create_timer(DURACAO_FADE, true), "timeout")

	if vai_para_proxima_fase:
		_ir_para_proxima_parte()
	else:
		_encerrar_dialogo_sem_avancar()

func _ir_para_proxima_parte():
	get_tree().paused = false
	# troque pela cena/lógica que você for criar, exemplo:
	get_tree().change_scene("res://TorreInterior.tscn")
	pass

func _encerrar_dialogo_sem_avancar():
	em_dialogo = false
	loading_screen.visible = false
	get_tree().paused = false
	# aqui a câmera do player já está na posição do mago;
	# se quiser volta suave, dá pra repetir o tween de zoom ao contrário


func _on_Area_body_entered(body):
	 if body.name == "Player":
		 _iniciar_dialogo()

func _on_Area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.
