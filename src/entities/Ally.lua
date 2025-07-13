-- src/entities/Ally.lua

-- 1. Módulos necessários
local Unit = require("src.entities.Unit")
local anim8 = require("lib.anim8.anim8")

-- 2. Classe Ally, herdando de Unit.
local Ally = {}
setmetatable(Ally, {__index = Unit})
Ally.__index = Ally

-- 3. Configuração Central de Tropas (Data-Driven Design)
-- Esta tabela é a fonte da verdade para todas as tropas aliadas.
-- NOTA: Os caminhos dos assets e os frames das animações são placeholders. Ajuste-os conforme seus arquivos.
local allyTypes = {
    soldado = {
        stats = { speed = 50, health = 100, damage = 10 },
        costFood = 10,
        attackType = 'melee',
        attackRange = 35,
        spriteSheetPath = "assets/allies/defenders/soldado/spritesheet.png", -- Exemplo de caminho
        grid = {w = 64, h = 64}, -- Largura e altura de cada frame
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-6', 1), 0.1) end,
            attack = function(g) return anim8.newAnimation(g('1-4', 2), 0.15) end,
            idle = function(g) return anim8.newAnimation(g('1-4', 3), 0.2) end
        }
    },
    tank = {
        stats = { speed = 30, health = 300, damage = 15 },
        costFood = 30,
        attackType = 'melee',
        attackRange = 35,
        spriteSheetPath = "assets/allies/defenders/tank/spritesheet.png",
        grid = {w = 64, h = 64},
        animations = {
            walk = function(g) return anim8.newAnimation(g('1-1', 1), 0.2) end,
            attack = function(g) return anim8.newAnimation(g('1-1', 1), 0.2) end,
            idle = function(g) return anim8.newAnimation(g('1-1', 1), 0.2) end
        }
    },
    arqueiro = {
        stats = { speed = 40, health = 70, damage = 12 },
        costFood = 25,
        attackType = 'ranged',
        attackRange = 250,
        spriteSheetPath = "assets/allies/defenders/arqueiro/spritesheet.png",
        grid = {w = 64, h = 64},
        animations = {} -- A preencher
    },
    ninja = {
        stats = { speed = 80, health = 80, damage = 20 },
        costFood = 25,
        attackType = 'melee',
        attackRange = 40,
        spriteSheetPath = "assets/allies/defenders/ninja/spritesheet.png",
        grid = {w = 64, h = 64},
        animations = {} -- A preencher
    },
    rei = {
        stats = { speed = 35, health = 800, damage = 50 },
        costFood = 100,
        attackType = 'melee',
        attackRange = 45,
        spriteSheetPath = "assets/allies/defenders/rei/spritesheet.png",
        grid = {w = 64, h = 64},
        animations = {} -- A preencher
    }
}

-- Construtor do Ally
function Ally.create(type, x, y, level, bonuses)
    local template = allyTypes[type]
    assert(template, "Tipo de aliado inválido: " .. tostring(type))
    
    level = level or 1
    bonuses = bonuses or {}

    local finalStats = {
        speed = template.stats.speed,
        health = (template.stats.health + (bonuses.health or 0)) * (1.15 ^ (level - 1)),
        damage = (template.stats.damage + (bonuses.damage or 0)) * (1.15 ^ (level - 1)),
        color = template.stats.color -- Pega a cor dos stats
    }
    local allyAnimations = {}
    local spritesheet = nil
    -- Carrega a spritesheet e cria o grid de animação
    -- Fazemos isso aqui para que cada tipo de tropa carregue sua imagem apenas uma vez (a ser otimizado depois)
    -- Verificamos se o arquivo de imagem existe ANTES de tentar carregá-lo.
    if love.filesystem.getInfo(template.spriteSheetPath) then
        spritesheet = love.graphics.newImage(template.spriteSheetPath)
        local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())
        
        for name, creator in pairs(template.animations) do
            -- Usamos pcall para capturar erros caso a animação peça um frame que não existe
            local ok, anim = pcall(function() return creator(grid):clone() end)
            if ok then
                allyAnimations[name] = anim
            else
                print("AVISO: Falha ao criar animação '" .. name .. "' para a tropa '" .. type .. "'. Verifique os frames no spritesheet.")
            end
        end
    else
        print("AVISO: Asset não encontrado para a tropa '" .. type .. "'. Usando placeholder.")
    end

    -- Cria a instância base, passando a configuração completa para Unit:new
    local ally = Unit:new({
        x = x, y = y,
        speed = finalStats.speed,
        health = finalStats.health,
        maxHealth = finalStats.health,
        damage = finalStats.damage,
        cost = template.costFood,
        color = finalStats.color, -- Passa a cor para o Unit
        animations = allyAnimations,
        flipped = false,
        spritesheet = spritesheet
    })
    
    -- Adiciona as propriedades restantes, específicas do Ally
    ally.type = type
    ally.level = level
    ally.attackType = template.attackType
    ally.attackRange = template.attackRange
    ally.state = 'walking' -- Estado inicial
    
    return setmetatable(ally, Ally)
end

-- 4. Função update simplificada
function Ally:update(dt, enemies)
    if not self.alive then return end

    -- Primeiro, delega a atualização da animação para a classe pai
    Unit.update(self, dt)

    -- Lógica de IA e mudança de estado
    local target = self:findTarget(enemies)

    if target then
        self.state = 'attacking'
    else
        self.state = 'walking'
    end

    -- Lógica de movimento e ataque
    if self.state == 'walking' then
        self.x = self.x + self.speed * dt
    elseif self.state == 'attacking' then
        self.timeSinceAttack = self.timeSinceAttack + dt
        if self.timeSinceAttack >= self.attackCooldown then
            -- Futuramente, aqui você verificará o self.attackType
            target:takeDamage(self.damage)
            self.timeSinceAttack = 0
        end
    end
end

function Ally:findTarget(enemies)
    for _, enemy in ipairs(enemies) do
        if enemy.alive and math.abs(self.x - enemy.x) < self.attackRange then
            return enemy
        end
    end
    return nil
end

-- 5. A FUNÇÃO DRAW FOI REMOVIDA.
-- Agora, Ally herda o método draw de Unit, que já desenha a animação e a barra de vida.
-- Menos código, menos bugs!

-- Função para obter o custo em comida
function Ally.getFoodCost(type)
    return allyTypes[type] and allyTypes[type].costFood or math.huge
end

return Ally