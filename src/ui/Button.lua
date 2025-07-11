-- src/ui/Button.lua
local Button = {}
Button.__index = Button

function Button.create(x, y, width, height, text, onClick)
    local btn = {
        x = x, y = y,
        width = width, height = height,
        text = text or "",
        onClick = onClick or function() end,
        isHovered = false
    }
    return setmetatable(btn, Button)
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.isHovered = mx > self.x and mx < self.x + self.width and
                     my > self.y and my < self.y + self.height
end

function Button:draw()
    if self.isHovered then
        love.graphics.setColor(0.5, 0.5, 0.5) -- Cinza quando hover
    else
        love.graphics.setColor(0.3, 0.3, 0.3) -- Cinza escuro normal
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.text, self.x, self.y + self.height / 4, self.width, "center")
end

function Button:mousepressed(x, y, button)
    if button == 1 and self.isHovered then
        self.onClick()
    end
end

return Button