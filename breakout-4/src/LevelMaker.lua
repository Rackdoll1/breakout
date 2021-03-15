--[[
    CS50G
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]

function LevelMaker.createMap(level)
	local bricks = {}

	-- randomly choose the number of rows
	local numRows = math.random(1,5)

	-- randomly choose the number of columns
	local numCols = math.random(7,13)

	-- lay out bricks such that they touch each other and fill the space
	for y = 1, numRows do
		for x = 1, numCols do
			-- initialize brick at these coordinates
			b = Brick(
				-- x coordinate
				(x - 1)					-- because tables are 1-indexed, we decrement it for initial brick
				* 32					-- the width of each brick
				+ 8						-- the initial left padding for every level, leaving 13 columns maximum with 8 pixels padding at each side
				+ (13 - numCols) * 16,	-- additional left padding for when there are fewer than 13 columns,
										-- and making the rest of the bricks centered

				-- y coordinate
				y * 16					-- we need top padding so we start from y = 1
			)

			table.insert(bricks, b)
		end
	end

	return bricks
end