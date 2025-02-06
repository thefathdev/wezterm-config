local wezterm = require("wezterm")

-- Define the colors for Kanagawa Wave
local kanagawa_wave = {
	foreground = "#DCD7BA",
	background = "#1F1F28",
	cursor_bg = "#E6E0C2",
	cursor_border = "#E6E0C2",
	cursor_fg = "#1F1F28",
	selection_bg = "#49473E",
	selection_fg = "#DCD7BA",
	ansi = { "#090618", "#C34043", "#76946A", "#C0A36E", "#7E9CD8", "#957FB8", "#6A9589", "#C8C093" },
	brights = { "#727169", "#E82424", "#98BB6C", "#E6C384", "#7FB4CA", "#938AA9", "#7AA89F", "#DCD7BA" },
}

-- Custom tab title function (unchanged)
local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

-- Update tab title formatting to use Kanagawa Wave colors
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	local background = kanagawa_wave.background
	local foreground = kanagawa_wave.foreground
	if tab.is_active then
		background = kanagawa_wave.ansi[6] -- Active tab color (purple)
		foreground = kanagawa_wave.background
	elseif hover then
		background = kanagawa_wave.brights[1] -- Hover color
	end
	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. title .. " " },
	}
end)

-- Update fancy tab bar function to use Kanagawa Wave colors
local function fancy_tab_bar(window)
	local tabs = window:mux_window():tabs_with_info()
	local tab_elements = {}
	for i, tab in ipairs(tabs) do
		local title = tab_title(tab)
		local background = kanagawa_wave.background
		local foreground = kanagawa_wave.foreground
		if tab.is_active then
			background = kanagawa_wave.ansi[6] -- Active tab color (purple)
			foreground = kanagawa_wave.background
		end
		table.insert(tab_elements, { Background = { Color = background } })
		table.insert(tab_elements, { Foreground = { Color = foreground } })
		table.insert(tab_elements, { Text = " " .. i .. ": " .. title .. " " })
	end
	return tab_elements
end

local config = {
	-- set higher fps
	max_fps = 120,
	-- Enable fullscreen mode on startup
	default_gui_startup_args = { "start", "--maximized" },
	-- Custom tab bar settings
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	tab_max_width = 25,
	hide_tab_bar_if_only_one_tab = false,
	-- Custom status bar with tabs
	window_frame = {
		font = wezterm.font({ family = "Cascadia Code NF", weight = "Bold" }),
		font_size = 11.0,
		active_titlebar_bg = kanagawa_wave.background,
		inactive_titlebar_bg = kanagawa_wave.background,
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 10,
		bottom = 0,
	},
	-- Set font family
	font = wezterm.font("JetBrains Mono Nerd Font"),
	-- Set font size
	font_size = 10,
	-- Set line height (as a multiplier of the font size)
	line_height = 1.3,
	-- Apply the Kanagawa Wave theme
	colors = kanagawa_wave,
	-- Hide the title bar and use custom window decorations
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	-- Optional: Set the background opacity if you want a slight transparency
	window_background_opacity = 0.95,
	-- Custom key bindings for tab management (unchanged)
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
