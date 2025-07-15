-- Arquivo principal do jogo, contém toda a lógica (Desculpa se ele ficar meio confuso kkkk)

local Gamestate = require "lib.hump.gamestate"

local Ally = require("src.entities.Ally")
local Enemy = require("src.entities.Enemy")
local Structure = require("src.entities.Structure")
local Button = require("src.ui.Button")

local WaveManager = require("src.systems.WaveManager")
local ProjectileManager = require("src.systems.ProjectileManager")

local floor = love.graphics.newImage("assets/background/Back_0.png")
local floor2 = love.graphics.newImage("assets/background/Back_1.png")
local background = love.graphics.newImage("assets/background/Background_0.png")

local PlayState = {}
PlayState.__index = PlayState

--------------------------------------------------------------------------------
-- DADOS E CONFIGURAÇÕES DO JOGO
--------------------------------------------------------------------------------

local gameSettings = {
    maxTowerLevel = 3,
    troopMaxLevelByTowerLevel = { [1] = 3, [2] = 5, [3] = 7 },
    -- Tropas desbloqueáveis por nível da torre
    troopsToUnlock = {
        [1] = { { key = "unlockTank", troop = "tank" } },
        [2] = { { key = "unlockArqueiro", troop = "arqueiro" } },
        [3] = { { key = "unlockCavaleiro", troop = "cavaleiro" }, { key = "unlockPrincipe", troop = "principe" } }
    }
}

--------------------------------------------------------------------------------
-- MÉTODOS DO GAMELOOP PRINCIPAL
--------------------------------------------------------------------------------

function PlayState:load()
    local state = {}
    setmetatable(state, PlayState)

    state.player = {
        gold = 999999999999000, -- <<<<<    Ouro inicial
        food = 100,
        foodMax = 500,
        foodPerSecond = 2,
        goldPerKillMultiplier = 1,
        towerLevel = 1,
        unlockedTroops = { soldado = true, tank = false, arqueiro = false, cavaleiro = false, principe = false },
        troopLevels = { soldado = 1, tank = 1, arqueiro = 1, cavaleiro = 1, principe = 1 }
    }
    state.ai = {
        towerLevel = 1,
        unlockedTroops = { soldado = true, tank = true, cavaleiro = true, arqueiro = true, principe = true },
        troopLevels = { soldado = 1, tank = 1, arqueiro = 1, cavaleiro = 1, principe = 1 },
        gold = 200,
    }

    state.allies, state.enemies, state.projectiles, state.structures = {}, {}, {}, {}
    state.groundY = love.graphics.getHeight() - 80
    state.playerStructure = Structure.create("player_base", 40, state.groundY, state.player.towerLevel)
    state.enemyStructure = Structure.create("enemy_base", love.graphics.getWidth() - 40, state.groundY, state.ai.towerLevel)
    table.insert(state.structures, state.playerStructure)
    table.insert(state.structures, state.enemyStructure)

    state.waveManager = WaveManager:new()
    state.projectileManager = ProjectileManager:new()
    
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
        Gamestate.switch(require("src.states.VictoryState")) -- Mudar para VictoryState
        return
    end

    if not self.isUpgradePanelOpen then
        self.player.food = math.min(self.player.foodMax, self.player.food + self.player.foodPerSecond * dt)
        
        self.waveManager:update(dt, self)
        self.projectileManager:update(dt)

        for _, s in ipairs(self.structures) do s:update(dt) end

        for i = #self.allies, 1, -1 do
            local ally = self.allies[i]
            ally:update(dt, self.enemies, self.enemyStructure, self)
            if not ally.alive then
                ally.deathTimer = ally.deathTimer + dt
                if ally.deathTimer >= ally.timeToDie then
                    table.remove(self.allies, i)
                end
            end
        end

        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            enemy:update(dt, self.allies, self.playerStructure, self)
            if not enemy.alive then
                enemy.deathTimer = enemy.deathTimer + dt
                if enemy.deathTimer >= enemy.timeToDie then
                    table.remove(self.enemies, i)
                end
                self.player.gold = self.player.gold + (enemy.reward or 0) * self.player.goldPerKillMultiplier
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

    love.graphics.draw(background, 0, 0, 0, 2, 2)
    love.graphics.draw(background, 496, 0, 0, 2, 2)
    love.graphics.draw(floor, 0, -8, 0, 2, 2)
    love.graphics.draw(floor2, 496, -8, 0, 2, 2)

    for _, s in ipairs(self.structures) do s:draw() end
    self.projectileManager:draw()
    for _, a in ipairs(self.allies) do a:draw() end
    for _, e in ipairs(self.enemies) do e:draw() end
    
    love.graphics.setColor(1, 0, 0)
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
        if self.isUpgradePanelOpen then self.isUpgradePanelOpen = false else Gamestate.switch(require("src.states.MenuState")) end
    end
end

--------------------------------------------------------------------------------
-- LÓGICA DE SPAWN E UI
--------------------------------------------------------------------------------

function PlayState:spawnAlly(allyType)
    if not self.player.unlockedTroops[allyType] then return end
    local cost = Ally.getFoodCost(allyType)
    if self.player.food >= cost then
        self.player.food = self.player.food - cost
        local level = self.player.troopLevels[allyType]
        table.insert(self.allies, Ally.create(allyType, 120, self.groundY, level))
    end
end

function PlayState:spawnEnemyFromWave(enemyType)
    local x = love.graphics.getWidth() + 40
    local level = self.ai.troopLevels[enemyType] or 1
    table.insert(self.enemies, Enemy.create(enemyType, x, self.groundY, level))
end

function PlayState:rebuildSpawnUI()
    self.uiSpawnElements = {}
    local yPos = 100
    local troopOrder = {"soldado", "tank", "arqueiro", "cavaleiro", "principe"}
    for _, troopName in ipairs(troopOrder) do
        if self.player.unlockedTroops[troopName] then
            local cost = Ally.getFoodCost(troopName)
            local text = troopName:gsub("^%l", string.upper) .. "\n(Custo: " .. cost .. ")"
            table.insert(self.uiSpawnElements, Button.create(10, yPos, 120, 50, text, function() self:spawnAlly(troopName) end))
            yPos = yPos + 60
        end
    end
    table.insert(self.uiSpawnElements, Button.create(10, 510, 120, 50, "UPGRADES", function()
        self.isUpgradePanelOpen = not self.isUpgradePanelOpen
    end))
end

--------------------------------------------------------------------------------
-- LÓGICA DO PAINEL DE UPGRADES
--------------------------------------------------------------------------------

function PlayState:purchaseUpgrade(upgradeKey)
    local upgrade = self.upgrades[upgradeKey]
    if not upgrade then return end
    if upgrade.canPurchase(self) then
        local cost = upgrade.getCost(self)
        if self.player.gold >= cost then
            self.player.gold = self.player.gold - cost
            upgrade.apply(self)
        end
    end
end

function PlayState:drawUpgradePanel()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 160, 50, love.graphics.getWidth() - 320, love.graphics.getHeight() - 100)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("UPGRADES", 160, 60, love.graphics.getWidth() - 320, "center")

    self.uiUpgradeElements = {}
    local columnWidth = (love.graphics.getWidth() - 320) / 3
    local columns = {
        x1 = 160,
        x2 = 160 + columnWidth,
        x3 = 160 + columnWidth * 2
    }
    local yPos = { 120, 120, 120 }

    local upgradeLayout = {
        [1] = {"upgradeTower", "unlockTank", "unlockArqueiro", "unlockCavaleiro", "unlockPrincipe"}, -- Coluna 1: Torre e Desbloqueios
        [2] = {"upgradeSoldado", "upgradeTank", "upgradeArqueiro", "upgradeCavaleiro", "upgradePrincipe"}, -- Coluna 2: Níveis de Tropas
        [3] = {"upgradeFoodGen", "buyFood", "upgradeGoldPerKill"} -- Coluna 3: Sustentabilidade
    }

    for col = 1, 3 do
        for _, key in ipairs(upgradeLayout[col]) do
            local upgrade = self.upgrades[key]
            if upgrade and upgrade.isVisible(self) then
                local btn = upgrade.getButton(self, columns['x'..col] + 10, yPos[col], columnWidth - 20, 60)
                btn:update(0)
                btn:draw()
                table.insert(self.uiUpgradeElements, btn)
                yPos[col] = yPos[col] + 70
            end
        end
    end
end

--------------------------------------------------------------------------------
-- ESTRUTURA DE DADOS DOS UPGRADES (ALINHADA COM O GDD)
--------------------------------------------------------------------------------

function PlayState:initializeUpgrades()
    local function createTroopLevelUpgrade(troopName, displayName)
        local key = "upgrade" .. displayName:gsub(" ", "")
        return {
            name = "Melhorar " .. displayName,
            getCost = function(state) return 50 * (state.player.troopLevels[troopName] ^ 1.4) end, -- <<< Balancear aqui o custo
            isVisible = function(state) return state.player.unlockedTroops[troopName] end,
            canPurchase = function(state)
                local maxLevel = gameSettings.troopMaxLevelByTowerLevel[state.player.towerLevel]
                if state.player.troopLevels[troopName] >= maxLevel then
                    state.upgrades[key].disabledReason = "Nível Máx. para Torre"
                    return false
                end
                return true
            end,
            apply = function(state) state.player.troopLevels[troopName] = state.player.troopLevels[troopName] + 1 end,
            levelInfo = function(state) return " (Nvl " .. state.player.troopLevels[troopName] .. ")" end
        }
    end

    local function createTroopUnlock(troopName, displayName, cost, requiredTowerLevel)
        return {
            name = "Desbloquear " .. displayName,
            getCost = function() return cost end,
            isVisible = function(state) return not state.player.unlockedTroops[troopName] end,
            canPurchase = function(state)
                if state.player.towerLevel < requiredTowerLevel then
                    return false, "Requer Torre Nvl " .. requiredTowerLevel
                end
                return true
            end,
            apply = function(state) state.player.unlockedTroops[troopName] = true; state:rebuildSpawnUI() end,
            levelInfo = function() return "" end
        }
    end

    self.upgrades = {
        -- === Categoria: Torre ===
        upgradeTower = {
            name = "Evoluir Torre",
            getCost = function(state) return 500 * (state.player.towerLevel ^ 2) end,
            isVisible = function() return true end,
            canPurchase = function(state)
                if state.player.towerLevel >= gameSettings.maxTowerLevel then
                    return false, "Nível Máximo"
                end
                return true
            end,
            apply = function(state)
                state.player.towerLevel = state.player.towerLevel + 1
                state.playerStructure:levelUp()
                state:rebuildSpawnUI()
            end,
            levelInfo = function(state) return " (Nvl " .. state.player.towerLevel .. ")" end
        },
        
        -- === Categoria: Tropas (Desbloqueio) ===
        unlockTank = createTroopUnlock("tank", "Tank", 250, 1),
        unlockArqueiro = createTroopUnlock("arqueiro", "Arqueiro", 400, 2),
        unlockCavaleiro = createTroopUnlock("cavaleiro", "Cavaleiro", 600, 3),
        unlockPrincipe = createTroopUnlock("principe", "Principe", 1500, 3),

        -- === Categoria: Tropas (Melhoria de Nível) ===
        upgradeSoldado = createTroopLevelUpgrade("soldado", "Soldado"),
        upgradeTank = createTroopLevelUpgrade("tank", "Tank"),
        upgradeArqueiro = createTroopLevelUpgrade("arqueiro", "Arqueiro"),
        upgradeCavaleiro = createTroopLevelUpgrade("cavaleiro", "Cavaleiro"),
        upgradePrincipe = createTroopLevelUpgrade("principe", "Principe"),

        -- === Categoria: Sustentabilidade ===
        upgradeFoodGen = {
            name = "Melhorar Ger. de Comida",
            getCost = function(state) return 150 * (1.8 ^ (state.player.foodPerSecond - 2)) end,
            isVisible = function() return true end,
            canPurchase = function() return true end,
            apply = function(state) state.player.foodPerSecond = state.player.foodPerSecond + 1 end,
            levelInfo = function(state) return string.format(" (+%d/s)", state.player.foodPerSecond) end
        },
        upgradeGoldPerKill = {
            name = "Aumentar Ouro por Abate",
            getCost = function(state) return 400 * (2 ^ ( (state.player.goldPerKillMultiplier - 1) / 0.25) ) end,
            isVisible = function() return true end,
            canPurchase = function() return true end,
            apply = function(state) state.player.goldPerKillMultiplier = state.player.goldPerKillMultiplier + 0.25 end,
            levelInfo = function(state) return string.format(" (x%.2f)", state.player.goldPerKillMultiplier) end
        },
        buyFood = {
            name = "Comprar Comida (+50)",
            getCost = function() return 75 end,
            isVisible = function() return true end,
            canPurchase = function() return true end,
            apply = function(state) state.player.food = math.min(state.player.foodMax, state.player.food + 50) end,
            levelInfo = function() return "" end
        }
    }

    for key, upgrade in pairs(self.upgrades) do
        upgrade.getButton = function(state, x, y, w, h)
            local canBuy, reason = upgrade.canPurchase(state)
            local cost = upgrade.getCost(state)
            local text = upgrade.name .. upgrade.levelInfo(state) .. "\nCusto: " .. math.floor(cost) .. " Ouro"
            
            local btn = Button.create(x, y, w, h, text, function()
                state:purchaseUpgrade(key)
            end)
            
            btn.enabled = (state.player.gold >= cost and canBuy)
            if not btn.enabled and reason then
                btn.text = upgrade.name .. "\n" .. reason
            elseif not btn.enabled and not canBuy then
                btn.text = upgrade.name .. "\n(Bloqueado)"
            end
            
            return btn
        end
    end
end

return PlayState