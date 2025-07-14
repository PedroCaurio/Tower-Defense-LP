local Gamestate = require "lib.hump.gamestate"
local menu = {}
menu.__index = menu


function menu:loadAssets()
    Background = love.graphics.newImage("assets/background/menu_1.png")
end

function menu:load()
    menu:loadAssets()
    return menu
end

function menu:draw()
    love.graphics.draw(Background, 0, 0, 0, 3, 3)
    love.graphics.printf("MENU - Pressione Enter para Jogar", 0, 300, love.graphics.getWidth(), "center")
end

function menu:keypressed(key)
    if key == "return" then
        Gamestate.switch(require("src.states.PlayState"):load())
    end
end

return menu:load()
