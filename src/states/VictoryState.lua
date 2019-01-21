--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu

    -- VictoryState Class --

    Represents the state that the game is in when we've just completed a level.
    Very similar to the ServeState, except here we increment the level.
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.lastLevel = params.lastLevel
    self.planet = params.planet
    self.probesByLevelMaker = params.probesByLevelMaker
    self.orbitsNeededToWin = params.orbitsNeededToWin
    self.colorZones = params.colorZones
end

function VictoryState:update(dt)
    
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['select']:play()
        gStateMachine:change('serve', {
            level = self.level,
            lastLevel = self.lastLevel,
            planet = self.planet,
            probesByLevelMaker = self.probesByLevelMaker,
            orbitsNeededToWin = self.orbitsNeededToWin,
            colorZones = self.colorZones
        })
    elseif love.keyboard.wasPressed('escape') then -- we no longer have this globally, so include here
        gStateMachine:change('start')
    end
end

function VictoryState:render()
    
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, WINDOW_HEIGHT / 4, WINDOW_WIDTH, 'center')

    -- instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, WINDOW_HEIGHT / 2,
        WINDOW_WIDTH, 'center')
end