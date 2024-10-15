extends Node2D

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

@onready var ms: MultiplayerSpawner = $MultiplayerSpawner

func _ready() -> void:
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(on_lobby_created)
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func hide_elements():
	$Host.hide()
	$Refresh.hide()
	$LobbyContainer/Lobbies.hide()

func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://scenes/level.tscn")
	hide_elements()

func on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName() + "'s lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	hide_elements()


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		var memb_count = Steam.getNumLobbyMembers(lobby)
		var but = Button.new()
		print(lobby_name)
		but.set_text(str(lobby_name, "| Player Count: ", memb_count))
		but.set_size(Vector2(100,5))
		but.connect("pressed",Callable(self,"join_lobby").bind(lobby))
		$LobbyContainer/Lobbies.add_child(but)


func _on_refresh_pressed() -> void:
	if $LobbyContainer/Lobbies.get_child_count() > 0:
		for n in $LobbyContainer/Lobbies.get_children():
			n.queue_free()
	open_lobby_list()
