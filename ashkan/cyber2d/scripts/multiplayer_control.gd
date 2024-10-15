extends Control

var peer

@export var address = "127.0.0.1"
@export var port = 8910

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		host_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func peer_connected(id):
	print("Player Connected: ", str(id))
	
func peer_disconnected(id):
	print("Player Disconnected: ", str(id))
	GameManager.players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
		
	
func connected_to_server():
	print("Connected to Server!")
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
	
func connection_failed(id):
	print("Connection failed :(")

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
			"score": 0,
		}
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i]["name"], GameManager.players[i]["id"])

func _on_host_button_down() -> void:
	host_game()
	send_player_information($LineEdit.text, multiplayer.get_unique_id())


func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players!")

func _on_join_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_button_down() -> void:
	start_game.rpc()

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/test_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
