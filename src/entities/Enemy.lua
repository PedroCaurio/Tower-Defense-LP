local Enemy = {}
Enemy.__index = Enemy

-- Define os tipos de aliados com seus atributos
local EnemyTypes = {
    ["soldado"] = { speed = 50, health = 100, cost = 10, damage = 10, color = {0, 1, 0} },
    ["tank"]    = { speed = 30, health = 300, cost = 30, damage = 25, color = {1, 0, 0} },
    ["ninja"]   = { speed = 80, health = 70,  cost = 15, damage = 5,  color = {0, 0, 1} },
}

-- Construtor do Enemy
function Enemy.create(type, x, y)
    local stats = EnemyTypes[type]
    assert(stats, "Tipo de inimigo inválido: " .. tostring(type))

    local enemy = {
        type = type,
        x = x,
        y = y,
        speed = stats.speed,
        health = stats.health,
        maxHealth = stats.health,
        damage = stats.damage,
        cost = stats.cost,
        color = stats.color,
        alive = true,
        attackCooldown = 1,  -- 1 segundo entre ataques
        timeSinceAttack = 0
    }

    return setmetatable(enemy, Enemy)
end

-- Atualiza posição e ataque
function Enemy:update(dt, allies, structures)
    if not self.alive then return end

    self.timeSinceAttack = self.timeSinceAttack + dt

    -- Verifica se há inimigos próximos para atacar
    local attacked = false
    for _, ally in ipairs(allies) do
        if ally.alive and math.abs(self.x - ally.x) < 25 then
            -- Atacar se estiver perto o suficiente
            if self.timeSinceAttack >= self.attackCooldown then
                ally:takeDamage(self.damage)
                self.timeSinceAttack = 0
            end
            attacked = true
            break
        end
    end

    for _, structure in ipairs(structures) do
        if structure.alive and math.abs(self.x - structure.x) < 25 then
            -- Atacar se estiver perto o suficiente
            if self.timeSinceAttack >= self.attackCooldown then
                structure:takeDamage(self.damage)
                self.timeSinceAttack = 0
            end
            attacked = true
            break
        end
    end

    -- Se não atacou, continua andando
    if not attacked then
        self.x = self.x - self.speed * dt
    end
end

-- Desenha aliado e barra de vida
function Enemy:draw()
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

    -- Reset cor
    love.graphics.setColor(1, 1, 1)
end

-- Sofrer dano
function Enemy:takeDamage(dmg)
    self.health = self.health - dmg
    if self.health <= 0 then
        self.alive = false
    end
end

-- Retorna o custo do tipo
function Enemy.getCost(type)
    return EnemyTypes[type] and EnemyTypes[type].cost or math.huge
end

return Enemy
