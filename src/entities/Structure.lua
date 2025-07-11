-- Structure.lua

local Structure = {}
Structure.__index = Structure

-- Tipos de estruturas pré-definidas (pode expandir depois)
local StructureTypes = {
    ["base"] = { width = 32, height = 128, health = 200, cost = 50, attackDamage = 0, attackRange = 0, attackSpeed = 0, color = {1, 1, 1} },
    -- Você pode adicionar mais tipos aqui no futuro
}

-- Construtor
function Structure.create(type, x, y)
    local stats = StructureTypes[type]
    assert(stats, "Tipo de estrutura inválido: " .. tostring(type))

    local structure = {
        type = type,
        x = x,
        y = y,
        width = stats.width,
        height = stats.height,
        health = stats.health,
        maxHealth = stats.health,
        cost = stats.cost,
        alive = true,
        attackDamage = stats.attackDamage,
        attackRange = stats.attackRange,
        attackSpeed = stats.attackSpeed,
        timeSinceLastAttack = 0,
        color = stats.color,
        image = nil  -- Pode ser configurado externamente se quiser imagem
    }

    return setmetatable(structure, Structure)
end

-- Atualiza estrutura
function Structure:update(dt)
    if not self.alive then return end

    if self.attackDamage > 0 and self.attackRange > 0 then
        self.timeSinceLastAttack = self.timeSinceLastAttack + dt
        if self.timeSinceLastAttack >= (1 / self.attackSpeed) then
            self:performAttack()
            self.timeSinceLastAttack = 0
        end
    end

    if self.health <= 0 then
        self.health = 0
        self.alive = false
        self:onDeath()
    end
end

-- Desenha estrutura e vida
function Structure:draw()
    if not self.alive then return end

    if self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 2)
    else
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    end

    -- Barra de vida
    local barWidth = 40
    local barHeight = 5
    local currentWidth = (self.health / self.maxHealth) * barWidth
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", self.x - barWidth / 2, self.y - self.height / 2 - 10, barWidth, barHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x - barWidth / 2, self.y - self.height / 2 - 10, currentWidth, barHeight)

    love.graphics.setColor(1, 1, 1) -- Reset cor
end

-- Recebe dano
function Structure:takeDamage(amount)
    if not self.alive then return end
    self.health = self.health - amount
    if self.health <= 0 then
        self.health = 0
        self.alive = false
        self:onDeath()
    end
end

-- Ataque (placeholder)
function Structure:performAttack()
    -- Implementação futura se quiser ataque automático
end

-- Ao morrer
function Structure:onDeath()
    print(self.type .. " at (" .. self.x .. ", " .. self.y .. ") has been destroyed!")
end

-- Custo
function Structure.getCost(type)
    return StructureTypes[type] and StructureTypes[type].cost or math.huge
end

return Structure