@abstract class_name Saver extends Object


const VERSION: int = 3
const PATH: String = "user://netris_save.tres"


static func save_name(name: String) -> void:
	var data: SaveData = SaveData.new()
	data.version = VERSION
	data.name = name
	ResourceSaver.save(data, PATH)


static func load_name() -> String:
	if not ResourceLoader.exists(PATH): return ""
	var data = ResourceLoader.load(PATH)
	if data is SaveData and data.version == VERSION: return data.name
	return ""
