local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

Knit.AddServices(script.Parent:WaitForChild("Services"))

Knit.Start()
	:andThen(function()
		print("Knit server started!")
	end)
	:catch(warn)
