local menuState = {}

-- functions
local function cycleSelection(self, direction)
    --loop back to begining/end
    self.selected = self.selected + direction
    if self.selected < 1 then
        self.selected = #self.buttons
    elseif self.selected > #self.buttons then
        self.selected = 1
    end

    -- for every button, update selection flags with the currently selected number
    for i, button in ipairs(self.buttons) do
        button.isSelected = (i == self.selected)
    end
end



function menuState:enter(gameObjects)
    self.gameObjects = gameObjects
    self.buttons = gameObjects.menu.buttons

    --enable mouse
    love.mouse.setVisible(true)
    --make sure a button is selected
    self.selected = gameObjects.menu.selected or 1  -- Ensure default selection
    self.buttons[self.selected].isSelected = true

    self.gameObjects.lives = 3
    self.gameObjects.currentLevel = 1
    self.gameObjects.score = 0
end

function menuState:update(dt)

end

function menuState:draw()
    gUtils.drawTextCentered("Breakout",H1,WINDOW_HEIGHT*0.1)
    if self.buttons then
        for _, button in ipairs(self.buttons) do
            button:draw()
        end
    end
end

function menuState:keypressed(key)
    if key == "return" and self.buttons[1].isSelected then

        love.mouse.setVisible(false)
        gStateMachine.change("paused", self.gameObjects)
    elseif key =="escape" then
        love.event.quit()
    elseif key =="up" then
        cycleSelection(self, -1)
        --play sound
        local soundInstance = BLOP:clone()
        soundInstance:play()

    elseif key=="down" then
        cycleSelection(self, 1)
        --play sound
        local soundInstance = BLOP:clone()
        soundInstance:play()
    end
end

function menuState:mousemoved(mx, my, dx, dy)
    for i, button in ipairs(self.buttons) do
        --for each button, check if mouse is hovering over it
        if gUtils.isMouseHovering(button, mx, my) then
            --if it is hovering a button, and that button isn't selected, switch it to selected.
            if not self.buttons[i].isSelected then
                
                self.buttons[self.selected].isSelected = false
                -- Update the selected one.
                self.selected = i
                -- Select new button
                self.buttons[self.selected].isSelected = true
                --play sound
                local soundInstance = BLOP:clone()
                soundInstance:play()
            end
        end
    end
end

function menuState:mousepressed()
    if self.buttons[1].isSelected then
        gStateMachine:change("ready", self.gameObjects)
    end
end

return menuState