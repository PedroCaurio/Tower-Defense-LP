-- src/entities/Enemy.lua

-- 1. Importa a classe base Unit
local Unit = require("src.entities.Unit")

-- 2. Cria a classe Enemy e a faz herdar de Unit
local Enemy = {}
setmetatable(Enemy, {__index = Unit})
Enemy.__index = Enemy

-- Tabela de atributos específicos para cada tipo de Inimigo
local enemyTypes = {
    ["soldado"] = { speed = 50, health = 100, cost = 10, damage = 10, color = {0.8, 0.5, 0} }, -- Cor diferente para distinguir
    ["tank"]    = { speed = 30, health = 300, cost = 30, damage = 25, color = {0.5, 0.2, 0.2} },
    ["ninja"]   = { speed = 80, health = 70,  cost = 15, damage = 5,  color = {0.3, 0.3, 0.3} },
}

-- Construtor do Enemy
function Enemy.create(type, x, y)
    local stats = enemyTypes[type]
    assert(stats, "Tipo de inimigo inválido: " .. tostring(type))

    -- 3. Prepara a configuração para passar para o construtor da classe pai (Unit)
    local config = {
        x = x, y = y,
        speed = stats.speed,
        health = stats.health,
        damage = stats.damage,
        cost = stats.cost, -- Custo para a IA, pode ser útil no futuro
        color = stats.color
    }

    -- 4. Cria a instância base usando Unit:new e depois define a metatable para Enemy
    local enemy = Unit:new(config)
    setmetatable(enemy, Enemy)
    enemy.type = type
    
    return enemy
end

-- Atualiza a lógica do Enemy, agora com capacidade de atacar aliados e a estrutura
function Enemy:update(dt, allies, structure)
    if not self.alive then return end

    self.timeSinceAttack = self.timeSinceAttack + dt
    local attacked = false

    -- Prioridade 1: Atacar aliados próximos
    for _, ally in ipairs(allies) do
        if ally.alive and math.abs(self.x - ally.x) < 25 then
            if self.timeSinceAttack >= self.attackCooldown then
                ally:takeDamage(self.damage)
                self.timeSinceAttack = 0
            end
            attacked = true
            break
        end
    end

    -- Prioridade 2: Se não atacou um aliado, verifica se pode atacar a estrutura
    if not attacked and structure and structure.alive and math.abs(self.x - structure.x) < 40 then
        if self.timeSinceAttack >= self.attackCooldown then
            structure:takeDamage(self.damage)
            self.timeSinceAttack = 0
        end
        attacked = true
    end

    -- Se não atacou ninguém, continua andando para a esquerda
    if not attacked then
        self.x = self.x - self.speed * dt
    end
end

-- Função estática para obter o custo de um tipo de inimigo (pode ser útil no WaveManager)
function Enemy.getCost(type)
    return enemyTypes[type] and enemyTypes[type].cost or math.huge
end

return Enemy