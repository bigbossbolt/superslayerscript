--// Fresh Script (Integrated)
-- Walkspeed | Jump Power | Fly | Aim Lock (with FOV circle, RGB/opacity, sticky aim)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Create Window
local Window = Rayfield:CreateWindow({
    Name = "Fresh Script",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Powered by Rayfield",
    ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = "FreshConfig"},
    KeySystem = false
})

-------------------------------------------------
-- MAIN TAB
local MainTab = Window:CreateTab("Main", 4483362458)

-- Walkspeed
local WalkspeedValue = 50
MainTab:CreateSlider({
    Name = "Walkspeed",
    Range = {0, 120},
    Increment = 2,
    Suffix = "studs/s",
    CurrentValue = WalkspeedValue,
    Callback = function(val) WalkspeedValue = val end
})

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    local Hum = char:FindFirstChildOfClass("Humanoid")
    if not (HRP and Hum) or Hum.Sit or Hum.Health <= 0 then return end

    local camCF = Camera.CFrame
    local fwd = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

    local move = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - right end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + right end

    if move.Magnitude > 0 then
        HRP.CFrame = HRP.CFrame + Vector3.new(move.Unit.X, 0, move.Unit.Z) * (WalkspeedValue * dt)
    end
end)

-- Jump Power
MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Callback = function(val)
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then Hum.JumpPower = val end
    end
})

-- Fly
local FlyEnabled = false
local FlySpeed = 50
MainTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = function(val) FlyEnabled = val end
})

RunService.RenderStepped:Connect(function()
    if not FlyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local move = Vector3.zero
    local camCF = Camera.CFrame
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + camCF.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - camCF.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - camCF.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + camCF.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end

    if move.Magnitude > 0 then
        HRP.Velocity = move.Unit * FlySpeed
    else
        HRP.Velocity = Vector3.zero
    end
end)

-------------------------------------------------
-- AIM LOCK TAB
local AimLockTab = Window:CreateTab("Aim Lock", 6031280882)

local CamLockEnabled = false
local StickyAimLock = false
local IsHoldingKey = false
local CamLockBindString = "MouseButton2"
local TargetPlayer = nil

AimLockTab:CreateToggle({
    Name = "Aim Lock",
    CurrentValue = false,
    Callback = function(v) CamLockEnabled = v end
})

AimLockTab:CreateToggle({
    Name = "Sticky Aim Lock",
    CurrentValue = false,
    Callback = function(v) StickyAimLock = v end
})

AimLockTab:CreateKeybind({
    Name = "Aim Lock Key",
    CurrentKeybind = "MouseButton2",
    HoldToInteract = true,
    Callback = function(keyString)
        if type(keyString) == "string" and keyString ~= "" then
            CamLockBindString = keyString
        end
    end
})

-- FOV circle
local FOV, FOVRed, FOVGreen, FOVBlue, FOVOpacity = 100, 255, 0, 0, 0.5
local FOVGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
FOVGui.Name = "AimLockFOV"
FOVGui.ResetOnSpawn = false

local Circle = Instance.new("Frame", FOVGui)
Circle.AnchorPoint = Vector2.new(0.5,0.5)
Circle.Size = UDim2.new(0, FOV*2, 0, FOV*2)
Circle.Position = UDim2.new(0.5,0,0.5,0)
Circle.BackgroundTransparency = 1

Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)
local UIStroke = Instance.new("UIStroke", Circle)
UIStroke.Thickness = 2

local function UpdateFOVCircle()
    UIStroke.Color = Color3.fromRGB(FOVRed, FOVGreen, FOVBlue)
    UIStroke.Transparency = 1 - FOVOpacity
end
UpdateFOVCircle()

-- FOV Sliders
AimLockTab:CreateLabel("FOV Settings")
AimLockTab:CreateSlider({ Name="Radius", Range={50,500}, Increment=5, CurrentValue=FOV, Callback=function(v) FOV=v; Circle.Size=UDim2.new(0,FOV*2,0,FOV*2) end })
AimLockTab:CreateSlider({ Name="Red", Range={0,255}, Increment=1, CurrentValue=FOVRed, Callback=function(v) FOVRed=v; UpdateFOVCircle() end })
AimLockTab:CreateSlider({ Name="Green", Range={0,255}, Increment=1, CurrentValue=FOVGreen, Callback=function(v) FOVGreen=v; UpdateFOVCircle() end })
AimLockTab:CreateSlider({ Name="Blue", Range={0,255}, Increment=1, CurrentValue=FOVBlue, Callback=function(v) FOVBlue=v; UpdateFOVCircle() end })
AimLockTab:CreateSlider({ Name="Opacity", Range={0,1}, Increment=0.05, CurrentValue=FOVOpacity, Callback=function(v) FOVOpacity=v; UpdateFOVCircle() end })

-- Center circle
RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    Circle.Position = UDim2.new(0, vp.X/2, 0, vp.Y/2)
end)

-- Helpers
local function GetClosestPlayerInFOV()
    local closest, dist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X,pos.Y)-center).Magnitude
                if mag <= FOV and mag < dist then
                    closest, dist = plr, mag
                end
            end
        end
    end
    return closest
end

-- Input events (string-based matching)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not CamLockEnabled then return end
    local match = (input.KeyCode.Name == CamLockBindString or input.UserInputType.Name == CamLockBindString)
    if match then
        IsHoldingKey = true
        if not StickyAimLock then
            TargetPlayer = GetClosestPlayerInFOV()
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    local match = (input.KeyCode.Name == CamLockBindString or input.UserInputType.Name == CamLockBindString)
    if match then
        IsHoldingKey = false
        TargetPlayer = nil
    end
end)

-- Camera follow
RunService.RenderStepped:Connect(function()
    if not (CamLockEnabled and IsHoldingKey) then return end
    if StickyAimLock then
        TargetPlayer = GetClosestPlayerInFOV()
    end
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPlayer.Character.HumanoidRootPart.Position)
    end
end)
