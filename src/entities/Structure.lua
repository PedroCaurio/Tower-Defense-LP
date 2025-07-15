-- src/entities/Structure.lua

local Unit = require("src.entities.Unit")
local anim8 = require("lib.anim8.anim8")

local Structure = {}
setmetatable(Structure, {__index = Unit})
Structure.__index = Structure

-- Dados de configuração (data-driven)
local structureTypes = {
    player_base = {
        levels = {
            [1] = { health = 2000, spriteSheetPath = "assets/structures/allies/tower/1.png" },
            [2] = { health = 4000, spriteSheetPath = "assets/structures/allies/tower/2.png" },
            [3] = { health = 7000, spriteSheetPath = "assets/structures/allies/tower/3.png" },
        },
        grid = {w = 70, h = 130}
    },
    enemy_base = {
        levels = {
            [1] = { health = 2000, spriteSheetPath = "assets/structures/enemies/tower/1.png" },
            [2] = { health = 4000, spriteSheetPath = "assets/structures/enemies/tower/2.png" },
            [3] = { health = 7000, spriteSheetPath = "assets/structures/enemies/tower/3.png" },
        },
        grid = {w = 70, h = 130}
    }
}

-- Cria uma nova estrutura
function Structure.create(type, x, y, level)
    level = level or 1
    local template = structureTypes[type]
    assert(template, "Tipo de estrutura inválido: " .. tostring(type))
    local levelData = template.levels[level]
    assert(levelData, "Nível inválido para estrutura: " .. tostring(level))

    local spritesheet = nil
    local animations = {}

    if love.filesystem.getInfo(levelData.spriteSheetPath) then
        spritesheet = love.graphics.newImage(levelData.spriteSheetPath)
        local grid = anim8.newGrid(template.grid.w, template.grid.h, spritesheet:getWidth(), spritesheet:getHeight())

        if type == "player_base" then
            animations.idle = anim8.newAnimation(grid('1-6', 1), 0.2):clone()
        elseif type == "enemy_base" then
            animations.idle = anim8.newAnimation(grid('1-4', 1), 0.2):clone()
        end
    end

    local structure = Unit:new({
        x = x, y = y,
        width = template.grid.w,
        height = template.grid.h,
        health = levelData.health,
        maxHealth = levelData.health,
        cost = math.huge,
        color = {0.7, 0.7, 0.8},
        animations = animations,
        flipped = (type == "enemy_base"),
        spritesheet = spritesheet
    })

    structure.type = type
    structure.level = level
    structure.state = "idle"

    return setmetatable(structure, Structure)
end

-- Atualização da estrutura
function Structure:update(dt)
    Unit.update(self, dt)
end

-- Evolui a estrutura para o próximo nível
function Structure:levelUp()
    local template = structureTypes[self.type]
    local nextLevel = self.level + 1
    local nextLevelData = template.levels[nextLevel]

    if not nextLevelData then
        print("A estrutura já está no nível máximo!")
        return
    end

    -- Atualiza a vida
    local oldMaxHealth = self.maxHealth
    self.level = nextLevel
    self.maxHealth = nextLevelData.health
    self.health = self.health + (self.maxHealth - oldMaxHealth)

    -- Troca a spritesheet e animação
    if love.filesystem.getInfo(nextLevelData.spriteSheetPath) then
        self.spritesheet = love.graphics.newImage(nextLevelData.spriteSheetPath)
        local grid = anim8.newGrid(template.grid.w, template.grid.h, self.spritesheet:getWidth(), self.spritesheet:getHeight())

        if self.type == "player_base" then
            self.animations.idle = anim8.newAnimation(grid('1-6', 1), 0.2):clone()
        elseif self.type == "enemy_base" then
            self.animations.idle = anim8.newAnimation(grid('1-4', 1), 0.2):clone()
        end
    end

    print(self.type .. " evoluiu para o nível " .. self.level)
end

return Structure
