conf = {
	bg_colour = 0xeeeeee,
	bg_alpha = 0.3,
	fg_colour = 0x0769d3,
	fg_alpha = 0.75,
	factor = 0.7
}
elements = {
	--[[ {
		name = 'acpitemp',
		arg = "",
		max = 80,
		x = 100,
		y = 80,
		r = 68,
		width = 6,
		start_angle = -90,
		end_angle = 180
	}, ]]
	{
		name = 'cpu',
		arg = "cpu1",
		max = 100,
		x = 100,
		y = 80,
		r = 76,
		width = 6,
		start_angle = -90,
		end_angle = 180
	},
	{
		name = 'cpu',
		arg = "cpu2",
		max = 100,
		x = 100,
		y = 80,
		r = 68,
		width = 6,
		start_angle = -90,
		end_angle = 200
	},
	{
		name = 'cpu',
		arg = "cpu3",
		max = 100,
		x = 100,
		y = 80,
		r = 60,
		width = 6,
		start_angle = -90,
		end_angle = 220
	},
	{
		name = 'cpu',
		arg = "cpu4",
		max = 100,
		x = 100,
		y = 80,
		r = 52,
		width = 6,
		start_angle = -90,
		end_angle = 240
	},
	{
		name = 'cpu',
		arg = "cpu5",
		max = 100,
		x = 100,
		y = 80,
		r = 44,
		width = 6,
		start_angle = -90,
		end_angle = 260
	},
	{
		name = 'cpu',
		arg = "cpu6",
		max = 100,
		x = 100,
		y = 80,
		r = 36,
		width = 6,
		start_angle = -90,
		end_angle = 280
	},
	{
		name = 'memperc',
		arg = '',
		max = 100,
		x = 100,
		y = 240,
		r = 60,
		width = 6,
		start_angle = -80,
		end_angle = 200
	},
	{
		name = 'swapperc',
		arg = '',
		max = 100,
		x = 100,
		y = 240,
		r = 52,
		width = 6,
		start_angle = -75,
		end_angle = 220
	},
	{
		name = 'execi',
		arg = "1 df | grep ^/dev/s | sed -n 1p | awk '{ print substr($5, 1, length($5) - 1) }'",
		max = 100,
		x = 100,
		y = 400,
		r = 60,
		width = 6,
		start_angle = -80,
		end_angle = 200
	},
	{
		name = 'execi',
		arg = "1 df | grep ^/dev/s | sed -n 3p | awk '{ print substr($5, 1, length($5) - 1) }'",
		max = 100,
		x = 100,
		y = 400,
		r = 52,
		width = 6,
		start_angle = -75,
		end_angle = 220
	},
	{
		name = 'upspeedf',
		arg = 'enp1s0',
		pre = '${if_up enp1s0}true${endif}',
		max = 12,
		log = true,
		x = 100,
		y = 560,
		r = 60,
		width = 6,
		start_angle = -80,
		end_angle = 200
	},
	{
		name = 'downspeedf',
		arg = 'enp1s0',
		pre = '${if_up enp1s0}true${endif}',
		max = 12,
		log = true,
		x = 100,
		y = 560,
		r = 52,
		width = 6,
		start_angle = -75,
		end_angle = 220
	}
}

require 'cairo'

function rgba(colour, alpha)
	return colour / 0x10000 % 0x100 / 255.,
	colour / 0x100 % 0x100 / 255.,
	colour % 0x100 / 255.,
	alpha
end

function draw_line(cr, pt)
	cairo_move_to(cr, pt['x0'], pt['y0'])
	cairo_line_to(cr, pt['x1'], pt['y1'])
	cairo_set_source_rgba(cr, rgba(conf['fg_colour'], conf['fg_alpha']))
	cairo_set_line_width(cr, pt['width'])
	cairo_stroke(cr)
end

function draw_ring(cr, val, pt)
	if pt['pre'] ~= nil then
		local pre = conky_parse(pt['pre'])
		if pre ~= 'true' then
			return
		end
	end

	local angle_0 = pt['start_angle'] * math.pi / 180 - math.pi / 2
	local angle_f = pt['end_angle'] * math.pi / 180 - math.pi / 2
	local angle_t = angle_0 + val / pt['max'] * (angle_f - angle_0)

	cairo_arc(cr, pt['x'] * conf['factor'], pt['y'] * conf['factor'], pt['r'] * conf['factor'], angle_0, angle_f)
	cairo_set_source_rgba(cr, rgba(conf['bg_colour'], conf['bg_alpha']))
	cairo_set_line_width(cr, pt['width'] * conf['factor'])
	cairo_stroke(cr)
	
	cairo_arc(cr, pt['x'] * conf['factor'], pt['y'] * conf['factor'], pt['r'] * conf['factor'], angle_0, angle_t)
	cairo_set_source_rgba(cr, rgba(conf['fg_colour'], conf['fg_alpha']))
	cairo_stroke(cr)
end

function setup_rings(cr, pt)
	if pt['name'] == nil then
		draw_line(cr, pt)
	else
		local val = conky_parse(string.format('${%s %s}', pt['name'],
		pt['arg'])):gsub('%%', '')
		val = tonumber(val)
		if val == nil then
			return
		end
		if pt['log'] then
			val = math.log(val + 1)
		end
		draw_ring(cr, val, pt)
	end
end

function conky_rings()
	if conky_window == nil then
		return
	end
	
	local cs = cairo_xlib_surface_create(
	conky_window.display, conky_window.drawable, conky_window.visual,
	conky_window.width, conky_window.height)
	local cr = cairo_create(cs)
	for i in pairs(elements) do
		setup_rings(cr, elements[i])
	end
end
