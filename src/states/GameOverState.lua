local Gamestate = require "lib.hump-master.gamestate"

local gameover = {}

function gameover:enter()
end

function gameover:draw()
    love.graphics.printf("GAME OVER - Pressione Espaço para Voltar ao Menu", 0, 300, love.graphics.getWidth(), "center")
end

function gameover:keypressed(key)
    if key == "space" then
        Gamestate.switch(require("src.states.MenuState"))
    end
end

return gameover
