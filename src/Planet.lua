--[[ 

  BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    -- Planet class --

  Para crear los planetas

]]--


Planet = Class{}

-- self.vector = require ("vector")

function Planet:init(x, y, radius, mass, gravityRadius, zones)
  
  --local self = self or {}
  
  self.x = x
  self.y = y
  self.radius = radius
  self.mass = mass
  self.gravityRadius = gravityRadius
  
  --color zones
  self.zones = zones
  self.orbitsNeededToWin = {}
  for i, p in ipairs(probes) do
    if p.intersect then
      self.orbitsNeededToWin[i] = true
    elseif not p.intersect then
      self.orbitsNeededToWin[i] = false
    end
  end
  self.spaceBetween = self.radius * 5/6
  self.spaceZone = self.gravityRadius - self.radius - self.spaceBetween
  self.colorZone = self.spaceZone / self.zones
  self.lineWidth = self.colorZone - self.spaceBetween

  self.zonasAlpha = 80

  self.zonasColor = {}

  self.pos = vector(self.x,self.y)

  self.name = 'none'
    
end

-- member functions

function Planet:render()
  
  --planeta
  love.graphics.setColor(150,150,250,255)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(30,30,30,255)
  love.graphics.circle("fill", self.x, self.y, self.radius - self.radius/10)
  
  --gravedad
  love.graphics.setColor(150,150,150,255)
  love.graphics.circle("line", self.x, self.y, self.gravityRadius)
  love.graphics.setColor(255,255,255,255)

  --para las orbitas de color
  for i = 1, self.zones do
    if #self.orbitsNeededToWin > 0 then
      if self.orbitsNeededToWin[i] then
        self.zonasAlpha = 200
      elseif not self.orbitsNeededToWin[i] then
        self.zonasAlpha = 80
      end
    end

    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.setColor(utils.numberToColor(i, self.zonasAlpha))
    local zona = (((self.lineWidth + self.spaceBetween) * i) - self.lineWidth/2 + self.spaceBetween)
    local orbit = love.graphics.circle("line", self.x, self.y, zona)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(100,100,100,255)
    local lineDwnOrbit = love.graphics.circle("line", self.x, self.y, zona - self.lineWidth/2)
    local lineUpOrbit = love.graphics.circle("line", self.x, self.y, zona + self.lineWidth/2)
    table.insert(self.zonasColor, {min = zona - (self.lineWidth / 2), max = zona + (self.lineWidth / 2)})
    love.graphics.setColor(255,255,255,255)
  end
  
end