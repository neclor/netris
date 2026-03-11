@abstract class_name Global extends Object


static var player_name: String = Saver.load_name():
	set  = set_player_name


static var _http_client: HTTPRequest = HTTPRequest.new()
static var _url: String = "https://netris.neclor.com/leaderboard"


static func set_player_name(value: String) -> void:
	player_name = value
	Saver.save_name(player_name)


static func send_score(score: int) -> void:
	if player_name == "" or score == 0: return
	_http_client.request()

	pass
