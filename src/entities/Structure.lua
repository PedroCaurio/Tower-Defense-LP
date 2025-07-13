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
            [1] = { health = 2000, spriteSheetPath = "assets/structures/allies/tower/1.png" },
            [2] = { health = 4000, spriteSheetPath = "assets/structures/allies/tower/2.png" },
            [3] = { health = 7000, spriteSheetPath = "assets/structures/allies/tower/3.png" },
        },
        grid = {w = 70, h = 130} -- Tamanho do frame do sprite da torre
    },
    enemy_base = {
        -- A ser preenchido com os dados da torre inimiga
        levels = {
            [1] = { health = 2000, spriteSheetPath = "assets/structures/enemies/tower/1.png" },
            [2] = { health = 4000, spriteSheetPath = "assets/structures/enemies/tower/2.png" },
            [3] = { health = 7000, spriteSheetPath = "assets/structures/enemies/tower/3.png" },
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

    local spritesheet = nil
    local structureAnimations = {}
    
    if love.filesystem.getInfo(levelData.spriteSheetPath) then
        spritesheet = love.graphics.newImage(levelData.spriteSheetPath)
        print(levelData.spriteSheetPath, spritesheet:getWidth(), spritesheet:getHeight(), type)
        local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())
        if type == "player_base" then
            structureAnimations.idle = anim8.newAnimation(grid('1-6', 1), 0.2):clone()
        end
        if type == "enemy_base" then
            structureAnimations.idle = anim8.newAnimation(grid('1-4', 1), 0.2):clone()
        end
    end
    
    -- ############ CORREÇÃO AQUI ############
    -- Adicionamos as propriedades width, height, color e spritesheet que estavam faltando.
    local structure = Unit:new({
        x = x, y = y,
        width = template.grid.w,
        height = template.grid.h,
        health = levelData.health,
        maxHealth = levelData.health,
        color = {0.7, 0.7, 0.8}, -- Uma cor padrão para o placeholder da torre
        animations = structureAnimations,
        flipped = (type == "enemy_base"),
        spritesheet = spritesheet
    })
    -- #######################################

    structure.type = type
    structure.level = level
    structure.state = 'idle'

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
    --self.animations.idle = anim8.newAnimation(grid('1-1', 1), 1):clone()
    if type == "player_base" then
        self.structureAnimations.idle = anim8.newAnimation(grid('1-9', 1), 0.2):clone()
    end
    if type == "enemy_base" then
        self.structureAnimations.idle = anim8.newAnimation(grid('1-4', 1), 0.2):clone()
    end
    
    print(self.type .. " evoluiu para o nível " .. self.level)
end

-- As funções takeDamage() e draw() foram REMOVIDAS, pois são herdadas de Unit.lua.

return Structure