-- Arquivo para gerenciar os projeteis

local Projectile = require("src.entities.Projectile")

local ProjectileManager = {}
ProjectileManager.__index = ProjectileManager

function ProjectileManager:new()
    local manager = {}
    setmetatable(manager, self)

    manager.projectiles = {}
    --print("ProjectileManager inicializado.")
    return manager
end

-- Função chamada por outras entidades (como o Arqueiro) para criar um projétil
function ProjectileManager:create(config)
    -- 'config' deve conter: x, y, damage, speed, target, owner
    local newProjectile = Projectile:new(config)
    table.insert(self.projectiles, newProjectile)
end

function ProjectileManager:update(dt)
    -- Percorre a lista de trás para frente para poder remover itens sem pular o próximo
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        proj:update(dt)

        -- Se o projétil ficou inativo (colidiu ou saiu da tela), remove-o da lista
        if not proj.active then
            table.remove(self.projectiles, i)
        end
    end
end

function ProjectileManager:draw()
    for _, proj in ipairs(self.projectiles) do
        proj:draw()
    end
end

return ProjectileManager