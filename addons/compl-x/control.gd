@tool
extends PanelContainer

var options
var options_count_by_kind = []
var code_edit:CodeEdit

var plugin:EditorPlugin

@onready var item_list = $VBoxContainer/ItemList
@onready var kind_button = $VBoxContainer/HBoxContainer/Kinds
@onready var search_algo:OptionButton = $VBoxContainer/HBoxContainer/SearchAlgo

@onready var wait_to_show = $WaitToShow

const  kinds: = [
	"Class",
	"Function",
	"Signal",
	"Variable",
	"Member",
	"Enum",
	"Constant",
	"NodePath",
	"FilePath",
	"PlainText"
]

func _ready():
	init_options_count_by_kind()

func init_options_count_by_kind():
	options_count_by_kind.resize(kinds.size())
	options_count_by_kind.fill(0)

#TODO: fuzzy search disabled

func select_first():
	if item_list.item_count:
		item_list.select(0)

func fill_items():
	item_list.clear()
	

	match search_algo.selected:
		# TODO: refactor

		0: # Fuzzy
			for i in options.size():
				var o = options[i]
				if kind_button.is_checked(o.kind):
					item_list.add_item(o.display_text, o.icon)
					item_list.set_item_metadata(i, o.insert_text)
					

		1: # Exact
			var word = get_word_before_caret()

			for i in options.size():
				var o = options[i]
				var text:String = o.display_text
				if kind_button.is_checked(o.kind) and word in text:
					item_list.add_item(text, o.icon)
					item_list.set_item_metadata(i, o.insert_text)

		2: # Starts with
			var word = get_word_before_caret()

			for i in options.size():
				var o = options[i]
				var text:String = o.display_text
				if kind_button.is_checked(o.kind) and text.begins_with(word):
					item_list.add_item(text, o.icon)
					item_list.set_item_metadata(i, o.insert_text)
					

		3: # Ends with
			var word: = get_word_before_caret()

			for i in options.size():
				var o = options[i]
				var text:String = o.display_text
				if kind_button.is_checked(o.kind) and text.ends_with(word):
					item_list.add_item(text, o.icon)
					item_list.set_item_metadata(i, o.insert_text)
					

	select_first()


const word_divisors = """ 	.,;+-*/=()%&~><^|$@[]"':"""

func get_word_before_caret()->String:
	var caret_col: = code_edit.get_caret_column()
	var caret_row:  = code_edit.get_caret_line()
	var line: = code_edit.get_line(caret_row)

	for i in caret_col:
		if caret_col-i<0: return line.substr(0, caret_col)
		var ch = line[caret_col-i-1]
		if ch in word_divisors: return line.substr(caret_col-i, i)
	return line.substr(0, caret_col)

# shows this control at caret position
func show_control():
	global_position = code_edit.global_position+code_edit.get_caret_draw_pos()
	visible = true

	
	

# use this to create new completion request and show options
func request_completion(should_wait: = true):
	if should_wait:
		wait_to_show.start()
		await wait_to_show.timeout

	code_edit.request_code_completion()
	options = code_edit.get_code_completion_options()
	code_edit.cancel_code_completion()
	self.options = options
	if options.is_empty():
		hide()
		
		return

	fill_items()
	update_options_count_by_kind()
	show_control()



func update_options_count_by_kind():
	options_count_by_kind.fill(0)
	for option in options:
		options_count_by_kind[option.kind]+=1

	kind_button.options_count_by_kind_updated()

func _on_kinds_item_toggle_checked():
	fill_items()


func _on_item_list_item_activated(index):
	insert_selected_option()
	
	
	
func insert_selected_option():
	var text_to_insert = item_list.get_item_metadata(item_list.get_selected_items()[0])
	code_edit.select_word_under_caret()
	code_edit.insert_text_at_caret(text_to_insert)
	hide()
	code_edit.grab_click_focus()
	code_edit.grab_focus()
	code_edit.cancel_code_completion()


