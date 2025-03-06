local M = {}

--AABB collision detection
function M.isColliding(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

function M.getCollisionSide(A, B)
    local overlapX = math.min(A.x + A.w - B.x, B.x + B.w - A.x)
    local overlapY = math.min(A.y + A.h - B.y, B.y + B.h - A.y)

    if overlapX < overlapY then
        return (A.x < B.x) and "left" or "right"
    else
        return (A.y < B.y) and "top" or "bottom"
    end
end

function M.isMouseHovering(button, mx, my)
    return mx >= button.x and mx <= button.x + button.w and
           my >= button.y and my <= button.y + button.h
end



--randomly return -1 or 1
function M.randomDirection()
    return love.math.random(0, 1) == 0 and -1 or 1
end

--return magnitude of inputs
function M.magnitude(dx,dy)
    return math.sqrt(dx^2 + dy^2)
end

--print text centered with given font and y-height
function M.drawTextCentered(text, font, yHeight)
    love.graphics.setFont(font)
    local width = font:getWidth(text)
    love.graphics.print(text, (WINDOW_WIDTH - width) / 2, yHeight)
end

function M.calculateBounce(ball, paddle)
    --returns  a table with proper dx and dy to apply
    local table = {}
    -- How far from the center of the paddle did the ball hit? (from -50 to 50)
    local relativeIntersectX = (ball.x + ball.w / 2) - (paddle.x + paddle.w / 2)
    -- turn the ball's distance from paddle center into a percentage, middle is 100%, edges are 0%
    local normalized = 1 - (relativeIntersectX / (paddle.w / 2))^2

    -- Max bounce angle to base on.
    local maxBounceAngle = math.rad(90)

    -- limit min and max angles to 30 and 80
    local bounceAngle = math.min(math.rad(80), math.max(math.rad(30), (normalized * maxBounceAngle)))

    -- turn the dx cos into a negative or positive (since we are not using angles over 90 for negative values)
    if relativeIntersectX > 0 then
        table.dx = math.cos(bounceAngle)
    else
        table.dx = -math.cos(bounceAngle)
    end

    -- return the dy sin of the current angle
    table.dy = -math.sin(bounceAngle)

    return table 
end

function M.resetBall(ball)
        -- paddle.x = paddle:DEFAULT_X()
    -- ball.x = ball:DEFAULT_X() --re-center ball x
    -- ball.y = ball:DEFAULT_Y() --re-center ball y
    ball.speed = ball.DEFAULT_SPEED
    local angle = math.rad(love.math.random(45, 135)) -- Random angle to shoot ball from
    ball.dx = math.cos(angle)
    ball.dy = -math.sin(angle)
end

return M