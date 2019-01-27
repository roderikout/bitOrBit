--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu
    
    -- Gravity System --

    Para manejar el sistema gravitatorio
  
]]

GravitySystem = Class{}

function GravitySystem.influencedByGravityOf(element, planet)  -- aplicacion de fuerza de gravedad de un planeta a la velocidad de la probe
    local distanceToPlanetSq = element.pos:dist2(planet.pos)
    local gravity = (planet.mass / distanceToPlanetSq)
    local gravAngle = math.atan2((element.pos.y - planet.pos.y), (element.pos.x - planet.pos.x))
    local xGrav = math.sin(gravAngle - math.pi/2) * gravity
    local yGrav = math.cos(gravAngle + math.pi/2) * gravity
    local gravAccel = vector(xGrav, yGrav)
    element.sp = element.sp + gravAccel
end

function GravitySystem.predictedPosition(element, planet, number, dt)

	local myElement = element
	local myPlanet = planet
	local myNumber = number
	local myPos = myElement.pos
	local myX = 0
	local myY = 0
	local mySp = myElement.sp

	for i = 1, number do

		myPos = myPos + mySp * (dt * myElement.modDt) --dt modificado para que vaya mas lento
		myX = myPos.x
		myY = myPos.y

		local myDistanceToPlanet = myPos:dist(planet.pos)
		local distanceToPlanetSq = myPos:dist2(planet.pos)
		local gravity = (planet.mass / distanceToPlanetSq)
		local gravAngle = math.atan2((myPos.y - planet.pos.y), (myPos.x - planet.pos.x))
		local xGrav = math.sin(gravAngle - math.pi/2) * gravity
		local yGrav = math.cos(gravAngle + math.pi/2) * gravity
		local gravAccel = vector(xGrav, yGrav)
		mySp = mySp + gravAccel

		if myDistanceToPlanet + myElement.r < myPlanet.gravityRadius and myDistanceToPlanet - myElement.r > myPlanet.radius then
			table.insert(myElement.predictedProbes, i, myPos)
		else
			table.remove(myElement.predictedProbes, i)
			myElement.dead = true
		end
	end

end

function GravitySystem.checkDestroyElement(element, planet)  --para chequear si la probe se salio de los limites de juego y marcarla como muerta
	element.distanceToPlanet = element.pos:dist(planet.pos)
	if (element.distanceToPlanet + element.r > planet.gravityRadius) or
	  (element.distanceToPlanet - element.r < planet.radius) then --Si la probe se sale del campo de gravedad o cae en el planeta
	if element.selected then
	  element.selected = false
	  probeSelected = 0
	end
	element.dead = true
	gSounds['explosion']:play()
	end
end