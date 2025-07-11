-- src/states/PlayState.lua

--[[
    PlayState é o estado principal do jogo, onde toda a ação acontece.
    Ele gerencia:
    - As unidades (aliados e inimigos)
    - A estrutura do jogador
    - A economia (dinheiro)
    - A interface do usuário (botões)
    - As regras de spawn de inimigos
    - As condições de fim de jogo
]]

local Gamestate = require "lib.hump-master.gamestate"

-- 1. Importando todos os módulos necessários
local Ally = require("src.entities.Ally")
local Enemy = require("src.entities.Enemy")
local Structure = require("src.entities.Structure") 
local Button = require("src.ui.Button")

local PlayState = {}
PlayState.__index = PlayState

-- A função load agora é responsável por criar o estado inicial do jogo
function PlayState:load()
    local state = {
        allies = {},
        enemies = {},
        structures = {},
        uiElements = {}, -- Tabela para guardar os botões e outros elementos de UI
        money = 100, -- Aumentei o dinheiro inicial para facilitar os testes
        enemySpawnTimer = 0,
        enemySpawnInterval = 5 -- Aumentei o intervalo inicial para dar um respiro
    }
    setmetatable(state, PlayState) -- Importante fazer isso antes de usar 'self' nas funções internas

    -- 2. Criando a estrutura principal do jogador (o castelo)
    -- Posicionei mais à esquerda e mais para baixo, para dar espaço para a ação
    local playerStructure = Structure.create("base", 80, love.graphics.getHeight() - 150)
    table.insert(state.structures, playerStructure)

    -- 3. Lógica de criação de botões para spawnar aliados
    -- Função genérica para evitar repetição de código
    local function spawnAlly(allyType)
        if state.money >= Ally.getCost(allyType) then
            -- Spawna o aliado um pouco à frente da estrutura
            table.insert(state.allies, Ally.create(allyType, 120, love.graphics.getHeight() - 100))
            state.money = state.money - Ally.getCost(allyType)
        else
            -- Feedback futuro: tocar um som de "dinheiro insuficiente"
            print("Dinheiro insuficiente para comprar: " .. allyType)
        end
    end

    -- Criando os botões da UI
    local soldadoCost = Ally.getCost("soldado")
    local tankCost = Ally.getCost("tank")
    local ninjaCost = Ally.getCost("ninja")

    table.insert(state.uiElements, Button.create(10, 100, 120, 40, "Soldado ($"..soldadoCost..")", function() spawnAlly("soldado") end))
    table.insert(state.uiElements, Button.create(10, 150, 120, 40, "Tank ($"..tankCost..")", function() spawnAlly("tank") end))
    table.insert(state.uiElements, Button.create(10, 200, 120, 40, "Ninja ($"..ninjaCost..")", function() spawnAlly("ninja") end))

    return state
end

function PlayState:update(dt)
    -- 4. Lógica de Fim de Jogo
    local playerStructure = self.structures[1]
    
    -- ############ CORREÇÃO AQUI ############
    -- Alterado de 'playerStructure.isAlive' para 'playerStructure.alive'
    if not playerStructure.alive then
        Gamestate.switch(require("src.states.GameOverState"))
        return -- Para a execução para evitar erros após a troca de estado
    end
    -- #######################################

    -- Atualiza a estrutura
    playerStructure:update(dt)

    -- Atualiza aliados e remove os mortos ou que saíram da tela
    for i = #self.allies, 1, -1 do
        local ally = self.allies[i]
        ally:update(dt, self.enemies)
        if not ally.alive or ally.x > love.graphics.getWidth() then
            table.remove(self.allies, i)
        end
    end

    -- 5. Atualiza inimigos (passando a estrutura como alvo) e remove os mortos
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        -- Passamos a lista de aliados E a estrutura do jogador como alvos potenciais
        enemy:update(dt, self.allies, playerStructure)
        if not enemy.alive or enemy.x < 0 then
            table.remove(self.enemies, i)
        end
    end
    
    -- 6. Atualiza os elementos da UI (para checar hover do mouse)
    for _, element in ipairs(self.uiElements) do
        element:update(dt)
    end

    -- Lógica de economia e spawn
    self.money = self.money + dt * 5 -- Ganho passivo de dinheiro
    self.enemySpawnTimer = self.enemySpawnTimer + dt
    if self.enemySpawnTimer >= self.enemySpawnInterval then
        self:spawnEnemy()
        self.enemySpawnTimer = 0
    end
end

function PlayState:draw()
    -- Desenha um fundo simples para melhor visualização
    love.graphics.clear(0.4, 0.5, 0.6)

    -- Desenha a estrutura, aliados e inimigos
    for _, s in ipairs(self.structures) do s:draw() end
    for _, a in ipairs(self.allies) do a:draw() end
    for _, e in ipairs(self.enemies) do e:draw() end

    -- 7. Desenha a UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Dinheiro: $" .. math.floor(self.money), 10, 10)
    
    for _, element in ipairs(self.uiElements) do
        element:draw()
    end
end

-- 8. Removemos a lógica de spawn de unidades do teclado
function PlayState:keypressed(key)
    if key == "escape" then
        -- Por enquanto, vamos manter o escape para ir para a tela de game over (para testes)
        Gamestate.switch(require("src.states.MenuState"))
    end
end

-- 9. Adicionamos a função de clique do mouse, essencial para os botões
function PlayState:mousepressed(x, y, button)
    if button == 1 then -- Apenas botão esquerdo do mouse
        for _, element in ipairs(self.uiElements) do
            element:mousepressed(x, y, button)
        end
    end
end

-- Spawna inimigos automaticamente do lado direito, fora da tela
function PlayState:spawnEnemy()
    local enemyTypes = {"soldado", "tank", "ninja"}
    local randomType = enemyTypes[love.math.random(#enemyTypes)]
    local x = love.graphics.getWidth() + 20 -- Spawna um pouco fora da tela
    local y = love.graphics.getHeight() - 100 -- Na mesma altura das tropas aliadas

    table.insert(self.enemies, Enemy.create(randomType, x, y))
end

return PlayState