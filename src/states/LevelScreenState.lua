--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu

    -- LaunchState Class --

    The state in which we are waiting to serve the probes. Hit space
    to begin
]]

LevelScreenState = Class{__includes = BaseState}

function LevelScreenState:enter(params)
    self.level = params.level
    self.firstLevel = params.firstLevel

     --levelInit
    self.lastLevel = TOTAL_LEVELS
    self.probesByLevelMaker = LevelMaker.createLevel(self.level)[1]
    self.planet = Planet(0, 0, 20, 300000, 340, self.probesByLevelMaker)
    self.orbitsNeededToWin = {}
    for i = 1, self.probesByLevelMaker do
      table.insert(self.orbitsNeededToWin, false)
    end
  
    --camera
    cameraMain:lookAt(0,0)

    --other flags
    gSounds['launch']:play()

end

function LevelScreenState:update(dt)

    if love.keyboard.wasPressed('space') then
      -- pass in all important state info to the PlayState
      gSounds['select']:play()
      gStateMachine:change('serve', {
          level = self.level,
          lastLevel = self.lastLevel,
          planet = self.planet,
          probesByLevelMaker = self.probesByLevelMaker,
          orbitsNeededToWin = self.orbitsNeededToWin,
          firstLevel = self.firstLevel 
      })
    elseif love.keyboard.wasPressed('escape') then
      gStateMachine:change('start')
    end
end

function LevelScreenState:render()

  if not self.firstLevel then
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf("Level " .. tostring(self.level - 1) .. " complete!",
      0, WINDOW_HEIGHT / 3, WINDOW_WIDTH, 'center')
  end

  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Press Space to start!', 0, WINDOW_HEIGHT / 2,
      WINDOW_WIDTH, 'center')
end 