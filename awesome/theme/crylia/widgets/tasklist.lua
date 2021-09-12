local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local color = require('theme.crylia.colors')
local naughty = require("naughty")

local list_update = function (widget, buttons, label, data, objects)
	widget:reset()

	for i, object in ipairs(objects) do

		local task_icon = wibox.widget{
			nil,
			{
				id = "icon",
				resize = true,
				widget = wibox.widget.imagebox
			},
			nil,
			layout = wibox.layout.align.horizontal
		}

		local task_icon_margin = wibox.widget{
			task_icon,
			forced_width = dpi(33),
			margins = dpi(3),
			widget = wibox.container.margin
		}

		local task_title = wibox.widget{
			text = "",
			align = "center",
			valign = "center",
			visible = true,
			widget = wibox.widget.textbox
		}

		local task_widget = wibox.widget{
			{
				{
					task_icon_margin,
					task_title,
					layout = wibox.layout.fixed.horizontal
				},
				margins = dpi(0),
				widget = wibox.container.margin
			},
			bg = color.color["White"],
			fg = color.color["Grey900"],
			shape = function (cr, width, height)
				gears.shape.rounded_rect(cr, width, height, 5)
			end,
			widget = wibox.widget.background
		}

		local task_tool_tip = awful.tooltip{
			objects = {task_widget},
			mode = "inside",
			align = "right",
			delay_show = 1
		}

		task_widget:buttons(buttons, object)

		local text, bg, bg_image, icon, args = label(object, task_title)

		if object == client.focus then
			if text == nil or text == '' then
				task_title:set_margins(0)
			else
				local text_full = text:match('>(.-)<')
				if text_full then
					text = text_full
					task_tool_tip:set_text(text_full)
					task_tool_tip:add_to_object(task_widget)
				else
					task_tool_tip:remove_from_object(task_widget)
				end
			end
			task_widget:set_bg(color.color["White"])
			task_widget:set_fg(color.color["Grey900"])
			task_title:set_text(text)
		else
			task_widget:set_bg("#3A475C")
			task_title:set_text('')
		end

		if icon then
			task_icon.icon:set_image(icon)
		else
			task_icon_margin:set_margins(0)
		end

		widget:add(task_widget)
		widget:set_spacing(dpi(6))

		local old_wibox, old_cursor, old_bg
    	task_widget:connect_signal(
    	    "mouse::enter",
    	    function ()
    	        old_bg = task_widget.bg
    	        task_widget.bg = "#ffffff" .. "bb"
    	        local w = mouse.current_wibox
    	        if w then
    	            old_cursor, old_wibox = w.cursor, w
    	            w.cursor = "hand1"
    	        end
    	    end
    	)

    	task_widget:connect_signal(
    	    "button::press",
    	    function ()
    	        task_widget.bg = "#ffffff" .. "aa"
    	    end
    	)

    	task_widget:connect_signal(
    	    "button::release",
    	    function ()
    	        task_widget.bg = "#ffffff" .. "bb"
    	    end
    	)

    	task_widget:connect_signal(
    	    "mouse::leave",
    	    function ()
    	        task_widget.bg = old_bg
    	        if old_wibox then
    	            old_wibox.cursor = old_cursor
    	            old_wibox = nil
    	        end
    	    end
    	)
	end

	if (widget.children and #widget.children or 0) == 0 then
		awesome.emit_signal("hide_centerbar", false)
	else
		awesome.emit_signal("hide_centerbar", true)
	end
	return widget
end

return function(s)
	return awful.widget.tasklist(
		s,
		awful.widget.tasklist.filter.currenttags,
		gears.table.join(
			awful.button(
				{},
				1,
				function (c)
					if c == client.focus then
						c.minimized = true
					else
						c.minimized = false
						if not c.invisible() and c.first_tag then
							c:emit_signal("request::activate")
							c:raise()
						end
					end
				end
			)
		),
		{},
		list_update,
		wibox.layout.fixed.horizontal()
	)
end