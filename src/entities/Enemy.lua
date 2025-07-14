-- src/entities/Enemy.lua

-- 1. Módulos necessários, incluindo a classe base e o anim8
local Unit = require("src.entities.Unit")
local anim8 = require("lib.anim8.anim8")

-- 2. Classe Enemy, herdando de Unit. A estrutura de herança está correta.
local Enemy = {}
setmetatable(Enemy, {__index = Unit})
Enemy.__index = Enemy

-- 3. Configuração Central dos Inimigos (Data-Driven Design)
-- Assim como em Ally, esta tabela se torna o cérebro dos inimigos.
local enemyTypes = {
    soldado = {
        stats = { speed = 50, health = 100, damage = 10, color = {0.8, 0.5, 0} },
        reward = 5,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/enemies/Spear.png",
        grid = {w = 32, h = 32},
        animations = {
            --walk = anim8.newAnimation(g('1-4', 2), 0.15),
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-6', 4), 0.15) end,
            idle = function(g) return anim8.newAnimation(g('1-4', 3), 0.2) end
        }
    },
    tank = {
        stats = { speed = 30, health = 300, damage = 25, color = {0.5, 0.2, 0.2} },
        reward = 15,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/enemies/Sword.png", -- Caminho adicionado
        grid = {w = 32, h = 32}, -- Grid adicionado
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.2) end,
            attack = function(g) return anim8.newAnimation(g('1-6', 4), 0.2) end,
            idle = function(g) return anim8.newAnimation(g('1-1', 1), 0.2) end
        }
    },
    ninja = {
        stats = { speed = 80, health = 70, damage = 5, color = {0.3, 0.3, 0.3} },
        reward = 10,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/enemies/Horse.png", -- Caminho adicionado
        grid = {w = 32, h = 32}, -- Grid adicionado
        animations = {
             -- Adicionando placeholders para evitar erros
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-7', 5), 0.15) end,
            idle = function(g) return anim8.newAnimation(g('1-1', 1), 0.2) end
        }
    }
}

-- Construtor do Enemy, preparado para a IA que evolui
function Enemy.create(type, x, y, level, bonuses)
    local template = enemyTypes[type]
    assert(template, "Tipo de inimigo inválido: " .. tostring(type))
    
    level = level or 1
    bonuses = bonuses or {}

    local finalStats = {
        speed = template.stats.speed,
        health = (template.stats.health + (bonuses.health or 0)) * (1.15 ^ (level - 1)),
        damage = (template.stats.damage + (bonuses.damage or 0)) * (1.15 ^ (level - 1)),
        color = template.stats.color
    }
    
    local enemyAnimations = {}
    local spritesheet = nil

    if template.spriteSheetPath and love.filesystem.getInfo(template.spriteSheetPath) then
        spritesheet = love.graphics.newImage(template.spriteSheetPath)
        local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())
        for name, creator in pairs(template.animations) do
            local ok, anim = pcall(function() return creator(grid):clone() end)
            if ok then
                enemyAnimations[name] = anim
            else
                print("AVISO: Falha ao criar animação '" .. name .. "' para a tropa '" .. type .. "'.")
            end
        end
    else
        print("AVISO: Asset não encontrado para a tropa '" .. type .. "'. Usando placeholder.")
    end
    
    -- ############ CORREÇÃO AQUI ############
    -- A variável foi renomeada de 'ally' para 'enemy'.
    local enemy = Unit:new({
        x = x, y = y,
        speed = finalStats.speed,
        health = finalStats.health,
        maxHealth = finalStats.health,
        damage = finalStats.damage,
        cost = nil, -- Inimigos não têm custo de 'food'
        color = finalStats.color,
        animations = enemyAnimations,
        flipped = true, -- Inimigos são virados para a esquerda
        spritesheet = spritesheet
    })

    -- Adiciona propriedades específicas do Enemy
    enemy.type = type
    enemy.level = level
    enemy.reward = template.reward
    enemy.attackType = template.attackType
    enemy.attackRange = template.attackRange
    enemy.state = 'walking'

    return setmetatable(enemy, Enemy)
end

function Enemy:update(dt, allies, playerStructure, playState) -- Adicionamos 'playState'
    if not self.alive then return end

    Unit.update(self, dt)

    local target = self:findTarget(allies, playerStructure)

    if target then
        self.state = 'attack'
    else
        self.state = 'walk'
    end

    if self.state == 'walk' then
        self.x = self.x - self.speed * dt
    elseif self.state == 'attack' then
        self.timeSinceAttack = self.timeSinceAttack + dt
        if self.timeSinceAttack >= self.attackCooldown then
            
            -- Lógica de ataque para inimigos (preparada para 'ranged' no futuro)
            if self.attackType == 'ranged' then
                playState.projectileManager:create({
                    x = self.x,
                    y = self.y - self.height / 2,
                    damage = self.damage,
                    target = target,
                    owner = self
                })
            else -- 'melee'
                target:takeDamage(self.damage)
            end

            self.timeSinceAttack = 0
        end
    end
end

function Enemy:findTarget(allies, playerStructure)
    -- Prioridade 1: Atacar aliados próximos
    for _, ally in ipairs(allies) do
        if ally.alive and math.abs(self.x - ally.x) < self.attackRange then
            return ally
        end
    end

    -- Prioridade 2: Atacar a estrutura principal
    if playerStructure and playerStructure.alive and math.abs(self.x - playerStructure.x) < self.attackRange + 20 then
        return playerStructure
    end

    return nil
end

-- 7. A FUNÇÃO DRAW FOI REMOVIDA
-- Não precisamos mais dela aqui, pois a função herdada de Unit.lua já faz todo o trabalho
-- de desenhar o sprite animado e a barra de vida. O código fica muito mais limpo!

-- A função getCost é usada pela IA para decidir o que comprar, então a mantemos.
function Enemy.getCost(type)
    return enemyTypes[type] and enemyTypes[type].cost or math.huge
end

return Enemy