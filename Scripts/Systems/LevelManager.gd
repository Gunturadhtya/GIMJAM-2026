class_name LevelManager extends Node2D

@onready var grid_system: GridSystem = $GridSystem
@onready var ghost_cursor: Node2D = $GhostCursor 
@onready var state_machine: StateMachine = $StateMachine
@onready var tile_map: TileMapLayer = $GridSystem/TileMapLayer
