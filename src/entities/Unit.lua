-- src/entities/Unit.lua

local Unit = {}
Unit.__index = Unit

function Unit:new(config)
    local unit = {}
    
    -- Status básicos
    unit.x = config.x or 0
    unit.y = config.y or 0
    unit.width = config.width or 20   -- Largura da entidade para desenho e colisões futuras
    unit.height = config.height or 40 -- Altura da entidade
    unit.speed = config.speed or 50
    unit.health = config.health or 100
    unit.maxHealth = config.maxHealth or unit.health
    unit.damage = config.damage or 10
    unit.cost = config.cost or 0
    unit.color = config.color or {1, 1, 1} -- Adicionando a cor aqui
    unit.alive = true

    -- Status de combate
    unit.attackCooldown = 1
    unit.timeSinceAttack = 0
    
    -- Lógica de Animação e Estado
    unit.state = 'idle' 
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
    if not self.alive then return end

    -- A coordenada (self.x, self.y) agora representa o CENTRO DA BASE (os pés)
    if self.animations and self.animations[self.state] and self.spritesheet then
        local anim = self.animations[self.state]
        local spritesheet = self.spritesheet
        
        local sx = self.flipped and -1 or 1
        -- O offset de origem agora é no centro da base do frame
        local ox = anim:getDimensions() / 2
        local oy = anim:getDimensions() -- Desenha a partir dos pés para cima

        love.graphics.setColor(1, 1, 1)
        anim:draw(spritesheet, self.x, self.y, 0, sx, 1, ox, oy)
    else
        -- Desenho de fallback: um retângulo cuja base está em self.y
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height, self.width, self.height)
    end

    -- Barra de vida desenhada acima da cabeça da entidade
    local barWidth = 40
    local barY = self.y - self.height - 10 -- Posição acima da cabeça
    love.graphics.setColor(0.7, 0, 0)
    love.graphics.rectangle("fill", self.x - barWidth / 2, barY, barWidth, 5)
    love.graphics.setColor(0, 0.8, 0)
    local lifeWidth = (self.health / self.maxHealth) * barWidth
    love.graphics.rectangle("fill", self.x - barWidth / 2, barY, lifeWidth, 5)

    love.graphics.setColor(1, 1, 1)
end

return Unit