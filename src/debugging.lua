local debugging = {}

function debugging.displayDebugInfo(mouse, card)
    -- Debug information printing (mouse position, flip timer, card dimensions, etc.)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Mouse Position: %d, %d", mouse.x, mouse.y), 10, 10)
    love.graphics.print(string.format("Flip Counter: %.2f", card.counter), 10, 20)
    love.graphics.print(string.format("Card Position: x: %.2f, y: %.2f", card.x, card.y), 10, 30)
    love.graphics.print(string.format("Card Dimensions: w: %.2f, h: %.2f", card.w, card.h), 200, 10)
    love.graphics.print("Current FPS: "..love.timer.getFPS( ), 10, 50)
    love.graphics.print(debugging.dump(card),10, 100)
end

function debugging.dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. debugging.dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

function debugging.showGlobal()
    for k,v in pairs(_G) do
        print('["'..k..'"] = ',v)
    end
end

-- Function to print the contents of a table
function debugging.printTable(t, name, indent)
    if not indent then indent = 0 end
    local prefix = string.rep("  ", indent)
    
    -- Print the name of the table if provided
    if name then
        print(prefix .. name .. " {")
    end

    -- Iterate over the table and print its keys and values
    for k, v in pairs(t) do
        if type(v) == "table" then
            debugging.printTable(v, k, indent + 1)  -- Recursive call for nested tables
        else
            print(prefix .. "  " .. k .. " = " .. tostring(v))
        end
    end

    -- Print the closing brace for the table
    print(prefix .. "}")
end

return debugging

