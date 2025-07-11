local Gamestate = require "lib.hump-master.gamestate"

local Ally = require("src/entities/Ally")
local Enemy = require("src/entities/Enemy")
local Structure = require("src.entities.Structure") -- Caminho corrigido e sem .lua

local PlayState = {}
PlayState.__index = PlayState

function PlayState:load()
    local state = {
        allies = {},
        enemies = {},
        structures = {},
        money = 50,
        enemySpawnTimer = 0,
        enemySpawnInterval = 3  -- Inimigos aparecem a cada 3 segundos
    }
    local myStructure = Structure.create("base", 50, 300)
    table.insert(state.structures, myStructure)
    return setmetatable(state, PlayState)
end

function PlayState:update(dt)
    for i = #self.structures, 1, -1 do
        local structure = self.structures[i]
        structure:update(dt)
    end
    
    -- Atualiza aliados
    for i = #self.allies, 1, -1 do
        local ally = self.allies[i]
        ally:update(dt, self.enemies)

        if not ally.alive or ally.x > love.graphics.getWidth() then
            table.remove(self.allies, i)
        end
    end

    -- Atualiza inimigos
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        enemy:update(dt, self.allies, self.structures)

        if not enemy.alive or enemy.x < 0 then
            table.remove(self.enemies, i)
        end
    end

    -- Dinheiro passivo
    self.money = self.money + dt * 5  -- +5 moedas por segundo

    -- Spawning de inimigos automático
    self.enemySpawnTimer = self.enemySpawnTimer + dt
    if self.enemySpawnTimer >= self.enemySpawnInterval then
        self:spawnEnemy()
        self.enemySpawnTimer = 0
    end
end

function PlayState:draw()
    for i = #self.structures, 1, -1 do
        local structure = self.structures[i]
        if structure.alive then
            structure:draw()
        else
            table.remove(self.structures, i)
            Gamestate.switch(require("src.states.GameOverState"))
        end
    end


    -- Desenhar aliados
    for _, ally in ipairs(self.allies) do
        ally:draw()
    end

    -- Desenhar inimigos
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Dinheiro: $" .. math.floor(self.money), 10, 10)
    love.graphics.print("[A] Soldado ($10)", 10, 30)
    love.graphics.print("[S] Tank ($30)", 10, 50)
    love.graphics.print("[D] Ninja ($15)", 10, 70)
end

function PlayState:keypressed(key)
    if key == "a" and self.money >= Ally.getCost("soldado") then
        table.insert(self.allies, Ally.create("soldado", 0, 300))
        self.money = self.money - Ally.getCost("soldado")

    elseif key == "s" and self.money >= Ally.getCost("tank") then
        table.insert(self.allies, Ally.create("tank", 0, 300))
        self.money = self.money - Ally.getCost("tank")

    elseif key == "d" and self.money >= Ally.getCost("ninja") then
        table.insert(self.allies, Ally.create("ninja", 0, 300))
        self.money = self.money - Ally.getCost("ninja")
    end
end

-- Spawna inimigos automaticamente do lado direito
function PlayState:spawnEnemy()
    local enemyTypes = {"soldado", "tank", "ninja"}
    local randomType = enemyTypes[love.math.random(#enemyTypes)]
    local x = love.graphics.getWidth() - 20
    local y = 300

    table.insert(self.enemies, Enemy.create(randomType, x, y))
end

return PlayState