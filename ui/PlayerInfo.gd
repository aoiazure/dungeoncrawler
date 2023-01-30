class_name PlayerInfo
extends PanelContainer

@export_node_path("Game") var game_path: NodePath

@onready var game: Game = get_node(game_path)

@onready var player_name: RichTextLabel = $Container/PlayerLabel
@onready var hp_label: RichTextLabel = $Container/HPLabel

var player: Player



func _ready():
	player = game.player
	player_name.text = " [font_size=36][b]%s[/b][/font_size]" % player.get_char_name()

func _process(_delta):
	hp_label.text = " [font_size=24][b]HP:[/b] %s/%s[font_size=24]" % [player.get_cur_hp(), player.get_max_hp()]

