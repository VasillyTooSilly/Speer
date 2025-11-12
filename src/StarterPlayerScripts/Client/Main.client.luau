local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage:WaitForChild("Packages", 10)
assert(packages, "ReplicatedStorage.Packages missing; ensure Wally packages are mapped into ReplicatedStorage")
local KnitModule = packages:WaitForChild("Knit", 10)
assert(KnitModule, "Knit package missing in ReplicatedStorage.Packages")
local Knit = require(KnitModule)

-- Add all controllers from the local folder
Knit.AddControllers(script.Parent:WaitForChild("Controllers"))

Knit.Start()
    :andThen(function()
        print("[Client] Knit started successfully!")
    end)
    :catch(warn)
