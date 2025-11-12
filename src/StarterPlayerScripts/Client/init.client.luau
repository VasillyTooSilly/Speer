local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

-- Add all controllers from the local folder
Knit.AddControllers(script.Parent:WaitForChild("Controllers"))

Knit.Start()
	:andThen(function()
		print("[Client] Knit started successfully!")
	end)
	:catch(warn)
