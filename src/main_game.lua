local Gamestate = require "lib.hump.gamestate"

-- Código para configuração da biblioteca hump e configuração básica

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- Aplicamos esse filtro para sprites pixelados, evita o blur.
    Gamestate.registerEvents()
    Gamestate.switch(require("src.states.MenuState"))
end
