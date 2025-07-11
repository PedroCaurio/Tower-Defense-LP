-- src/main_game.lua
local Gamestate = require "lib.hump-master.gamestate"

local menu = require "src.states.MenuState"
local play = require "src.states.PlayState"
local gameover = require "src.states.GameOverState"

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
