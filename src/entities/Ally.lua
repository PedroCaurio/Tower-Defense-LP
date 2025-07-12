---Modulos
local Sprite = require("src.systems.Sprite")
local animation = require("src.systems.animation")

local allyTypes = {
    ["soldado"] = {
        speed = 50, health = 100, cost = 10, damage = 10, color = {0, 0.8, 0},
        -- sprite = Sprite:newSprite(
        -- animation:newAnimation(spritePath+"1/Idle.png", 48, 48, 1),
        -- animation:newAnimation(spritePath+"1/Attack.png", 48, 48, 1),
        -- animation:newAnimation(spritePath+"1/Preattack.png", 48, 48, 1)
        -- )
    },
    ["tank"]    = {
        speed = 30, health = 300, cost = 30, damage = 25, color = {0.8, 0, 0},
        -- sprite = Sprite:newSprite(
        -- animation:newAnimation(spritePath+"2/Idle.png", 48, 48, 1),
        -- animation:newAnimation(spritePath+"2/Attack.png", 48, 48, 1),
        -- animation:newAnimation(spritePath+"2/Preattack.png", 48, 48, 1)
        -- )
    },
    ["ninja"]   = {
        speed = 80, health = 70,  cost = 15, damage = 5,  color = {0, 0, 0.8},
        -- sprite = Sprite:newSprite(
        -- animation:newAnimation(spritePath+"3/Idle.png", 48, 48, 1),
        -- animation:newAnimation(spritePath+"3/Attack.png", 72, 48, 1),
        -- animation:newAnimation(spritePath+"3/Preattack.png", 48, 48, 1)
        -- )
    },
}

---Início do módulo de aliados
local Ally = {
}
Ally.__index = Ally

-- Define os tipos de aliados com seus atributos


-- Construtor do Ally
function Ally.create(type, x, y)
    local stats = allyTypes[type]
    assert(stats, "Tipo de aliado inválido: " .. tostring(type))

    local allySpritePath = string.format("assets/allies/defenders/%s/", type)
    local ally = {
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
        timeSinceAttack = 0,
        sprite = Sprite:newSprite(
            animation:newAnimation(allySpritePath.."Idle.png", 48, 48, 1),
            animation:newAnimation(allySpritePath.."Attack.png", 48, 48, 1),
            animation:newAnimation(allySpritePath.."Preattack.png", 48, 48, 1),
            true
        ),
    }

    return setmetatable(ally, Ally)
end

-- Atualiza posição e ataque
function Ally:update(dt, enemies)
    if not self.alive then return end

    self.sprite:update(dt)
    self.timeSinceAttack = self.timeSinceAttack + dt

    -- Verifica se há inimigos próximos para atacar
    local attacked = false
    for _, enemy in ipairs(enemies) do
        if enemy.alive and math.abs(self.x - enemy.x) < 25 then
            -- Atacar se estiver perto o suficiente
            if self.timeSinceAttack >= self.attackCooldown then
                -- self.sprite:setState(Sprite.attack)
                enemy:takeDamage(self.damage)
                self.timeSinceAttack = 0
            end
            else
                self.sprite:setState(Sprite.attack)
                attacked = true
            break
        end
    end

    -- Se não atacou, continua andando
    if not attacked then
        self.x = self.x + self.speed * dt
        self.sprite:setState(Sprite.idle)
    end
end

-- Desenha aliado e barra de vida
function Ally:draw()
    if not self.alive then return end

    -- Corpo
    -- love.graphics.setColor(self.color)
    -- love.graphics.rectangle("fill", self.x, self.y, 20, 20)
    self.sprite:draw(self.x, self.y)

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
function Ally:takeDamage(dmg)
    self.health = self.health - dmg
    if self.health <= 0 then
        self.alive = false
    end
end

-- Retorna o custo do tipo
function Ally.getCost(type)
    return type and allyTypes[type].cost or math.huge
end

return Ally
