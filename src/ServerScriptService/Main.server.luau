local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

Knit.AddServices(script.Parent:WaitForChild("Services"))

Knit.Start()
	:andThen(function()
		print("Knit server started!")
	end)
	:catch(warn)

-- Server Bootstrap
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages", 10)
assert(Packages, "Packages missing; run wally install and check Rojo mapping")

Knit.AddServices(ServerScriptService:WaitForChild("Services"))

Knit.Start()
	:andThen(function()
		print("[Knit] Server started")
	end)
	:catch(warn)
