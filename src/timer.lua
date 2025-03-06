local Timer = {}

local timers = {}

--- Add a one-time timer
function Timer.after(delay, func)
    table.insert(timers, { time = delay, callback = func, repeating = false })
end

--- Add a repeating timer
function Timer.every(interval, func)
    local t = { time = interval, interval = interval, callback = func, repeating = true }
    table.insert(timers, t)
    return t -- Return reference for canceling
end

--- Cancel a timer
function Timer.cancel(t)
    for i = #timers, 1, -1 do
        if timers[i] == t then
            table.remove(timers, i)
            break
        end
    end
end

--- Chain timers together
function Timer.chain(...)
    local funcs = { ... }
    local function runNext()
        if #funcs > 0 then
            local nextFunc = table.remove(funcs, 1)
            nextFunc()
            if #funcs > 0 then
                Timer.after(0, runNext) -- Schedule the next function
            end
        end
    end
    runNext()
end

--- Update timers
function Timer.update(dt)
    for i = #timers, 1, -1 do
        local t = timers[i]
        t.time = t.time - dt
        if t.time <= 0 then
            t.callback()
            if t.repeating then
                t.time = t.interval -- Reset for next repeat
            else
                table.remove(timers, i) -- Remove one-time timers
            end
        end
    end
end

return Timer