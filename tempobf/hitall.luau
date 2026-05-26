local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = ReplicatedStorage.Knit.Knit.Services.TwofoldKickService.RE.Effects

local switchDelay = 0.001
local running = false

local function getHRP(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function isValidPosition(hrp)
	local pos = hrp.Position
	
	if pos.X > 1000 then return false end
	if pos.Y < -2500 then return false end
	
	return true
end

local function startSwitching()
	if running then return end
	running = true

	task.spawn(function()
		while running do
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					local myHRP = getHRP(LocalPlayer.Character)
					local targetHRP = getHRP(player.Character)

					if myHRP and targetHRP and isValidPosition(targetHRP) then
						myHRP.CFrame = targetHRP.CFrame
						task.wait(switchDelay)
					end
				end
			end
			task.wait()
		end
	end)
end

local function stopSwitching()
	running = false
end

local function monitorAnimation()
	local char = LocalPlayer.Character
	if not char then return end
	
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Animation and track.Animation.AnimationId == "rbxassetid://116811846715462" then
			track.Stopped:Connect(function()
				stopSwitching()
			end)
		end
	end
end

Event.OnClientEvent:Connect(function(action, character)
	if action == "Domain" and character == LocalPlayer.Character then
		startSwitching()
		task.delay(0.1, monitorAnimation) -- slight delay so animation exists
	end
end)
