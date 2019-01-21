--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu

    -- WinState Class --

    The state in which we've lost all of our health and get our score displayed to us. Should
    transition to the EnterHighScore state if we exceeded one of our stored high scores, else back
    to the StartState
]]

WinState = Class{__includes = BaseState}

function WinState:enter(params)
    
end

function WinState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['select']:play()
        gStateMachine:change('start')
    elseif love.keyboard.wasPressed('escape') then -- we no longer have this globally, so include here
        gStateMachine:change('start')
    end
end

function WinState:render()
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf('WIN', 0, WINDOW_HEIGHT / 3, WINDOW_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter!', 0, WINDOW_HEIGHT - WINDOW_HEIGHT / 2,
        WINDOW_WIDTH, 'center')
end