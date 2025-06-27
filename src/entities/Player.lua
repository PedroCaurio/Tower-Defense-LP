local Player = {}
Player.__index = Player

setmetatable(Player, {
    __call = function(cls, ...)
        return cls.create(...)
    end
})

function Player.create(x, y, z, speed)
    local player = {
        x = x,
        y = y,
        z = z,
        pz = z,
        speed = speed
    }
    return setmetatable(player, Player)
end

function Player:update()
    self.pz = self.z
    self.z = self.z - self.speed
end

function Player.map(value, low1, high1, low2, high2)
    return math.floor(low2 + (high2 - low2) * ((value - low1) / (high1 - low1)))
end


function Player:get(width, height)
    local x = self.map(self.x / self.z, 0, 1, 0, width)
    local y = self.map(self.y / self.z, 0, 1, 0, height)
    local r = self.map(self.z, 0, width, 4, 0)

    if self.pz > width / 2 then
        return x, y, r
    end

    local px = self.map(self.x / self.pz, 0, 1, 0, width)
    local py = self.map(self.y / self.pz, 0, 1, 0, height)
    
    return x, y, r, px, py
end


return Player