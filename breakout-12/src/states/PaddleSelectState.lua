--[[
    CS50G
    Breakout Remake

    -- PaddleSelectState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
	
	Represents the screen where the player can choose the paddle color. 
    
]]

PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
	self.highScores = params.highScores
end

function PaddleSelectState:init()
	-- the paddle we´re highlighting; will be passed to the ServeState
	-- when we press enter
	self.currentPaddle = 1
end

function PaddleSelectState:update(dt)
	if love.keyboard.wasPressed('left') then
		if self.currentPaddle == 1 then
			gSounds['no-select']:stop()
			gSounds['no-select']:play()
		else
			self.currentPaddle = self.currentPaddle - 1
			gSounds['select']:stop()
			gSounds['select']:play()
		end
	elseif love.keyboard.wasPressed('right') then
		if self.currentPaddle == 4 then
			gSounds['no-select']:stop()
			gSounds['no-select']:play()
		else
			self.currentPaddle = self.currentPaddle + 1
			gSounds['select']:stop()
			gSounds['select']:play()
		end
	end

	-- select paddle and move on to the serve state, assing in the selection
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		gSounds['confirm']:play()

		gStateMachine:change('serve', {
				level = 1,
				paddle = Paddle(self.currentPaddle),
				bricks = LevelMaker.createMap(1),
				health = 3,
				score = 0,
				highScores = self.highScores
			})
	end

	if love.keyboard.wasPressed('escape') then
		love.event.quit()
	end
end

function PaddleSelectState:render()
	-- instructions
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf('Select your paddle with left and right!', 0, VIRTUAL_HEIGHT / 4,
		VIRTUAL_WIDTH, 'center')
	love.graphics.setFont(gFonts['small'])
	love.graphics.printf('Press Enter to continue!', 0, VIRTUAL_HEIGHT / 3,
		VIRTUAL_WIDTH, 'center')

	-- left arrow; should render normally if we´re higher than 1, else
	-- in a shadowy form to let us know we´re as far left as we can go
	if self.currentPaddle == 1 then
		-- tint; give it a dark gray with half opacity
		love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
	end

	love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
		VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
	-- reset drawing color to full white for proper rendering
	love.graphics.setColor(1, 1, 1, 1)

	-- right arrow; should render normally if we´re lower than 4, else
	-- in a shadowy form to let us know we´re as far right as we can go
	if self.currentPaddle ==  4 then
		love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
	end

	love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
		VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
	-- reset drawing color to full white for proper rendering
	love.graphics.setColor(1, 1, 1, 1)

	-- draw the paddle itself, based on which one we have selected
	love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)],
		VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end





