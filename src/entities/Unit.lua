-- Arquivo da classe base que será herdada por Enemy, Ally e Structure
local Unit = {}
Unit.__index = Unit

function Unit:new(config)
    local unit = {}
    
    -- Status básicos
    unit.x = config.x or 0
    unit.y = config.y or 0
    unit.width = config.width or 20   
    unit.height = config.height or 40 
    unit.speed = config.speed or 50
    unit.health = config.health or 100
    unit.maxHealth = config.maxHealth or unit.health
    unit.damage = config.damage or 10
    unit.cost = config.cost or 0
    unit.color = config.color or {1, 1, 1} 
    unit.alive = true
    

    -- Status de combate
    unit.attackCooldown = 1
    unit.timeSinceAttack = 0
    
    -- Lógica de Animação e Estado
    unit.state = 'walk' 
    unit.animations = config.animations or {}
    unit.flipped = config.flipped or false
    unit.spritesheet = config.spritesheet

    return setmetatable(unit, self)
end

function Unit:takeDamage(dmg)
    if not self.alive then return end
    self.health = self.health - dmg
    if self.health <= 0 then
        self.health = 0
        self.alive = false
    end
end

function Unit:update(dt)
    if not self.alive then return end   
    if self.animations[self.state] then
        self.animations[self.state]:update(dt)
    end
end

function Unit:draw()   
    if self.animations and self.animations[self.state] and self.spritesheet then
        local anim = self.animations[self.state]
        
        local w, h = anim:getDimensions()

        local sx = self.flipped and -1 or 1
        local ox = w / 2
        local oy = h     
        
        love.graphics.setColor(1, 1, 1)
        anim:draw(self.spritesheet, self.x, self.y, 0, sx*2, 1*2, ox, oy)
    else
        love.graphics.setColor(self.color or {1,1,1})
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height, self.width, self.height)
    end

    local barWidth = 40
        local barY = self.y - self.height - 10
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - barWidth / 2, barY, barWidth, 5)

        if self.cost ~= 0 and self.cost ~= "enemy_base" then
            love.graphics.setColor(0, 0.8, 0)
        else
            love.graphics.setColor(0.8, 0, 0)
        end

        local lifeWidth = (self.health / self.maxHealth) * barWidth
        love.graphics.rectangle("fill", self.x - barWidth / 2, barY, lifeWidth, 5)

    love.graphics.setColor(1, 1, 1)
end

return Unit