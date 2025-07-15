-- Arquivo para criar o projetil e aplicar a fisica nele
local Projectile = {}
Projectile.__index = Projectile

-- Construtor
function Projectile:new(config) -- Pq aqui usamos new ao inves de create?
    local proj = {}
    setmetatable(proj, self)

    proj.x = config.x or 0
    proj.y = config.y or 0
    proj.damage = config.damage or 10
    proj.speed = config.speed or 400 
    proj.target = config.target 
    proj.owner = config.owner 

    proj.asset = nil
    if love.filesystem.getInfo("assets/structures/allies/defenders/Projectiles/1.png") then
        proj.asset = love.graphics.newImage("assets/structures/allies/defenders/Projectiles/1.png")
    end
    proj.width = proj.asset and proj.asset:getWidth() or 10
    proj.height = proj.asset and proj.asset:getHeight() or 2

    -- Calcula a direção para o alvo
    local dx = proj.target.x - proj.x 
    local dy = proj.target.y - proj.y - proj.target.height / 4
    proj.angle = math.atan2(dy, dx)

    -- Calcula os componentes da velocidade
    proj.vx = math.cos(proj.angle) * proj.speed
    proj.vy = math.sin(proj.angle) * proj.speed
    
    proj.active = true 

    return proj
end

function Projectile:update(dt)
    if not self.active then return end

    -- Move o projétil
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Verificação de colisão simples (baseada em distância)
    local dist = math.sqrt((self.target.x - self.x)^2 + (self.target.y - self.y)^2)
    if dist < 50 then 
        if self.target.alive then
            self.target:takeDamage(self.damage)
        end
        self.active = false 
    end

    -- Remove se sair da tela 
    if self.x < -self.width or self.x > love.graphics.getWidth() + self.width then
        self.active = false
    end
end

function Projectile:draw()
    if not self.active then return end

    love.graphics.setColor(1, 1, 1)
    if self.asset then
        love.graphics.draw(self.asset, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
    else
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.angle)
        love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)
        love.graphics.pop()
    end
end

return Projectile