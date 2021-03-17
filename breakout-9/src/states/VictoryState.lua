--[[
    CS50G
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state that the game is in when we've just completed a level.
    Very similar to the ServeState, except here we increment the level 
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
	self.level = params.level
	self.paddle = params.paddle
    self.health = params.health
    self.score = params.score
    self.ball = params.ball
end

function VictoryState:update(dt)
	self.paddle:update(dt)

	-- have the ball track the player
	self.ball.x = self.paddle.x + (self.paddle.width / 2) - (self.ball.width / 2)
    self.ball.y = self.paddle.y - self.ball.height

    -- go to play screen if player presses Enter
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    	gStateMachine:change('serve', {
				level = self.level + 1,
				paddle = self.paddle,
				bricks = LevelMaker.createMap(self.level + 1),
				health = self.health,
				score = self.score
			})
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
end

function VictoryState:render()
	self.paddle:render()
	self.ball:render()

	renderHealth(self.health)
	renderScore(self.score)

	-- level complete text
	love.graphics.setFont(gFonts['large'])
	love.graphics.printf("Level "..tostring(self.level).." complete!",
		0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

	-- instruction text
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf("Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2,
		VIRTUAL_WIDTH, 'center')
end


