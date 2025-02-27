local love = require "love"




local playState = {}

function playState:enter(gameObjects)
    self.gameObjects = gameObjects
    love.mouse.setVisible(false)
end

-- Table mapping collision sides to position update functions (defined once)
local collisionActions = {
    right = function(ball, block)
        ball.x = block.x + block.w + 1
        ball.dx = -ball.dx
    end,
    left = function(ball, block)
        ball.x = block.x - ball.w - 1
        ball.dx = -ball.dx
    end,
    top = function(ball, block)
        ball.y = block.y - ball.h
        ball.dy = -ball.dy
    end,
    bottom = function(ball, block)
        ball.y = block.y + block.h
        ball.dy = -ball.dy
    end
}

local function handleCollision(ball, block)
    local side = utils.getCollisionSide(ball, block)
    if collisionActions[side] then
        collisionActions[side](ball, block)
    end
    block.visible = false
end


function playState:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    -- paddle movement
    -- paddle.dx = (love.keyboard.isDown('left') and -1) or (love.keyboard.isDown('right') and 1) or 0
    self.gameObjects.paddle.x = mouseX-self.gameObjects.paddle.w/2
    self.gameObjects.paddle:update(dt)
    self.gameObjects.ball:update(dt)

    --if paddle/ball collision
    if utils.checkCollision(self.gameObjects.paddle, self.gameObjects.ball) then
        BLOP:play()
        local angle = utils.calculateBounce(self.gameObjects.ball, self.gameObjects.paddle)
        self.gameObjects.ball.dy = angle.dy
        self.gameObjects.ball.dx = angle.dx
        self.gameObjects.ball.y = self.gameObjects.paddle.y - self.gameObjects.ball.h --pop the ball out of the paddle to prevent multiple collisions
        -- ball.speed = ball.speed * 1.05 -- Gradual speed increase
    end

    --if ball/block collision
    for r, row in ipairs(self.gameObjects.blocks) do
        for c, block in ipairs(row) do
            if utils.checkCollision(self.gameObjects.ball, block) and block.visible then
                handleCollision(self.gameObjects.ball, block)
                --play sound
                local soundInstance = BLIP:clone()
                soundInstance:play()

                self.gameObjects.score = self.gameObjects.score + 1
            end
        end
    end
    
    --loss consequence
    if self.gameObjects.ball.y >= WINDOW_HEIGHT-self.gameObjects.ball.h then
        GAMEOVER:play()
        self.gameObjects.lives = self.gameObjects.lives-1
        
        if self.gameObjects.lives > -1 then
            --if still alive, play again
            gStateMachine:change("ready", self.gameObjects)
        else
            -- if no more lives, go back to menu and reset level and everything.
            self.gameObjects.blocks = nil
            self.gameObjects.lives = 3
            self.gameObjects.score = 0
            gStateMachine:change("menu", self.gameObjects) 
        end
    end
end

function playState:draw()
    love.graphics.setFont(H2)
    love.graphics.print("Score "..self.gameObjects.score, 50, 50)
    love.graphics.print("Balls ", 550, 50)
    for i=1, self.gameObjects.lives do
        love.graphics.rectangle("fill", 650 + 25*i, 50, 20, 20)
    end
    love.graphics.setFont(H1)

    --draw paddle, ball, and block grid
    self.gameObjects.paddle:draw() --paddle
    self.gameObjects.ball:draw() --ball
    for r, row in ipairs(self.gameObjects.blocks) do --blocks
        for c, block in ipairs(row) do
            if block.visible then
                block:draw()
            end
        end
    end
end

function playState:keypressed(key)
    if key == "escape" then
        gStateMachine:change("menu", self.gameObjects)
    end
end

function playState:mousemoved(mx, my, dx, dy)
end

return playState