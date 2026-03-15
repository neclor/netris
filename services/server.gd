extends HTTPRequest


var _url: String = "https://netris.neclor.com/Leaderboard"


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func send_score(player_name: String, score: int) -> void:
	if player_name == "" or score == 0: return
	request(
		_url,
		["Content-Type: application/json"], 
		HTTPClient.Method.METHOD_POST,
		JSON.stringify({"name": player_name, "score": score})
	)


func load_leaderboard() -> Array[Dictionary]:
	request(_url, ["Content-Type: application/json"])
	var result: Array = await request_completed
	if result[1] != 200: return []

	var body: PackedByteArray = result[3]
	var json: Array = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != Variant.Type.TYPE_ARRAY: return []

	return Array(json, Variant.Type.TYPE_DICTIONARY, "", null)
