-- R Hub - Logic
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer

local Logic = {}

-- Settings
Logic.WalkSpeed = 16
Logic.JumpPower = 50
Logic.Gravity = 196.2
Logic.FlySpeed = 60
Logic.InfiniteJump = false
Logic.FlyEnabled = false
Logic.FullBrightEnabled = false

-- Helpers
function Logic.Humanoid()
    local character = Player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Logic.Root()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Logic.InfiniteJump then
        local humanoid = Logic.Humanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character respawn
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    local humanoid = Logic.Humanoid()
    if humanoid then
        humanoid.WalkSpeed = Logic.WalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Logic.JumpPower
    end
    if Logic.FlyEnabled then
        task.wait(0.2)
        Logic.StartFly()
    end
end)

-- Fly
local FlyConnection, FlyVelocity, FlyGyro

function Logic.StopFly()
    Logic.FlyEnabled = false
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
    if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
    local humanoid = Logic.Humanoid()
    if humanoid then humanoid.PlatformStand = false end
end

function Logic.StartFly()
    Logic.StopFly()
    local root = Logic.Root()
    local humanoid = Logic.Humanoid()
    if not root or not humanoid then return end

    Logic.FlyEnabled = true
    humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyVelocity.Parent = root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyGyro.P = 9000
    FlyGyro.Parent = root

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Logic.FlyEnabled or not root.Parent then
            Logic.StopFly()
            return
        end
        local camera = workspace.CurrentCamera
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end

        if direction.Magnitude > 0 then direction = direction.Unit end
        FlyVelocity.Velocity = direction * Logic.FlySpeed
        FlyGyro.CFrame = camera.CFrame
    end)
end

-- Lighting
local OriginalClockTime = Lighting.ClockTime
local OriginalBrightness = Lighting.Brightness
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient
local TimeConnection

function Logic.StopTimeLock()
    if TimeConnection then
        TimeConnection:Disconnect()
        TimeConnection = nil
    end
end

function Logic.LockTime(hour)
    Logic.StopTimeLock()
    Lighting.ClockTime = hour
    TimeConnection = RunService.Heartbeat:Connect(function()
        if math.abs(Lighting.ClockTime - hour) > 0.05 then
            Lighting.ClockTime = hour
        end
    end)
end

function Logic.SetFullBright(value)
    Logic.FullBrightEnabled = value
    if value then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = OriginalBrightness
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
    end
end

function Logic.ResetLighting()
    Logic.StopTimeLock()
    Lighting.ClockTime = OriginalClockTime
    Lighting.Brightness = OriginalBrightness
    Lighting.Ambient = OriginalAmbient
    Lighting.OutdoorAmbient = OriginalOutdoorAmbient
end

return Logic
