@tool
extends "checkable_option_button.gd"




func _ready():
	fill(get_owner().kinds)

func options_count_by_kind_updated():
	var options_count_by_kind = get_owner().options_count_by_kind
	var items = tree.items
	for i in items.size():
		var item:TreeItem = items[i]
		item.set_text(2, str(options_count_by_kind[i]))
	
