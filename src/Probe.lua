--[[ 

  BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    -- Probes Class --

  Para generar y manejar las probes

]]--


Probe = Class{}

function Probe:init(x, y, speed, direction)

	--Basic position and movement data
	self.x = x
	self.y = y
	self.r = 10
	self.pos= vector(self.x, self.y)
  self.prevPos = vector(0,0)
  self.postPos = vector(0,0)
  self.speed = speed
  self.direction = direction
  self.sp = vector.fromPolar(self.direction, self.speed)
	self.gravityAngle = 0
	self.alpha = 255
 	self.vectorDirection = {x =0, y = 0}
 	self.distanceToPlanet = 0
 	self.name = "none"
  self.number = 0

  --movement
  self.selected = false
  self.up = false
  self.down = false
  self.probeThrustPower = 100
  self.modDT = 0.6

  --checking orbits
  local intersection = false
  local vectorPlanet = {0,0}
  local zonaMin = 0
  local zonaMax = 0
  local distancia = 0
  local angle = 0

  self.probeMinMax = {}
  self.probeInOrbitLine = {}
  self.pIn = {0,0}
  self.pMin = {0,0}
  self.pMax = {0,0}
  self.intersect = false
  self.laps = 0
  self.firstIntersection = false
  self.inMyOrbit = false


 	--Pop circle waves
	self.popX = 0
	self.popY = 0
	self.radCirc = 10
	self.alphaCirc = 80
	self.lineaCircles = 3

 	--stela
 	self.probeStela = {}
 	self.stelaMax = 40

end

function Probe:render() --renderiza todo

  if gameState == "play" then
    if self.up then
      self:drawThrust("up")
    elseif self.down then
      self:drawThrust("down")
    end
  end

  self:probeDraw()

  self:popCirclesDraw()

  self:stelaDraw()

end

function Probe:probeDraw() --dibuja las probes, un circulo sobre otro para simular el borde
	love.graphics.setColor(ColorZones.colorToLine(self.number, self.alpha)) 
  love.graphics.circle("fill", self.x, self.y, self.r)
  love.graphics.setColor(0,0,0,255)
  love.graphics.circle("line", self.x, self.y, self.r)
  love.graphics.setColor(255,255,255,255)
end

function Probe:popCirclesDraw()  --dibujas los circulos al aparecer las probes
  love.graphics.setLineWidth(self.lineaCircles)
  love.graphics.setColor(250, 250, 250, self.alphaCirc)
  love.graphics.circle("line", self.popX, self.popY, self.radCirc)
  love.graphics.setColor(250, 250, 250, self.alphaCirc - 5)
  love.graphics.circle("line", self.popX, self.popY, self.radCirc - 20)
  love.graphics.setColor(250, 250, 250, self.alphaCirc - 10)
  love.graphics.circle("line", self.popX, self.popY, self.radCirc - 40)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setLineWidth(1)
end

function Probe:stelaDraw() --dibuja la estela que deja la probe al moverse
	for i, p in ipairs(self.probeStela) do
   	love.graphics.setColor(ColorZones.colorToLine(self.number, self.alpha/10 * (#self.probeStela - i * 1.8) / #self.probeStela))
   	love.graphics.circle('fill', p.x, p.y, self.r / (1 + (i * 0.02)))    
  end
end

function Probe:update(dt) --update de todas las funciones necesarias de las probes

	self:movementBySpeed(dt)

  if self.selected then
    if love.keyboard.isDown("up") then
      self.up = true
      gSounds['trust']:play()
    elseif love.keyboard.isDown("down") then
      self.down = true
      gSounds['trust']:play()
    else
      self.up = false
      self.down = false
      gSounds['trust']:stop()
    end
  end

  self:keyboardMove(dt)
end

function Probe:movementBySpeed(dt) --Movimiento de la probe solo dependiente de velocidad, no de aceleracion

  self.prevPos = self.pos

  self:popCirclesUpdate(dt)

  self:stelaUpdate()

  self.pos = self.pos + self.sp * (dt * self.modDT) --dt modificado para que vaya mas lento
  self.postPos = self.pos
  self.direction = math.atan2((self.pos.y - self.prevPos.y), (self.pos.x - self.prevPos.x))

  self.x = self.pos.x
  self.y = self.pos.y

end

function Probe:popCirclesUpdate(dt)  --update del crecimiento y desaparicion de los circulos de pop de las probes
  	if self.radCirc > 0 then
    	self.radCirc = self.radCirc + (15 * (dt * 5))
    	self.alphaCirc =  self.alphaCirc - (21 * (dt * 5))
    	if self.radCirc > 190 then
      		self.radCirc = 0
      		self.alphaCirc = 0
    	end
  	end
end

function Probe:stelaUpdate()  --update del movimiento de la estela
	if #self.probeStela < self.stelaMax then
    	table.insert(self.probeStela, 1, self.pos)
  	end
  	if #self.probeStela == self.stelaMax then
    	table.remove(self.probeStela, #self.probeStela)
  	end
end

function Probe:influencedByGravityOf(planet)  -- aplicacion de fuerza de gravedad de un planeta a la velocidad de la probe

    self.planet = planet
    self.distanceToPlanet = self.pos:dist(planet.pos)
    local distanceToPlanetSq = self.pos:dist2(planet.pos)
    local gravity = (planet.mass / distanceToPlanetSq)
    local gravAngle = math.atan2((self.pos.y - planet.pos.y), (self.pos.x - planet.pos.x))
    local xGrav = math.sin(gravAngle - math.pi/2) * gravity
    local yGrav = math.cos(gravAngle + math.pi/2) * gravity
    local gravAccel = vector(xGrav, yGrav)
    self.sp = self.sp + gravAccel

end

function Probe:keyboardMove(dt)  --aplicacion de los thrust de aceleracion de las probes con Up y Down
  if self.selected then
    self.vectorDirection = vector.fromPolar(self.direction, self.probeThrustPower)
    local b = self.vectorDirection:rotated(math.pi/2)
    if love.keyboard.isDown("up") then
      self.sp = self.sp + self.vectorDirection * dt
    elseif love.keyboard.isDown("down") then
      self.sp = self.sp - self.vectorDirection * dt
    end
  end
end

function Probe:drawThrust(dir)  -- para dibujar el thrust de la probe al ser impulsada
  love.graphics.setLineWidth(15)
  local rInt = utils.randomInt(1,2)
  local direction = math.atan2((self.pos.y - self.prevPos.y), (self.pos.x - self.prevPos.x))
  if dir == "up" then
    local long = lume.random(0.5, 2)
    local shift = lume.random(-2, 2)
    love.graphics.setColor(255,255,255,150)
    love.graphics.polygon('fill', self.pos.x +(math.sin(direction) * 10), self.pos.y - (math.cos(direction) * 10), self.pos.x - (math.sin(direction) * 10), self.pos.y + (math.cos(direction) * 10), self.pos.x - (self.vectorDirection.x * long - shift), self.pos.y - (self.vectorDirection.y * long - shift))
  elseif dir == "down" then
    local long = lume.random(0.5, 2)
    local shift = lume.random(-2, 2)
    love.graphics.setColor(255,255,255,150)
    love.graphics.polygon('fill', self.pos.x - (math.sin(direction) * 10), self.pos.y + (math.cos(direction) * 10), self.pos.x + (math.sin(direction) * 10), self.pos.y - (math.cos(direction) * 10), self.pos.x + (self.vectorDirection.x * long - shift), self.pos.y + (self.vectorDirection.y * long - shift))
  end
  love.graphics.setColor(255,255,255,255)
  love.graphics.setLineWidth(1)
end

function Probe:checkDestroyProbe(planet)  --para chequear si la probe se salio de los limites de juego y marcarla como muerta
  self.planet = planet
  if (self.distanceToPlanet + self.r > planet.gravityRadius) or
      (self.distanceToPlanet - self.r < planet.radius) then --Si la probe se sale del campo de gravedad o cae en el planeta
    if self.selected then
      self.selected = false
      probeSelected = 0
    end
    self.dead = true
    gSounds['explosion']:play()
  end
end

function Probe:checkLowHigh(planet, colorZones)  -- saber el punto mas alto y mas bajo de la orbita de la probe
  intersection = false
  vectorPlanet = vector.new(planet.x, planet.y)
  zonaMin = colorZones.zonasColor[self.number].min
  zonaMax = colorZones.zonasColor[self.number].max 
  distancia = utils.distanceTo(self.x, self.y, planet.x, planet.y)
  angle = math.atan2((self.pos.y - planet.y), (self.pos.x - planet.x))

  self:checkInsideOrbit()
  self:checkLaps()
end

function Probe:checkInsideOrbit() --para saber si la probe esta dentro de su orbita
   if distancia + self.r > zonaMin and distancia + self.r < zonaMax then 
      self.pIn = vector.fromPolar(angle, distancia)
      self.pMin = vector.fromPolar(angle, zonaMin)
      self.pMax = vector.fromPolar(angle, zonaMax)
      self.inMyOrbit = true
      table.insert(self.probeMinMax, {pIn = self.pIn, pMin = self.pMin, pMax = self.pMax})
      if #self.probeInOrbitLine == 0 then
        table.insert(self.probeInOrbitLine, {pIn = self.pIn, pMin = self.pMin, pMax = self.pMax})
      end
    elseif distancia + self.r < zonaMin or distancia + self.r > zonaMax then
      self.probeInOrbitLine = {}
      self.probeMinMax = {}
      self.laps = 0
      self.inMyOrbit = false
    end
end

function Probe:checkLaps() --Viene de CheckInsideOrbit y Luego a Game.checkOrbitsDone, cuenta las vueltas que da sin salirse de la orbita
  if self.inMyOrbit then
    intersection = utils.intersectSegment(self.prevPos.x, self.prevPos.y, self.postPos.x, self.postPos.y, self.probeInOrbitLine[1].pMin.x, self.probeInOrbitLine[1].pMin.y, self.probeInOrbitLine[1].pMax.x, self.probeInOrbitLine[1].pMax.y)
  end

  if intersection then
    if self.firstIntersection == false then
      self.laps = self.laps + 1
      self.firstIntersection = true
    end
  else
    self.firstIntersection = false
  end

  if self.laps > 2 then
    self.intersect = true
  else
    self.intersect = false
  end
end