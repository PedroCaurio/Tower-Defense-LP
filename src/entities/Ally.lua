-- Arquivo herdado de unit para representar os aliados

local Unit = require("src.entities.Unit")
local anim8 = require("lib.anim8.anim8")

local Ally = {}
setmetatable(Ally, {__index = Unit})
Ally.__index = Ally

-- Tipos de aliados, temos que balancear aquiii
local allyTypes = {
    soldado = {
        stats = { speed = 50, health = 100, damage = 10, color = {0.2, 0.6, 1} },
        costFood = 10,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/units/allies/Spear.png",
        grid = {w = 32, h = 32},
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-7', 4), 0.1) end,
            die = function(g) return anim8.newAnimation(g('1-5', 6), 0.1) end
        }
    },
    arqueiro = {
        stats = { speed = 40, health = 70, damage = 12, color = {0.2, 0.8, 0.2} },
        costFood = 25, attackType = 'ranged', attackRange = 250,
        spriteSheetPath = "assets/units/allies/Archer.png", grid = {w = 32, h = 32}, animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-11', 4), 0.1) end,
            die = function(g) return anim8.newAnimation(g('1-4', 7), 0.15) end
        }
    },
    tank = {
        stats = { speed = 30, health = 300, damage = 15, color = {0.8, 0.2, 0.2} },
        costFood = 30, attackType = 'melee', attackRange = 40,
        spriteSheetPath = "assets/units/allies/Sword.png", grid = {w = 32, h = 32}, animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-6', 4), 0.1) end,
            die = function(g) return anim8.newAnimation(g('1-4', 6), 0.1) end
        }
    },
    cavaleiro = {
        stats = { speed = 80, health = 80, damage = 20, color = {0.1, 0.1, 0.1} },
        costFood = 25, attackType = 'melee', attackRange = 40,
        spriteSheetPath = "assets/units/allies/Horse.png", grid = {w = 32, h = 32}, animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-7', 5), 0.1) end,
            die = function(g) return anim8.newAnimation(g('1-6', 7), 0.1) end
        }
    },
    principe = {
        stats = { speed = 35, health = 500, damage = 50, color = {1, 0.8, 0} },
        costFood = 200, attackType = 'melee', attackRange = 45,
        spriteSheetPath = "assets/units/allies/Prince.png", grid = {w = 32, h = 32}, animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 2), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-6', 4), 0.1) end,
            die = function(g) return anim8.newAnimation(g('1-6', 6), 0.1) end
        }
    }
}
-- Construtor
function Ally.create(type, x, y, level, bonuses)
    local template = allyTypes[type]
    assert(template, "Tipo de aliado inválido: " .. tostring(type))
    
    level = level or 1
    bonuses = bonuses or {}

    local finalStats = {
        speed = template.stats.speed,
        health = (template.stats.health + (bonuses.health or 0)) * (1.15 ^ (level - 1)),
        damage = (template.stats.damage + (bonuses.damage or 0)) * (1.15 ^ (level - 1)),
        color = template.stats.color
    }
    
    local allyAnimations = {}
    local spritesheet = nil
    
    if template.spriteSheetPath and love.filesystem.getInfo(template.spriteSheetPath) then
        spritesheet = love.graphics.newImage(template.spriteSheetPath)
        local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())
        for name, creator in pairs(template.animations) do
            local ok, anim = pcall(function() return creator(grid):clone() end)
            if ok then
                allyAnimations[name] = anim
            else
                print("Falha ao criar animação '" .. name .. "' para a tropa '" .. type .. "'")
            end
        end
    else
        print("Asset não encontrado para a tropa '" .. type .. "'. Usando placeholder.")
    end

    local ally = Unit:new({
        x = x, y = y,
        width = template.grid.w, height = template.grid.h,
        speed = finalStats.speed,
        health = finalStats.health,
        maxHealth = finalStats.health,
        damage = finalStats.damage,
        cost = template.costFood,
        color = finalStats.color,
        animations = allyAnimations,
        flipped = false,
        spritesheet = spritesheet
    })
    
    ally.type, ally.level, ally.attackType, ally.attackRange, ally.state = type, level, template.attackType, template.attackRange, 'walk'
    
    ally.deathTimer = 0
    ally.timeToDie = 0.5
    return setmetatable(ally, Ally)
end

function Ally:update(dt, enemies, enemyStructure, playState)
    if not self.alive then
        self.state = 'die'
        Unit.update(self, dt)
        return
    end
    Unit.update(self, dt)
    
    local target = self:findTarget(enemies, enemyStructure)
 
    if target then
        self.state = 'attack'
    else
        self.state = 'walk'
    end

    if self.state == 'walk' then
        self.x = self.x + self.speed * dt
    elseif self.state == 'attack' then
        self.timeSinceAttack = self.timeSinceAttack + dt
        if self.timeSinceAttack >= self.attackCooldown then
            if self.attackType == 'ranged' then
                if playState and playState.projectileManager then
                    playState.projectileManager:create({ x = self.x, y = self.y - self.height / 2, damage = self.damage, target = target, owner = self })
                end
            else
                target:takeDamage(self.damage)
            end
            self.timeSinceAttack = 0
        end
    end
end

function Ally:findTarget(enemies, enemyStructure)
    for _, enemy in ipairs(enemies) do
        if enemy.alive and math.abs(self.x - enemy.x) < self.attackRange then
            return enemy
        end
    end

    if enemyStructure and enemyStructure.alive and math.abs(self.x - enemyStructure.x) < self.attackRange then
        return enemyStructure
    end

    return nil
end

function Ally.getFoodCost(type)
    --print(type, allyTypes[type], allyTypes[type].costFood)
    return allyTypes[type] and allyTypes[type].costFood or math.huge
end

return Ally