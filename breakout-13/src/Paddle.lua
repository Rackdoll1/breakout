--[[
    CS50G
    Breakout Remake

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move left and right. Used in the main
    program to deflect the ball toward the bricks; if the ball passes
    the paddle, the player loses one heart. The Paddle can have a skin,
    which the player gets to choose upon starting the game.
]]

Paddle = Class{}

--[[
	Our Paddle will initialize at the same spot every time, in the middle
	of the world horizontally, toward the bottom.
]]
function Paddle:init(skin)
	-- x is placed in the middle (64 is the medium paddle total width)
	self.x = VIRTUAL_WIDTH / 2 - 32

	-- y is placed a litlle above the bottom edge of the screen
	-- 16 is the total height of every paddle
	self.y = VIRTUAL_HEIGHT - 32

	-- start us off with no velocity
	self.dx = 0

	-- starting dimensions
	self.width = 64
	self.height = 16

	-- the skin only has the effect of changing our color, used to offset us
	-- into the gPaddleSkins table later
	self.skin = skin

	-- the variant is which of the four paddle sizes we currently are; 2
	-- is the starting size, as the smallest is too tough to start with
	self.size = 2
end

function Paddle:update(dt)
	-- keyboard input
	if love.keyboard.isDown('left') then
		self.dx = -PADDLE_SPEED
	elseif love.keyboard.isDown('right') then
		self.dx = PADDLE_SPEED
	else
		self.dx = 0
	end

	-- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated X position when pressing left so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dx < 0 then
    	self.x = math.max(0, self.x + self.dx * dt)
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- length (or else it will go partially off-screen, since position is
    -- based on its top left corner)
	else
		self.x = math.min(self.x + self.dx * dt, VIRTUAL_WIDTH - self.width)
	end
end

--[[
	Render the paddle by drawing the main texture, passing in the quad
	that corresponds to the proper skin and size
]]
function Paddle:render()
	love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 *(self.skin - 1)],
		self.x, self.y)
end