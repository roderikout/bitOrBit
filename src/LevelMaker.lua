--[[
    BitOrBit v.1.1.5

    Author: Rodrigo Garcia
    roderikout@gmail.com

    Original by: Colton Ogden, cogden@cs50.harvard.edu
    
    -- Level Maker --

    Para hacer los niveles. ARREGLAR, demasiado sencillo
  
]]



LevelMaker = Class{}

function LevelMaker.createLevel(level)

	local levelData = {}
	local numberOfProbes = 0
	local multSpeedOfProbes = 0

	if level < 3 then
		numberOfProbes = level + 1
		multSpeedOfProbes = 0.4
	elseif level >= 3 and level < 6 then
		numberOfProbes = level + 1
		multSpeedOfProbes = 0.8
	else
		numberOfProbes = 7
		multSpeedOfProbes = 1
	end	

	levelData = {numberOfProbes, multSpeedOfProbes}

	return levelData
end