local love = require "love"
local utils = require "utils"

-- resources
local h1 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",48)
local h2 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",18)
local blop = love.audio.newSource("sounds/blop.mp3", "static")
local blip = love.audio.newSource("sounds/blip.mp3", "static")
local gameover = love.audio.newSource("sounds/gameover.wav", "static")

--constants
WINDOW_WIDTH = love.graphics.getWidth()
WINDOW_HEIGHT = love.graphics.getHeight()

local function createButton(x, y, w, h, text, textColor, buttonColor)
    return {
        text = text,
        w = w,
        h = h,
        x = x-w/2,
        y = y,
        textColor = textColor,
        buttonColor = buttonColor,
        mode = "fill",
        textWidth = h2:getWidth(text),
        textHeight = h2:getAscent() - h2:getDescent(),
        isSelected = false,

        draw = function(self)
            love.graphics.setFont(h2)
            if self.isSelected then
                love.graphics.setColor(buttonColor[1],buttonColor[2],buttonColor[3])
                love.graphics.rectangle(self.mode, self.x, self.y, self.w, self.h)
                love.graphics.setColor(textColor[1],textColor[2],textColor[3])
                love.graphics.print(self.text, self.x + self.w/2 - self.textWidth/2, self.y + self.h/2 - self.textHeight/2)
            else
                love.graphics.setColor(buttonColor[1],buttonColor[2],buttonColor[3])
                love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
                love.graphics.setColor(buttonColor[1],buttonColor[2],buttonColor[3])
                love.graphics.print(self.text, self.x + self.w/2 - self.textWidth/2, self.y + self.h/2 - self.textHeight/2)
            end
        end,
    }
end

local button1 = createButton(WINDOW_WIDTH/2, 250, 200, 50, "Play", {0,0,0}, {1,1,1})

--variables
local gameState = "menu"

local ball = {
    x = 0,
    y = 0,
    w = 20,
    h = 20,
    dx = 1,
    dy = -1,
    speed = 400,

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
            blip:play()
            self.x = 0
            self.dx = -self.dx
        end

        if self.x >= (WINDOW_WIDTH - self.w) then
            blip:play()
            self.x = WINDOW_WIDTH - self.w
            self.dx = -self.dx
        end

        --if the ball touches the top, reverse Y direction.
        if self.y <= 0 then
            blip:play()
            self.y = 0
            self.dy = -self.dy
        end

        --ball movement
        self.x = self.x + self.speed * self.dx * dt
        self.y = self.y + self.speed * self.dy * dt
    end
}

local function createPaddle(id, x, y, w, h)
    return {
        id = id,
        w = w,
        h = h,
        x = x,
        y = y, 
        speed = 600,
        dx = 0,
        reactionTime = 0.4,
        timer = 0,
        draw = function(self)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end,
        update = function(self, dt, ball)
            --paddle movement, with max a min stoppers for left and right edge of screen.
            self.x = math.max(0, math.min(WINDOW_WIDTH - self.w, self.x + self.speed * self.dx * dt))
        end
    }
end

local paddle_obj = {
    w = 100,
    h = 20
}
local paddle = createPaddle(1, WINDOW_WIDTH/2-paddle_obj.w/2, 560, paddle_obj.w, paddle_obj.h)


-- functions
local function resetPositions()
    paddle.x = WINDOW_WIDTH/2-paddle.w/2 --re-center the paddle
    ball.x = ball:DEFAULT_X() --re-center ball x
    ball.y = ball:DEFAULT_Y() --re-center ball y

    local angle = math.rad(love.math.random(45, 135)) -- Random angle to shoot ball from
    ball.dx = math.cos(angle)
    ball.dy = -math.sin(angle)

    ball.speed = 400
end


function love.load ()
    love.math.setRandomSeed(os.time() + love.timer.getTime())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(h1)
    button1.isSelected = true
    

end

function love.update(dt)
    if gameState == "play" then
        --player1
        paddle.dx = (love.keyboard.isDown('left') and -1) or (love.keyboard.isDown('right') and 1) or 0

        paddle:update(dt,ball)
        ball:update(dt)

        if utils.checkCollision(paddle, ball) then
            blop:play()
            local angle = utils.calculateBounce(ball, paddle)
            ball.dy = angle.dy
            ball.dx = angle.dx
            ball.y = paddle.y - ball.h --pop the ball out of the paddle to prevent multiple collisions
            -- ball.speed = ball.speed * 1.05 -- Gradual speed increase
        end


        if ball.y >= WINDOW_HEIGHT-ball.h then
            gameover:play()

            gameState = "paused"
            ball.dx = -1
            resetPositions()
        end
    elseif gameState == "menu" then
        local mouseX, mouseY = love.mouse.getPosition()
        -- button1:update(dt, mouseX, mouseY)
        -- button2:update(dt, mouseX, mouseY)

    end

end

function love.draw()
    love.graphics.setColor(1,1,1)
    
    if gameState == "play" or gameState == "paused" then
        

        if gameState == "paused" then
            utils.drawTextCentered("Press Enter to Play",h2,WINDOW_HEIGHT*0.2)
        end

        paddle:draw()
        ball:draw()
        

        --fps debugging
        -- love.graphics.print("dx : "..ball.dx,80)
        -- love.graphics.print(love.timer.getFPS())
    elseif gameState == "menu" then
        utils.drawTextCentered("Breakout",h1,WINDOW_HEIGHT*0.1)
        button1:draw()
    end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		if gameState == "menu" then
            love.event.quit()
        else
            gameState = "menu"

        end
	end
    if key == "return" then
        if gameState == "paused" then
            gameState = "play"
        end
    end
    if gameState == "menu" then 

        if key == "return" and button1.isSelected then
            ball.dx = utils.randomDirection()
            resetPositions()
            gameState = "paused"
        end
    end
end
