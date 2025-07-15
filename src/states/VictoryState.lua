local Gamestate = require "lib.hump.gamestate"
local image = love.graphics.newImage("assets/menus/winImage.png")

local victory = {}

function victory:load()
end

function victory:draw()
    love.graphics.draw(image, 0, 0)
end

function victory:keypressed(key)
    if key == "space" then
        Gamestate.switch(require("src.states.MenuState"))
    end
end

return victory
