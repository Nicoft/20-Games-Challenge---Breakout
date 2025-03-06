local winState = {}

local timer = 0

local winMsg = function(level)
    return "Round "..level.." completed"
end


function winState:enter(gameObjects)
    self.gameObjects = gameObjects
    love.mouse.setVisible(false)

end

function winState:update(dt)

    if self.gameObjects.currentLevel < #self.gameObjects.levels then
        timer = timer + dt
        if timer > 3 then
            timer = 0
            self.gameObjects.currentLevel = self.gameObjects.currentLevel + 1
            gStateMachine:change("ready", self.gameObjects)
        end
    else
        
    end
end

function winState:draw()
    if self.gameObjects.currentLevel < #self.gameObjects.levels then
        gUtils.drawTextCentered(winMsg(self.gameObjects.currentLevel), H2, WINDOW_HEIGHT*0.2)
    else
        gUtils.drawTextCentered("You won!", H2, WINDOW_HEIGHT*0.2)
    end

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
            block:draw()
        end
    end
end

function winState:keypressed(key)
   if key == "return" then

   elseif key == "escape" then
        gStateMachine:change("menu", self.gameObjects)
   end
end

function winState:mousemoved(mx, my, dx, dy)

end

function winState:mousepressed(x, y, button, istouch, presses)

end

return winState