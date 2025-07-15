-- Arquivo da classe inimigo
local Unit = require("src.entities.Unit")
local anim8 = require("lib.anim8.anim8")

local Enemy = {}
setmetatable(Enemy, {__index = Unit}) -- Herança
Enemy.__index = Enemy

local enemyTypes = {
    soldado = {
        stats = { speed = 50, health = 100, damage = 10, color = {0.8, 0.5, 0} },
        reward = 5,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/enemies/Spear.png",
        grid = {w = 32, h = 32},
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-6', 4), 0.15) end,
            die = function(g) return anim8.newAnimation(g('1-5', 6), 0.2) end
        }
    },
    tank = {
        stats = { speed = 30, health = 300, damage = 25, color = {0.5, 0.2, 0.2} },
        reward = 15,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/enemies/Sword.png", 
        grid = {w = 32, h = 32}, 
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.2) end,
            attack = function(g) return anim8.newAnimation(g('1-6', 4), 0.2) end,
            die = function(g) return anim8.newAnimation(g('1-4', 7), 0.25) end
        }
    },
    cavaleiro = {
        stats = { speed = 80, health = 70, damage = 5, color = {0.3, 0.3, 0.3} },
        reward = 10,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/enemies/Horse.png", 
        grid = {w = 32, h = 32}, 
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-7', 5), 0.15) end,
            die = function(g) return anim8.newAnimation(g('1-6', 7), 0.2) end
        }
    },
    arqueiro = {
        stats = { speed = 40, health = 70, damage = 12, color = {0.2, 0.8, 0.2} },
        costFood = 25, attackType = 'ranged', attackRange = 250,
        spriteSheetPath = "assets/units/enemies/Archer.png", grid = {w = 32, h = 32}, animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-10', 4), 0.1) end,
            die = function(g) return anim8.newAnimation(g('1-4', 7), 0.15) end
        }
    }
    
}

-- Construtor do Enemy
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
                print("Falha ao criar animação '" .. name .. "' para a tropa '" .. type .. "'.")
            end
        end
    else
        print("Asset não encontrado para a tropa '" .. type .. "'. Usando placeholder.")
    end
    
    
    local enemy = Unit:new({
        x = x, y = y,
        speed = finalStats.speed,
        health = finalStats.health,
        maxHealth = finalStats.health,
        damage = finalStats.damage,
        cost = nil, -- Inimigos não têm custo de 'food'
        color = finalStats.color,
        animations = enemyAnimations,
        flipped = true, 
        spritesheet = spritesheet
    })

    enemy.type = type
    enemy.level = level
    enemy.reward = template.reward
    enemy.attackType = template.attackType
    enemy.attackRange = template.attackRange
    enemy.state = 'walk'

    enemy.deathTimer = 0
    enemy.timeToDie = 0.5
    return setmetatable(enemy, Enemy)
end

function Enemy:update(dt, allies, playerStructure, playState) 
    if not self.alive then
        self.state = 'die'
        Unit.update(self, dt)
        return
    end

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

-- Eu acho que isso aqui tá inutil guys
function Enemy.getCost(type)
    return enemyTypes[type] and enemyTypes[type].cost or math.huge
end

return Enemy