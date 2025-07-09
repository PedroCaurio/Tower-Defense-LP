-- src/main_game.lua

local PlayState = require("src/states/PlayState")
local Structure = require("src.entities.Structure") -- Caminho corrigido e sem .lua

local MainGame = {} -- Tabela para o nosso "módulo/classe"
local structures = {} -- Tabela para estruturas
local currentState

function MainGame:new()
    local o = {} -- Nova instância
    setmetatable(o, self)
    self.__index = self

    print("MainGame initialized!")

    -- Exemplo de como você criaria uma instância da sua Structure aqui:
    local myStructure = Structure:new(16, 400, { health = 100, type = "BaseStructure"})
    currentState = PlayState:new()
    -- Você provavelmente terá uma lista de estruturas no seu MainGame
    table.insert(structures, myStructure)
    return o
end

-- Método de atualização
function MainGame:update(dt)
    -- Se você tiver uma lista de estruturas, as atualizaria aqui
    currentState:update(dt)
    for i, structure in ipairs(structures) do
        structure:update(dt)
    end
end

-- Método de desenho
function MainGame:draw()
    currentState:draw()  
    -- Se você tiver uma lista de estruturas, as desenharia aqui
    for i, structure in ipairs(structures) do
        if structure.isAlive then
            structure:draw()
        else
            table.remove(structures, structure)
        end
    end
end

function love.keypressed(key)
    currentState:keypressed(key)
end

return MainGame -- Retorna a tabela para que possa ser 'requirida'