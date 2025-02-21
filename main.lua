local love = require "love"
local utils = require "utils"
local debugging = require "debugging"

local Button = require("modules/button")
local Ball = require("modules/ball")
local Paddle = require("modules/paddle")
local Block = require("modules/block")  -- Import the block module

--Globals
    WINDOW_WIDTH = love.graphics.getWidth()
    WINDOW_HEIGHT = love.graphics.getHeight()
    H1 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",48)
    H2 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",18)

    --Audio
    BLOP = love.audio.newSource("sounds/BLOP.mp3", "static")
    BLIP = love.audio.newSource("sounds/BLIP.mp3", "static")
    GAMEOVER = love.audio.newSource("sounds/GAMEOVER.wav", "static")
    GAMEOVER:setVolume(0.1)
    BLIP:setVolume(0.1)
    BLOP:setVolume(0.1)


--Game objects
local gameState = "menu"
local score = 0
local lives = 3

local buttons = {
    current = 1,
    Button:new(WINDOW_WIDTH/2, 250, 200, 50, "Play", {0,0,0}, {1,1,1}),
    Button:new(WINDOW_WIDTH/2, 350, 200, 50, "Pay", {0,0,0}, {1,1,1}),
    Button:new(WINDOW_WIDTH/2, 450, 200, 50, "Py", {0,0,0}, {1,1,1}),
}
buttons[buttons.current].isSelected = true

local ball = Ball:new()
local paddle = Paddle:new(100, 20)

-- Instantiate blocks with config table and store the result in a variable
local level1 = {columns = 10, rows = 5, startY = 150}
local blocks = Block.instantiateBlocks(level1)

-- functions
local function cycleSelection(direction)
    -- Deselect current button
    buttons[buttons.current].isSelected = false
    -- Update index and wrap around
    buttons.current = (buttons.current - 1 + direction) % #buttons + 1
    -- Select new button
    buttons[buttons.current].isSelected = true
end

local function resetPositions()
    -- paddle.x = paddle:DEFAULT_X()
    -- ball.x = ball:DEFAULT_X() --re-center ball x
    -- ball.y = ball:DEFAULT_Y() --re-center ball y
    ball.speed = ball.DEFAULT_SPEED

    local angle = math.rad(love.math.random(45, 135)) -- Random angle to shoot ball from
    ball.dx = math.cos(angle)
    ball.dy = -math.sin(angle)
end

local function resetGame()
    resetPositions()
    score = 0
    lives = 3
    blocks = Block.instantiateBlocks(level1)
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





function love.load ()
    love.math.setRandomSeed(os.time() + love.timer.getTime())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(H1)
end

function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()

    if gameState == "play" then

        -- paddle movement
        -- paddle.dx = (love.keyboard.isDown('left') and -1) or (love.keyboard.isDown('right') and 1) or 0

        paddle.x = mouseX-paddle.w/2
        paddle:update(dt)
        ball:update(dt)

        --if paddle/ball collision
        if utils.checkCollision(paddle, ball) then
            BLOP:play()
            local angle = utils.calculateBounce(ball, paddle)
            ball.dy = angle.dy
            ball.dx = angle.dx
            ball.y = paddle.y - ball.h --pop the ball out of the paddle to prevent multiple collisions
            -- ball.speed = ball.speed * 1.05 -- Gradual speed increase
        end

        --if ball/block collision
        for r, row in ipairs(blocks) do
            for c, block in ipairs(row) do
                if utils.checkCollision(ball, block) and block.visible then
                    handleCollision(ball, block)
                    --play sound
                    local soundInstance = BLIP:clone()
                    soundInstance:play()

                    score = score + 1
                end
            end
        end
        
        --loss consequence
        if ball.y >= WINDOW_HEIGHT-ball.h then
            GAMEOVER:play()
            lives = lives-1
            gameState = "paused"
            resetPositions()
            if lives == -1 then
                gameState = "menu"
                love.mouse.setVisible(true)
                
            end
        end
    elseif gameState=="paused" then
        paddle.x = mouseX-paddle.w/2
        ball.y = ball:DEFAULT_Y() --re-center ball y
        ball.x = math.max(paddle.w/2 - ball.w/2, math.min(WINDOW_WIDTH - paddle.w/2 - ball.w/2, paddle.x + paddle.w/2 - ball.w/2))
        paddle:update(dt)
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)

    --fps debugging
    -- love.graphics.print(love.timer.getFPS())
    
    if gameState == "play" or gameState == "paused" then
        if gameState == "paused" then
            utils.drawTextCentered("Click or press Enter to Play",H2,WINDOW_HEIGHT*0.2)
        end
        
        love.graphics.setFont(H2)
        love.graphics.print("Score "..score, 50, 50)
        love.graphics.print("Balls ", 550, 50)
        for i=1, lives do
            love.graphics.rectangle("fill", 650 + 25*i, 50, 20, 20)
        end
        love.graphics.setFont(H1)

        --draw paddle, ball, and block grid
        paddle:draw() --paddle
        ball:draw() --ball
        for r, row in ipairs(blocks) do --blocks
            for c, block in ipairs(row) do
                if block.visible then
                    block:draw()
                end
            end
        end


    elseif gameState == "menu" then
        utils.drawTextCentered("Breakout",H1,WINDOW_HEIGHT*0.1)
        for _, button in ipairs(buttons) do
            button:draw()
        end
    end
end



function love.keypressed(key, unicode)
    if gameState == "menu" then
        if key == "return" and buttons[1].isSelected then
            resetGame()
            love.mouse.setVisible(false)
            gameState = "paused"
        elseif key =="escape" then
            love.event.quit()
        elseif key =="up" then
            cycleSelection(-1)
            --play sound
            local soundInstance = BLOP:clone()
            soundInstance:play()

        elseif key=="down" then
            cycleSelection(1)
            --play sound
            local soundInstance = BLOP:clone()
            soundInstance:play()
        end

    elseif gameState == "play" then
        if key == "return" then
            elseif key == "escape" then
                gameState = "menu"
                love.mouse.setVisible(true)
            end

    elseif gameState == "paused" then
        if key == "return" then
             gameState = "play"
        elseif key == "escape" then
            gameState = "menu"
            love.mouse.setVisible(true)
        end

    end 

end


function love.mousepressed( x, y, button, istouch, presses)
    if button == 1 then
        if gameState == "paused" then
            gameState = "play"
        elseif gameState =="menu" and buttons[1].isSelected then
            resetGame()
            love.mouse.setVisible(false)
            gameState = "paused"     
        end
    end
end

function love.mousemoved(mx, my, dx, dy)
    if gameState == "menu" then
        for i, button in ipairs(buttons) do
            --for each button, check if mouse is hovering over it
            if utils.isMouseHovering(button, mx, my) then
                --if it is hovering a button, and that button isn't selected, switch it to selected.
                if not buttons[i].isSelected then
                    
                    buttons[buttons.current].isSelected = false
                    -- Update the selected one.
                    buttons.current = i
                    -- Select new button
                    buttons[buttons.current].isSelected = true
                    --play sound
                    local soundInstance = BLOP:clone()
                    soundInstance:play()
                end
            end
        end
    end
end