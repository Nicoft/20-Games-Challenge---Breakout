local love = require "love"

local readyState = {}


function readyState:enter(gameObjects)
    self.gameObjects = gameObjects
    love.mouse.setVisible(false)

    if gameObjects.lives >= 3 then
        self.gameObjects:levelFactory(self.gameObjects.levels[self.gameObjects.currentLevel]) -- Instantiate blocks with config table and send the results to blocks object
    end

    utils.resetBall(self.gameObjects.ball)
end

function readyState:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    self.gameObjects.paddle.x = mouseX-self.gameObjects.paddle.w/2
    self.gameObjects.ball.y = self.gameObjects.ball:DEFAULT_Y() --re-center ball y
    self.gameObjects.ball.x = math.max(
        self.gameObjects.paddle.w/2 - self.gameObjects.ball.w/2,
        math.min(
            WINDOW_WIDTH - self.gameObjects.paddle.w/2 - self.gameObjects.ball.w/2,
            self.gameObjects.paddle.x + self.gameObjects.paddle.w/2 - self.gameObjects.ball.w/2
        )
    )
    self.gameObjects.paddle:update(dt)
end

function readyState:draw()
    utils.drawTextCentered("Click or press Enter to Play",H2,WINDOW_HEIGHT*0.2)

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
            if block.isActive then
                block:draw()
            end
        end
    end
end

function readyState:keypressed(key)
    if key == "return" then
        gStateMachine:change("play", self.gameObjects)
   elseif key == "escape" then
        gStateMachine:change("menu", self.gameObjects)
   end
end

function readyState:mousemoved(mx, my, dx, dy)
end

function readyState:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        gStateMachine:change("play", self.gameObjects)
    end
end

return readyState