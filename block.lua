-- block.lua
local Block = {}

-- Block creation function
function Block:new(x, y, w, h)
    local block = {
        x = x,
        y = y,
        w = w,
        h = h,
        visible = true
    }
    setmetatable(block, {__index = Block})
    return block
end

-- Drawing function
function Block:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

-- Function to instantiate and returns a grid table of blocks
function Block.instantiateBlocks(config)
    local blockWidth = config.blockWidth or 60
    local blockHeight = config.blockHeight or 30
    local gutter = config.gutter or 5
    local columns = config.columns or 10
    local rows = config.rows or 5
    local startX = config.startX or 0
    local startY = config.startY or 100
    local blockOffset = (WINDOW_WIDTH - blockWidth * columns - gutter * (columns - 1)) / 2

    -- Create a grid of blocks and return it
    local blocks = {}

    -- Loop through rows and columns to create blocks
    for r = 1, rows do  -- Loop through rows
        blocks[r] = {}  -- Initialize the row in the table
        for c = 1, columns do  -- Loop through columns
            table.insert(blocks[r], Block:new(
                startX + blockOffset + (c - 1) * (blockWidth + gutter),  -- Adjusted for 1-index
                startY + (r - 1) * (blockHeight + gutter),  -- Adjusted for 1-index
                blockWidth,
                blockHeight
            ))
        end
    end

    return blocks
end

return Block