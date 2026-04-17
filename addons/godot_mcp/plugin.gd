@tool
extends EditorPlugin
## Godot MCP Plugin
## Connects to the godot-mcp-server via WebSocket and executes tools.

const MCPClientScript = preload("res://addons/godot_mcp/mcp_client.gd")
const ToolExecutorScript = preload("res://addons/godot_mcp/tool_executor.gd")

var _mcp_client: Node  # MCPClient
var _tool_executor: Node  # ToolExecutor
var _status_label: Label

func _enter_tree() -> void:
	print("[Godot MCP] Plugin loading...")

	# Create MCP client
	_mcp_client = MCPClientScript.new()
	_mcp_client.name = "MCPClient"
	add_child(_mcp_client)

	# Create tool executor
	_tool_executor = ToolExecutorScript.new()
	_tool_executor.name = "ToolExecutor"
	add_child(_tool_executor)  # _ready() runs here, creating child tools
	_tool_executor.set_editor_plugin(self)  # Now _visualizer_tools exists

	# Connect signals
	_mcp_client.connected.connect(_on_connected)
	_mcp_client.disconnected.connect(_on_disconnected)
	_mcp_client.tool_requested.connect(_on_tool_requested)
	_mcp_client.client_count_changed.connect(_on_client_count_changed)

	# Add status indicator to editor
	_setup_status_indicator()

	# Start connection
	_mcp_client.connect_to_server()

	print("[Godot MCP] Plugin loaded - connecting to MCP server...")

func _exit_tree() -> void:
	print("[Godot MCP] Plugin unloading...")

	if _mcp_client:
		_mcp_client.disconnect_from_server()
		_mcp_client.queue_free()

	if _tool_executor:
		_tool_executor.queue_free()

	if _status_label:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _status_label)
		_status_label.queue_free()

	print("[Godot MCP] Plugin unloaded")

func _setup_status_indicator() -> void:
	"""Add a small status label to the editor toolbar."""
	_status_label = Label.new()
	_status_label.text = "MCP: Connecting..."
	_status_label.add_theme_color_override("font_color", Color.YELLOW)
	_status_label.add_theme_font_size_override("font_size", 20)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _status_label)

func _on_connected() -> void:
	print("[Godot MCP] Connected to MCP server")
	if _status_label:
		_status_label.text = "MCP: No Agent"
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.0))  # orange

func _on_disconnected() -> void:
	print("[Godot MCP] Disconnected from MCP server")
	if _status_label:
		_status_label.text = "MCP: Disconnected"
		_status_label.add_theme_color_override("font_color", Color.RED)

func _on_client_count_changed(count: int) -> void:
	if not _status_label:
		return
	if count > 0:
		_status_label.text = "MCP: Agent Active" if count == 1 else "MCP: Agents (%d)" % count
		_status_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		_status_label.text = "MCP: No Agent"
		_status_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.0))  # orange

func _on_tool_requested(request_id: String, tool_name: String, args: Dictionary) -> void:
	"""Handle incoming tool request from MCP server."""
	print("[Godot MCP] Executing tool: ", tool_name)

	# Execute the tool
	var result: Dictionary = _tool_executor.execute_tool(tool_name, args)

	var success: bool = result.get(&"ok", false)
	if success:
		result.erase(&"ok")
		_mcp_client.send_tool_result(request_id, true, result)
	else:
		var error: String = result.get(&"error", "Unknown error")
		_mcp_client.send_tool_result(request_id, false, null, error)
