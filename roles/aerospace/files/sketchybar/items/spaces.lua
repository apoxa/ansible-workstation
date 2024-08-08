local colors = require("colors")
local settings = require("settings")
local app_icons = require("plugins/icon_map")

local function lines(str)
	local result = {}
	for line in str:gmatch("[^\n]+") do
		table.insert(result, line)
	end
	return result
end

local function icons_for_apps(app_names)
	local icon_line = {}
	for _, app in pairs(app_names) do
		local lookup = app_icons[app]
		-- replace iterm icon with default terminal
		local icon = ((lookup == nil) and app_icons["Default"] or lookup):gsub("iterm", "terminal")
		table.insert(icon_line, icon)
	end
	return icon_line
end

local function reload_app_icons(spaces)
	-- set icons for workspace
	for sid, space in pairs(spaces) do
		sbar.exec("aerospace list-windows --format '%{app-name}' --workspace " .. sid, function(windows)
			local app_names = lines(windows)
			local icon_line = icons_for_apps(app_names)
			space:set({ label = table.concat(icon_line, " ") })
		end)
	end
end

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local function splitbydelimiter(
	s, -- string value
	delimiter, -- string value with defines the delimiter. default is ","
	item -- number: (optional) item in array to return.
	-- Let's say you want the 3rd item parsed from string  "item1,item2,item3"
	-- If you say 2 item2 will be returned.
	-- Note that Lua arrays start at 1 and not 0.
) -- returns table of split items or item entry
	answer = {}
	delimiter1 = delimiter or ","
	for word in string.gmatch(s, "(.-)" .. delimiter1) do
		table.insert(answer, word)
	end
	if #answer == 0 then
		result = nil -- return nil if nothing found.
	elseif item then -- does the user want an entry verses a parsed table?
		if #answer >= item then
			result = answer[item]
		else
			result = nil
		end
	else
		result = answer
	end
	return result
end

sbar.exec("aerospace list-workspaces --monitor all --format '%{monitor-id}|%{workspace}|'", function(all_workspaces)
	local aerospaces = lines(all_workspaces)

	local spaces = {}

	for _, monitor_app in pairs(aerospaces) do
		local monitor = splitbydelimiter(monitor_app, "|", 1)
		local sid = splitbydelimiter(monitor_app, "|", 2)
		local space_name = "space." .. sid
		local space = sbar.add("item", space_name, {
			background = {
				color = 0x44ffffff,
				corner_radius = 5,
				height = 20,
				drawing = false,
			},
			label = {
				y_offset = -1,
				font = "sketchybar-app-font:Regular:18.0",
			},
			display = 1,
			icon = { string = sid, padding_left = 4 },
		})
		if sid ~= nil then
			spaces[sid] = space
		end

		space:subscribe("aerospace_workspace_change", function(env)
			selected = env.FOCUSED_WORKSPACE == sid
			space:set({ background = { drawing = selected } })
		end)

		space:subscribe("space_windows_change", function(env)
			-- run window change events only on first item, since aerospace places everyting on a single space and this events get's triggered for every item
			local is_first = env.NAME == "space.1"
			if is_first == true then
				reload_app_icons(spaces)
			end
		end)
	end
	reload_app_icons(spaces)
end)
