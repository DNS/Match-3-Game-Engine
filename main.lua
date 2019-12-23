--[[ 
	Match-3 Game Engine
	© 2019 by Daniel Sirait <dsirait@outlook.com>
]]

local debug_str, gem_color, gems, gem_size, new_game
local start_x, start_y

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
	start_x = (love.graphics.getWidth() - gem_size * 8) / 2
	start_y = (love.graphics.getHeight() - gem_size * 8) / 1.9

	-- init gem
	for y = 1, 8 do
		gems[y] = {}
		for x = 1, 8 do
			gems[y][x] = {}
			gems[y][x].color = love.math.random(1, 6)
			gems[y][x].pos_x = (x-1) * gem_size + start_x
			gems[y][x].pos_y = (y-1) * gem_size + start_y
			gems[y][x].width = gem_size
			gems[y][x].height = gem_size
			
			gems[y][x].fall = false
			gems[y][x].removed = false
			
			-- mouse/touch dragging
			gems[y][x].diff_x = 0
			gems[y][x].diff_y = 0
			gems[y][x].mouse_hold = false
		end
	end

	--debug_str = gems[1][1].color ..','.. gems[1][2].color ..','.. gems[1][3].color

	new_game = true
end

function love.draw()
	love.graphics.setColor(255,255,255,255)	-- white
	love.graphics.print(debug_str)
	for y = 1, 8 do
		for x = 1, 8 do
			love.graphics.setColor(gem_color[gems[y][x].color])
			love.graphics.rectangle('fill', gems[y][x].pos_x, gems[y][x].pos_y, gems[y][x].width, gems[y][x].height)
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

function Match3InitReplace()
	-- check horizontal
	for y = 1, 8 do
		for x = 1, 6 do
			if gems[y][x].color == gems[y][x+1].color and gems[y][x].color == gems[y][x+2].color then
				local remove_gems = {}
				local colors = {1, 2, 3, 4, 5, 6}
				
				if y == 1 then
					table.insert(remove_gems, gems[y][x+1].color)
					table.insert(remove_gems, gems[y+1][x+1].color)
				elseif y == 8 then
					table.insert(remove_gems, gems[y][x+1].color)
					table.insert(remove_gems, gems[y-1][x+1].color)
				else
					table.insert(remove_gems, gems[y][x+1].color)
					table.insert(remove_gems, gems[y-1][x+1].color)
					table.insert(remove_gems, gems[y+1][x+1].color)
				end
				
				for i = 1, #remove_gems do
					for j = 1, #colors do
						if colors[j] == remove_gems[i] then
							table.remove(colors, j)
						end
					end
				end
				
				local r = love.math.random(1, #colors)
				gems[y][x+1].color = colors[r]
			end
		end
	end

	--------------------------
	-- check vertical
	for x = 1, 8 do
		for y = 1, 6 do
			if gems[y][x].color == gems[y+1][x].color and gems[y][x].color == gems[y+2][x].color then
				local remove_gems = {}
				local colors = {1, 2, 3, 4, 5, 6}
				
				if x == 1 then
					table.insert(remove_gems, gems[y+1][x].color)
					table.insert(remove_gems, gems[y+1][x+1].color)
				elseif x == 8 then
					table.insert(remove_gems, gems[y+1][1].color)
					table.insert(remove_gems, gems[y+1][x-1].color)
				else
					table.insert(remove_gems, gems[y+1][x].color)
					table.insert(remove_gems, gems[y+1][x-1].color)
					table.insert(remove_gems, gems[y+1][x+1].color)
				end
				
				for i = 1, #remove_gems do
					for j = 1, #colors do
						if colors[j] == remove_gems[i] then
							table.remove(colors, j)
						end
					end
				end
				
				local r = love.math.random(1, #colors)
				gems[y+1][x].color = colors[r]
			end
		end
	end
end

-- if no matches found return false, maybe the game is over?
function Match3PossibleMove()
	for y = 1, 6 do
		for x = 1, 6 do
			-- check horizontal
			if gems[y][x].color == gems[y][x+1].color and gems[y][x].color == gems[y][x+2].color then
				return true
			end
			
			-- check vertical
			if gems[y][x].color == gems[y+1][x].color and gems[y][x].color == gems[y+2][x].color then
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
	for y = 1, 8 do
		for x = 1, 4 do
			if gems[y][x].color == gems[y][x+1].color and gems[y][x].color == gems[y][x+2].color and gems[y][x].color == gems[y][x+3].color and gems[y][x].color == gems[y][x+4].color then
				
			end
		end
	end
	
	-- match 5 vertical
	for x = 1, 8 do
		for y = 1, 4 do
			if gems[y][x].color == gems[y+1][x].color and gems[y][x].color == gems[y+2][x].color and gems[y][x].color == gems[y+3][x].color and gems[y][x].color == gems[y+4][x].color then
				
			end
		end
	end
	
	-- match 4 horizontal
	for y = 1, 8 do
		for x = 1, 5 do
			if gems[y][x].color == gems[y][x+1].color and gems[y][x].color == gems[y][x+2].color and gems[y][x].color == gems[y][x+3].color then
				
			end
		end
	end
	
	-- match 4 vertical
	for x = 1, 8 do
		for y = 1, 5 do
			if gems[y][x].color == gems[y+1][x].color and gems[y][x].color == gems[y+2][x].color and gems[y][x].color == gems[y+3][x].color then
				
			end
		end
	end
	
	-- match 3 horizontal
	for y = 1, 8 do
		for x = 1, 6 do
			if gems[y][x].color == gems[y][x+1].color and gems[y][x].color == gems[y][x+2].color then
				--debug_str = 'match 3 horizontal'
			end
		end
	end
	
	-- match 3 vertical
	for x = 1, 8 do
		for y = 1, 6 do
			if gems[y][x].color == gems[y+1][x].color and gems[y][x].color == gems[y+2][x].color then
				--debug_str = 'match 3 vertical'
			end
		end
	end
	
end


-- tell all pieces above this one to move down


--[[ animate fall
function AnimateGemsFall(dt)
	--gem_fall
	for x = 8, 1, -1 do
		for y = 8, 1, -1 do
			if gems[y][x].fall then
				if y == 8 then
					
				elseif y <= 7 and gems[y][x].fall and (gems[y][x].pos_y+gem_size+1*dt) < gems[y+1][x].pos_y then
					gems[y][x].pos_y = gems[y][x].pos_y + 1*dt
				else
					gems[y][x].pos_y = gems[y+1][x].pos_y - gem_size
					gems[y][x].fall = false
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

