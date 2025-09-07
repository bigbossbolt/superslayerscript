-- Full Roblox Script - GitHub Ready
-- All features included: Walkspeed, Jump, Fly, ESP, AimLock, Settings

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Modules
local Modules = {
    Walkspeed = {Speed = 0},
    Jump = {Enabled = false},
    Fly = {Enabled = false, Speed = 60},
    ESP = {Enabled = false, VisibleColor = Color3.fromRGB(0,255,0), WallColor = Color3.fromRGB(255,0,0)},
    AimLock = {Enabled = false, TargetPlayer = nil, Key = Enum.UserInputType.MouseButton2},
    Settings = {}
}

-- Utility: Closest player
local function GetClosestPlayer()
    local closest, distance = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = UIS:GetMouseLocation()
                local mag = (Vector2.new(pos.X,pos.Y) - mousePos).Magnitude
                if mag < distance then
                    closest, distance = plr, mag
                end
            end
        end
    end
    return closest
end

-- CFrame Walkspeed
RunService.Heartbeat:Connect(function(dt)
    if Modules.Walkspeed.Speed <= 0 or not Player.Character then return end
    local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
    local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if not (HRP and Hum) or Hum.Sit or Hum.Health <= 0 then return end
    if Modules.Fly.Enabled then return end

    local camCF = Camera.CFrame
    local fwd = Vector3.new(camCF.LookVector.X,0,camCF.LookVector.Z)
    local right = Vector3.new(camCF.RightVector.X,0,camCF.RightVector.Z)
    if fwd.Magnitude > 0 then fwd = fwd.Unit end
    if right.Magnitude > 0 then right = right.Unit end

    local move = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - right end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + right end

    if move.Magnitude > 0 then
        HRP.CFrame = HRP.CFrame + move.Unit * (Modules.Walkspeed.Speed * dt)
    end
end)

-- Jump & Infinite Jump
UIS.JumpRequest:Connect(function()
    if Modules.Jump.Enabled and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly Mode
RunService.RenderStepped:Connect(function()
    if Modules.Fly.Enabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Player.Character.HumanoidRootPart
        local dir = Vector3.zero
        local camCF = Camera.CFrame
        local fwd = camCF.LookVector
        local right = camCF.RightVector
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + fwd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - fwd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        HRP.Velocity = dir.Magnitude > 0 and dir.Unit*Modules.Fly.Speed or Vector3.zero
    end
end)

-- ESP with line-of-sight
RunService.RenderStepped:Connect(function()
    if not Modules.ESP.Enabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = plr.Character.HumanoidRootPart
            local highlight = plr.Character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Parent = plr.Character
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = Modules.ESP.WallColor
            end

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {Player.Character, plr.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.IgnoreWater = true
            local rayResult = workspace:Raycast(Camera.CFrame.Position, HRP.Position - Camera.CFrame.Position, rayParams)

            if rayResult then
                highlight.FillColor = Modules.ESP.WallColor
            else
                highlight.FillColor = Modules.ESP.VisibleColor
            end
        end
    end
end)

-- Aim Lock
UIS.InputBegan:Connect(function(input)
    if Modules.AimLock.Enabled and input.UserInputType == Modules.AimLock.Key then
        Modules.AimLock.TargetPlayer = GetClosestPlayer()
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Modules.AimLock.Key then
        Modules.AimLock.TargetPlayer = nil
    end
end)
RunService.RenderStepped:Connect(function()
    if Modules.AimLock.Enabled and Modules.AimLock.TargetPlayer and Modules.AimLock.TargetPlayer.Character and Modules.AimLock.TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Modules.AimLock.TargetPlayer.Character.HumanoidRootPart.Position)
    end
end)

-- Settings Unload
Modules.Settings.Unload = function()
    for _, ui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if ui.Name:find("Rayfield") then ui:Destroy() end
    end
end
