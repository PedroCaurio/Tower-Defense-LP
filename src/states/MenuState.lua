local Gamestate = require "lib.hump.gamestate"
local menu = {}
menu.__index = menu


function menu:loadAssets()
    image = love.graphics.newImage("assets/menus/menuImage.png")
end

function menu:load()
    menu:loadAssets()
    return menu
end

function menu:draw()
    love.graphics.draw(image, 0, 0)
end

function menu:keypressed(key)
    if key == "return" then
        Gamestate.switch(require("src.states.PlayState"):load())
    end
end

return menu:load()
