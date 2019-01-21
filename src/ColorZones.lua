--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    -- ColorZones Class --
    
    Clase usada para manejar las orbitas de colores y sus regiones llamadas zonas
    Se inicializa con el planeta alredeor del cual se ubican las zonas, el numero de zonas y la tabla
      orbitsNeededToWin  
]]


ColorZones = Class{}

function ColorZones:init(planet, zones, orbitsNeededToWin)
	self.planet = planet
	self.zones = zones
  self.orbitsNeededToWin = orbitsNeededToWin or {}

	self.spaceBetween = self.planet.radius * 5/6
	self.spaceZone = self.planet.gravityRadius - self.planet.radius - self.spaceBetween
	self.colorZone = self.spaceZone / self.zones
	self.lineWidth = self.colorZone - self.spaceBetween

	self.alpha = 80

	self.zonasColor = {}
end


--[[
  En el render se maneja el alpha si la probe esta en su orbita de manera estable
]]
function ColorZones:render()
	for i = 1, self.zones do
    if #self.orbitsNeededToWin > 0 then
      if self.orbitsNeededToWin[i] then
        self.alpha = 200
      elseif not self.orbitsNeededToWin[i] then
        self.alpha = 80
      end
    end

		love.graphics.setLineWidth(self.lineWidth)
    love.graphics.setColor(self.colorToLine(i, self.alpha))
    local zona = (((self.lineWidth + self.spaceBetween) * i) - self.lineWidth/2 + self.spaceBetween)
    local orbit = love.graphics.circle("line", self.planet.x, self.planet.y, zona)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(100,100,100,255)
    local lineDwnOrbit = love.graphics.circle("line", self.planet.x, self.planet.y, zona - self.lineWidth/2)
    local lineUpOrbit = love.graphics.circle("line", self.planet.x, self.planet.y, zona + self.lineWidth/2)
    table.insert(self.zonasColor, {min = zona - (self.lineWidth / 2), max = zona + (self.lineWidth / 2)})
    love.graphics.setColor(255,255,255,255)
	end
end

--[[
  -Metodo no estatico, se puede usar solo llamando a la clase sin instanciarla
  -Asigna colores a probes y orbitas según número de probes, maximo 7 probes. ARREGLAR, Buscar otro método más amplio  
]]
function ColorZones.colorToLine(i, alpha)  

  if i == 1 then  -- rojo
    red, green, blue = 255, 0 , 0
  elseif i == 2 then  -- naranja
    red, green, blue = 255, 100, 0
  elseif i == 3 then -- amarillo
    red, green, blue = 255, 255, 0
  elseif i == 4 then -- verde
    red, green, blue = 0, 255, 0
  elseif i == 5 then -- cyan
    red, green, blue = 0, 255, 255
  elseif i == 6 then -- azul
    red, green, blue = 0, 0, 255
  elseif i == 7 then -- magenta
    red, green, blue = 255, 0, 255
  end

  return red, green, blue, alpha
end