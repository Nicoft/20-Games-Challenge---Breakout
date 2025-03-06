local stateMachine = {}

function stateMachine:new(states)
    local obj = {
        states = states or {},
        current = nil
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function stateMachine:change(stateName, ...)
    assert(self.states[stateName], "State " .. stateName .. " does not exist!")
    self.current = self.states[stateName]
    if self.current.enter then
        self.current:enter(...) -- Call enter function if it exists
    end
end

function stateMachine:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function stateMachine:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function stateMachine:keypressed(key)
    if self.current and self.current.keypressed then
        self.current:keypressed(key)
    end
end

function stateMachine:mousepressed(x, y, button, istouch, presses)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(x, y, button, istouch, presses)
    end
end


function stateMachine:mousemoved(mx, my, dx, dy)
    if self.current and self.current.mousemoved then
        self.current:mousemoved(mx, my, dx, dy)
    end
end

return stateMachine