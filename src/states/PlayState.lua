--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu
    
    -- PlayState Class --

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
  end   

  --update probe launching and movement
  self:launchProbes(dt)
  self:checkWin()
  self:probeMechanics(dt)
  self:checkOrbitsDone()
  

  --update ColorZones for alpha change purposes
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

--[[ launchProbes:
  -Se encarga de lanzar las probes usando la funcion manageLaunchProbes en intervalos de tiempo X
  -Por cada probe lanzada se anade su numero id a la tabla probesOrbiting
  -Si por alguna razon cualquier probe deja de existir, se lanza de nuevo la misma probe pasado el tiempo X
]]--
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

--[[ manageLaunchProbes:
  -Establece la posicion, direccion y velocidad inicial de las probes, al azar, 
    segun un numero de posibilidades predeterminadas (4 opciones que no resultaron tan buenas) ARREGLAR, 
    se puede hacer en Enter muchas mas opciones una vez y en esta funcion solo se hace el randomchoice.  
  -El parametro first se refiere a si es la primera probe lanzada.
  -Establece las posibilidades para x, y y direccion
  -Selecciona una al azar
  -Le coloca un nombre ??
  -Crea una probe con esos datos al azar y con la velocidad tambien seleccionada entre dos limites.
  -Establece la posicion pop, para los circulos concentricos
  -La primera probe entra sola, las demas usando el parametro i
]]--
function PlayState:manageLaunchProbes(first, dt, i)
  local modRad = lume.random(50)
  local uno = {self.probeX, self.probeY, lume.randomchoice({math.rad(300 - modRad), math.rad(270 + modRad)})}
  local dos = {self.probeX, -self.probeY, lume.randomchoice({math.rad(300 + modRad), math.rad(90 - modRad)})}
  local tres = {-self.probeX, self.probeY, lume.randomchoice({math.rad(360 - modRad), math.rad(0 + modRad)})}
  local cuatro = {-self.probeX, -self.probeY, lume.randomchoice({math.rad(100 - modRad), math.rad(90 + modRad)})}
  local probeData = lume.randomchoice({uno,dos,tres,cuatro})

  gSounds['bwam']:play()
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

end

--[[ drawTableEntities:
  Para rendear todas las entidades que hay en una tabla (probes, por ejemplo)
]]--
function PlayState:drawTableEntities(table)
  for i, entity in ipairs(table) do
    entity:render()
  end
end

--[[ probeMechanics:
  -For loop entre todas las probes de la tabla y usa las funciones de:
    -influencedByGravityOf, para que se vean afectadas por la gravedad de un planeta
    -checkDestroyProbe, para ver si pasaron los limites interno y externo y destruir la probe
    -checkLowHigh, para establecer el punto alto y bajo de su orbita
    -Revisa si la probe esta muerta para eliminarla de la lista
    -Finalmente ejecuta el update de la probe
]]--
function PlayState:probeMechanics(dt)
  for i, p in ipairs(probes) do        
      p:influencedByGravityOf(self.planet)
      p:checkDestroyProbe(self.planet)
      p:checkLowHigh(self.planet, self.colorZones)
      if p.dead then
        table.remove(probes, i)
      end
      p:update(dt)
  end
end

--[[ gravityBeam:
  -Si estamos en modo play hacemos un for loop por todas las probes para ver si alguna esta seleccionada. ARREGLAR,
    se puede buscar si una esta seleccionada en la tabla y usar solo esa, no hacer el for loop cada frame
  -Dibuja el gravity beam sobre la probe seleccionada
]]--
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

--[[ checkOrbitsDone
  -For loop sobre las probes para ver si hay orbitas estables 
  -Si hay orbita estable se coloca un true en la misma posicion de la probe en la tabla orbitsNeededToWin, 
    creada segun el numero de probes de este nivel.
  -Se usa la propiedad intersect de la probe, que es cuando ha pasado 2 veces por el mismo punto de la orbita
    sin salirse de la misma
  -Si la probe se sale de la orbita, se llena esta posicion con false.
]]
function PlayState:checkOrbitsDone()  
  for i, p in ipairs(probes) do
    if p.intersect then
      self.orbitsNeededToWin[i] = true
    elseif not p.intersect then
      self.orbitsNeededToWin[i] = false
    end
  end
end

--[[ checkWin:
  -Chequea si se lograron todas las orbitas de un nivel. 
  -Chequea si se completaron todos los niveles del juego.
  - Si solo se completo un nivel, sube al siguiente nivel y resetean 
    initLevel, orbitsNeededToWin, zonasColor y probes, y deselecciona la probe seleccionada.
]]
function PlayState:checkWin() 
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