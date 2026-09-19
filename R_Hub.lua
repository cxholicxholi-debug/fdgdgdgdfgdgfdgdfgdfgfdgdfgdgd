--[[
    R HUB
    Home
    Client Options
    Game Options

    Right Shift = Toggle UI
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("RHub")
if old then
    old:Destroy()
end

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
-- SETTINGS
------------------------------------------------------------

local LoadingImageId = "110712703042870"

local WalkSpeed = 16
local JumpPower = 50
local Gravity = 196.2
local FlySpeed = 60

local InfiniteJump = false
local FlyEnabled = false

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function Create(class, props, parent)
    local obj = Instance.new(class)

    for k,v in pairs(props or {}) do
        obj[k] = v
    end

    if parent then
        obj.Parent = parent
    end

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
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )

    t:Play()
    return t
end

local function Humanoid()
    local character = Player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function Root()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
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
-- LOADING
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

local HasImage = LoadingImageId ~= ""

local LoadImage = Create("ImageLabel", {
    AnchorPoint = Vector2.new(.5,0),
    Position = UDim2.new(.5,0,0,16),
    Size = UDim2.fromOffset(48,48),
    BackgroundTransparency = 1,
    Image = LoadingImageId,
    ImageTransparency = HasImage and 0 or 1,
    ZIndex = 51
}, Loading)

Corner(LoadImage,10)

local LoadLogo = Create("TextLabel", {
    AnchorPoint = Vector2.new(.5,0),
    Position = UDim2.new(.5,0,0,16),
    Size = UDim2.fromOffset(48,48),
    BackgroundColor3 = C.Accent,
    Text = "R",
    TextColor3 = Color3.fromRGB(12,16,24),
    TextSize = 24,
    Font = Enum.Font.GothamBlack,
    Visible = not HasImage,
    ZIndex = 51
}, Loading)

Corner(LoadLogo,10)

local LoadTitle = Create("TextLabel", {
    AnchorPoint = Vector2.new(.5,0),
    Position = UDim2.new(.5,0,0,72),
    Size = UDim2.fromOffset(260,25),
    BackgroundTransparency = 1,
    Text = "R Hub",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    ZIndex = 51
}, Loading)

local LoadStatus = Create("TextLabel", {
    AnchorPoint = Vector2.new(.5,0),
    Position = UDim2.new(.5,0,0,98),
    Size = UDim2.fromOffset(260,18),
    BackgroundTransparency = 1,
    Text = "Loading...",
    TextColor3 = C.Gray,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    ZIndex = 51
}, Loading)

local BarBG = Create("Frame", {
    AnchorPoint = Vector2.new(.5,0),
    Position = UDim2.new(.5,0,0,128),
    Size = UDim2.fromOffset(250,7),
    BackgroundColor3 = Color3.fromRGB(40,44,55),
    BorderSizePixel = 0,
    ZIndex = 51
}, Loading)

Corner(BarBG,4)

local BarFill = Create("Frame", {
    Size = UDim2.fromScale(0,1),
    BackgroundColor3 = C.Accent,
    BorderSizePixel = 0,
    ZIndex = 52
}, BarBG)

Corner(BarFill,4)

local LoadPercent = Create("TextLabel", {
    AnchorPoint = Vector2.new(.5,0),
    Position = UDim2.new(.5,0,0,143),
    Size = UDim2.fromOffset(250,18),
    BackgroundTransparency = 1,
    Text = "0%",
    TextColor3 = C.Gray,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    ZIndex = 51
}, Loading)

------------------------------------------------------------
-- MAIN
------------------------------------------------------------

local Main = Create("Frame", {
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.5),
    Size = UDim2.fromOffset(780,500),
    BackgroundColor3 = C.Main,
    BorderSizePixel = 0,
    Visible = false
}, Gui)

Corner(Main,12)
Stroke(Main,C.Border)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------

local Sidebar = Create("Frame", {
    Size = UDim2.new(0,200,1,0),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0
}, Main)

Corner(Sidebar,12)

Create("Frame", {
    Position = UDim2.new(1,-14,0,0),
    Size = UDim2.new(0,14,1,0),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0
}, Sidebar)

------------------------------------------------------------
-- LOGO
------------------------------------------------------------

local Logo = Create("Frame", {
    Size = UDim2.new(1,0,0,58),
    BackgroundTransparency = 1
}, Sidebar)

local LogoBadge = Create("TextLabel", {
    Position = UDim2.fromOffset(16,13),
    Size = UDim2.fromOffset(34,34),
    BackgroundColor3 = C.Accent,
    Text = "R",
    TextColor3 = Color3.fromRGB(12,16,24),
    TextSize = 16,
    Font = Enum.Font.GothamBlack
}, Logo)

Corner(LogoBadge,8)

Create("TextLabel", {
    Position = UDim2.fromOffset(58,18),
    Size = UDim2.fromOffset(120,24),
    BackgroundTransparency = 1,
    Text = "R Hub",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Logo)

------------------------------------------------------------
-- SIDEBAR SCROLL
------------------------------------------------------------

local SideScroll = Create("ScrollingFrame", {
    Position = UDim2.fromOffset(0,58),
    Size = UDim2.new(1,0,1,-114),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.AccentDark,
    CanvasSize = UDim2.new(0,0,0,0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, Sidebar)

Create("UIListLayout", {
    Padding = UDim.new(0,4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, SideScroll)

Create("UIPadding", {
    PaddingLeft = UDim.new(0,10),
    PaddingRight = UDim.new(0,10),
    PaddingTop = UDim.new(0,4),
    PaddingBottom = UDim.new(0,8)
}, SideScroll)

------------------------------------------------------------
-- TAB CREATOR
------------------------------------------------------------

local function CreateTab(name, icon, order)

    local button = Create("TextButton", {
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = C.Sidebar,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order
    }, SideScroll)

    Corner(button,8)

    local indicator = Create("Frame", {
        Position = UDim2.fromOffset(0,8),
        Size = UDim2.fromOffset(3,20),
        BackgroundColor3 = C.Accent,
        Visible = false
    }, button)

    Corner(indicator,2)

    local iconLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(14,0),
        Size = UDim2.fromOffset(22,36),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = C.Gray,
        TextSize = 15,
        Font = Enum.Font.GothamBold
    }, button)

    local textLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(40,0),
        Size = UDim2.new(1,-48,1,0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, button)

    button.MouseEnter:Connect(function()
        if not indicator.Visible then
            Tween(button,.15,{
                BackgroundColor3 = C.SidebarHov
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if not indicator.Visible then
            Tween(button,.15,{
                BackgroundColor3 = C.Sidebar
            })
        end
    end)

    return button, indicator, iconLabel, textLabel
end

------------------------------------------------------------
-- THE THREE TABS
------------------------------------------------------------

local HomeTab, HomeIndicator, HomeIcon, HomeText =
    CreateTab("Home","⌂",1)

local ClientOptionsTab, ClientIndicator, ClientIcon, ClientText =
    CreateTab("Client Options","⚙",2)

local GameOptionsTab, GameIndicator, GameIcon, GameText =
    CreateTab("Game Options","☀",3)

------------------------------------------------------------
-- USER BAR
------------------------------------------------------------

local UserBar = Create("Frame", {
    AnchorPoint = Vector2.new(0,1),
    Position = UDim2.new(0,0,1,0),
    Size = UDim2.new(1,0,0,56),
    BackgroundColor3 = Color3.fromRGB(25,27,35)
}, Sidebar)

local Avatar = Create("TextLabel", {
    Position = UDim2.fromOffset(14,10),
    Size = UDim2.fromOffset(36,36),
    BackgroundColor3 = C.AccentDark,
    Text = string.sub(Player.DisplayName,1,1):upper(),
    TextColor3 = C.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold
}, UserBar)

Corner(Avatar,18)

Create("TextLabel", {
    Position = UDim2.fromOffset(58,11),
    Size = UDim2.new(1,-70,0,17),
    BackgroundTransparency = 1,
    Text = Player.DisplayName,
    TextColor3 = C.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, UserBar)

Create("TextLabel", {
    Position = UDim2.fromOffset(58,29),
    Size = UDim2.new(1,-70,0,15),
    BackgroundTransparency = 1,
    Text = "@"..Player.Name,
    TextColor3 = C.Gray,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, UserBar)

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------

local Content = Create("Frame", {
    Position = UDim2.fromOffset(200,0),
    Size = UDim2.new(1,-200,1,0),
    BackgroundColor3 = C.Main,
    BorderSizePixel = 0
}, Main)

local function CreatePage(name)

    local page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.AccentDark,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    Create("UIListLayout", {
        Padding = UDim.new(0,12),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Create("UIPadding", {
        PaddingLeft = UDim.new(0,16),
        PaddingRight = UDim.new(0,16),
        PaddingTop = UDim.new(0,16),
        PaddingBottom = UDim.new(0,20)
    }, page)

    return page
end

local HomePage = CreatePage("Home")
local ClientPage = CreatePage("ClientOptions")
local GamePage = CreatePage("GameOptions")

------------------------------------------------------------
-- PANEL
------------------------------------------------------------

local function CreatePanel(parent,height,order)

    local panel = Create("Frame", {
        Size = UDim2.new(1,0,0,height),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        LayoutOrder = order
    }, parent)

    Corner(panel,10)
    Stroke(panel,C.Border)

    return panel
end

------------------------------------------------------------
-- HOME
------------------------------------------------------------

local HomePanel = CreatePanel(HomePage,190,1)

Create("TextLabel", {
    Position = UDim2.fromOffset(14,14),
    Size = UDim2.new(1,-28,0,24),
    BackgroundTransparency = 1,
    Text = "Home",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, HomePanel)

Create("TextLabel", {
    Position = UDim2.fromOffset(14,45),
    Size = UDim2.new(1,-28,0,20),
    BackgroundTransparency = 1,
    Text = "Welcome to R Hub.",
    TextColor3 = C.Text,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, HomePanel)

Create("TextLabel", {
    Position = UDim2.fromOffset(14,73),
    Size = UDim2.new(1,-28,0,18),
    BackgroundTransparency = 1,
    Text = "Client and game options are available in the sidebar.",
    TextColor3 = C.Gray,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, HomePanel)

Create("TextLabel", {
    Position = UDim2.fromOffset(14,99),
    Size = UDim2.new(1,-28,0,18),
    BackgroundTransparency = 1,
    Text = "Right Shift  •  Toggle UI",
    TextColor3 = C.GrayDark,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, HomePanel)

local DestroyButton = Create("TextButton", {
    Position = UDim2.fromOffset(14,130),
    Size = UDim2.new(1,-28,0,42),
    BackgroundColor3 = C.Red,
    BorderSizePixel = 0,
    Text = "Destroy UI",
    TextColor3 = C.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, HomePanel)

Corner(DestroyButton,8)

DestroyButton.MouseEnter:Connect(function()
    Tween(DestroyButton,.15,{
        BackgroundColor3 = Color3.fromRGB(240,75,85)
    })
end)

DestroyButton.MouseLeave:Connect(function()
    Tween(DestroyButton,.15,{
        BackgroundColor3 = C.Red
    })
end)

DestroyButton.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local function CreateToggle(parent,title,desc,order,callback)

    local frame = CreatePanel(parent,66,order)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14,10),
        Size = UDim2.new(1,-90,0,20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.White,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14,32),
        Size = UDim2.new(1,-90,0,18),
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = C.Gray,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local button = Create("TextButton", {
        AnchorPoint = Vector2.new(1,.5),
        Position = UDim2.new(1,-14,.5,0),
        Size = UDim2.fromOffset(48,26),
        BackgroundColor3 = Color3.fromRGB(55,58,70),
        Text = "OFF",
        TextColor3 = C.Gray,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, frame)

    Corner(button,13)

    local enabled = false

    local function SetEnabled(value)
        enabled = value

        if enabled then
            button.BackgroundColor3 = C.Accent
            button.Text = "ON"
            button.TextColor3 = Color3.fromRGB(10,18,25)
        else
            button.BackgroundColor3 = Color3.fromRGB(55,58,70)
            button.Text = "OFF"
            button.TextColor3 = C.Gray
        end

        callback(enabled)
    end

    button.MouseButton1Click:Connect(function()
        SetEnabled(not enabled)
    end)

    return frame,SetEnabled
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

local function CreateSlider(parent,title,min,max,default,order,callback)

    local frame = CreatePanel(parent,82,order)

    local label = Create("TextLabel", {
        Position = UDim2.fromOffset(14,10),
        Size = UDim2.new(1,-28,0,20),
        BackgroundTransparency = 1,
        Text = title..": "..default,
        TextColor3 = C.White,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local track = Create("Frame", {
        Position = UDim2.new(0,14,0,48),
        Size = UDim2.new(1,-28,0,6),
        BackgroundColor3 = Color3.fromRGB(48,52,63)
    }, frame)

    Corner(track,4)

    local fill = Create("Frame", {
        Size = UDim2.fromScale((default-min)/(max-min),1),
        BackgroundColor3 = C.Accent
    }, track)

    Corner(fill,4)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.fromScale((default-min)/(max-min),.5),
        Size = UDim2.fromOffset(14,14),
        BackgroundColor3 = C.White
    }, track)

    Corner(knob,7)

    local dragging = false

    local function SetValue(x)

        local pct = math.clamp(
            (x-track.AbsolutePosition.X)/track.AbsoluteSize.X,
            0,
            1
        )

        local value = math.floor(min+(max-min)*pct+.5)

        local p = (value-min)/(max-min)

        fill.Size = UDim2.fromScale(p,1)
        knob.Position = UDim2.fromScale(p,.5)

        label.Text = title..": "..value

        callback(value)
    end

    track.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetValue(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging
        and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            SetValue(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    return frame
end

------------------------------------------------------------
-- CLIENT OPTIONS
------------------------------------------------------------

CreateToggle(
    ClientPage,
    "Infinite Jump",
    "Jump continuously without touching the ground.",
    2,
    function(value)
        InfiniteJump = value
    end
)

CreateSlider(
    ClientPage,
    "Walk Speed",
    16,
    200,
    16,
    3,
    function(value)
        WalkSpeed = value

        local humanoid = Humanoid()

        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
)

CreateSlider(
    ClientPage,
    "Jump Power",
    50,
    200,
    50,
    4,
    function(value)
        JumpPower = value

        local humanoid = Humanoid()

        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
        end
    end
)

CreateSlider(
    ClientPage,
    "Gravity",
    20,
    300,
    196,
    5,
    function(value)
        Gravity = value
        workspace.Gravity = value
    end
)

------------------------------------------------------------
-- FLY
------------------------------------------------------------

local FlyConnection
local FlyVelocity
local FlyGyro

local function StopFly()

    FlyEnabled = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    local humanoid = Humanoid()

    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function StartFly()

    StopFly()

    local root = Root()
    local humanoid = Humanoid()

    if not root or not humanoid then
        return
    end

    FlyEnabled = true
    humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyVelocity.Parent = root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyGyro.P = 9000
    FlyGyro.Parent = root

    FlyConnection = RunService.RenderStepped:Connect(function()

        if not FlyEnabled or not root.Parent then
            StopFly()
            return
        end

        local camera = workspace.CurrentCamera
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit
        end

        FlyVelocity.Velocity = direction * FlySpeed
        FlyGyro.CFrame = camera.CFrame
    end)
end

CreateToggle(
    ClientPage,
    "Fly",
    "WASD to move • Space up • Left Ctrl down.",
    6,
    function(value)
        if value then
            StartFly()
        else
            StopFly()
        end
    end
)

CreateSlider(
    ClientPage,
    "Fly Speed",
    20,
    200,
    60,
    7,
    function(value)
        FlySpeed = value
    end
)

------------------------------------------------------------
-- GAME OPTIONS
------------------------------------------------------------

local OriginalClockTime = Lighting.ClockTime
local OriginalBrightness = Lighting.Brightness
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

local TimeConnection

local function StopTimeLock()

    if TimeConnection then
        TimeConnection:Disconnect()
        TimeConnection = nil
    end
end

local function LockTime(hour)

    StopTimeLock()

    Lighting.ClockTime = hour

    TimeConnection = RunService.Heartbeat:Connect(function()

        if math.abs(Lighting.ClockTime-hour) > 0.05 then
            Lighting.ClockTime = hour
        end
    end)
end

------------------------------------------------------------
-- GAME OPTIONS HEADER
------------------------------------------------------------

local GameHeader = CreatePanel(GamePage,72,1)

Create("TextLabel", {
    Position = UDim2.fromOffset(14,12),
    Size = UDim2.new(1,-28,0,24),
    BackgroundTransparency = 1,
    Text = "Game Options",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, GameHeader)

Create("TextLabel", {
    Position = UDim2.fromOffset(14,39),
    Size = UDim2.new(1,-28,0,18),
    BackgroundTransparency = 1,
    Text = "Local lighting and environment controls.",
    TextColor3 = C.Gray,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, GameHeader)

------------------------------------------------------------
-- GAME OPTION BUTTON
------------------------------------------------------------

local function CreateGameOptionButton(parent,title,description,order,callback)

    local frame = CreatePanel(parent,66,order)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14,10),
        Size = UDim2.new(1,-150,0,20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.White,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14,32),
        Size = UDim2.new(1,-150,0,18),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = C.Gray,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local button = Create("TextButton", {
        AnchorPoint = Vector2.new(1,.5),
        Position = UDim2.new(1,-14,.5,0),
        Size = UDim2.fromOffset(110,32),
        BackgroundColor3 = C.Selected,
        BorderSizePixel = 0,
        Text = title,
        TextColor3 = C.White,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, frame)

    Corner(button,8)

    button.MouseEnter:Connect(function()
        Tween(button,.15,{
            BackgroundColor3 = C.SidebarHov
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button,.15,{
            BackgroundColor3 = C.Selected
        })
    end)

    button.MouseButton1Click:Connect(callback)

    return frame
end

------------------------------------------------------------
-- TIME OPTIONS
------------------------------------------------------------

CreateGameOptionButton(
    GamePage,
    "Always Day",
    "Locks the local time at noon.",
    2,
    function()
        LockTime(12)
    end
)

CreateGameOptionButton(
    GamePage,
    "Always Night",
    "Locks the local time at night.",
    3,
    function()
        LockTime(21)
    end
)

CreateGameOptionButton(
    GamePage,
    "Sunrise",
    "Sets the local time to sunrise.",
    4,
    function()
        LockTime(6)
    end
)

CreateGameOptionButton(
    GamePage,
    "Sunset",
    "Locks the local time at sunset.",
    5,
    function()
        LockTime(18)
    end
)

CreateGameOptionButton(
    GamePage,
    "Midnight",
    "Locks the local time at midnight.",
    6,
    function()
        LockTime(0)
    end
)

CreateGameOptionButton(
    GamePage,
    "Normal Time",
    "Lets the game control the time normally.",
    7,
    function()
        StopTimeLock()
    end
)

------------------------------------------------------------
-- FULL BRIGHT
------------------------------------------------------------

local FullBrightEnabled = false

CreateToggle(
    GamePage,
    "Full Bright",
    "Makes the local environment much brighter.",
    8,
    function(value)

        FullBrightEnabled = value

        if value then

            Lighting.Brightness = 3
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)

        else

            Lighting.Brightness = OriginalBrightness
            Lighting.Ambient = OriginalAmbient
            Lighting.OutdoorAmbient = OriginalOutdoorAmbient
        end
    end
)

------------------------------------------------------------
-- CUSTOM TIME
------------------------------------------------------------

CreateSlider(
    GamePage,
    "Time Of Day",
    0,
    24,
    math.floor(Lighting.ClockTime),
    9,
    function(value)

        StopTimeLock()
        Lighting.ClockTime = value
    end
)

------------------------------------------------------------
-- RESET LIGHTING
------------------------------------------------------------

local ResetLighting = Create("TextButton", {
    Size = UDim2.new(1,0,0,44),
    BackgroundColor3 = C.Selected,
    BorderSizePixel = 0,
    Text = "Reset Lighting",
    TextColor3 = C.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    LayoutOrder = 10
}, GamePage)

Corner(ResetLighting,10)
Stroke(ResetLighting,C.Border)

ResetLighting.MouseEnter:Connect(function()
    Tween(ResetLighting,.15,{
        BackgroundColor3 = C.SidebarHov
    })
end)

ResetLighting.MouseLeave:Connect(function()
    Tween(ResetLighting,.15,{
        BackgroundColor3 = C.Selected
    })
end)

ResetLighting.MouseButton1Click:Connect(function()

    StopTimeLock()

    Lighting.ClockTime = OriginalClockTime
    Lighting.Brightness = OriginalBrightness
    Lighting.Ambient = OriginalAmbient
    Lighting.OutdoorAmbient = OriginalOutdoorAmbient

end)

------------------------------------------------------------
-- TAB SWITCHING
------------------------------------------------------------

local function SelectTab(tabName)

    HomePage.Visible = tabName == "Home"
    ClientPage.Visible = tabName == "Client"
    GamePage.Visible = tabName == "Game"

    local tabs = {
        {
            HomeTab,
            HomeIndicator,
            HomeIcon,
            HomeText,
            tabName == "Home"
        },

        {
            ClientOptionsTab,
            ClientIndicator,
            ClientIcon,
            ClientText,
            tabName == "Client"
        },

        {
            GameOptionsTab,
            GameIndicator,
            GameIcon,
            GameText,
            tabName == "Game"
        }
    }

    for _,data in ipairs(tabs) do

        local button = data[1]
        local indicator = data[2]
        local icon = data[3]
        local textLabel = data[4]
        local selected = data[5]

        indicator.Visible = selected

        button.BackgroundColor3 =
            selected and C.Selected or C.Sidebar

        icon.TextColor3 =
            selected and C.Accent or C.Gray

        textLabel.TextColor3 =
            selected and C.White or C.Text
    end
end

------------------------------------------------------------
-- TAB CLICKS
------------------------------------------------------------

HomeTab.MouseButton1Click:Connect(function()
    SelectTab("Home")
end)

ClientOptionsTab.MouseButton1Click:Connect(function()
    SelectTab("Client")
end)

GameOptionsTab.MouseButton1Click:Connect(function()
    SelectTab("Game")
end)

SelectTab("Home")

------------------------------------------------------------
-- INFINITE JUMP
------------------------------------------------------------

UserInputService.JumpRequest:Connect(function()

    if InfiniteJump then

        local humanoid = Humanoid()

        if humanoid then
            humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
end)

------------------------------------------------------------
-- CHARACTER RESPAWN
------------------------------------------------------------

Player.CharacterAdded:Connect(function()

    task.wait(.5)

    local humanoid = Humanoid()

    if humanoid then

        humanoid.WalkSpeed = WalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = JumpPower
    end

    if FlyEnabled then
        task.wait(.2)
        StartFly()
    end
end)

------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

local DragZone = Create("Frame", {
    Position = UDim2.fromOffset(0,0),
    Size = UDim2.new(1,0,0,50),
    BackgroundTransparency = 1,
    Active = true,
    ZIndex = 10
}, Main)

DragZone.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not Dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + delta.Y
    )
end)

------------------------------------------------------------
-- RIGHT SHIFT
------------------------------------------------------------

local UIVisible = true

UserInputService.InputBegan:Connect(function(input,processed)

    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then

        UIVisible = not UIVisible
        Main.Visible = UIVisible
    end
end)

------------------------------------------------------------
-- LOADING
------------------------------------------------------------

task.spawn(function()

    local steps = {
        {0.15,"Initializing..."},
        {0.35,"Loading interface..."},
        {0.55,"Loading client options..."},
        {0.75,"Loading game options..."},
        {1,"Complete!"}
    }

    for _,step in ipairs(steps) do

        LoadStatus.Text = step[2]
        LoadPercent.Text = math.floor(step[1]*100).."%"

        Tween(BarFill,.4,{
            Size = UDim2.fromScale(step[1],1)
        })

        task.wait(.45)
    end

    task.wait(.3)

    Tween(Loading,.4,{
        BackgroundTransparency = 1
    })

    Tween(LoadLogo,.3,{
        BackgroundTransparency = 1,
        TextTransparency = 1
    })

    Tween(LoadImage,.3,{
        ImageTransparency = 1
    })

    Tween(LoadTitle,.3,{
        TextTransparency = 1
    })

    Tween(LoadStatus,.3,{
        TextTransparency = 1
    })

    Tween(LoadPercent,.3,{
        TextTransparency = 1
    })

    Tween(BarBG,.3,{
        BackgroundTransparency = 1
    })

    Tween(BarFill,.3,{
        BackgroundTransparency = 1
    })

    task.wait(.4)

    Loading:Destroy()

    Main.Visible = true

    Main.Size = UDim2.fromOffset(740,470)

    Tween(Main,.4,{
        Size = UDim2.fromOffset(780,500),
        Position = UDim2.fromScale(.5,.5)
    })
end)
