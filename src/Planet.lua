--[[ 

  BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    -- Planet class --

  Para crear los planetas

]]--


Planet = Class{}

-- self.vector = require ("vector")

function Planet:init(x, y, radius, mass, gravityRadius)
  
  --local self = self or {}
  
  self.x = x
  self.y = y
  self.radius = radius
  self.mass = mass
  self.gravityRadius = gravityRadius

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
  
end