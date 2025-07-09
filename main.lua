local game = require("src/main_game")


function love.load()
    mygame = game:new()
end

function love.update(dt)
    mygame:update(dt)
end

function love.draw()
    mygame:draw()
end