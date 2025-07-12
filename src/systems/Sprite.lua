---@class Sprite
---@field currentState number
---@field flipped boolean
local Sprite = {
    idle = 1, attack = 2, preAttack = 3
}
Sprite.__index = Sprite


---@param idle Animation
---@param attack Animation
---@param preAttack Animation
---@param flipped boolean
---@return Sprite
function Sprite:newSprite(idle, attack, preAttack, flipped)
    local obj = {
        idle,
        attack,
        preAttack,
        currentState = Sprite.idle,
        flipped = flipped
    }
    setmetatable(obj, Sprite)
    return obj
end

---@param state integer
function Sprite:setState(state)
    if self.currentState ~= state then
        self[self.currentState]:reset()
        self.currentState = state
    end
end

function Sprite:draw(x, y)
    self[self.currentState]:_draw(x, y, self.flipped)
end

function Sprite:update(dt)
    self[self.currentState]:_update(dt)
end

return Sprite