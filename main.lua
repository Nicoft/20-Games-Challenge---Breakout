gUtils = require "src.utils"
gDebugging = require "src.debugging"
gTimer = require "src.timer"
local stateMachine = require("src.stateMachine")
local playState = require("states.playState")
local menuState = require("states.menuState")
local readyState = require("states.readyState")
local winState = require("states.winState")

local Button = require("modules.button")
local Ball = require("modules.ball")
local Paddle = require("modules.paddle")
local Block = require("modules.block")

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

    --art
    local blockImg = love.graphics.newImage("assets/block.png")
    
--Game objects
local gameObjects = {
    score = 0,
    lives = 3,
    ball = Ball:new(),
    paddle = Paddle:new(100, 20),
    menu = {
        selected = 1,
        buttons = {
            Button:new(WINDOW_WIDTH/2, 250, 200, 50, "Play", {0,0,0}, {1,1,1}),
            Button:new(WINDOW_WIDTH/2, 350, 200, 50, "Pay", {0,0,0}, {1,1,1}),
            Button:new(WINDOW_WIDTH/2, 450, 200, 50, "Py", {0,0,0}, {1,1,1}),
        },
    },
    levels = {
        {columns = 1, rows = 1, startY = 150, isRandom = false, strength = 1},
        {columns = 2, rows = 2, startY = 150, isRandom = false, strength = 1},
        {columns = 10, rows = 5, startY = 150, isRandom = false, strength = 1},
        {columns = 10, rows = 5, startY = 150, isRandom = true, strength = 1},
    },
    currentLevel = 1,
    blocks = nil,
    blockCounter = 0,
    levelFactory = function(self, level)
            self.blocks, self.blockCounter = Block.instantiateBlocks(level) -- Instantiate blocks with config table and send the results to blocks object
        end
}

--States
gStateMachine = stateMachine:new({
    play = playState,
    menu = menuState,
    ready = readyState,
    win = winState
})

--Love2d functions
function love.load ()
    love.math.setRandomSeed(os.time() + love.timer.getTime())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(H1)
    --start on the menuState
    gStateMachine:change("menu", gameObjects)
end

function love.update(dt)
    gTimer.update(dt)
    gStateMachine:update(dt)
end

function love.draw()
    love.graphics.setColor(1,1,1)

    gUtils.drawTextCentered(love.timer.getFPS(), H2, WINDOW_HEIGHT*0.9)
    gStateMachine:draw()
end



function love.keypressed(key, unicode)
    gStateMachine:keypressed(key)
end


function love.mousepressed( x, y, button, istouch, presses)
    gStateMachine:mousepressed(x, y, button, istouch, presses)
end

function love.mousemoved(mx, my, dx, dy)
    gStateMachine:mousemoved(mx, my, dx, dy)
end