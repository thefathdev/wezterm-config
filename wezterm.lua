local wezterm = require("wezterm")

-- Define the colors for Tokyo Night (night variant)
local tokyo_night = {
	foreground = "#c0caf5",
	background = "#1a1b26",
	cursor_bg = "#c0caf5",
	cursor_border = "#c0caf5",
	cursor_fg = "#1a1b26",
	selection_bg = "#33467c",
	selection_fg = "#c0caf5",
	ansi = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
	brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
}

-- Custom tab bar
local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	local background = tokyo_night.background
	local foreground = tokyo_night.foreground

	if tab.is_active then
		background = tokyo_night.ansi[5] -- Active tab color (blue)
		foreground = tokyo_night.background
	elseif hover then
		background = tokyo_night.brights[1] -- Hover color
	end

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. title .. " " },
	}
end)

-- Function to create a fancy tab bar
local function fancy_tab_bar(window)
	local tabs = window:mux_window():tabs_with_info()
	local tab_elements = {}

	for i, tab in ipairs(tabs) do
		local title = tab_title(tab)
		local background = tokyo_night.background
		local foreground = tokyo_night.foreground

		if tab.is_active then
			background = tokyo_night.ansi[5] -- Active tab color (blue)
			foreground = tokyo_night.background
		end

		table.insert(tab_elements, { Background = { Color = background } })
		table.insert(tab_elements, { Foreground = { Color = foreground } })
		table.insert(tab_elements, { Text = " " .. i .. ": " .. title .. " " })
	end

	return tab_elements
end

local config = {
	-- Enable fullscreen mode on startup
	default_gui_startup_args = { "start", "--maximized" },

	-- Custom tab bar settings
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	tab_max_width = 25,
	hide_tab_bar_if_only_one_tab = true,

	-- Custom status bar with tabs
	window_frame = {
		font = wezterm.font({ family = "Cascadia Code NF", weight = "Bold" }),
		font_size = 11.0,
		active_titlebar_bg = tokyo_night.background,
		inactive_titlebar_bg = tokyo_night.background,
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},

	-- Set font family
	font = wezterm.font("Cascadia Code NF"),
	-- Set font size
	font_size = 11,

	-- Set line height (as a multiplier of the font size)
	line_height = 1.2,

	-- Apply the Tokyo Night theme
	colors = tokyo_night,

	-- Hide the title bar and use custom window decorations
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",

	-- Optional: Set the background opacity if you want a slight transparency
	-- window_background_opacity = 0.95,

	-- Custom key bindings for tab management
	keys = {
		{ key = "t", mods = "CTRL", action = wezterm.action({ SpawnTab = "DefaultDomain" }) },
		{ key = "w", mods = "CTRL", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
		{ key = "Tab", mods = "CTRL", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },
	},
}

-- Use the custom status bar function
config.status_update_interval = 1000
wezterm.on("update-status", function(window, pane)
	window:set_right_status(wezterm.format(fancy_tab_bar(window)))
end)

return config
