--[[
    CS50G
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves.
StartState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function StartState:update(dt)
	 -- toggle highlighted option if we press an arrow key up or down
	if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
		-- as there are only two options, this basically just toogles between both of them
		highlighted = highlighted == 1 and 2 or 1
		gSounds['select']:play()
	end

	-- confirm whichever option we have selected to change screens
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		gSounds['confirm']:play()

		if highlighted == 1 then
			gStateMachine:change('play')
		end
	end

	-- we must include escape key action in every state
	if love.keyboard.wasPressed('escape') then
		love.event.quit()
	end
end

function StartState:render()
	-- title
	love.graphics.setFont(gFonts['large'])
	love.graphics.printf('BREAKOUT', 0, VIRTUAL_HEIGHT / 3 + 5, VIRTUAL_WIDTH, 'center')

	-- instructions
	love.graphics.setFont(gFonts['medium'])

	-- if we´re highlighting 1, render option one blue
	if highlighted == 1 then
		love.graphics.setColor(103/255, 1, 1, 1)
	end
	love.graphics.printf('START', 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')

	-- reset color
	love.graphics.setColor(1, 1, 1, 1)

	-- render option 2 blue if it is highlighted
	if highlighted == 2 then
		love.graphics.setColor(103/255, 1, 1, 1)
	end
	love.graphics.printf('HIGH SCORES', 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')

	-- reset color
	love.graphics.setColor(1, 1, 1, 1)
end