local Gamestate = require "lib.hump-master.gamestate"
local menu = {}

function menu:load()
end

function menu:draw()
    love.graphics.printf("MENU - Pressione Enter para Jogar", 0, 300, love.graphics.getWidth(), "center")
end

function menu:keypressed(key)
    if key == "return" then
        Gamestate.switch(require("src.states.PlayState"):load())
    end
end

return menu
