--[[ 

	BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

  	-- Prints --

	Para imprimir algunas cosas en pantalla
]]--

function printTitle(level, debug, instructionsOn)

	local yPos = 10
	local yShift = 600

	local font = love.graphics.setNewFont(12)
 	love.graphics.setColor(255,255,255,255)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, yPos)
	local font = love.graphics.setNewFont(24)
	love.graphics.print("Level: " .. tostring(level), 10, yPos * 3)
	local font = love.graphics.setNewFont(15)
	love.graphics.print("Press 'i' for keys", 10, yPos * 9)
	
	if not instructionsOn then

		local font = love.graphics.setNewFont(15)
		love.graphics.print("Debug text: " .. tostring(debug), 10, (yPos * 3) + yShift)

	else
		love.graphics.print("Keys: ", 10, (yPos * 3) + yShift)
	    love.graphics.print("Space: start the game ", 10, (yPos * 4.5)+ yShift)
	    love.graphics.print("P: to select probes", 10, (yPos * 6)+ yShift)
	    love.graphics.print("X: to destroy selected probe ", 10, (yPos * 7.5)+ yShift)
	    love.graphics.print("R: to reset the system     ", 10, (yPos * 9)+ yShift)
	    love.graphics.print("Up & down arrows: to increase and decrease \n velocity of selected probe", 10, (yPos * 10.5)+ yShift)
	    love.graphics.print("Escape: to exit the game   ", 10, (yPos * 13.5)+ yShift)
	    love.graphics.print("H: to pause the game   ", 10, (yPos * 15)+ yShift)
	    love.graphics.print("F: to follow the selected probe   ", 10, (yPos * 16.5)+ yShift)
	end

end