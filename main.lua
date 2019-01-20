--[[Rehaciendo el main para adaptarlo a nuevos
aprendizajes, todavia no se muy bien como lo 
voy a hacer...
]]--

require 'src/Dependencies'

function love.load()

	-- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --camaras
	--cameraMain:zoom(0.58)

	--Seed the RNG
	math.randomseed(os.time())

	--shuffle de RNG
	for i=1, math.random(10) do
		math.random()
	end

	--load fonts
	gFonts = {

	['big'] = love.graphics.setNewFont(50),
	['medium'] = love.graphics.setNewFont(30),
	['small'] = love.graphics.setNewFont(20)

	}

	--[[ initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })]]

	--load sounds
	gSounds = {

	['musicGamePlay'] = love.audio.newSource("sounds/orbitSong3.ogg", "static"),
	['musicIntro'] = love.audio.newSource("sounds/orbitSong2.ogg", "static"),
	['bwam'] = love.audio.newSource("sounds/Bwam2.ogg"),
	['pop'] = love.audio.newSource("sounds/Pop3.ogg"),
	['explosion'] = love.audio.newSource("sounds/Xplode2.ogg"),
	['trust'] = love.audio.newSource("sounds/Trust2.ogg"),
	['select'] = love.audio.newSource("sounds/select.wav")
 
	}

	--generate State Machine

	gStateMachine = StateMachine {

	['start'] = function() return StartState() end,
	['play'] = function() return PlayState() end,
	['serve'] = function() return ServeState() end,
	['game-over'] = function() return GameOverState() end,
	['victory'] = function() return VictoryState() end,
	['win'] = function() return WinState() end

	}

	gStateMachine:change('start')

	-- a table we'll use to keep track of which keys have been pressed this
    -- frame, to get around the fact that LÖVE's default callback won't let us
    -- test for input from within other functions
	love.keyboard.keysPressed = {}

	--Global Variables
	gameState = 'start'
  	probes = {}
  	probeSelected = 0
  
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
function love.resize(w, h)
    push:resize(w, h)
end

]]

function love.update(dt)
	gStateMachine:update(dt)

	-- reset keys pressed
	love.keyboard.keysPressed = {}

end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
	--add to our table of keys pressed this frame
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


function love.draw()

	gStateMachine:render()

end