# SynchronicityEngine.gd
# Godot 2D - The Core Engine of Synchronicity Narrative System

extends Node

class_name SynchronicityEngine

# Signals to communicate with rest of the game
signal emergent_quest_generated(context)
signal dramatic_incident_triggered(context)

# Track world state and recent events
var recent_events : Array = []
var npc_registry : Dictionary = {}

# Timers
var check_interval = 5.0 # seconds
var _time_since_last_check = 0.0

# Parameters
const MAX_RECENT_EVENTS = 50
const TRIGGER_THRESHOLD = 0.6 # 0-1 float: probability to spawn synchronic event

# Called when added to scene
func _ready():
    print("Synchronicity Engine Online.")

# Called every frame
func _process(delta):
    _time_since_last_check += delta
    if _time_since_last_check >= check_interval:
        _time_since_last_check = 0
        _analyze_world_state()

# Public method for NPCs or World to log significant events
func log_event(event_data: Dictionary):
    recent_events.append(event_data)
    if recent_events.size() > MAX_RECENT_EVENTS:
        recent_events.pop_front()

# Public method to register an NPC with their traits
func register_npc(npc_id: String, npc_data: Dictionary):
    npc_registry[npc_id] = npc_data

# Main analysis loop
func _analyze_world_state():
    if recent_events.empty():
        return

    # Find potential synchronicities
    var candidate_events = []
    for event in recent_events:
        if _is_narratively_important(event):
            candidate_events.append(event)

    if candidate_events.size() >= 2:
        # High chance to trigger narrative event
        if randf() < TRIGGER_THRESHOLD:
            var selected_context = _build_narrative_context(candidate_events)
            # Randomly decide what to generate
            if randi() % 2 == 0:
                emit_signal("emergent_quest_generated", selected_context)
            else:
                emit_signal("dramatic_incident_triggered", selected_context)

# Heuristic to decide if an event could be part of a story
func _is_narratively_important(event: Dictionary) -> bool:
    if event.has("type") and event["type"] in ["conflict", "discovery", "betrayal", "ambition", "loss", "love"]:
        return true
    return false

# Build a storytelling context (to send to AI or Quest Generator)
func _build_narrative_context(events: Array) -> Dictionary:
    var context = {
        "involved_npcs": [],
        "location": "",
        "theme": "",
        "summary": ""
    }

    # Select two interesting events
    var event_a = events[randi() % events.size()]
    var event_b = events[randi() % events.size()]
    
    # Make sure they are not identical
    while event_a == event_b and events.size() > 1:
        event_b = events[randi() % events.size()]

    # Merge their info
    context["involved_npcs"] = [event_a.get("npc_id", ""), event_b.get("npc_id", "")]
    context["location"] = event_a.get("location", "unknown")
    context["theme"] = _infer_theme(event_a, event_b)
    context["summary"] = "Two events occurred: %s and %s." % [event_a.get("description", ""), event_b.get("description", "")]
    
    return context

# Simple theme inference based on event types
func _infer_theme(event_a: Dictionary, event_b: Dictionary) -> String:
    var types = [event_a.get("type", ""), event_b.get("type", "")]
    if "love" in types and "betrayal" in types:
        return "romantic tragedy"
    if "conflict" in types and "ambition" in types:
        return "power struggle"
    if "loss" in types and "discovery" in types:
        return "quest for redemption"
    return "emergent conflict"
