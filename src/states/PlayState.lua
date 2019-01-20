--[[
    BitOrBit v.1.1.5

    -- PlayState Class --

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu
    
    Represents the state of the game in which we are actively playing;
  
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    
    self.level = params.level
    self.lastLevel = params.lastLevel
    self.firstLevel = params.firstLevel
    self.planet = params.planet
    self.probesByLevelMaker = params.probesByLevelMaker
    self.orbitsNeededToWin = params.orbitsNeededToWin
    self.colorZones = params.colorZones

    --launching probes variables
    self.probeLanzar = true
    self.probesOrbiting = {}
    self.launchInterval = 0.5
    self.timeProbes = 0

    --launching probes initial position
    self.probeX = self.planet.gravityRadius * 2/5 
    self.probeY = self.planet.gravityRadius * 2/5

    --launching probes initial speed
    self.probeSpeedInitialMin = 300
    self.probeSpeedInitialMax = 400 

    gameState = 'play'

    gSounds['musicGamePlay']:play()
    gSounds['musicGamePlay']:setLooping(true)

    --camera
    cameraMain:lookAt(0,0)

    --debugging
    self.debug = 'Nothing happening'

end

function PlayState:update(dt)

  --manage pause state
  if self.paused then
      if love.keyboard.wasPressed('space') then
          self.paused = false
          gameState = 'play'
      else
          return
      end
  elseif love.keyboard.wasPressed('space') then
      self.paused = true
      gameState = 'pause'
      return
  end

  --manage exit and instructions
  if love.keyboard.wasPressed('escape') then
      gStateMachine:change('start')
      probeSelected = 0
      probes = {}
      self.probeLanzar = false
  elseif love.keyboard.wasPressed('i') then
      self.instructionsOn = not self.instructionsOn
  end

  --manage probe selecting
  if love.keyboard.wasPressed('p') then  -- rotar en seleccion de probes
    if #probes > 0 then
      gSounds['pop']:play()
      probeSelected = probeSelected + 1
      if probeSelected > #probes then
        probeSelected = 0
      end
      for i, p in ipairs(probes) do
        p.selected = false
      end
      if probeSelected > 0 then
        probes[probeSelected].selected = true
      end
    end
  elseif love.keyboard.wasPressed('x') then --remove probe
    table.remove(probes, probeSelected)
    if probeSelected > 0 then
      gSounds['explosion']:play()
    end
    probeSelected = 0
  elseif love.keyboard.wasPressed('r') then -- reset all probes
    probes = {}
    probeSelected = 0
    gameState  = 'play'
    gSounds['explosion']:play()
  elseif love.keyboard.wasPressed('f') then -- follow probe with camera
    --cameraFollows = not cameraFollows
  end   

  --update probe launching and movement
  self:launchProbes(dt)
  self:checkWin()
  self:probeMechanics(dt)
  self:checkOrbitsDone()
  

  --update ColorZones
  self.colorZones = ColorZones(self.planet, self.probesByLevelMaker, self.orbitsNeededToWin)

end

function PlayState:render()
  cameraMain:draw(
    function()
      self.colorZones:render()
      self.planet:render()
      self:drawTableEntities(probes)
      if probeSelected > 0 then
        self:gravityBeam()
      end
    end
  ) 
  printTitle(self.level, self.debug, self.instructionsOn)

  if gameState == 'pause' then
    love.graphics.setFont(gFonts['big'])
    love.graphics.printf("PAUSE",
      0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, 'center')
  end
end

function PlayState:launchProbes(dt)
  self.probesOrbiting = {}
  if #probes == 0 and self.probeLanzar then --probes es Global en Main
    self.timeProbes = self.timeProbes + dt
    if self.timeProbes > self.launchInterval then
      self:manageLaunchProbes(true, dt, 0)
      self.timeProbes = 0
    end
  elseif #probes > 0 and #probes < self.probesByLevelMaker and self.probeLanzar then
    for i, p in ipairs(probes) do
      self.probesOrbiting[i] = p.number
    end
    self.timeProbes = self.timeProbes + dt
    for i = 1, self.probesByLevelMaker do
      if self.timeProbes > self.launchInterval then
        if utils.tableCount(self.probesOrbiting, i) == 0 then
          self:manageLaunchProbes(false, dt, i)
        end
      end
    end
  end
end

function PlayState:generateProbesInitialPositionDirection(dt)
  local modRad = lume.random(50)
  local uno = {self.probeX, self.probeY, lume.randomchoice({math.rad(300 - modRad), math.rad(270 + modRad)})}
  local dos = {self.probeX, -self.probeY, lume.randomchoice({math.rad(300 + modRad), math.rad(90 - modRad)})}
  local tres = {-self.probeX, self.probeY, lume.randomchoice({math.rad(360 - modRad), math.rad(0 + modRad)})}
  local cuatro = {-self.probeX, -self.probeY, lume.randomchoice({math.rad(100 - modRad), math.rad(90 + modRad)})}

  local probeData = {}
  local probeTry = {}

  local iniciando = true
  
  local countLoop = 0

  repeat
    if iniciando then
      probeData = lume.randomchoice({uno,dos,tres,cuatro})
      probeTry = Probe(probeData[1], probeData[2], utils.randomInt(self.probeSpeedInitialMin, self.probeSpeedInitialMax), probeData[3])
    end
    iniciando = false
    probeTry:moveProbe(dt)
    probeTry:influencedByGravityOf(self.planet)
    probeTry:checkDestroyProbe(self.planet, true)
    if probeTry.dead then
      iniciando = true 
      countLoop = 0     
    end
    countLoop = countLoop + 1
  until countLoop == 10000

  return probeData
end

function PlayState:manageLaunchProbes(first, dt, i)-- maneja la posicion, direccion y velocidad inicial de las probes, first se refiere a si es la primera probe lanzada
-- por ahora esta este metodo para garantizar probes exitosos pero es muy limitado, solo a 4 variables.

  local probeData = self:generateProbesInitialPositionDirection(dt)
  
  local p = #probes + 1
  local probString = "probe" .. tostring(p)
  local probStr = Probe(probeData[1], probeData[2], utils.randomInt(self.probeSpeedInitialMin, self.probeSpeedInitialMax), probeData[3])
  probStr.name = probString
  probStr.popX = probStr.x
  probStr.popY = probStr.y

  
  if first then
    probStr.number = p
    probes[p] = probStr
    self.timeProbes = self.timeProbes + dt
  else 
    probStr.number = i
    table.insert(probes, i, probStr)
    self.timeProbes = 0
  end
  gSounds['bwam']:play()

end

function PlayState:drawTableEntities(table)  -- dibuja planetas y probes
  for i, entity in ipairs(table) do
    entity:render()
  end
end

function PlayState:probeMechanics(dt)
  for i, p in ipairs(probes) do        
      p:influencedByGravityOf(self.planet)
      p:checkDestroyProbe(self.planet, false)
      p:checkLowHigh(self.planet, self.colorZones)
      if p.dead then
        table.remove(probes, i)
      end
      p:update(dt)
  end
end

function PlayState:gravityBeam()
  if gameState == "play" then
    for i, p in ipairs(probes) do
      --for j, pl in ipairs(planetas) do
        if p.selected then
          local anglePlanet =  math.atan2((p.pos.y - self.planet.pos.y), (p.pos.x - self.planet.pos.x))
          local rDistRel = p.r + utils.randomInt(5, 15)
          red, green, blue, alpha = ColorZones.colorToLine(i, 150)
          love.graphics.setColor(red - 50, green - 50, blue + 50, alpha)
          love.graphics.polygon("fill", self.planet.x, self.planet.y, p.x + (math.sin(anglePlanet) * rDistRel), p.y - (math.cos(anglePlanet) * rDistRel), p.x - (math.sin(anglePlanet) * rDistRel), p.y + (math.cos(anglePlanet) * rDistRel))
          love.graphics.arc("fill", p.pos.x, p.pos.y, rDistRel, anglePlanet + math.rad(90), anglePlanet - math.rad(90))
          love.graphics.setColor(0,0,0,255)
          love.graphics.line(self.planet.x, self.planet.y, p.x + (math.sin(anglePlanet) * rDistRel), p.y - (math.cos(anglePlanet) * rDistRel))
          love.graphics.line(self.planet.x, self.planet.y, p.x - (math.sin(anglePlanet) * rDistRel), p.y + (math.cos(anglePlanet) * rDistRel))
          love.graphics.arc("line","open", p.pos.x, p.pos.y, rDistRel, anglePlanet + math.rad(90), anglePlanet - math.rad(90))
          love.graphics.setColor(255,255,255,255)
        end
      --end
    end
  end
end

function PlayState:checkOrbitsDone()  --Chequea si lograste alguna orbita estable, si es asi llena la posición de la tabla de ese nivel con un true, si se desestabiliza la llena con false. (Debería ir en Levels pero no he podido pasarlo exitosamente)
  for i, p in ipairs(probes) do
    if p.intersect then
      self.orbitsNeededToWin[i] = true
    elseif not p.intersect then
      self.orbitsNeededToWin[i] = false
    end
  end
end


function PlayState:checkWin() -- chequea si se lograron todas las orbitas de un nivel. Si se completaron todos los niveles el estado de juego es Win, lo que pone la pantalla a Win en pausa. Si solo se completo un nivel, sube al siguiente nivel y resetea initLevel, resetea orbits needed to win, zonas Color y probes, deselecciona la probe seleccionada. (Debería ir en Levels pero no he podido pasarlo exitosamente)
  if #self.orbitsNeededToWin > 0 then
    if utils.tableCount(self.orbitsNeededToWin, true) == #self.orbitsNeededToWin then
      self.level = self.level + 1
      if self.level <= self.lastLevel then
        self.probesByLevelMaker = LevelMaker.createLevel(self.level)[1]
        --level variables
        self.orbitsNeededToWin = {}
        for i = 1, self.probesByLevelMaker do
          table.insert(self.orbitsNeededToWin, false)
        end
        --orbits area
        self.colorZones = ColorZones(self.planet, self.probesByLevelMaker, self.orbitsNeededToWin)
        
        probes = {}
        probeSelected = 0
        
        gSounds['select']:play()
        
        gStateMachine:change('serve', {
            level = self.level,
            lastLevel = self.lastLevel,
            planet = self.planet,
            probesByLevelMaker = self.probesByLevelMaker,
            orbitsNeededToWin = self.orbitsNeededToWin,
            colorZones = self.colorZones,
            firstLevel = self.firstLevel
        })
      else
        gSounds['select']:play()
      
        gStateMachine:change('win')
      end
    end
  end
end