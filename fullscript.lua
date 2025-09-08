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

--// Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Walkspeed Slider
local WalkspeedValue = 50
MainTab:CreateSlider({
    Name = "Walkspeed",
    Range = {0, 120},
    Increment = 2,
    Suffix = "studs/s",
    CurrentValue = WalkspeedValue,
    Callback = function(value) WalkspeedValue = value end
})

-- Jump Power
MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50,300},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Callback = function(value)
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then Hum.JumpPower = value end
    end
})

-- Simple Fly
local FlyEnabled = false
local FlySpeed = 50
MainTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = function(val) FlyEnabled = val end
})

-- CFrame Walkspeed movement
RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    local Hum = char:FindFirstChildOfClass("Humanoid")
    if not (HRP and Hum) or Hum.Sit or Hum.Health <= 0 then return end

    local camCF = Camera.CFrame
    local fwd = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    if fwd.Magnitude > 0 then fwd = fwd.Unit end
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
    if right.Magnitude > 0 then right = right.Unit end

    local move = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - right end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + right end

    if move.Magnitude > 0 then
        HRP.CFrame = HRP.CFrame + Vector3.new(move.Unit.X,0,move.Unit.Z)*(WalkspeedValue*dt)
    end

    if FlyEnabled then
        local flyMove = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then flyMove = flyMove + camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then flyMove = flyMove - camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then flyMove = flyMove - camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then flyMove = flyMove + camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then flyMove = flyMove + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then flyMove = flyMove - Vector3.new(0,1,0) end

        if flyMove.Magnitude > 0 then
            HRP.Velocity = flyMove.Unit*FlySpeed
        else
            HRP.Velocity = Vector3.new(0,0,0)
        end
    end
end)

--// Aim Lock Tab
local AimLockTab = Window:CreateTab("Aim Lock",6031280882)
local CamLockEnabled = false
local TargetPlayer = nil
local HoldingBind = false
local FOV = 100
local StickyAim = false
local CircleColor = Color3.fromRGB(255,0,0)
local CircleOpacity = 0.5

AimLockTab:CreateToggle({
    Name="Aim Lock (RMB)",
    CurrentValue=false,
    Callback=function(val) CamLockEnabled=val end
})

AimLockTab:CreateToggle({
    Name="Sticky Aim",
    CurrentValue=false,
    Callback=function(val) StickyAim=val end
})

local FOVCircle = Instance.new("ScreenGui")
FOVCircle.Name="AimLockFOV"
FOVCircle.ResetOnSpawn=false
FOVCircle.Parent=game:GetService("CoreGui")

local Circle = Instance.new("Frame")
Circle.Size=UDim2.new(0,FOV*2,0,FOV*2)
Circle.AnchorPoint=Vector2.new(0.5,0.5)
Circle.Position=UDim2.new(0.5,0,0.5,0)
Circle.BackgroundTransparency=1
Circle.BorderSizePixel=0
Circle.BackgroundColor3=CircleColor
Circle.Parent=FOVCircle

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius=UDim.new(1,0)
UICorner.Parent=Circle

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness=2
UIStroke.Color=CircleColor
UIStroke.Transparency=CircleOpacity
UIStroke.Parent=Circle

AimLockTab:CreateSlider({Name="FOV Radius",Range={50,500},Increment=5,Suffix="px",CurrentValue=FOV,Callback=function(value)FOV=value;Circle.Size=UDim2.new(0,FOV*2,0,FOV*2)end})
AimLockTab:CreateSlider({Name="FOV Opacity",Range={0,1},Increment=0.05,CurrentValue=CircleOpacity,Callback=function(val)CircleOpacity=val;UIStroke.Transparency=CircleOpacity end})
AimLockTab:CreateSlider({Name="FOV R",Range={0,255},Increment=1,CurrentValue=CircleColor.R*255,Callback=function(val)CircleColor=Color3.fromRGB(val,CircleColor.G*255,CircleColor.B*255);UIStroke.Color=CircleColor end})
AimLockTab:CreateSlider({Name="FOV G",Range={0,255},Increment=1,CurrentValue=CircleColor.G*255,Callback=function(val)CircleColor=Color3.fromRGB(CircleColor.R*255,val,CircleColor.B*255);UIStroke.Color=CircleColor end})
AimLockTab:CreateSlider({Name="FOV B",Range={0,255},Increment=1,CurrentValue=CircleColor.B*255,Callback=function(val)CircleColor=Color3.fromRGB(CircleColor.R*255,CircleColor.G*255,val);UIStroke.Color=CircleColor end})

local function GetClosestPlayerInFOV()
    local closest,distance=nil,math.huge
    local mousePos=UIS:GetMouseLocation()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos,onScreen=Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag=(Vector2.new(pos.X,pos.Y)-mousePos).Magnitude
                if mag<=FOV and mag<distance then closest=plr; distance=mag end
            end
        end
    end
    return closest
end

UIS.InputBegan:Connect(function(input,gpe)
    if gpe or not CamLockEnabled then return end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then
        HoldingBind=true
        TargetPlayer=GetClosestPlayerInFOV()
    end
end)

UIS.InputEnded:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then
        HoldingBind=false
        TargetPlayer=nil
    end
end)

RunService.RenderStepped:Connect(function()
    if CamLockEnabled and HoldingBind and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame=CFrame.new(Camera.CFrame.Position, TargetPlayer.Character.HumanoidRootPart.Position)
    elseif CamLockEnabled and StickyAim and HoldingBind then
        if not TargetPlayer then TargetPlayer=GetClosestPlayerInFOV() end
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame=CFrame.new(Camera.CFrame.Position, TargetPlayer.Character.HumanoidRootPart.Position)
        end
    end
end)

--// ESP Tab
local ESPTab = Window:CreateTab("ESP", 6031280882)

local ESPEnabled = false
local NameESPEnabled = false
local ESPTransparency = 0.5
local MaxDistance = 1000

ESPTab:CreateToggle({Name="Enable Skeleton ESP",CurrentValue=false,Callback=function(val) ESPEnabled=val end})
ESPTab:CreateToggle({Name="Enable Name ESP",CurrentValue=false,Callback=function(val) NameESPEnabled=val end})
ESPTab:CreateButton({Name="Clear ESP", Callback=function()
    for _,obj in pairs(Drawing:GetObjects()) do obj:Remove() end
end})

-- storage
local Drawings = {}

local function ClearPlayerESP(plr)
    if Drawings[plr] then
        for _,d in pairs(Drawings[plr]) do d:Remove() end
        Drawings[plr]=nil
    end
end

local function SetupPlayerESP(plr)
    ClearPlayerESP(plr)
    Drawings[plr]={}
    if Drawing then
        local nameDraw = Drawing.new("Text")
        nameDraw.Size=16
        nameDraw.Center=true
        nameDraw.Outline=true
        nameDraw.Color=Color3.new(1,1,1)
        nameDraw.Visible=false
        table.insert(Drawings[plr],nameDraw)
        local skeletonLines={}
        for i=1,15 do
            local line=Drawing.new("Line")
            line.Thickness=1.5
            line.Color=Color3.new(0,1,0)
            line.Visible=false
            table.insert(skeletonLines,line)
            table.insert(Drawings[plr],line)
        end
        Drawings[plr].Name=nameDraw
        Drawings[plr].Skeleton=skeletonLines
    end
end

for _,plr in pairs(Players:GetPlayers()) do if plr~=LocalPlayer then SetupPlayerESP(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr~=LocalPlayer then SetupPlayerESP(plr) end end)
Players.PlayerRemoving:Connect(function(plr) ClearPlayerESP(plr) end)

-- skeleton rig map (R15 minimal)
local rigMap={
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

-- light update (positions every frame)
RunService.RenderStepped:Connect(function()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and Drawings[plr] then
            local char=plr.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if char and hrp then
                local pos,onScreen=Camera:WorldToViewportPoint(hrp.Position)
                local dist=(hrp.Position-Camera.CFrame.Position).Magnitude
                if onScreen and dist<MaxDistance then
                    if NameESPEnabled then
                        local text=Drawings[plr].Name
                        text.Text=string.format("%s [%d]",plr.Name,math.floor(dist))
                        text.Position=Vector2.new(pos.X,pos.Y-50)
                        text.Size=math.clamp(18-(dist/100),12,18)
                        text.Visible=true
                    else
                        Drawings[plr].Name.Visible=false
                    end
                    if ESPEnabled then
                        local lines=Drawings[plr].Skeleton
                        for i,pair in ipairs(rigMap) do
                            local p1=char:FindFirstChild(pair[1])
                            local p2=char:FindFirstChild(pair[2])
                            if p1 and p2 then
                                local v1,on1=Camera:WorldToViewportPoint(p1.Position)
                                local v2,on2=Camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then
                                    lines[i].From=Vector2.new(v1.X,v1.Y)
                                    lines[i].To=Vector2.new(v2.X,v2.Y)
                                    lines[i].Visible=true
                                else
                                    lines[i].Visible=false
                                end
                            else
                                lines[i].Visible=false
                            end
                        end
                    else
                        for _,l in pairs(Drawings[plr].Skeleton) do l.Visible=false end
                    end
                else
                    Drawings[plr].Name.Visible=false
                    for _,l in pairs(Drawings[plr].Skeleton) do l.Visible=false end
                end
            else
                Drawings[plr].Name.Visible=false
                for _,l in pairs(Drawings[plr].Skeleton) do l.Visible=false end
            end
        end
    end
end)
