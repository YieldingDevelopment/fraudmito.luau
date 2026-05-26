-- not obf cuh i dont know how to obf lol
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = ReplicatedStorage.Knit.Knit.Services.SpikeWrathService.RE.Effects

local switchDelay = 0.03

local running = false

local allowDummies = true

local TARGET_ANIM_ID = "rbxassetid://127727754867974"

local function getHRP(char)

	return char and char:FindFirstChild("HumanoidRootPart")

end

local function getHumanoid(char)

	return char and char:FindFirstChildOfClass("Humanoid")

end

local function isValidPosition(hrp)

	local pos = hrp.Position

	if pos.X > 1000 then return false end

	if pos.Y < -2500 then return false end

	return true

end

local function isEnemy(player)

	if not player.Team or not LocalPlayer.Team then return true end

	return player.Team ~= LocalPlayer.Team

end

local function getTargets()

	local targets = {}

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer and isEnemy(player) then

			local char = player.Character

			if char and getHRP(char) and getHumanoid(char) then

				table.insert(targets, char)

			end

		end

	end

	if allowDummies then

		for _, obj in ipairs(workspace:GetDescendants()) do

			if obj:IsA("Model") and obj ~= LocalPlayer.Character then

				local humanoid = getHumanoid(obj)

				local hrp = getHRP(obj)

				if humanoid and hrp and not Players:GetPlayerFromCharacter(obj) then

					table.insert(targets, obj)

				end

			end

		end

	end

	return targets

end

local function stopSwitching()

	running = false

end

local function startSwitching()

	if running then return end

	running = true

	task.spawn(function()

		while running do

			local myChar = LocalPlayer.Character

			local myHRP = getHRP(myChar)

			if myHRP then

				for _, targetChar in ipairs(getTargets()) do

					if not running then break end

					local targetHRP = getHRP(targetChar)

					if targetHRP and isValidPosition(targetHRP) then

						myHRP.CFrame = targetHRP.CFrame

						task.wait(switchDelay)

					end

				end

			end

			task.wait()

		end

	end)

end

local function monitorMyAnimation()

	task.spawn(function()

		local myChar = LocalPlayer.Character

		if not myChar then return end

		local humanoid = getHumanoid(myChar)

		if not humanoid then return end

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if not animator then return end

		local found = false

		for _ = 1, 20 do

			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do

				if track.Animation and track.Animation.AnimationId == TARGET_ANIM_ID then

					track.Stopped:Connect(stopSwitching)

					found = true

					break

				end

			end

			if found then break end

			task.wait(0.05)

		end



		if not found then

			task.wait(3)

			stopSwitching()

		end

	end)

end

LocalPlayer.CharacterAdded:Connect(function()

	running = false

end)

Event.OnClientEvent:Connect(function(...)

	startSwitching()

	monitorMyAnimation()

end)
