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
        -- isHovered = false,
        isSelected = false,
        -- update = function(self, dt, mouseX, mouseY)
        --     self.isHovered = mouseX > self.x and mouseX < self.x + self.w and mouseY > self.y and mouseY < self.y + self.h
        -- end,
        draw = function(self)
            love.graphics.setFont(h2)
            if self.isHovered or self.isSelected then
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

local score_player1 = 0
local score_player2 = 0



local ball = {
    DEFAULT_X = WINDOW_WIDTH/2,
    DEFAULT_Y = WINDOW_HEIGHT/2,
    x = 0,
    y = 0,
    w = 20,
    h = 20,
    dx = 1,
    dy = 1,
    speed = 300,

    draw = function(self)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end,
    update = function(self, dt)

        --if the ball touches the top or bottom, reverse Y direction.
        if self.y <= 0 then
            blip:play()
            self.y = 0
            self.dy = -self.dy
        end

        if self.y >= (WINDOW_HEIGHT - self.h) then
            blip:play()
            self.y = WINDOW_HEIGHT - self.h
            self.dy = -self.dy
        end

        --ball movement
        -- self.x = self.x + self.speed * self.dx * dt
        -- self.y = self.y + self.speed * self.dy * dt
    end
}

local function createPaddle(id, x, y, w, h)
    return {
        id = id,
        w = w,
        h = h,
        x = x,
        y = y, 
        speed = 400,
        dy = 0,
        reactionTime = 0.4,
        timer = 0,
        draw = function(self)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end,
        update = function(self, dt, ball)

            --paddle movement, with max a min stoppers for top and bottom edge of screen.
            self.x = math.max(0, math.min(WINDOW_WIDTH - self.w, self.x + self.speed * self.dx * dt))
        end
    }
end

local paddle = {
    w = 100,
    h = 20
}
local paddle1 = createPaddle(1, WINDOW_WIDTH/2-paddle.w/2, 560, paddle.w, paddle.h)

local function resetPositions()
    paddle1.y = 560
    ball.x = ball.DEFAULT_X - ball.w / 2
    ball.y = ball.DEFAULT_Y - ball.h / 2
    -- Small random vertical angle
    local angle = math.rad(love.math.random(-30, 30)) -- Random angle between -30° and 30°
    ball.dy = math.sin(angle)
    ball.speed = 300
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
        paddle1.dx = (love.keyboard.isDown('left') and -1) or (love.keyboard.isDown('right') and 1) or 0

        paddle1:update(dt,ball)
        ball:update(dt)

        if utils.checkCollision(paddle1, ball) then
            blop:play()
            local angle = utils.calculateBounce(ball, paddle1)
            ball.dx = math.cos(angle) -- Adjust X based on the angle
            ball.dy = -math.sin(angle)
            local magnitude = utils.magnitude(ball.dx,ball.dy)
            ball.dx = ball.dx / magnitude
            ball.dy = ball.dy / magnitude
            ball.x = paddle1.x + paddle1.w
            ball.speed = ball.speed * 1.05 -- Gradual speed increase
        end

        if ball.x <= 0 then
            gameover:play()
            score_player2 = score_player2 + 1
            gameState = "paused"
            ball.dx = -1
            resetPositions()
        end

        if (ball.x + ball.w) >= WINDOW_WIDTH then
            gameover:play()
            score_player1 = score_player1 + 1
            gameState = "paused"
            ball.dx = 1
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
    utils.drawTextCentered("PONG",h1,WINDOW_HEIGHT*0.1)
    if gameState == "play" or gameState == "paused" then
        
        love.graphics.print(score_player1, WINDOW_WIDTH*0.15, WINDOW_HEIGHT*0.1)
        love.graphics.print(score_player2, WINDOW_WIDTH*0.85-h1:getWidth(score_player2)/2, WINDOW_HEIGHT*0.1)
        if gameState == "paused" then
            utils.drawTextCentered("Press Enter to Play",h2,WINDOW_HEIGHT*0.2)
        end

        paddle1:draw()
        ball:draw()
        

        --fps debugging
        -- love.graphics.print("dx : "..ball.dx,80)
        -- love.graphics.print(love.timer.getFPS())
    elseif gameState == "menu" then
        button1:draw()
    end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		if gameState == "menu" then
            love.event.quit()
        else
            gameState = "menu"
            --reset scores when going back to menu
            score_player1 = 0
            score_player2 = 0
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
        elseif key == "return" and button2.isSelected then
            --turn on ai on paddle1 if ai is selected
            paddle1.isAI = true
            ball.dx = utils.randomDirection()
            resetPositions()
            gameState = "paused"
        end
    end
end
