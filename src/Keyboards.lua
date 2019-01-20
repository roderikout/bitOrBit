--[[Funciones de teclado --[[Hay unas funciones de teclado que no están bien, 
las que se presionan seguido.


function love.keypressed(key)
  --Teclas de control de juego
  if game.level.levelNumber > 0 then
    if key == "p" then  -- rotar en seleccion de probes
      if #probes > 0 then
        pop:play()
        probeSelected = probeSelected + 1
        if probeSelected > #probes then
          probeSelected = 0
          cameraFollows = false
        end
        for i, prob in ipairs(probes) do
          prob.selected = false
        end
        if probeSelected > 0 then
          probes[probeSelected].selected = true
        end
      end
    elseif key == "x" then   --Lanzar la probe
      table.remove(probes, probeSelected)
      probeSelected = 0
      explosion:play()
    elseif key == "r" then   --Lanzar la probe
      probes = {}
      probeSelected = 0
      game.gameState  = "play"
    elseif key == "f" then   --Lanzar la probe
      cameraFollows = not cameraFollows
    elseif key == "c" then   --Lanzar la probe
      testColors = testColors + 1
      if testColors > probesMax then testColors = 1 end
    elseif key == "space" then   --Lanzar la probe
      game.gameState = "play"
      probeLanzar = true
    elseif key == "h" then   --Lanzar la probe
      if game.gameState == "play" then
        game.gameState = "pause"
      elseif game.gameState == "pause" then
        game.gameState = "play"
      end
    end
  end
  if game.level.levelNumber == 0 then
    if key == "space" then  --Zoom
      game.level = Level1()
      level.currentLevel = 1
      game.gameState = "play"
    end
  end
  if key == "escape" then  --Salir del juego
    if game.level.levelNumber == 0 then
      love.event.quit()
    else
      music:stop()
      probes = {}
      probeSelected = 0
      probeLanzar = false
      game.level = LevelStart()
    end
  --elseif key == "i" then
   -- level.instructionsOn = not level.instructionsOn
  end
end

]]--