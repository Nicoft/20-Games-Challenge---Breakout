local blockImg = love.graphics.newImage("assets/block.png")
local blockImgH = love.graphics.newImage("assets/blockH.png")

-- block.lua
local Block = {}

-- Block creation function
function Block:new(x, y, w, h, strength)
    local block = {
        x = x,
        y = y,
        w = w,
        h = h,
        strength = strength,
        isActive = true,
        isDying = false,

    }
    setmetatable(block, {__index = Block})
    return block
end

function Block:destroy()
    self.isDying = true
    gTimer.after(0.05, function()
        self.isActive = false
    end)
end

function Block:update(dt)
    if not self.isActive then
        if self.deathCounter <= self.deathLimit then
            self.deathCounter = self.deathCounter + dt
        end             
    end 
end

-- Drawing function
function Block:draw()
    -- love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    if self.isActive then
        if self.isDying then
            love.graphics.draw(blockImgH, self.x, self.y)
        else
            love.graphics.draw(blockImg, self.x, self.y)
        end
        
    end
end

-- Function to instantiate and returns a grid table of blocks
function Block.instantiateBlocks(config)
    local blockWidth = config.blockWidth or 60
    local blockHeight = config.blockHeight or 30
    local strength = config.strength or 1
    local gutter = config.gutter or 5
    local columns = config.columns or 10
    local rows = config.rows or 5
    local startX = config.startX or 0
    local startY = config.startY or 100
    local isRandom = config.isRandom or false
    local blockCounter = 0
    local blockOffset = (WINDOW_WIDTH - blockWidth * columns - gutter * (columns - 1)) / 2

    -- Create a grid of blocks and return it
    local blocks = {}

    local insertBlock = function(r,c)
        table.insert(blocks[r], Block:new(
            startX + blockOffset + (c - 1) * (blockWidth + gutter),  -- Adjusted for 1-index
            startY + (r - 1) * (blockHeight + gutter),  -- Adjusted for 1-index
            blockWidth,
            blockHeight,
            strength
        ))  
        blockCounter = blockCounter +1
    end
    -- Loop through rows and columns to create blocks
    for r = 1, rows do  -- Loop through rows
        blocks[r] = {}  -- Initialize the row in the table
        for c = 1, columns do  -- Loop through columns
            if isRandom then
                if math.random(0, 1) == 1 then
                    insertBlock(r,c)
                end
            else
                insertBlock(r,c)
            end
        end
    end

    -- local blockModule = {
    --     blocks = blocks,
    --     blockCounter = blockCounter
    -- }
    return blocks, blockCounter
end

return Block