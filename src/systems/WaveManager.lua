-- Conceito para WaveManager.lua
local WaveManager = {}
-- ... (código do construtor)

function WaveManager:update(dt, enemies)
    if self.waveInProgress then
        -- Lógica de spawnar inimigos da wave atual
    elseif #enemies == 0 then
        -- Todos os inimigos morreram, inicia timer para próxima wave
        self.timer = self.timer + dt
        if self.timer > self.timeBetweenWaves then
            self:startNextWave()
        end
    end
end

function WaveManager:startNextWave()
    self.waveNumber = self.waveNumber + 1
    -- Aumenta a dificuldade: mais inimigos, inimigos mais fortes, etc.
end