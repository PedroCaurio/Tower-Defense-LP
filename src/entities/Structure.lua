-- src/entities/Structure.lua

-- 1. Módulos necessários
local Unit = require("src.entities.Unit")
local anim8 = require("lib.anim8.anim8")

-- 2. Classe Structure, herdando de Unit.
local Structure = {}
setmetatable(Structure, {__index = Unit})
Structure.__index = Structure

-- 3. Configuração Central das Estruturas (Data-Driven Design)
-- Define os atributos para cada nível da torre, incluindo a imagem a ser usada.
local structureTypes = {
    player_base = {
        -- Define os atributos para cada nível da torre do jogador
        levels = {
            [1] = { health = 2000, spriteSheetPath = "assets/allies/tower/1.png" },
            [2] = { health = 4000, spriteSheetPath = "assets/allies/tower/2.png" },
            [3] = { health = 7000, spriteSheetPath = "assets/allies/tower/3.png" },
        },
        grid = {w = 70, h = 130} -- Tamanho do frame do sprite da torre
    },
    enemy_base = {
        -- A ser preenchido com os dados da torre inimiga
        levels = {
            [1] = { health = 2000, spriteSheetPath = "assets/enemies/tower/1.png" },
            [2] = { health = 4000, spriteSheetPath = "assets/enemies/tower/2.png" },
            [3] = { health = 7000, spriteSheetPath = "assets/enemies/tower/3.png" },
        },
        grid = {w = 70, h = 130}
    }
}

-- Construtor da Structure
function Structure.create(type, x, y, level)
    level = level or 1
    local template = structureTypes[type]
    local levelData = template.levels[level]
    assert(template and levelData, "Tipo ou nível de estrutura inválido: " .. tostring(type) .. " Lvl " .. tostring(level))

    -- Carrega a spritesheet e cria o grid de animação
    local spritesheet = love.graphics.newImage(levelData.spriteSheetPath)
    local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())
    
    local structureAnimations = {
        -- Estruturas podem ter apenas um estado 'idle' (parado)
        idle = anim8.newAnimation(grid('1-1', 1), 1):clone()
        -- Futuramente, podemos adicionar um estado 'destroyed'
    }

    -- 4. Cria a instância usando o construtor de Unit, passando a configuração completa
    local structure = Unit:new({
        x = x, y = y,
        health = levelData.health,
        maxHealth = levelData.health,
        animations = structureAnimations,
        -- Estruturas não são viradas. A torre inimiga usará um asset já virado.
        flipped = false 
    })

    -- Adiciona propriedades específicas da Estrutura
    structure.type = type
    structure.level = level
    structure.state = 'idle' -- O estado padrão é 'idle'

    return setmetatable(structure, Structure)
end

-- 5. Atualização simplificada
-- A estrutura não se move, então sua lógica de update é bem simples.
function Structure:update(dt)
    -- Apenas precisamos chamar o update da classe pai para a animação funcionar.
    Unit.update(self, dt)
    -- Lógica de ataque pode ser adicionada aqui no futuro se a torre atacar.
end

-- 6. Novo método para evoluir a torre
function Structure:levelUp()
    local template = structureTypes[self.type]
    local nextLevel = self.level + 1
    
    local nextLevelData = template.levels[nextLevel]
    if not nextLevelData then
        print("A estrutura já está no nível máximo!")
        return
    end

    -- Atualiza o nível e os status
    self.level = nextLevel
    self.maxHealth = nextLevelData.health
    self.health = self.health + (nextLevelData.health - template.levels[nextLevel - 1].health) -- Aumenta a vida

    -- Atualiza o visual (animação)
    local spritesheet = love.graphics.newImage(nextLevelData.spriteSheetPath)
    local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())
    self.animations.idle = anim8.newAnimation(grid('1-1', 1), 1):clone()
    
    print(self.type .. " evoluiu para o nível " .. self.level)
end

-- As funções takeDamage() e draw() foram REMOVIDAS, pois são herdadas de Unit.lua.

return Structure