local love = require "love"

local Ball = {}

function Ball:new()
    local ball = {
        x = 0,
        y = 0,
        w = 20,
        h = 20,
        dx = 1,
        dy = -1,
        speed = 400,
        DEFAULT_SPEED = 400,
    
        DEFAULT_X = function(self)
            return WINDOW_WIDTH/2-self.w/2
        end,
    
        DEFAULT_Y = function(self)
            return 560-self.h-5
        end,
    
        draw = function(self)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end,
    
        update = function(self, dt)
            --if the ball touches the left or right, reverse X direction.
            if self.x <= 0 then
                BLIP:play()
                self.x = 0
                self.dx = -self.dx
            end
    
            if self.x >= (WINDOW_WIDTH - self.w) then
                BLIP:play()
                self.x = WINDOW_WIDTH - self.w
                self.dx = -self.dx
            end
    
            --if the ball touches the top, reverse Y direction.
            if self.y <= 0 then
                BLIP:play()
                self.y = 0
                self.dy = -self.dy
            end
    
            --ball movement
            self.x = self.x + self.speed * self.dx * dt
            self.y = self.y + self.speed * self.dy * dt
        end
    }
    return ball
end

return Ball