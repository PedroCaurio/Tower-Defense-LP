-- Arquivo de estado para mostrar a tela de derrota

local Gamestate = require "lib.hump.gamestate"

local image = love.graphics.newImage("assets/menus/lostImage.png")

local gameover = {}

function gameover:load()
end

function gameover:draw()
    love.graphics.draw(image, 0, 0)
end

function gameover:keypressed(key)
    if key == "space" then
        Gamestate.switch(require("src.states.MenuState"))
    end
end

return gameover
