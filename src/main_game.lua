-- src/main_game.lua
local Gamestate = require "lib.hump.gamestate"

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(require("src.states.MenuState"))
end
