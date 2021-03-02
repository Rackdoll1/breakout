--[[
	CS50G
    Breakout Remake

	breakout-0
	"The Day-0 Update"

	*BASED ON  CS50Gs Introduction to Game Development course given by:

	Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally developed by Atari in 1976. An effective evolution of
    Pong, Breakout ditched the two-player mechanic in favor of a single-
    player game where the player, still controlling a paddle, was tasked
    with eliminating a screen full of differently placed bricks of varying
    values by deflecting a ball back at them.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.

    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch
	
	Background:
    Author: PixelChoice | Credit: Getty Images/iStockphoto

    Credit for music (great loop):
    http://freesound.org/people/joshuaempyre/sounds/251461/
    http://www.soundcloud.com/empyreanma

    Music from Zapsplat.com
]]--

require 'src/Dependencies'

--[[
	Called just once at the beginning of the game; used to set up
	game objects, variables, etc. and prepare the game world.
]]

function love.load()
	-- set love´s default filter to "nearest-neighbor", which basucally
	-- means there will be no filtering of pixels (blurriness), which is
	-- important for a nice crisp 2D look
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- seed de RNG so OS time, so calls to random are always random
	math.randomseed(os.time())

	-- set the application tittle bar
	love.window.setTitle('Breakout')

	-- initialize retro-looking text fonts
	gFonts = {
		['small'] = love.graphics.newFont('fonts/font.ttf', 8),
		['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
		['large'] = love.graphics.newFont('fonts/font.ttf', 32)
	}

	love.graphics.setFont(gFonts['small'])

	-- load up the graphics we´ll be using  throughout our states
	gTextures = {
		['background'] = love.graphics.newImage('graphics/background.png'),
		['main'] = love.graphics.newImage('graphics/breakout.png'),
		['arrows'] = love.graphics.newImage('graphics/arrows.png'),
		['hearts'] = love.graphics.newImage('graphics/hearts.png'),
		['particle'] = love.graphics.newImage('graphics/particle.png')
	}

	-- initialize our virtual resolution which will be rendered within our
	-- actual window no matter its dimensions
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true
	})

	-- set up our sounds effects; later, we can just index this table
	-- and call each entry´s play method
	gSounds = {
		['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
		['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
		['select'] = love.audio.newSource('sounds/select.wav', 'static'),
		['no-select'] = love.audio.newSource('sounds/no_select.wav', 'static'),
		['brick-hit-1'] = love.audio.newSource('sounds/brick_hit1.wav', 'static'),
		['brick-hit-2'] = love.audio.newSource('sounds/brick_hit2.wav', 'static'),
		['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
		['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
		['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
		['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
		['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

		['music'] = love.audio.newSource('sounds/music.wav', 'static'),

	}

	-- our current game state can be any of the following:
	-- 1. 'start' (the beginning of the game, where we´re told to press Enter)
	-- 2. 'paddle-select' (where we can choose the color of the paddle)
	-- 3. 'serve' (waiting on a key press to serve the ball)
	-- 4. 'play' (the ball in motion, bouncing) between paddle, blocks and walls)
	-- 5. 'vicroty' (the current level is over, with a victory jingle)
	-- 6. 'game-over' (the player has lost; display score and allow restart)
	gStateMachine = StateMachine {
		['start'] = function() return StartState() end
	}
	gStateMachine:change('start')

	-- a table we´ll use to keep track of which keys have been pressed this
	-- frame, to get around the fact that Love´s default callback won´t let us
	-- test for input from within other functions
	love.keyboard.keysPressed = {}

end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
	push:resize(w.h)
end

--[[
    Called every frame, passing in `dt` (deltaTime) since the last frame. 
    Multiplying this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]
function love.update(dt)
	gStateMachine:update(dt)

	-- reset keys pressed
	love.keyboard.keysPressed = {}
end


--[[
    A callback that processes key strokes as they happen, just once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
	-- add the key that was pressed this frame to our table of keys pressed
	love.keyboard.keysPressed[key] = true
end

--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
	if love.keyboard.keysPressed[key] then
		return true
	else
		return false
	end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
	-- begin drawing with push, in our virtual resolution
	push:apply('start')

	-- background should be drawn regardless of state, scaled to fit our
	-- virtual resolution
	local backgroundWidth = gTextures['background']:getWidth()
	local backgroundHeight = gTextures['background']:getHeight()

	love.graphics.draw(gTextures['background'],
		-- draw at coordinates 0,0
		0, 0,
		-- no rotation
		0,
		-- scale on X and Y axis so it fills the screen
		VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

	-- use the state machine to defer rendering to the current state we´re in
	gStateMachine:render()

	-- display FPS for debugging; to remove it simply comment it out
	displayFPS()

	push:apply('end')
end

--[[
	Render the current FPS
]]--
function displayFPS()
	-- simple FPS display across all states
	love.graphics.setFont(gFonts['small'])
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('FPS: '..tostring(love.timer.getFPS()), 5, 5)
end



