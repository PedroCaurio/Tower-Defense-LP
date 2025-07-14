local Gamestate = require "lib.hump.gamestate"

local victory = {}

function victory:load()
end

function victory:draw()
    love.graphics.printf("YOU WIN - Pressione Espaço para Voltar ao Menu", 0, 300, love.graphics.getWidth(), "center")
end

function victory:keypressed(key)
    if key == "space" then
        Gamestate.switch(require("src.states.MenuState"))
    end
end

return victory
