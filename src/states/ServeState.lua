--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu

    -- LaunchState Class --

    The state in which we are waiting to serve the probes. Hit space
    to begin
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    self.levelText = params.levelText
    self.level = params.level
    self.lastLevel = params.lastLevel
    self.planet = params.planet
    self.probesByLevelMaker = params.probesByLevelMaker
    self.orbitsNeededToWin = params.orbitsNeededToWin
    self.firstLevel = params.firstLevel
  
    self.colorZones = self.planet.zonasColor
    --camera
    cameraMain:lookAt(0,0)

    --other flags
    self.instructionsOn = false
    
    gSounds['launch']:play()

    --debugging
    self.debug = "Nothing happnning"
end

function ServeState:update(dt)

    if love.keyboard.wasPressed('space') then
      -- pass in all important state info to the PlayState
      gSounds['select']:play()
      self.firstLevel = false
      gStateMachine:change('play', {
          level = self.level,
          lastLevel = self.lastLevel,
          planet = self.planet,
          probesByLevelMaker = self.probesByLevelMaker,
          orbitsNeededToWin = self.orbitsNeededToWin,
          firstLevel = self.firstLevel 
      })
    elseif love.keyboard.wasPressed('escape') then
      gStateMachine:change('start')
    elseif love.keyboard.wasPressed('i') then
      self.instructionsOn = not self.instructionsOn
    end
end

function ServeState:render()
  cameraMain:draw(
     function()
        self.planet:render()
    end
  ) 
  printTitle(self.level, self.debug, self.instructionsOn)

  love.graphics.setFont(gFonts['big'])
  love.graphics.printf("Level " .. tostring(self.level),
    0, WINDOW_HEIGHT / 3, WINDOW_WIDTH, 'center')

  -- instructions text
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Press Space to launch probes!', 0, WINDOW_HEIGHT / 2,
      WINDOW_WIDTH, 'center')
end 