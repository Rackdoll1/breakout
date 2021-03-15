--[[
    CS50G
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- initialize ball with random skin
    self.ball = Ball(math.random(7))
    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
    -- give ball position in the center
    self.ball.x = VIRTUAL_WIDTH / 2 - 4
    self.ball.y = VIRTUAL_HEIGHT / 2 - 4

    self.paddle = Paddle()
    self.paused = false

    -- use the "static" createMap function to generate a bricks table
    self.bricks = LevelMaker.createMap()
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)

    -- ball collision detection with paddle
    if self.ball:collides(self.paddle) then
        -- reverse dy
        self.ball.dy = -self.ball.dy

        if self.ball.y + self.ball.height > self.paddle.y then

            if self.ball.x + self.ball.width <= self.paddle.x + self.ball.width then
                self.ball.dx = -self.ball.dx
                self.ball.x = self.paddle.x - self.ball.width - 2
            elseif self.ball.x >= self.paddle.x + self.paddle.width - self.ball.width then
                self.ball.dx = -self.ball.dx
                self.ball.x = self.paddle.x + self.paddle.width + 2
            end
        end

        -- tweak angle of bounce based on where it hits the paddle
        --
        -- if we hit the paddle on its left side while moveing left...
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = 50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        --else if we hit the paddle on its right side while moving right...
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 -self.ball.x))
        end

        gSounds['paddle-hit']:play()
        
    end

    -- ball collision detection across all bricks in the scene
    for k, brick in pairs(self.bricks) do
        -- only check collision if we´re in play 
        if brick.inPlay and self.ball:collides(brick) then
            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- collision code for bricks
            --
            -- we check to see if the opposite side of our ball is OUTSIDE of the brick;
            -- if its is, we trigger a collision on that side. Else we´re within the X + width of 
            -- the brick and should check to see if the top or bottom edge is outside the brick,
            -- colliding on the top or bottom accordingly.
            -- X position will be given priority when the ball collides with a brick at an angle
            -- 
            -- left edge; only check if we´re moving right
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            -- right edge; only check if we are moving left
            elseif self.ball.x + self.ball.width - 2 > brick.x + brick.width and self.ball.dx < 0 then
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            -- top edge if no X collisions, always check
            elseif self.ball.y < brick.y then
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            -- bottom edge if no X or top collisions, last possibility
            else
                -- flip velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end 

            -- slightly scale the y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02

            -- only allow colliding with one brick, for corners
            break
        end
    end


    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    self.paddle:render()

    self.ball:render()

    -- pause text, if paused
    if  self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('Ball dy: '..tostring(self.ball.dy), 5, 15)
    love.graphics.print('Ball dx: '..tostring(self.ball.dx), 5, 25)
end