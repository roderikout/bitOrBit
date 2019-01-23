--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu

    -- StartState Class --

    Represents the state the game is in when we've just started; should
    simply display Bit Or Bit
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
StartState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"

function StartState:init()
    self.map = {
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 1, 1, 1, 2, 0, 1, 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 1, 1, 1, 2, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 1, 1, 1, 1, 0, 1, 1, 1, 2, 0, 0 },
        { 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0 },
        { 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0 },
        { 0, 1, 0, 0, 1, 0, 1, 1, 1, 2, 0, 0 },
        { 0, 1, 1, 1, 1, 0, 1, 1, 3, 1, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        { 0, 1, 1, 1, 2, 0, 1, 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 1, 1, 1, 2, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0 },
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    }

    --logo movement flags
    self.a = 1
    self.b = "up"

    --other flags
    self.instructionsOn = false

    --music
    gSounds['musicIntro']:stop()
    gSounds['musicGamePlay']:stop()
    gSounds['musicIntro']:play()
    gSounds['musicIntro']:setLooping(true)

    --levelInit
    self.levelInit = INITIAL_LEVEL
    self.lastLevel = TOTAL_LEVELS
    self.planet = Planet(0, 0, 20, 300000, 380)
    self.probesByLevelMaker = LevelMaker.createLevel(self.levelInit)[1]
    self.orbitsNeededToWin = {}
    for i = 1, self.probesByLevelMaker do
      table.insert(self.orbitsNeededToWin, false)
    end
    self.colorZones = ColorZones(self.planet, self.probesByLevelMaker, self.orbitsNeededToWin)
    self.firstLevel = true

    --camera
    cameraMain:lookAt(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
    --cameraMain:zoom(2)
end

function StartState:update(dt)

    if love.keyboard.wasPressed('i') then
        gSounds['select']:play()
        self.instructionsOn = not self.instructionsOn
    elseif love.keyboard.wasPressed('space') then 
        gSounds['select']:play()
        gStateMachine:change('serve', {
            levelText = 'Launching probes',
            level = self.levelInit,
            lastLevel = self.lastLevel,
            planet = self.planet,
            probesByLevelMaker = self.probesByLevelMaker,
            orbitsNeededToWin = self.orbitsNeededToWin,
            colorZones = self.colorZones,
            firstLevel = self.firstLevel
        })
    elseif love.keyboard.wasPressed('escape') then -- we no longer have this globally, so include here
        love.event.quit()
    end

    -- para hacer crecer y decrecer las letras de BitOrBit
    if self.b =="up" then
        self.a = self.a + (10 * dt)
        if self.a > 7 then
            self.b = "down"
        end
    elseif self.b == "down" then
        self.a = self.a - (10 * dt)
        if self.a < 1 then
            self.b = "up"
        end
    end

end

function StartState:render()
    cameraMain:draw(
        function()
            self:drawStartLogo()
            self:drawStartText()
        end
    )
end

function StartState:drawStartLogo()
    --parsea la tabla map, si es 1 dibuja un cuadro, si es 0 no
    for y=1, #self.map do
        for x=1, #self.map[y] do
            if self.map[y][x] == 1 then
                love.graphics.rectangle("fill", x * 37, y * 37
                    , 30 + self.a, 30 + self.a)
            end
        end
    end
end

function StartState:drawStartText()  --tratar de tomar los textos del archivo textos
    
    if not self.instructionsOn then
        love.graphics.setFont(gFonts['medium'])
        local fontHeight = gFonts['medium']:getHeight()
        love.graphics.print("Press \"Space\" to start", width/2 - self.a, height/2)
        love.graphics.print("Press \"i\" to read the instructions", width/2 - self.a, height/2 + fontHeight)
    else
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("-Try to take each probe to the orbit of the correct color using only the thrusters to accelerate or decelerate it\n\n\nKeys:\n\n-Press 'Space' to start the game / launch the probes / pause the game\n\n-Press up or down arrows to accelerate or decelerate the probe\n\n-Press 'P' to select and cicle between the probes\n\n-Press 'X' when a probe is selected to destroy it and create a new one\n\n-Press 'R' to reset all the probes\n\n-Press 'Escape' to exit the game\n\n-Press 'I' to enter / exit the instructions", width/2, 60, 600, 'left')
            --Use 'A' and 'Z' to zoom in and out\n\n
            --Press 'F' to follow the selected probe\n\n
    end
end