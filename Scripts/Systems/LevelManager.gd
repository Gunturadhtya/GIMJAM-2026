class_name LevelManager extends Node2D

@export var grid_system: GridSystem
@export var ghost_cursor: Node2D
@export var state_machine: StateMachine
@export var tile_map: TileMapLayer
@export var held_visual: Node2D
@export var inventory_bar: HBoxContainer = null # keep null if you didnt wanted inventory feature
@export var map_position: Marker2D

@export_category("Stage Desc")
@export var stage_title: String = "Title"
@export var stage_day: int = 99
@export var stage_desc: String = "Description\nDescription"

const SLOT_SCENE = preload("res://Scene/UI/InventorySlot.tscn")

@onready var floor_tile = $Floor
@onready var wall_tile = $Wall
@onready var astar = $GridSystem/AstarLine

@onready var stage_desc_label = $CanvasLayer/Description

func _ready() -> void:
	tile_map.position = map_position.position
	floor_tile.position = map_position.position
	astar.position = map_position.position
	wall_tile.position = map_position.position
	
	update_mission_text()

## -- THIS IS USED ONLY BY INVENTORY --
func start_dragging_item(slot_node: PanelContainer):
	state_machine._transition_to_next_state("Dragging", {"slot_node" : slot_node})

func add_random_item_to_inventory(): # add random item from /Data
	var shape_data = GameData.get_random_shape()
	
	if shape_data:
		var new_slot = SLOT_SCENE.instantiate()
		inventory_bar.add_child(new_slot)
		
		new_slot.setup(shape_data)
			
		print("Added item: ", shape_data.atlas_id)

func add_item(item: Container):
	inventory_bar.add_child(item)
## -- END --

func update_mission_text():
	var text = ""
	
	# Title (Sandy Yellow)
	text += "[color=#e4c892]%s[/color]\n" % stage_title
	
	# Subtitle (White)
	text += "Day %d\n\n" % stage_day
	
	# Description (Light Cyan/Blue)
	text += "[color=#9bd2d9]%s[/color]" % stage_desc
	
	stage_desc_label.text = text
