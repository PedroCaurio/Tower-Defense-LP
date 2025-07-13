-- src/systems/WaveManager.lua

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
                { type = "soldado", count = 5, delay = 2, interval = 0.8 }
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
                { type = "ninja", count = 6, delay = 1, interval = 0.5 },
                { type = "soldado", count = 5, delay = 3, interval = 0.6 },
                { type = "tank", count = 2, delay = 5, interval = 1.5 }
            }
        },
    }

    -- Estado Inicial
    manager.waveNumber = 0
    manager.state = 'BETWEEN_WAVES'
    manager.countdown = 5

    manager.currentWaveGroups = {}
    manager.spawnTimers = {}

    print("WaveManager inicializado. Primeira onda em 5 segundos.")
    return manager
end

-- Inicia a próxima onda
function WaveManager:startNextWave()
    self.waveNumber = self.waveNumber + 1
    local currentWaveData = self.waveData[self.waveNumber]

    if not currentWaveData then
        print("Todas as ondas foram derrotadas!")
        currentWaveData = self.waveData[#self.waveData] -- Repete a última onda
    end
    
    print("Iniciando Wave " .. self.waveNumber)
    self.state = 'SPAWNING'
    self.currentWaveGroups = {}
    self.spawnTimers = {}

    for i, groupData in ipairs(currentWaveData.enemies) do
        local group = {
            type = groupData.type,
            count = groupData.count,
            remaining = groupData.count,
            interval = groupData.interval,
            -- ############ CORREÇÃO AQUI ############
            -- Inicializamos o timer de intervalo para 0.
            -- Isso garante que o primeiro inimigo do grupo seja criado
            -- assim que o 'delay' inicial terminar.
            intervalTimer = 0
            -- ##########################################
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
            self:startNextWave()
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
            print("Onda " .. self.waveNumber .. " em progresso. Derrote todos os inimigos!")
        end

    elseif self.state == 'WAVE_IN_PROGRESS' then
        if #playState.enemies == 0 then
            print("Onda " .. self.waveNumber .. " derrotada!")
            local waveData = self.waveData[self.waveNumber] or self.waveData[#self.waveData]
            self.countdown = waveData.timeBetweenWaves
            self.state = 'BETWEEN_WAVES'
            print("Próxima onda em " .. self.countdown .. " segundos.")
        end
    end
end

return WaveManager