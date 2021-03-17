--[[
    CS50G
    Breakout Remake

    -- Brick Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a brick in the world space that the ball can collide with;
    differently colored bricks have different point values. On collision,
    the ball will bounce away depending on the angle of collision. When all
    bricks are cleared in the current map, the player should be taken to a new
    layout of bricks.
]]

Brick = Class{}

-- some of the colors in our palette (to be used with particle systems)
paletteColors = {
	-- blue
	[1] = {
		['r'] = 99,
		['g'] = 155,
		['b'] = 255
	},
	-- green
	[2] = {
		['r'] = 106,
		['g'] = 190,
		['b'] = 47
	},
	-- red
	[3] = {
		['r'] = 217,
		['g'] = 87,
		['b'] = 99
	},
	-- purple
	[4] = {
		['r'] = 215,
		['g'] = 123,
		['b'] = 186
	},
	-- gold
	[5] = {
		['r'] = 251,
		['g'] = 242,
		['b'] = 54
	}
}

function Brick:init(x,y)
	-- used for coloring and score calculation
	self.tier = 0
	self.color = 1

	self.x = x
	self.y = y
	self.width = 32
	self.height = 16

	-- in smaller projects, it is fine to have flags for rendering objects; in larger
	-- games it would be better to despawn or destroy the objects

	-- used to determine whether this brick should be rendered
	self.inPlay = true

	-- particle system belonging to the brick, emitted on hit
	self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

	-- various behaviour-determining functions for the particle system
	--
	-- lasts between 0.5-1 seconds
	self.psystem:setParticleLifetime(0.5, 1)

	-- give it an acceleration of anywhere between X1, Y1 and X2, Y2 (-15, 0) and (15, 80)
	-- with these values it will go generally downwards
	self.psystem:setLinearAcceleration(-15, 0, 15, 80) -- min x,y acceleration; then max x,y acceleration

	-- spread of particles; normal looks more natural than uniform, which is clumpsy; numbers
	-- are amount of standard deviation away in X and Y axis
	self.psystem:setEmissionArea('normal', 10, 10)
end

--[[
    Triggers a hit on the brick, taking it out of play if at 0 health or
    changing its color otherwise.
]]
function Brick:hit()
	-- set the particle system to interpolate between two colors; in this case, we give
	-- it our self.color but with varying alpha; brighter for higher tiers, fading to 0
	-- over the particle´s lifetime (the second color)
	self.psystem:setColors(
		paletteColors[self.color].r / 255,
		paletteColors[self.color].g / 255,
		paletteColors[self.color].b / 255,
		55 * (self.tier + 1) / 255,			-- alpha value
		paletteColors[self.color].r / 255,
		paletteColors[self.color].g / 255,
		paletteColors[self.color].b / 255,
		0
	)
	self.psystem:emit(64)

	-- we first stop any previous sounding brick hit to play the current one
	gSounds['brick-hit-2']:stop()
	gSounds['brick-hit-2']:play()

	-- if we´re at a higher tier than the base, we need to go down a tier if
	-- we´re already at the lowest color, else just go down a color
	if self.tier > 0 then
		if self.color == 1 then
			self.tier = self.tier - 1
			self.color = 5
		else 
			self.color = self.color -1
		end
	else
		-- if we´re in the first tier and base color, remove brick from play
		if self.color == 1 then
			self.inPlay = false
			gSounds['brick-hit-2']:stop()
			gSounds['brick-hit-1']:stop()
			gSounds['brick-hit-1']:play()
		else
			self.color = self.color - 1
		end
	end
end

function Brick:update(dt)
	-- particle system must be updated
	self.psystem:update(dt)
end

function Brick:render()
	if self.inPlay then
		love.graphics.draw(gTextures['main'],
			-- multiply color by 4(-1) to get our color offset, then add tier to that
			-- to draw the correct tier and color brick on screen
			gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
			self.x, self.y)
	end
end

--[[
    Need a separate render function for our particles so it can be called after all bricks are drawn;
    otherwise, some bricks would render over other bricks' particle systems.
]]
function Brick:renderParticles()
	love.graphics.draw(self.psystem, self.x + self.width / 2, self.y + self.height / 2)
end
