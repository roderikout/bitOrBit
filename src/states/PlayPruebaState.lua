--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu
    
    -- PlayState Class --

    Represents the state of the game in which we are actively playing;
  --]]


PlayPruebaState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayPruebaState:enter(params)
    
    self.probesByLevelMaker = 1
    self.planet = Planet(0, 0, 20, 300000, 340, self.probesByLevelMaker)

    --launching probes initial position
    self.probeX = self.planet.gravityRadius * 2/5 
    self.probeY = self.planet.gravityRadius * 2/5
    --launching probes initial speed
    self.probeSpeedInitialMin = 300
    self.probeSpeedInitialMax = 400 

    --launching probes variables
    self.probeLanzar = true
    self.probesOrbiting = {}
    self.launchInterval = 0.5
    self.timeProbes = 0

    self.predictionNumber = 100

    --camera
    cameraMain:lookAt(0,0)

    self.debug = "Nada"
    gameState = "play"
    self.paused = false

end

function PlayPruebaState:update(dt)

  --manage pause state
  if self.paused then
      if love.keyboard.wasPressed('space') then
          self.paused = false
          gameState = "play"
      else
          return
      end
  elseif love.keyboard.wasPressed('space') then
      self.paused = true
      gameState = "pause"
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
    gameState  = "play"
    gSounds['explosion']:play()
  end   

  self:launchProbes(dt)
  self:probeMechanics(dt)

end

function PlayPruebaState:render()
  cameraMain:draw(
    function()
     self:drawTableEntities(probes)
      self.planet:render()
      if probeSelected > 0 then
        self:gravityBeam()
        self.debug = "Al menos una probe seleccionada"
      else
        self.debug = "Nada"
      end
    end
  )

  printTitle( 1, self.debug, false)

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
function PlayPruebaState:launchProbes(dt)
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
function PlayPruebaState:manageLaunchProbes(first, dt, i)
  local modRad = lume.random(50)
  local uno = {self.probeX, self.probeY, lume.randomchoice({math.rad(100 - modRad), math.rad(270 + modRad)})}
  local dos = {self.probeX, -self.probeY, lume.randomchoice({math.rad(100 + modRad), math.rad(90 - modRad)})}
  local tres = {-self.probeX, self.probeY, lume.randomchoice({math.rad(150 - modRad), math.rad(0 + modRad)})}
  local cuatro = {-self.probeX, -self.probeY, lume.randomchoice({math.rad(100 - modRad), math.rad(90 + modRad)})}
  local probeData = lume.randomchoice({uno,dos,tres,cuatro})

  gSounds['bwam']:play()
  local p = #probes + 1
  local probString = "probe" .. tostring(p)
  local probStr = Probe(probeData[1], probeData[2], utils.randomInt(self.probeSpeedInitialMin, self.probeSpeedInitialMax), probeData[3])
  probStr.name = probString
  probStr.popX = probStr.x
  probStr.popY = probStr.y
  probStr.needPop = true

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
function PlayPruebaState:drawTableEntities(table, dt)
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
function PlayPruebaState:probeMechanics(dt)
  for i, p in ipairs(probes) do        
      GravitySystem.influencedByGravityOf(p, self.planet)
      GravitySystem.predictedPosition(p, self.planet, self.predictionNumber, dt)
      GravitySystem.checkDestroyElement(p, self.planet)
      
      --p:checkLowHigh(self.planet, self.planet.colorZones)
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
function PlayPruebaState:gravityBeam()
  if gameState == "play" then
    for i, p in ipairs(probes) do
      if p.selected then
        local anglePlanet =  math.atan2((p.pos.y - self.planet.pos.y), (p.pos.x - self.planet.pos.x))
        local rDistRel = p.r + utils.randomInt(5, 15)
        red, green, blue, alpha = utils.numberToColor(i, 150)
        love.graphics.setColor(red - 50, green - 50, blue + 50, alpha)
        love.graphics.polygon("fill", self.planet.x, self.planet.y, p.x + (math.sin(anglePlanet) * rDistRel), p.y - (math.cos(anglePlanet) * rDistRel), p.x - (math.sin(anglePlanet) * rDistRel), p.y + (math.cos(anglePlanet) * rDistRel))
        love.graphics.arc("fill", p.pos.x, p.pos.y, rDistRel, anglePlanet + math.rad(90), anglePlanet - math.rad(90))
        love.graphics.setColor(0,0,0,255)
        love.graphics.line(self.planet.x, self.planet.y, p.x + (math.sin(anglePlanet) * rDistRel), p.y - (math.cos(anglePlanet) * rDistRel))
        love.graphics.line(self.planet.x, self.planet.y, p.x - (math.sin(anglePlanet) * rDistRel), p.y + (math.cos(anglePlanet) * rDistRel))
        love.graphics.arc("line","open", p.pos.x, p.pos.y, rDistRel, anglePlanet + math.rad(90), anglePlanet - math.rad(90))
        love.graphics.setColor(255,255,255,255)
      end
    end
  end
end