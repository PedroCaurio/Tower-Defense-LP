-- src/entities/Unit.lua

-- Não precisa mais do anim8 aqui, pois ele não cria animações, apenas as gerencia.
local Unit = {}
Unit.__index = Unit

function Unit:new(config)
    local unit = {}
    
    -- Status básicos
    unit.x = config.x or 0
    unit.y = config.y or 0
    unit.speed = config.speed or 50
    unit.health = config.health or 100
    unit.maxHealth = config.maxHealth or unit.health
    unit.damage = config.damage or 10
    unit.cost = config.cost or 0
    unit.alive = true

    -- Status de combate
    unit.attackCooldown = 1
    unit.timeSinceAttack = 0
    
    -- Lógica de Animação e Estado
    unit.state = 'idle' 
    unit.animations = config.animations or {}
    unit.flipped = config.flipped or false

    -- ############ MUDANÇA IMPORTANTE ############
    -- Agora a instância da unidade guarda uma referência à sua própria imagem.
    unit.spritesheet = config.spritesheet
    -- ##########################################

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

    if self.animations and self.animations[self.state] and self.spritesheet then
        local anim = self.animations[self.state]

        -- ############ CORREÇÃO DA LÓGICA DE DESENHO ############
        -- Em vez de tentar extrair a imagem da animação,
        -- nós usamos a imagem que guardamos (self.spritesheet) e a passamos para a função draw do anim8.
        local sx = self.flipped and -1 or 1
        local ox = anim:getDimensions() / 2
        local oy = anim:getDimensions() / 2

        love.graphics.setColor(1, 1, 1)
        anim:draw(self.spritesheet, self.x, self.y, 0, sx, 1, ox, oy)
        -- ######################################################
    else
        love.graphics.setColor(self.color or {1, 1, 1})
        love.graphics.rectangle("fill", self.x - 10, self.y - 20, 20, 40) -- Retângulo um pouco maior
    end

    -- Barra de vida
    local barWidth = 40
    local barY = self.y - 35
    love.graphics.setColor(0.7, 0, 0)
    love.graphics.rectangle("fill", self.x - barWidth / 2, barY, barWidth, 5)
    love.graphics.setColor(0, 0.8, 0)
    local lifeWidth = (self.health / self.maxHealth) * barWidth
    love.graphics.rectangle("fill", self.x - barWidth / 2, barY, lifeWidth, 5)

    love.graphics.setColor(1, 1, 1)
end

return Unit