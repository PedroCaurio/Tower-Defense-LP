---@class Animation
---@field spriteSheet love.Image
---@field quads table
---@field duration number
---@field currentTime number
local Animation = {}
Animation.__index = Animation


---@param imagePath string
---@param width integer
---@param height integer
---@param duration integer
---@return Animation obj
function Animation:newAnimation(imagePath, width, height, duration)
    local image = love.graphics.newImage(imagePath)
    local obj = {
        spriteSheet = image,
        quads = {}
    }
    setmetatable(obj, Animation)
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(obj.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    obj.duration = duration or 1
    obj.currentTime = 0
    return obj
end

function Animation:_draw(x, y, flipped)
    local spriteNum = math.floor(self.currentTime / self.duration * #self.quads) + 1
    if spriteNum > #self.quads then spriteNum = #self.quads end
    local quad = self.quads[spriteNum]
    local sx = flipped and -1 or 1
    local ox = 0
    if flipped then
        local _, _, w, _ = quad:getViewport()
        ox = w
    end
    love.graphics.draw(self.spriteSheet, quad, x + ox, y, 0, sx, 1)
end


function Animation:_update(dt)
    self.currentTime = self.currentTime + dt
    if self.currentTime >= self.duration then
        self.currentTime = self.currentTime - self.duration
    end
end

function Animation:reset() self.currentTime = 0 end

return Animation