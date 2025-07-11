-- Conceito para Projectile.lua
local Projectile = {}

function Projectile.create(x, y, target, damage)
    -- ...
    -- Calcula a velocidade em direção ao alvo
    local angle = math.atan2(target.y - y, target.x - x)
    proj.velocityX = math.cos(angle) * speed
    proj.velocityY = math.sin(angle) * speed
    -- ...
end

function Projectile:update(dt)
    self.x = self.x + self.velocityX * dt
    self.y = self.y + self.velocityY * dt
    -- Lógica de colisão com alvos
end