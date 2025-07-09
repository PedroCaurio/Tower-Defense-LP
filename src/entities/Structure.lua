-- Structure.lua

--- Módulo da Estrutura Defensiva
-- Representa a estrutura defensiva no jogo.

local Structure = {} -- Tabela para armazenar métodos e propriedades da classe

-- Construtor da Estrutura Defensiva
-- @param x number A posição X da estrutura no mundo.
-- @param y number A posição Y da estrutura no mundo.
-- @param properties table Uma tabela contendo propriedades específicas da estrutura,
--                         como 'health', 'attackDamage', 'attackRange', 'cost', etc.
function Structure:new(x, y, properties)
    local o = o or {} -- Cria uma nova instância da estrutura
    setmetatable(o, self)
    self.__index = self

    -- Propriedades básicas da estrutura
    o.x = x
    o.y = y
    o.width = properties.width or 32   -- Largura padrão, ajuste conforme necessário
    o.height = properties.height or 128 -- Altura padrão, ajuste conforme necessário
    o.health = properties.health or 100
    o.maxHealth = properties.health or 100
    o.cost = properties.cost or 50
    o.isAlive = true
    --o.type = properties.type or "Structure" -- Tipo genérico, subclasses sobrescreverão

    -- Propriedades defensivas (pode ser específico de subclasses)
    o.attackDamage = properties.attackDamage or 0
    o.attackRange = properties.attackRange or 0
    o.attackSpeed = properties.attackSpeed or 0 -- Ataques por segundo
    o.timeSinceLastAttack = 0

    -- Propriedades visuais (placeholders)
    o.image = nil -- Irá armazenar um objeto love.graphics.Image
    o.color = {1, 1, 1, 1} -- Cor padrão (branco opaco)

    -- Carregar imagem, se fornecida nas propriedades
    if properties.imagePath then
        o.image = love.graphics.newImage(properties.imagePath)
    end

    print("Structure created at (" .. o.x .. ", " .. o.y .. ") with " .. o.health .. " HP.")

    return o
end

--- Atualiza o estado da estrutura a cada frame do jogo.
-- @param dt number O tempo decorrido desde o último frame (delta time).
function Structure:update(dt)
    if not self.isAlive then return end

    -- Lógica de ataque (se a estrutura for uma torre, por exemplo)
    if self.attackDamage > 0 and self.attackRange > 0 then
        self.timeSinceLastAttack = self.timeSinceLastAttack + dt
        if self.timeSinceLastAttack >= (1 / self.attackSpeed) then
            self:performAttack() -- Método a ser implementado por subclasses ou aqui
            self.timeSinceLastAttack = 0
        end
    end

    -- Lógica de regeneração de vida (opcional)
    -- self.health = math.min(self.maxHealth, self.health + self.regenRate * dt)

    -- Verificar se a estrutura foi destruída
    if self.health <= 0 then
        self.health = 0
        self.isAlive = false
        self:onDeath()
    end
end

--- Desenha a estrutura na tela.
function Structure:draw()
    if not self.isAlive then return end

    -- love.graphics.setColor(self.color) -- Define a cor para desenhar (se não tiver imagem)

    if self.image then
        -- Desenha a imagem centralizada na posição (x, y)
        love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 2)
    else
        -- Desenha um retângulo como placeholder se não houver imagem
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    end

    -- Desenhar barra de vida (opcional)
    local healthBarWidth = 40
    local healthBarHeight = 5
    local currentHealthWidth = (self.health / self.maxHealth) * healthBarWidth
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8) -- Fundo da barra de vida (cinza escuro)
    love.graphics.rectangle("fill", self.x - healthBarWidth / 2, self.y - self.height / 2 - 10, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0, 1) -- Barra de vida (verde)
    love.graphics.rectangle("fill", self.x - healthBarWidth / 2, self.y - self.height / 2 - 10, currentHealthWidth, healthBarHeight)

    love.graphics.setColor(1, 1, 1, 1) -- Reseta a cor para o padrão (importante!)
end

--- Causa dano à estrutura.
-- @param amount number A quantidade de dano a ser aplicada.
function Structure:takeDamage(amount)
    if not self.isAlive then return end
    self.health = self.health - amount
    print(self.type .. " at (" .. self.x .. ", " .. self.y .. ") took " .. amount .. " damage. Current HP: " .. self.health)
end

--- Método para a estrutura realizar um ataque.
-- Será implementado por subclasses mais específicas (e.g., Tower).
function Structure:performAttack()
    -- Este método será sobrescrito pelas subclasses (ex: Tower)
    -- Aqui você adicionaria a lógica para encontrar um alvo e aplicar dano.
    -- print(self.type .. " is trying to attack!")
end

--- Chamado quando a estrutura é destruída.
function Structure:onDeath()
    print(self.type .. " at (" .. self.x .. ", " .. self.y .. ") has been destroyed!")
    self.isAlive = false
    -- Adicionar lógica para remover a estrutura do jogo, reproduzir efeitos, etc.
end

return Structure -- Retorna a tabela para que possa ser usada como um módulo