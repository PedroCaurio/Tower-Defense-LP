-- src/states/PlayState.lua
local Gamestate = require "lib.hump.gamestate"

local Ally = require("src.entities.Ally")
local Enemy = require("src.entities.Enemy")
local Structure = require("src.entities.Structure")
local Button = require("src.ui.Button")

local WaveManager = require("src.systems.WaveManager")
-- local ProjectileManager = require("src.entities.Projectile") -- Descomente quando for implementar
-- local AIController = require("src.systems.AIController") -- Descomente quando for implementar

local PlayState = {}
PlayState.__index = PlayState

--------------------------------------------------------------------------------
-- FUNÇÕES DE SETUP E LÓGICA INTERNA
--------------------------------------------------------------------------------

function PlayState:rebuildUpgradeUI()
    self.uiUpgradeElements = {}
    if not self.isUpgradePanelOpen then return end
    -- A UI é construída dinamicamente dentro da função de desenho para sempre estar atualizada.
end

function PlayState:purchaseUpgrade(upgradeKey)
    local upgrade = self.upgrades[upgradeKey]
    if not upgrade then
        print("Erro: Tentativa de comprar upgrade inexistente: " .. upgradeKey)
        return
    end

    local cost = upgrade.getCost(self)

    if self.player.gold >= cost then
        if upgrade.canPurchase(self) then
            self.player.gold = self.player.gold - cost
            upgrade.apply(self)
            print("Upgrade comprado: " .. upgrade.name)
        else
            print("Não pode comprar: " .. (upgrade.disabledReason or "Requisitos não atendidos"))
        end
    else
        print("Ouro insuficiente para: " .. upgrade.name)
    end
end

--------------------------------------------------------------------------------
-- MÉTODOS DO GAMELOOP PRINCIPAL
--------------------------------------------------------------------------------

function PlayState:load()
    local state = {}
    setmetatable(state, PlayState)

    state.player = {
        gold = 999999900, food = 50, foodMax = 100, foodPerSecond = 2,
        towerLevel = 1,
        unlockedTroops = { soldado = true, tank = false, arqueiro = false, ninja = false, rei = false },
        troopLevels = { soldado = 1, tank = 1, arqueiro = 1, ninja = 1, rei = 1 }
    }
    state.ai = {
        towerLevel = 1,
        unlockedTroops = { soldado = true, tank = true, ninja = false },
        troopLevels = { soldado = 1, tank = 1, ninja = 1 },
        gold = 200,
    }

    

    state.allies, state.enemies, state.projectiles, state.structures = {}, {}, {}, {}
    state.playerStructure = Structure.create("player_base", 80, love.graphics.getHeight() - 198, state.player.towerLevel)
    state.enemyStructure = Structure.create("enemy_base", love.graphics.getWidth() - 80, love.graphics.getHeight() - 198, state.ai.towerLevel)
    table.insert(state.structures, state.playerStructure)
    table.insert(state.structures, state.enemyStructure)

    state.waveManager = WaveManager:new()
    
    state.uiSpawnElements, state.uiUpgradeElements = {}, {}
    state.isUpgradePanelOpen = false

    state:initializeUpgrades()
    state:rebuildSpawnUI()

    return state
end

function PlayState:update(dt)
    if not self.playerStructure.alive then
        Gamestate.switch(require("src.states.GameOverState"))
        return
    end
    if not self.enemyStructure.alive then
        print("VITÓRIA!")
        Gamestate.switch(require("src.states.MenuState"))
        return
    end

    if not self.isUpgradePanelOpen then
        self.player.food = math.min(self.player.foodMax, self.player.food + self.player.foodPerSecond * dt)
        
        -- ############ MUDANÇA IMPORTANTE ############
        -- O WaveManager agora controla o fluxo do jogo e chama a função de spawn quando necessário.
        self.waveManager:update(dt, self)
        -- ##########################################
        
        for _, s in ipairs(self.structures) do s:update(dt) end
        -- for _, p in ipairs(self.projectiles) do p:update(dt) end

        for i = #self.allies, 1, -1 do
            local ally = self.allies[i]
            ally:update(dt, self.enemies, self.enemyStructure)
            if not ally.alive then table.remove(self.allies, i) end
        end

        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            enemy:update(dt, self.allies, self.playerStructure)
            if not enemy.alive then
                self.player.gold = self.player.gold + (enemy.reward or 0)
                table.remove(self.enemies, i)
            end
        end
    end

    for _, element in ipairs(self.uiSpawnElements) do element:update(dt) end
    if self.isUpgradePanelOpen then
        for _, element in ipairs(self.uiUpgradeElements) do element:update(dt) end
    end
end

function PlayState:draw()
    love.graphics.clear(0.4, 0.5, 0.6)

    for _, s in ipairs(self.structures) do s:draw() end
    -- for _, p in ipairs(self.projectiles) do p:draw() end
    for _, a in ipairs(self.allies) do a:draw() end
    for _, e in ipairs(self.enemies) do e:draw() end
    
    love.graphics.print("Ouro: " .. math.floor(self.player.gold), 10, 10)
    love.graphics.print("Comida: " .. math.floor(self.player.food) .. "/" .. self.player.foodMax, 10, 30)
    love.graphics.print("Wave: " .. self.waveManager.waveNumber, love.graphics.getWidth() / 2 - 30, 10)
    for _, element in ipairs(self.uiSpawnElements) do element:draw() end
    
    if self.isUpgradePanelOpen then
        self:drawUpgradePanel()
    end
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
        if self.isUpgradePanelOpen then
            self.isUpgradePanelOpen = false
        else
            Gamestate.switch(require("src.states.MenuState"))
        end
    end
end

--------------------------------------------------------------------------------
-- LÓGICA DE SPAWN E UI
--------------------------------------------------------------------------------

function PlayState:spawnAlly(allyType)
    if not self.player.unlockedTroops[allyType] then
        print("Tropa bloqueada: " .. allyType)
        return
    end

    local cost = Ally.getFoodCost(allyType)
    if self.player.food >= cost then
        self.player.food = self.player.food - cost
        local level = self.player.troopLevels[allyType]
        local bonuses = { damage = 0, health = 0 }
        table.insert(self.allies, Ally.create(allyType, 120, love.graphics.getHeight() - 100, level, bonuses))
    else
        print("Comida insuficiente.")
    end
end

-- ############ FUNÇÃO REMOVIDA ############
-- A antiga função 'spawnEnemy' que criava inimigos aleatórios foi removida.
-- #########################################

-- ############ NOVA FUNÇÃO ############
-- Esta é a nova função que o WaveManager usará para criar inimigos específicos.
function PlayState:spawnEnemyFromWave(enemyType)
    local x = love.graphics.getWidth() + 40
    local y = love.graphics.getHeight() - 100

    local level = self.ai.troopLevels[enemyType] or 1
    local bonuses = {} -- A IA poderá ter bônus no futuro

    table.insert(self.enemies, Enemy.create(enemyType, x, y, level, bonuses))
end
-- #####################################

function PlayState:rebuildSpawnUI()
    self.uiSpawnElements = {}
    local yPos = 100
    local troopOrder = {"soldado", "tank", "arqueiro", "ninja", "rei"}

    for _, troopName in ipairs(troopOrder) do
        if self.player.unlockedTroops[troopName] then
            local cost = Ally.getFoodCost(troopName)
            local text = troopName:gsub("^%l", string.upper) .. "\n(Custo: " .. cost .. ")"
            table.insert(self.uiSpawnElements, Button.create(10, yPos, 120, 50, text, function() self:spawnAlly(troopName) end))
            yPos = yPos + 60
        end
    end

    table.insert(self.uiSpawnElements, Button.create(10, 450, 120, 50, "UPGRADES", function()
        self.isUpgradePanelOpen = not self.isUpgradePanelOpen
    end))
end

function PlayState:drawUpgradePanel()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 150, 50, love.graphics.getWidth() - 300, love.graphics.getHeight() - 100)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("UPGRADES", 150, 60, love.graphics.getWidth() - 300, "center")

    self.uiUpgradeElements = {}
    local yPos = 120
    for key, upgrade in pairs(self.upgrades) do
        local btn = upgrade.getButton(self, 200, yPos, love.graphics.getWidth() - 400, 50)
        btn:update(0)
        btn:draw()
        table.insert(self.uiUpgradeElements, btn)
        yPos = yPos + 60
    end
end

--------------------------------------------------------------------------------
-- ESTRUTURA DE DADOS DOS UPGRADES
--------------------------------------------------------------------------------

function PlayState:initializeUpgrades()
    self.upgrades = {
        upgradeTower = {
            name = "Evoluir Torre",
            getCost = function(state) return 500 * (state.player.towerLevel ^ 2) end,
            canPurchase = function(state)
                if state.player.towerLevel >= 3 then
                    state.upgrades.upgradeTower.disabledReason = "Nível Máximo"
                    return false
                end
                return true
            end,
            apply = function(state)
                state.player.towerLevel = state.player.towerLevel + 1
                state.playerStructure:levelUp()
                state:rebuildSpawnUI()
            end
        },
        unlockTank = {
            name = "Desbloquear Tank",
            getCost = function() return 300 end,
            canPurchase = function(state)
                if state.player.unlockedTroops.tank then return false end
                return state.player.towerLevel >= 1
            end,
            apply = function(state)
                state.player.unlockedTroops.tank = true
                state:rebuildSpawnUI()
            end
        },
        upgradeSoldier = {
            name = "Melhorar Soldado",
            getCost = function(state) return 100 * (state.player.troopLevels.soldado ^ 1.5) end,
            canPurchase = function(state)
                local maxLevel = state.player.towerLevel * 2 + 1
                if state.player.troopLevels.soldado >= maxLevel then
                    state.upgrades.upgradeSoldier.disabledReason = "Nível da Torre baixo"
                    return false
                end
                return true
            end,
            apply = function(state) state.player.troopLevels.soldado = state.player.troopLevels.soldado + 1 end
        },
        upgradeFoodGen = {
            name = "Melhorar Geração de Comida",
            getCost = function(state) return 150 * (1.8 ^ ((state.player.foodPerSecond - 2))) end,
            canPurchase = function() return true end,
            apply = function(state) state.player.foodPerSecond = state.player.foodPerSecond + 1 end
        },
        buyFood = {
            name = "Comprar Comida (+50)",
            getCost = function() return 75 end,
            canPurchase = function() return true end,
            apply = function(state) state.player.food = math.min(state.player.foodMax, state.player.food + 50) end
        }
    }

    for key, upgrade in pairs(self.upgrades) do
        upgrade.getButton = function(state, x, y, w, h)
            local cost = upgrade.getCost(state)
            local canBuy = upgrade.canPurchase(state)
            
            local levelInfo = ""
            if key == "upgradeSoldier" then levelInfo = " (Lvl " .. state.player.troopLevels.soldado .. ")" end
            if key == "upgradeTower" then levelInfo = " (Lvl " .. state.player.towerLevel .. ")" end
            
            local text = upgrade.name .. levelInfo .. "\nCusto: " .. math.floor(cost) .. " Ouro"
            
            local btn = Button.create(x, y, w, h, text, function()
                state:purchaseUpgrade(key)
            end)
            
            return btn
        end
    end
end

return PlayState