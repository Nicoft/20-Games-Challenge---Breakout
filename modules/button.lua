local love = require "love"

local Button = {}

function Button:new(x, y, w, h, text, textColor, buttonColor)
    local button = {
        text = text,
        w = w,
        h = h,
        x = x-w/2,
        y = y,
        textColor = textColor,
        buttonColor = buttonColor,
        mode = "fill",
        textWidth = H2:getWidth(text),
        textHeight = H2:getAscent() - H2:getDescent(),
        isSelected = false,

        update = function(self, dt)
        end,

        draw = function(self)
            love.graphics.setFont(H2)
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
    return button
end

return Button