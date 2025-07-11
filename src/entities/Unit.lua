-- src/entities/Unit.lua
local Unit = {}
Unit.__index = Unit

function Unit:new(config)
    local unit = {}
    
    unit.x = config.x or 0
    unit.y = config.y or 0
    unit.speed = config.speed or 50
    unit.health = config.health or 100
    unit.maxHealth = config.health or 100
    unit.damage = config.damage or 10
    unit.cost = config.cost or 0
    unit.color = config.color or {1, 1, 1}
    unit.alive = true
    unit.attackCooldown = 1
    unit.timeSinceAttack = 0

    return setmetatable(unit, self)
end

function Unit:takeDamage(dmg)
    self.health = self.health - dmg
    if self.health <= 0 then
        self.health = 0
        self.alive = false
    end
end

function Unit:draw()
    if not self.alive then return end

    -- Corpo
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, 20, 20)

    -- Barra de vida
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y - 5, 20, 3)

    love.graphics.setColor(0, 1, 0)
    local lifeWidth = (self.health / self.maxHealth) * 20
    love.graphics.rectangle("fill", self.x, self.y - 5, lifeWidth, 3)

    love.graphics.setColor(1, 1, 1)
end

-- Outras funções que são comuns a Ally e Enemy podem vir aqui.

return Unit