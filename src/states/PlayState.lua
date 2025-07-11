-- src/states/PlayState.lua
local Gamestate = require "lib.hump-master.gamestate"

local Ally = require("src.entities.Ally")
local Enemy = require("src.entities.Enemy")
local Structure = require("src.entities.Structure")
local Button = require("src.ui.Button")

local PlayState = {}
PlayState.__index = PlayState

-- ############### NOVA FUNÇÃO AUXILIAR ###############
-- Esta função cria/recria os botões do painel de upgrade.
-- Ela será chamada apenas quando precisarmos atualizar a UI dos upgrades.
function PlayState:rebuildUpgradeUI()
    self.uiUpgradeElements = {} -- Limpa a lista antiga
    if not self.isUpgradePanelOpen then return end -- Se o painel está fechado, não faz nada

    local yPos = 120
    for key, upgrade in pairs(self.upgrades) do
        local cost = math.floor(upgrade.baseCost * (upgrade.costMultiplier ^ upgrade.level))
        local text = upgrade.name .. " (Lvl " .. upgrade.level .. ")\nCusto: $" .. cost
        
        local currentKey = key
        local btn = Button.create(200, yPos, love.graphics.getWidth() - 400, 60, text, function()
            self:purchaseUpgrade(currentKey)
        end)
        
        table.insert(self.uiUpgradeElements, btn)
        yPos = yPos + 80
    end
end
-- ######################################################

function PlayState:load()
    local state = {
        allies = {},
        enemies = {},
        structures = {},
        uiSpawnElements = {},
        uiUpgradeElements = {}, -- Começa vazia
        isUpgradePanelOpen = false,
        money = 150,
        enemySpawnTimer = 0,
        enemySpawnInterval = 5
    }
    setmetatable(state, PlayState)

    state.upgrades = {
        soldierDamage = { name = "Dano Soldado", level = 0, baseCost = 50, costMultiplier = 1.6, value = 5 },
        income = { name = "Renda Passiva", level = 0, baseCost = 100, costMultiplier = 2, value = 2 },
        baseHealth = { name = "Vida da Base", level = 0, baseCost = 75, costMultiplier = 1.8, value = 250 }
    }

    local playerStructure = Structure.create("base", 80, love.graphics.getHeight() - 150)
    table.insert(state.structures, playerStructure)

    local function spawnAlly(allyType)
        local bonusDamage = state.upgrades.soldierDamage.level * state.upgrades.soldierDamage.value
        local bonusHealth = 0
        local allyCost = Ally.getCost(allyType)
        if state.money >= allyCost then
            table.insert(state.allies, Ally.create(allyType, 120, love.graphics.getHeight() - 100, bonusDamage, bonusHealth))
            state.money = state.money - allyCost
        end
    end

    table.insert(state.uiSpawnElements, Button.create(10, 100, 120, 40, "Soldado", function() spawnAlly("soldado") end))
    table.insert(state.uiSpawnElements, Button.create(10, 150, 120, 40, "Tank", function() spawnAlly("tank") end))
    table.insert(state.uiSpawnElements, Button.create(10, 200, 120, 40, "Ninja", function() spawnAlly("ninja") end))
    
    -- ############### MUDANÇA NA LÓGICA DO BOTÃO ###############
    -- Agora, além de mudar a flag, ele chama a função para construir a UI.
    table.insert(state.uiSpawnElements, Button.create(10, 280, 120, 50, "UPGRADES", function()
        state.isUpgradePanelOpen = not state.isUpgradePanelOpen
        state:rebuildUpgradeUI()
    end))

    return state
end

function PlayState:purchaseUpgrade(upgradeType)
    local upgrade = self.upgrades[upgradeType]
    if not upgrade then return end
    local cost = math.floor(upgrade.baseCost * (upgrade.costMultiplier ^ upgrade.level))

    if self.money >= cost then
        self.money = self.money - cost
        upgrade.level = upgrade.level + 1

        if upgradeType == "baseHealth" then
            local structure = self.structures[1]
            structure.maxHealth = structure.maxHealth + upgrade.value
            structure.health = structure.health + upgrade.value
        end
        print("Upgrade '" .. upgrade.name .. "' comprado! Nível: " .. upgrade.level)
        
        -- ############### ATUALIZA A UI APÓS A COMPRA ###############
        self:rebuildUpgradeUI()
    else
        print("Dinheiro insuficiente para o upgrade: " .. upgrade.name)
    end
end

function PlayState:update(dt)
    print("No início do update, o tipo de Enemy é: " .. type(Enemy)) -- <<< ADICIONE ESTA LINHA

    local playerStructure = self.structures[1]
    if not playerStructure.alive then
        Gamestate.switch(require("src.states.GameOverState"))
        return
    end

    if not self.isUpgradePanelOpen then
        playerStructure:update(dt)

        -- Atualiza aliados
        for i = #self.allies, 1, -1 do
            local ally = self.allies[i]
            ally:update(dt, self.enemies)
            if not ally.alive or ally.x > love.graphics.getWidth() then
                table.remove(self.allies, i)
            end
        end

        -- Atualiza inimigos
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i] -- Note o 'e' minúsculo, que é o correto.
            enemy:update(dt, self.allies, playerStructure)

            -- Verifica se o inimigo morreu ou saiu da tela
            if not enemy.alive or enemy.x < 0 then
                -- Se o inimigo foi derrotado (e não apenas saiu da tela), dá a recompensa.
                if not enemy.alive then
                    self.money = self.money + (enemy.reward or 0)
                end
                -- Remove o inimigo do jogo
                table.remove(self.enemies, i)
            end
        end

        -- Lógica de economia e spawn
        local incomeValue = 5 + (self.upgrades.income.level * self.upgrades.income.value)
        self.money = self.money + incomeValue * dt
        
        self.enemySpawnTimer = self.enemySpawnTimer + dt
        if self.enemySpawnTimer >= self.enemySpawnInterval then
            self:spawnEnemy()
            self.enemySpawnTimer = 0
        end
    end
    
    -- Atualiza UI
    for _, element in ipairs(self.uiSpawnElements) do element:update(dt) end
    if self.isUpgradePanelOpen then
        for _, element in ipairs(self.uiUpgradeElements) do element:update(dt) end
    end
end

function PlayState:draw()
    love.graphics.clear(0.4, 0.5, 0.6)

    for _, s in ipairs(self.structures) do s:draw() end
    for _, a in ipairs(self.allies) do a:draw() end
    for _, e in ipairs(self.enemies) do e:draw() end

    local incomeValue = 5 + (self.upgrades.income.level * self.upgrades.income.value)
    love.graphics.print("Dinheiro: $" .. math.floor(self.money), 10, 10)
    love.graphics.print("Renda: $" .. incomeValue .. "/s", 10, 30)
    for _, element in ipairs(self.uiSpawnElements) do element:draw() end
    
    -- ############### FUNÇÃO DRAW SIMPLIFICADA ###############
    -- Agora ela apenas desenha, sem criar nada.
    if self.isUpgradePanelOpen then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 150, 50, love.graphics.getWidth() - 300, love.graphics.getHeight() - 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Painel de Upgrades", 150, 60, love.graphics.getWidth() - 300, "center")
        
        for _, element in ipairs(self.uiUpgradeElements) do element:draw() end
    end

    love.graphics.setColor(1, 1, 1)
end

function PlayState:mousepressed(x, y, button)
    if button ~= 1 then return end

    if self.isUpgradePanelOpen then
        for _, element in ipairs(self.uiUpgradeElements) do element:mousepressed(x, y, button) end
    end
    for _, element in ipairs(self.uiSpawnElements) do element:mousepressed(x, y, button) end
end

function PlayState:keypressed(key)
    if key == "escape" then
        Gamestate.switch(require("src.states.MenuState"))
    end
end

function PlayState:spawnEnemy()
    print("No início do spawnEnemy, o tipo de Enemy é: " .. type(Enemy)) -- <<< ADICIONE ESTA LINHA

    local enemyTypes = {"soldado", "tank", "ninja"}
    local randomType = enemyTypes[love.math.random(#enemyTypes)]
    local x = love.graphics.getWidth() + 20
    local y = love.graphics.getHeight() - 100
    
    -- Esta linha usa 'Enemy' (maiúsculo), que é a referência correta ao módulo.
    table.insert(self.enemies, Enemy.create(randomType, x, y))
end

return PlayState