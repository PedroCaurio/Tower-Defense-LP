local PlayState = require("src/states/PlayState")

local currentState

function love.load()
    currentState = PlayState:new()
end

function love.update(dt)
    currentState:update(dt)
end

function love.draw()
    currentState:draw()
end

function love.keypressed(key)
    currentState:keypressed(key)
end
