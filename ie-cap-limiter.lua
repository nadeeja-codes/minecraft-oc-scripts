local component = require("component")
local sides = require("sides")
local event = require("event")
local computer = require("computer")
local rs = component.redstone
local cap = component.ie_hv_capacitor

print("IE Capacitor Limiter program starting...")

local maxRf = cap.getMaxEnergyStored()
local lastRemain = 0
local overflowState = false
local running = true

local args = {...}
if (args[1] == nil or args[2] == nil or args[3] == nil) then
    print("All arameter not specified (outSide, minRF, maxRF")
    return
end
local outSide = tonumber(args[1])
local minRF = tonumber(args[2])
local maxRF = tonumber(args[3])

print ("Cap Max RF: " .. maxRf)
print ("RF Output Side: " .. outSide)
computer.beep(1000, 0.25)

function handleInterrupt(_, addr, char)
    if (char == 96) then
        running = false
    end
end

function registestEvents() 
    event.listen("key_down", handleInterrupt)
end

function round(val)
    return (math.floor(val * 100) / 100)
end

function getRemainingRf()
    local currentRf = cap.getEnergyStored()
    return round(currentRf / maxRf)
end

function setOverflowState(state)
    local outVal = 0
    if state then
        outVal = 15
    end
    overflowState = state
    rs.setOutput(outSide, outVal)
end

setOverflowState(false)
registestEvents()

while running do
    local remain = getRemainingRf()

    if remain ~= lastRemain then
        print("RF change detected. Remaining RF: " .. remain)
        
        if overflowState == true and remain < minRF then
            print("RF below " .. (minRF * 100) .. "% | Switching Off Overflow until 90% Charge")
            setOverflowState(false)
            computer.beep(1000, 0.25)
            computer.beep(1000, 0.25)
        end

        if overflowState == false and remain > maxRF then
            print("RF above " .. (maxRF * 100) .. "% | Switching On Overflow")
            setOverflowState(true)
            computer.beep(1000, 0.25)
        end
    end

    lastRemain = remain
    os.sleep(1)
end

print("Cleaning up and Closing")
event.ignore("key_down", handleInterrupt)
setOverflowState(false)