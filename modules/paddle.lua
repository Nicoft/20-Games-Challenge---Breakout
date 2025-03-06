local Paddle = {}

function Paddle:new(w, h)
    local paddle = {
        w = w,
        h = h,
        x = 0,
        y = 560, 
        speed = 600,
        dx = 0,
        reactionTime = 0.4,
        timer = 0,
        DEFAULT_X = function(self)
            return WINDOW_WIDTH/2-self.w/2
        end,
        draw = function(self)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end,
        update = function(self, dt)
            --paddle movement, with max a min stoppers for left and right edge of screen.
            self.x = math.max(0, math.min(WINDOW_WIDTH - self.w, self.x + self.speed * self.dx * dt))
        end
    }
    return paddle
end

return Paddle