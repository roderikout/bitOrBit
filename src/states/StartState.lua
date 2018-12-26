--[[
    GD50
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
    gSounds['musicIntro']:play()
    gSounds['musicIntro']:setLooping(true)
end

function StartState:update(dt)
    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('i') then
        gSounds['select']:play()
        self.instructionsOn = not self.instructionsOn
    end

    -- confirm whichever option we have selected to change screens
    if love.keyboard.wasPressed('space') then
        gSounds['select']:play()
        gStateMachine:change('serve', {
            health = 3,
            --score = 0,
            level = 1
        })
    end

    -- we no longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

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
    self:drawStartLogo()
    self:drawStartText()
end

function StartState:drawStartLogo()
    for y=1, #self.map do
        for x=1, #self.map[y] do
            if self.map[y][x] == 1 then
                love.graphics.rectangle("fill", x * 37, y * 37
                    , 30 + self.a, 30 + self.a)
            end
        end
    end
end

function StartState:drawStartText()
    
    if not self.instructionsOn then
        love.graphics.setFont(gFonts['medium'])
        local fontHeight = gFonts['medium']:getHeight()
        love.graphics.print("Press \"Space\" to start", width/2 - self.a, height/2)
        love.graphics.print("Press \"i\" to read the instructions", width/2 - self.a, height/2 + fontHeight)
    else
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("-Try to take each probe to the orbit of the correct color using only the thrusters to accelerate or decelerate it\n\n\nKeys:\n\n-Press 'Space' to launch the probes\n\n-Use up and down arrows to accelerate or decelerate the probe\n\n-Press 'P' to select and cicle between the probes\n\n-Press 'X' when a probe is selected to destroy it and create a new one\n\n-Press 'R' to reset all the probes\n\n-Use 'A' and 'Z' to zoom in and out\n\n-Press 'F' to follow the selected probe\n\n-Press 'Escape' to exit the game\n\n-Press 'Space' to start the game\n\n-Press 'H' to pause the game\n\n-Press 'I' to exit the instructions", width/2, 60, 600, 'left')
    end
end