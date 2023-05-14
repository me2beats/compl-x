@tool
extends OptionButton


func _on_item_selected(index):
	get_owner().fill_items()
	
