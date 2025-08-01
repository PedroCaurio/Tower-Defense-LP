-- Arquivo que gerencia as waves de inimigos

local WaveManager = {}
WaveManager.__index = WaveManager

function WaveManager:new()
    local manager = {}
    setmetatable(manager, self)

    -- Definição das Ondas
    manager.waveData = {
        [1] = {
            timeBetweenWaves = 10,
            enemies = {
                { type = "soldado", count = 5, delay = 2, interval = 0.8 },
                --{ type = "cavaleiro", count = 6, delay = 1, interval = 0.5 },
                --{ type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 },
                --{ type = "cavaleiro", count = 200, delay = 2, interval = 1.5 },
                { type = "arqueiro", count = 2, delay = 5, interval = 1.5 }
            }
        },
        [2] = {
            timeBetweenWaves = 15,
            enemies = {
                { type = "soldado", count = 8, delay = 2, interval = 0.7 },
                { type = "tank", count = 1, delay = 4, interval = 1 }
            }
        },
        [3] = {
            timeBetweenWaves = 15,
            enemies = {
                { type = "cavaleiro", count = 6, delay = 1, interval = 0.5 },
                { type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 }
            }
        },
        [4] = {
            timeBetweenWaves = 15,
            enemies = {
                { type = "cavaleiro", count = 6, delay = 1, interval = 0.5 },
                { type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 }
            }
        },
        [5] = {
            timeBetweenWaves = 15,
            enemies = {
                { type = "cavaleiro", count = 6, delay = 1, interval = 0.5 },
                { type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 }
            }
        },
        [6] = {
            timeBetweenWaves = 15,
            enemies = {
                { type = "cavaleiro", count = 6, delay = 1, interval = 0.5 },
                { type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 }
            }
        },
        [7] = {
            timeBetweenWaves = 15,
            enemies = {
                { type = "cavaleiro", count = 6, delay = 1, interval = 0.5 },
                { type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 }
            }
        },
    }

    -- Estado Inicial
    manager.waveNumber = 0
    manager.state = 'BETWEEN_WAVES'
    manager.countdown = 2

    manager.currentWaveGroups = {}
    manager.spawnTimers = {}

    --print("WaveManager inicializado. Primeira onda em 2 segundos.")
    return manager
end

-- Inicia a próxima onda
function WaveManager:startNextWave(playState)
    self.waveNumber = self.waveNumber + 1
    local currentWaveData = self.waveData[self.waveNumber]

    if not currentWaveData then
        --print("Todas as ondas foram derrotadas!")
        currentWaveData = self.waveData[#self.waveData] -- Repete a última onda
    end
    
     if (self.waveNumber > 1) and (playState.enemyStructure.level < 3) then
        playState.ai.towerLevel = playState.ai.towerLevel + 1
        playState.enemyStructure:levelUp()
        --print("Torre inimiga evoluiu para o nível " .. playState.enemyStructure.level)
    end

    --print("Iniciando Wave " .. self.waveNumber)
    self.state = 'SPAWNING'
    self.currentWaveGroups = {}
    self.spawnTimers = {}

    for i, groupData in ipairs(currentWaveData.enemies) do
        local group = {
            type = groupData.type,
            count = groupData.count,
            remaining = groupData.count,
            interval = groupData.interval,
            intervalTimer = 0
        }
        self.currentWaveGroups[i] = group
        self.spawnTimers[i] = groupData.delay
    end
end

-- Atualização principal
function WaveManager:update(dt, playState)
    if self.state == 'BETWEEN_WAVES' then
        self.countdown = self.countdown - dt
        if self.countdown <= 0 then
            self:startNextWave(playState)
        end

    elseif self.state == 'SPAWNING' then
        local groupsFinished = true
        for i, group in ipairs(self.currentWaveGroups) do
            if group.remaining > 0 then
                groupsFinished = false
                self.spawnTimers[i] = self.spawnTimers[i] - dt
                
                if self.spawnTimers[i] <= 0 then
                    group.intervalTimer = group.intervalTimer - dt
                    if group.intervalTimer <= 0 then
                        group.intervalTimer = group.interval
                        group.remaining = group.remaining - 1
                        playState:spawnEnemyFromWave(group.type)
                    end
                end
            end
        end

        if groupsFinished then
            self.state = 'WAVE_IN_PROGRESS'
            --print("Onda " .. self.waveNumber .. " em progresso.")
        end

    elseif self.state == 'WAVE_IN_PROGRESS' then
        if #playState.enemies == 0 then
            print("Onda " .. self.waveNumber .. " derrotada")
            local waveData = self.waveData[self.waveNumber] or self.waveData[#self.waveData]
            self.countdown = waveData.timeBetweenWaves
            self.state = 'BETWEEN_WAVES'
            print("Próxima onda em " .. self.countdown .. " segundos.")
        end
    end
end

return WaveManager