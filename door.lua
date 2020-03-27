local component = require("component")
local sides = require("sides")
local colors = require("colors")
local event = require("event")
local rs = component.redstone

local wire = sides.left
local enable = sides.back

-- Color aliases
local bottomHalf = colors.green
local sidePullers = colors.brown
local midActivator = colors.blue
local topPositioner = colors.purple
local bottomPositionerL1 = colors.cyan
local bottomPositionerL2 = colors.silver

local openButton = colors.gray

-- State
local isOpen = false -- TODO: detect starting state

print("Door program starting...")

function isEnabled() 
    return rs.getInput(enable) > 0
end

function setControlState(control, state)
    local outVal = 0
    if state then
        outVal = 15
    end
    rs.setBundledOutput(wire, control, outVal)
end

function closeRoutine() 
    print("Starting Close Routine")

    setControlState(bottomHalf, false)

    setControlState(sidePullers, true)

    setControlState(bottomPositionerL1, true)
    os.sleep(0.5)
    setControlState(bottomPositionerL2, true)
    os.sleep(0.5)

    setControlState(midActivator, true)
    os.sleep(0.5)
    setControlState(midActivator, false)
    setControlState(sidePullers, false)
    os.sleep(0.5)

    setControlState(bottomPositionerL2, false)
    os.sleep(0.5)
    setControlState(bottomPositionerL1, false)
    os.sleep(0.5)

    setControlState(bottomPositionerL2, true)
    os.sleep(0.5)
    setControlState(bottomPositionerL2, false)

    isOpen = false
    print("Close Routine Finished")

end

function openRoutine() 
    print("Starting Open Routine")

    setControlState(bottomHalf, true)

    setControlState(topPositioner, true)
    setControlState(midActivator, true)

    os.sleep(0.5)
    setControlState(midActivator, false)
    os.sleep(0.5)

    setControlState(topPositioner, false)
    setControlState(sidePullers, true)
    os.sleep(0.5)
    setControlState(sidePullers, false)

    isOpen = true
    print("Open Routine Finished")
end

function mainLoop()
    print("Starting main loop")

    while isEnabled() do

        -- check if open button is pressed
        if rs.getBundledInput(wire, openButton) > 0 then
            if isOpen then
                closeRoutine()
            else
                openRoutine()
            end
        end

        os.sleep(1)
    end

    print("Enable signal not found. Exiting..")

end

mainLoop()