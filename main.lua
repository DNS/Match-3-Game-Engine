--[[ 
	Match-3 Game Engine
	© 2019 by Daniel Sirait <dsirait@outlook.com>
]]

local debug_str, gem_color, gems, gem_size, new_game
local start_x, start_y
local info = {}

debug_str = ''

gem_color = {
	[1] = {255, 0, 0, 255},		-- 1: RED
	[2] = {0, 0, 255, 255},		-- 2: BLUE
	[3] = {0, 255, 0, 255},		-- 3: GREEN
	[4] = {255, 255, 0, 255},	-- 4: YELLOW
	[5] = {255, 128, 0, 255},	-- 5: ORANGE
	[6] = {255, 0, 255, 255}	-- 6: PURPLE
	--[7] = {255, 255, 255, 0}	-- 7: TRANSPARENT
}

gems = {}
gem_size = 30 -- pixels

-- x,y dimension for each stage ?

function love.load()
	load_info()
	
	start_x = (love.graphics.getWidth() - gem_size * 8) / 2
	start_y = (love.graphics.getHeight() - gem_size * 8) / 1.9

	-- init gem: 
	-- y -> j
	-- x -> i
	for j = 1, 8 do
		gems[j] = {}
		for i = 1, 8 do
			gems[j][i] = {}
			gems[j][i].color = love.math.random(1, 6)
			gems[j][i].x = (i-1) * gem_size + start_x
			gems[j][i].y = (j-1) * gem_size + start_y
			gems[j][i].w = gem_size
			gems[j][i].h = gem_size
			
			gems[j][i].fall = false
			gems[j][i].removed = false
			
			-- mouse/touch dragging
			gems[j][i].diff_x = 0
			gems[j][i].diff_y = 0
			gems[j][i].mouse_hold = false
		end
	end


	--debug_str = info.resolution_x .. 'x' .. info.resolution_y

	
	new_game = true
end

function love.draw()
	love.graphics.setColor(255,255,255,255)	-- white
	love.graphics.print(debug_str)
	for j = 1, 8 do
		for i = 1, 8 do
			love.graphics.setColor(gem_color[gems[j][i].color])
			love.graphics.rectangle('fill', gems[j][i].x, gems[j][i].y, gems[j][i].w, gems[j][i].h)
		end
	end
end

function love.update(dt)
	--debug_str = '343'
	if new_game then
		new_game = false
		Match3InitReplace()
	end
	
	-- wait for input
	DetectInput()
	
	
	---Match543()
	
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

function DetectInput()
	
end

function detect_click (x, y, w, h)
	if not love.mouse.isDown(1) then return false end
	
	if love.mouse.getX() >= x and love.mouse.getX() <= x+w and love.mouse.getY() >= y and love.mouse.getY() <= y+h then
		return true
	else
		return false
	end
end

function load_info()
	info.OS = love.system.getOS()
	info.CPU_count = love.system.getProcessorCount()
	info.power = love.system.getPowerInfo()
	info.resolution_x = love.graphics.getWidth()
	info.resolution_y = love.graphics.getHeight()
end

function Match3InitReplace()
	-- check horizontal
	for j = 1, 8 do
		for i = 1, 6 do
			if gems[j][i].color == gems[j][i+1].color and gems[j][i].color == gems[j][i+2].color then
				local remove_gems = {}
				local colors = {1, 2, 3, 4, 5, 6}
				
				if j == 1 then
					table.insert(remove_gems, gems[j][i+1].color)
					table.insert(remove_gems, gems[j+1][i+1].color)
				elseif j == 8 then
					table.insert(remove_gems, gems[j][i+1].color)
					table.insert(remove_gems, gems[j-1][i+1].color)
				else
					table.insert(remove_gems, gems[j][i+1].color)
					table.insert(remove_gems, gems[j-1][i+1].color)
					table.insert(remove_gems, gems[j+1][i+1].color)
				end
				
				for k = 1, #remove_gems do
					for l = 1, #colors do
						if colors[l] == remove_gems[k] then
							table.remove(colors, l)
						end
					end
				end
				
				local r = love.math.random(1, #colors)
				gems[j][i+1].color = colors[r]
			end
		end
	end

	--------------------------
	-- check vertical
	for i = 1, 8 do
		for j = 1, 6 do
			if gems[j][i].color == gems[j+1][i].color and gems[j][i].color == gems[j+2][i].color then
				local remove_gems = {}
				local colors = {1, 2, 3, 4, 5, 6}
				
				if i == 1 then
					table.insert(remove_gems, gems[j+1][i].color)
					table.insert(remove_gems, gems[j+1][i+1].color)
				elseif i == 8 then
					table.insert(remove_gems, gems[j+1][1].color)
					table.insert(remove_gems, gems[j+1][i-1].color)
				else
					table.insert(remove_gems, gems[j+1][i].color)
					table.insert(remove_gems, gems[j+1][i-1].color)
					table.insert(remove_gems, gems[j+1][i+1].color)
				end
				
				for k = 1, #remove_gems do
					for l = 1, #colors do
						if colors[l] == remove_gems[k] then
							table.remove(colors, l)
						end
					end
				end
				
				local r = love.math.random(1, #colors)
				gems[j+1][i].color = colors[r]
			end
		end
	end
end

-- if no matches found return false, maybe the game is over?
function Match3PossibleMove()
	for j = 1, 6 do
		for i = 1, 6 do
			-- check horizontal
			if gems[j][i].color == gems[y][x+1].color and gems[j][i].color == gems[j][i+2].color then
				return true
			end
			
			-- check vertical
			if gems[j][i].color == gems[j+1][i].color and gems[j][i].color == gems[j+2][i].color then
				return true
			end
		end
	end
	
	return false
end

-- Match543: match, fade/remove, shift upper gem to empty cell,
-- add new gem on top & spawn new gem from top and animate the fall/gravity
function Match543()
	-- match 5 horizontal
	for j = 1, 8 do
		for i = 1, 4 do
			if gems[j][i].color == gems[j][i+1].color and gems[j][i].color == gems[j][i+2].color and gems[j][i].color == gems[j][i+3].color and gems[j][i].color == gems[j][i+4].color then
				
			end
		end
	end
	
	-- match 5 vertical
	for j = 1, 8 do
		for i = 1, 4 do
			if gems[j][i].color == gems[j+1][i].color and gems[j][i].color == gems[j+2][i].color and gems[j][i].color == gems[j+3][i].color and gems[j][i].color == gems[j+4][i].color then
				
			end
		end
	end
	
	-- match 4 horizontal
	for j = 1, 8 do
		for i = 1, 5 do
			if gems[j][i].color == gems[j][i+1].color and gems[j][i].color == gems[j][i+2].color and gems[j][i].color == gems[j][i+3].color then
				
			end
		end
	end
	
	-- match 4 vertical
	for i = 1, 8 do
		for j = 1, 5 do
			if gems[j][i].color == gems[j+1][i].color and gems[j][i].color == gems[j+2][i].color and gems[j][i].color == gems[j+3][i].color then
				
			end
		end
	end
	
	-- match 3 horizontal
	for j = 1, 8 do
		for i = 1, 6 do
			if gems[j][i].color == gems[j][i+1].color and gems[j][i].color == gems[j][i+2].color then
				--debug_str = 'match 3 horizontal'
			end
		end
	end
	
	-- match 3 vertical
	for i = 1, 8 do
		for j = 1, 6 do
			if gems[j][i].color == gems[j+1][i].color and gems[j][i].color == gems[j+2][i].color then
				--debug_str = 'match 3 vertical'
			end
		end
	end
	
end


-- tell all pieces above this one to move down


--[[ animate fall
function AnimateGemsFall(dt)
	--gem_fall
	for i = 8, 1, -1 do
		for j = 8, 1, -1 do
			if gems[j][i].fall then
				if j == 8 then
					
				elseif j <= 7 and gems[j][i].fall and (gems[j][i].y+gem_size+1*dt) < gems[j+1][i].y then
					gems[j][i].y = gems[j][i].y + 1*dt
				else
					gems[j][i].y = gems[j+1][i].y - gem_size
					gems[j][i].fall = false
				end
			end
		end
	end
end
]]

local ShiftDown = false
-- Gems shift down animation
function ShiftDownAnimate(dt)
	
end

-- add input, start animated swap of two pieces

-- tell all pieces above this one to move down

-- if there are missing pieces in a column, add one to drop

-- return an array of all matches found, randomize it and give suggestion to player

-- if all dropping is done

