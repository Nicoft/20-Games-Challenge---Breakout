# Timer

A custom small timer module for timing function callbacks

## _How to Use the Timer Module_




## Installation

require **Timer.lua**

```sh
gTimer = require "src.timer"
```


## 1. Delayed Action (`after`)

Have a callback function trigger after a certain time.
```
Timer.after(2, function()
    print("This prints after 2 seconds")
end)
```

## 2. Repeating Action (`every`)

Have a callback function trigger repeatedly at each interval.
```
local blinkTimer = Timer.every(1, function()
    print("This prints every second")
end)
```


## 3. Canceling a Timer (`cancel`)

Mostly used to cancel repeated timers. Must pass in the same timer used for the repeat.
```
Timer.cancel(blinkTimer) -- Stops the repeating timer
```
>


## Using the Timer in love.update

```
function love.update(dt)
    gTimer.update(dt)
end
```
