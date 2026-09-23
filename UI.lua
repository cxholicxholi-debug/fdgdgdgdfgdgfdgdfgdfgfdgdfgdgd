
-- R Hub - UI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Load Logic
local Logic = loadstring(game:HttpGet("https://github.com/cxholicxholi-debug/fdgdgdgdfgdgfdgdfgdfgfdgdfgdgd/blob/main/logic.lua"))() -- replace this

local old = PlayerGui:FindFirstChild("RHub")
if old then old:Destroy() end

------------------------------------------------------------
-- COLORS
------------------------------------------------------------
local C = {
    Sidebar = Color3.fromRGB(30,32,40),
    SidebarHov = Color3.fromRGB(40,44,55),
    Selected = Color3.fromRGB(38,44,58),
    Main = Color3.fromRGB(18,20,26),
    Panel = Color3.fromRGB(28,31,40),
    Border = Color3.fromRGB(48,52,65),
    Accent = Color3.fromRGB(0,210,230),
    AccentDark = Color3.fromRGB(0,150,170),
    White = Color3.fromRGB(240,242,248),
    Text = Color3.fromRGB(225,228,235),
    Gray = Color3.fromRGB(145,150,165),
    GrayDark = Color3.fromRGB(95,100,115),
    Red = Color3.fromRGB(220,65,75)
}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function Stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Border
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function Tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local Gui = Create("ScreenGui", {
    Name = "RHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

------------------------------------------------------------
-- LOADING SCREEN (same as original)
------------------------------------------------------------
local Loading = Create("Frame", {
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.5),
    Size = UDim2.fromOffset(320,190),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    ZIndex = 50
}, Gui)
Corner(Loading,12)
Stroke(Loading,C.Border)

-- (keep all your loading code here exactly the same)

------------------------------------------------------------
-- MAIN FRAME + SIDEBAR + TABS + PAGES
------------------------------------------------------------
-- (paste the entire Main, Sidebar, Tab creator, Pages, etc. here)

-- When creating toggles/sliders, connect them to Logic:

-- Example Infinite Jump toggle:
CreateToggle(ClientPage, "Infinite Jump", "Jump continuously without touching the ground.", 2, function(value)
    Logic.InfiniteJump = value
end)

-- WalkSpeed slider:
CreateSlider(ClientPage, "Walk Speed", 16, 200, 16, 3, function(value)
    Logic.WalkSpeed = value
    local humanoid = Logic.Humanoid()
    if humanoid then humanoid.WalkSpeed = value end
end)

-- Fly toggle:
CreateToggle(ClientPage, "Fly", "WASD to move • Space up • Left Ctrl down.", 6, function(value)
    if value then Logic.StartFly() else Logic.StopFly() end
end)

-- Full Bright:
CreateToggle(GamePage, "Full Bright", "Makes the local environment much brighter.", 8, function(value)
    Logic.SetFullBright(value)
end)

-- Time buttons:
CreateGameOptionButton(GamePage, "Always Day", "Locks the local time at noon.", 2, function()
    Logic.LockTime(12)
end)

-- etc...

------------------------------------------------------------
-- RIGHT SHIFT TOGGLE
------------------------------------------------------------
local UIVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        Main.Visible = UIVisible
    end
end)

------------------------------------------------------------
-- LOADING ANIMATION (same as original)
------------------------------------------------------------
task.spawn(function()
    -- your original loading steps...
end)
