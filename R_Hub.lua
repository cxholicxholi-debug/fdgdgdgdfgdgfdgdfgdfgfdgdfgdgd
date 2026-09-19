--[[
    R Hub
    Home + Client Options

    Right Shift = Toggle UI

    Client Options:
    - Fly
    - Infinite Jump
    - Walk Speed
    - Jump Power
    - Gravity
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------

local old = PlayerGui:FindFirstChild("RHub")

if old then
    old:Destroy()
end

------------------------------------------------------------
-- COLORS
------------------------------------------------------------

local C = {
    Bg          = Color3.fromRGB(22, 24, 30),
    Sidebar     = Color3.fromRGB(30, 32, 40),
    SidebarHov  = Color3.fromRGB(40, 44, 55),
    Selected    = Color3.fromRGB(38, 44, 58),
    Main        = Color3.fromRGB(18, 20, 26),
    Panel       = Color3.fromRGB(28, 31, 40),
    Border      = Color3.fromRGB(48, 52, 65),

    Accent      = Color3.fromRGB(0, 210, 230),
    AccentDark  = Color3.fromRGB(0, 150, 170),

    White       = Color3.fromRGB(240, 242, 248),
    Text        = Color3.fromRGB(225, 228, 235),
    Gray        = Color3.fromRGB(145, 150, 165),
    GrayDark    = Color3.fromRGB(95, 100, 115),

    Red         = Color3.fromRGB(220, 65, 75),
    Green       = Color3.fromRGB(65, 200, 110),
}

------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------

local LoadingImageId = "110712703042870"

------------------------------------------------------------
-- CLIENT SETTINGS
------------------------------------------------------------

local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local DefaultGravity = 196.2

local WalkSpeed = DefaultWalkSpeed
local JumpPower = DefaultJumpPower
local Gravity = DefaultGravity

local FlyEnabled = false
local InfiniteJump = false

local FlySpeed = 60

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function Create(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
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
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        props
    )

    tween:Play()
    return tween
end

local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local Character = GetCharacter()
    return Character:FindFirstChildOfClass("Humanoid")
end

------------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------------

local Gui = Create("ScreenGui", {
    Name = "RHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

------------------------------------------------------------
-- LOADING SCREEN
------------------------------------------------------------

local Loading = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(320, 190),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    ZIndex = 50
}, Gui)

Corner(Loading, 12)
Stroke(Loading, C.Border, 1)

local HasLoadingImage = LoadingImageId ~= ""

local LoadImage = Create("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 16),
    Size = UDim2.fromOffset(48, 48),
    BackgroundTransparency = 1,
    Image = LoadingImageId,
    ImageTransparency = HasLoadingImage and 0 or 1,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 51
}, Loading)

Corner(LoadImage, 10)

local LoadLogo = Create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 16),
    Size = UDim2.fromOffset(48, 48),
    BackgroundColor3 = C.Accent,
    Text = "R",
    TextColor3 = Color3.fromRGB(12, 16, 24),
    TextSize = 24,
    Font = Enum.Font.GothamBlack,
    Visible = not HasLoadingImage,
    ZIndex = 51
}, Loading)

Corner(LoadLogo, 10)

local LoadTitle = Create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 72),
    Size = UDim2.fromOffset(260, 25),
    BackgroundTransparency = 1,
    Text = "R Hub",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    ZIndex = 51
}, Loading)

local LoadStatus = Create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 98),
    Size = UDim2.fromOffset(260, 18),
    BackgroundTransparency = 1,
    Text = "Loading...",
    TextColor3 = C.Gray,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    ZIndex = 51
}, Loading)

local BarBG = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 128),
    Size = UDim2.fromOffset(250, 7),
    BackgroundColor3 = Color3.fromRGB(40, 44, 55),
    BorderSizePixel = 0,
    ZIndex = 51
}, Loading)

Corner(BarBG, 4)

local BarFill = Create("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = C.Accent,
    BorderSizePixel = 0,
    ZIndex = 52
}, BarBG)

Corner(BarFill, 4)

local LoadPercent = Create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 143),
    Size = UDim2.fromOffset(250, 18),
    BackgroundTransparency = 1,
    Text = "0%",
    TextColor3 = C.Gray,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    ZIndex = 51
}, Loading)

------------------------------------------------------------
-- MAIN UI
------------------------------------------------------------

local Main = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(780, 500),
    BackgroundColor3 = C.Main,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 1
}, Gui)

Corner(Main, 12)
Stroke(Main, C.Border, 1)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------

local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 200, 1, 0),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 2
}, Main)

Corner(Sidebar, 12)

Create("Frame", {
    Position = UDim2.new(1, -14, 0, 0),
    Size = UDim2.new(0, 14, 1, 0),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 2
}, Sidebar)

------------------------------------------------------------
-- SIDEBAR LOGO
------------------------------------------------------------

local Logo = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1,
    ZIndex = 3
}, Sidebar)

local LogoBadge = Create("TextLabel", {
    Position = UDim2.fromOffset(16, 13),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = C.Accent,
    Text = "R",
    TextColor3 = Color3.fromRGB(12, 16, 24),
    TextSize = 16,
    Font = Enum.Font.GothamBlack,
    ZIndex = 4
}, Logo)

Corner(LogoBadge, 8)

Create("TextLabel", {
    Position = UDim2.fromOffset(58, 18),
    Size = UDim2.fromOffset(120, 24),
    BackgroundTransparency = 1,
    Text = "R Hub",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, Logo)

------------------------------------------------------------
-- SIDEBAR SCROLL
------------------------------------------------------------

local SideScroll = Create("ScrollingFrame", {
    Position = UDim2.fromOffset(0, 58),
    Size = UDim2.new(1, 0, 1, -114),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.AccentDark,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 3
}, Sidebar)

Create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, SideScroll)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 8)
}, SideScroll)

------------------------------------------------------------
-- SIDEBAR BUTTON FUNCTION
------------------------------------------------------------

local function CreateTabButton(text, icon, order)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.Sidebar,
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        ZIndex = 4
    }, SideScroll)

    Corner(Button, 8)

    local Indicator = Create("Frame", {
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromOffset(3, 20),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5
    }, Button)

    Corner(Indicator, 2)

    local Icon = Create("TextLabel", {
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.fromOffset(22, 36),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = C.Gray,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        ZIndex = 5
    }, Button)

    local Text = Create("TextLabel", {
        Position = UDim2.fromOffset(40, 0),
        Size = UDim2.new(1, -48, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = C.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    }, Button)

    Button.MouseEnter:Connect(function()
        if not Indicator.Visible then
            Tween(Button, 0.12, {
                BackgroundColor3 = C.SidebarHov
            })
        end
    end)

    Button.MouseLeave:Connect(function()
        if not Indicator.Visible then
            Tween(Button, 0.12, {
                BackgroundColor3 = C.Sidebar
            })
        end
    end)

    return Button, Indicator, Icon, Text
end

------------------------------------------------------------
-- TABS
------------------------------------------------------------

local HomeButton, HomeIndicator, HomeIcon, HomeText =
    CreateTabButton("Home", "⌂", 1)

local ClientButton, ClientIndicator, ClientIcon, ClientText =
    CreateTabButton("Client Options", "⚙", 2)

------------------------------------------------------------
-- USER FOOTER
------------------------------------------------------------

local UserBar = Create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = Color3.fromRGB(25, 27, 35),
    BorderSizePixel = 0,
    ZIndex = 3
}, Sidebar)

local Avatar = Create("TextLabel", {
    Position = UDim2.fromOffset(14, 10),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = C.AccentDark,
    Text = string.sub(Player.DisplayName, 1, 1):upper(),
    TextColor3 = C.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    ZIndex = 4
}, UserBar)

Corner(Avatar, 18)

Create("TextLabel", {
    Position = UDim2.fromOffset(58, 11),
    Size = UDim2.new(1, -70, 0, 17),
    BackgroundTransparency = 1,
    Text = Player.DisplayName,
    TextColor3 = C.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 4
}, UserBar)

Create("TextLabel", {
    Position = UDim2.fromOffset(58, 29),
    Size = UDim2.new(1, -70, 0, 15),
    BackgroundTransparency = 1,
    Text = "@" .. Player.Name,
    TextColor3 = C.Gray,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, UserBar)

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------

local Content = Create("Frame", {
    Position = UDim2.fromOffset(200, 0),
    Size = UDim2.new(1, -200, 1, 0),
    BackgroundColor3 = C.Main,
    BorderSizePixel = 0,
    ZIndex = 2
}, Main)

------------------------------------------------------------
-- HOME PAGE
------------------------------------------------------------

local Home = Create("ScrollingFrame", {
    Name = "Home",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = C.AccentDark,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = true,
    ZIndex = 3
}, Content)

Create("UIListLayout", {
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Home)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 16),
    PaddingRight = UDim.new(0, 16),
    PaddingTop = UDim.new(0, 16),
    PaddingBottom = UDim.new(0, 20)
}, Home)

------------------------------------------------------------
-- HOME PANEL
------------------------------------------------------------

local HomePanel = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 190),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    LayoutOrder = 1,
    ZIndex = 4
}, Home)

Corner(HomePanel, 10)
Stroke(HomePanel, C.Border, 1)

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.new(1, -28, 0, 24),
    BackgroundTransparency = 1,
    Text = "Home",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, HomePanel)

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 45),
    Size = UDim2.new(1, -28, 0, 20),
    BackgroundTransparency = 1,
    Text = "Welcome to R Hub.",
    TextColor3 = C.Text,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, HomePanel)

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 73),
    Size = UDim2.new(1, -28, 0, 18),
    BackgroundTransparency = 1,
    Text = "Client options are available in the sidebar.",
    TextColor3 = C.Gray,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, HomePanel)

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 99),
    Size = UDim2.new(1, -28, 0, 18),
    BackgroundTransparency = 1,
    Text = "Right Shift  •  Toggle UI",
    TextColor3 = C.GrayDark,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, HomePanel)

------------------------------------------------------------
-- DESTROY UI BUTTON
------------------------------------------------------------

local DestroyButton = Create("TextButton", {
    Position = UDim2.fromOffset(14, 130),
    Size = UDim2.new(1, -28, 0, 42),
    BackgroundColor3 = C.Red,
    BorderSizePixel = 0,
    Text = "Destroy UI",
    TextColor3 = C.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 6
}, HomePanel)

Corner(DestroyButton, 8)

DestroyButton.MouseEnter:Connect(function()
    Tween(DestroyButton, 0.12, {
        BackgroundColor3 = Color3.fromRGB(240, 75, 85)
    })
end)

DestroyButton.MouseLeave:Connect(function()
    Tween(DestroyButton, 0.12, {
        BackgroundColor3 = C.Red
    })
end)

DestroyButton.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

------------------------------------------------------------
-- CLIENT OPTIONS PAGE
------------------------------------------------------------

local ClientPage = Create("ScrollingFrame", {
    Name = "ClientOptions",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = C.AccentDark,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
    ZIndex = 3
}, Content)

Create("UIListLayout", {
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder
}, ClientPage)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 16),
    PaddingRight = UDim.new(0, 16),
    PaddingTop = UDim.new(0, 16),
    PaddingBottom = UDim.new(0, 20)
}, ClientPage)

------------------------------------------------------------
-- CLIENT OPTIONS HEADER
------------------------------------------------------------

local ClientHeader = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    LayoutOrder = 1,
    ZIndex = 4
}, ClientPage)

Corner(ClientHeader, 10)
Stroke(ClientHeader, C.Border, 1)

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 12),
    Size = UDim2.new(1, -28, 0, 24),
    BackgroundTransparency = 1,
    Text = "Client Options",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, ClientHeader)

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 39),
    Size = UDim2.new(1, -28, 0, 18),
    BackgroundTransparency = 1,
    Text = "Local movement and character settings.",
    TextColor3 = C.Gray,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, ClientHeader)

------------------------------------------------------------
-- TOGGLE CREATOR
------------------------------------------------------------

local function CreateToggle(parent, title, description, order, callback)
    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 4
    }, parent)

    Corner(Frame, 10)
    Stroke(Frame, C.Border, 1)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -90, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.White,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    }, Frame)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14, 32),
        Size = UDim2.new(1, -90, 0, 18),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = C.Gray,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    }, Frame)

    local Button = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(48, 26),
        BackgroundColor3 = Color3.fromRGB(55, 58, 70),
        BorderSizePixel = 0,
        Text = "OFF",
        TextColor3 = C.Gray,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 5
    }, Frame)

    Corner(Button, 13)

    local Enabled = false

    local function Update()
        if Enabled then
            Tween(Button, 0.15, {
                BackgroundColor3 = C.Accent
            })

            Button.Text = "ON"
            Button.TextColor3 = Color3.fromRGB(10, 18, 25)
        else
            Tween(Button, 0.15, {
                BackgroundColor3 = Color3.fromRGB(55, 58, 70)
            })

            Button.Text = "OFF"
            Button.TextColor3 = C.Gray
        end

        callback(Enabled)
    end

    Button.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Update()
    end)

    return Frame, function(value)
        Enabled = value
        Update()
    end
end

------------------------------------------------------------
-- SLIDER CREATOR
------------------------------------------------------------

local function CreateSlider(parent, title, minimum, maximum, default, order, callback)
    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 82),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 4
    }, parent)

    Corner(Frame, 10)
    Stroke(Frame, C.Border, 1)

    local ValueLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text = title .. ": " .. tostring(default),
        TextColor3 = C.White,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    }, Frame)

    local Track = Create("Frame", {
        Position = UDim2.new(0, 14, 0, 48),
        Size = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = Color3.fromRGB(48, 52, 63),
        BorderSizePixel = 0,
        ZIndex = 5
    }, Frame)

    Corner(Track, 4)

    local Fill = Create("Frame", {
        Size = UDim2.fromScale(
            (default - minimum) / (maximum - minimum),
            1
        ),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    }, Track)

    Corner(Fill, 4)

    local Knob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(
            (default - minimum) / (maximum - minimum),
            0.5
        ),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
        ZIndex = 7
    }, Track)

    Corner(Knob, 7)

    local DraggingSlider = false

    local function SetValueFromX(x)
        local Relative = math.clamp(
            (x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X,
            0,
            1
        )

        local Value = minimum + ((maximum - minimum) * Relative)

        Value = math.floor(Value + 0.5)

        local Percent = (Value - minimum) / (maximum - minimum)

        Fill.Size = UDim2.fromScale(Percent, 1)
        Knob.Position = UDim2.fromScale(Percent, 0.5)

        ValueLabel.Text = title .. ": " .. tostring(Value)

        callback(Value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            DraggingSlider = true
            SetValueFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not DraggingSlider then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            SetValueFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            DraggingSlider = false
        end
    end)

    return Frame
end

------------------------------------------------------------
-- FLY SYSTEM
------------------------------------------------------------

local FlyConnection = nil
local FlyVelocity = nil
local FlyGyro = nil

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

    local Humanoid = GetHumanoid()

    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

local function StartFly()
    StopFly()

    FlyEnabled = true

    local Character = GetCharacter()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Root or not Humanoid then
        FlyEnabled = false
        return
    end

    Humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    FlyGyro.P = 9000
    FlyGyro.D = 500
    FlyGyro.CFrame = workspace.CurrentCamera.CFrame
    FlyGyro.Parent = Root

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then
            return
        end

        if not Root.Parent then
            StopFly()
            return
        end

        local Camera = workspace.CurrentCamera

        local MoveDirection = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveDirection += Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveDirection -= Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveDirection += Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveDirection -= Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveDirection += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            MoveDirection -= Vector3.new(0, 1, 0)
        end

        if MoveDirection.Magnitude > 0 then
            MoveDirection = MoveDirection.Unit
        end

        FlyVelocity.Velocity = MoveDirection * FlySpeed
        FlyGyro.CFrame = Camera.CFrame
    end)
end

------------------------------------------------------------
-- INFINITE JUMP
------------------------------------------------------------

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJump then
        return
    end

    local Humanoid = GetHumanoid()

    if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

------------------------------------------------------------
-- CLIENT OPTION CONTROLS
------------------------------------------------------------

CreateToggle(
    ClientPage,
    "Fly",
    "Fly using WASD, Space and Left Ctrl.",
    2,
    function(enabled)

        if enabled then
            StartFly()
        else
            StopFly()
        end

    end
)

CreateToggle(
    ClientPage,
    "Infinite Jump",
    "Jump continuously without touching the ground.",
    3,
    function(enabled)

        InfiniteJump = enabled

    end
)

CreateSlider(
    ClientPage,
    "Walk Speed",
    16,
    200,
    DefaultWalkSpeed,
    4,
    function(value)

        WalkSpeed = value

        local Humanoid = GetHumanoid()

        if Humanoid then
            Humanoid.WalkSpeed = value
        end

    end
)

CreateSlider(
    ClientPage,
    "Jump Power",
    50,
    200,
    DefaultJumpPower,
    5,
    function(value)

        JumpPower = value

        local Humanoid = GetHumanoid()

        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = value
        end

    end
)

CreateSlider(
    ClientPage,
    "Gravity",
    20,
    300,
    DefaultGravity,
    6,
    function(value)

        Gravity = value
        workspace.Gravity = value

    end
)

CreateSlider(
    ClientPage,
    "Fly Speed",
    20,
    200,
    FlySpeed,
    7,
    function(value)

        FlySpeed = value

    end
)

------------------------------------------------------------
-- RESET CLIENT SETTINGS
------------------------------------------------------------

local ResetButton = Create("TextButton", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = C.Selected,
    BorderSizePixel = 0,
    Text = "Reset Client Settings",
    TextColor3 = C.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    LayoutOrder = 8,
    ZIndex = 4
}, ClientPage)

Corner(ResetButton, 10)
Stroke(ResetButton, C.Border, 1)

ResetButton.MouseEnter:Connect(function()
    Tween(ResetButton, 0.12, {
        BackgroundColor3 = C.SidebarHov
    })
end)

ResetButton.MouseLeave:Connect(function()
    Tween(ResetButton, 0.12, {
        BackgroundColor3 = C.Selected
    })
end)

ResetButton.MouseButton1Click:Connect(function()

    StopFly()

    FlyEnabled = false
    InfiniteJump = false

    WalkSpeed = DefaultWalkSpeed
    JumpPower = DefaultJumpPower
    Gravity = DefaultGravity

    workspace.Gravity = DefaultGravity

    local Humanoid = GetHumanoid()

    if Humanoid then
        Humanoid.WalkSpeed = DefaultWalkSpeed
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = DefaultJumpPower
        Humanoid.PlatformStand = false
    end

end)

------------------------------------------------------------
-- TAB SWITCHING
------------------------------------------------------------

local function SelectTab(tab)
    if tab == "Home" then

        Home.Visible = true
        ClientPage.Visible = false

        HomeIndicator.Visible = true
        ClientIndicator.Visible = false

        HomeButton.BackgroundColor3 = C.Selected
        ClientButton.BackgroundColor3 = C.Sidebar

        HomeIcon.TextColor3 = C.Accent
        ClientIcon.TextColor3 = C.Gray

        HomeText.TextColor3 = C.White
        ClientText.TextColor3 = C.Text

    elseif tab == "Client" then

        Home.Visible = false
        ClientPage.Visible = true

        HomeIndicator.Visible = false
        ClientIndicator.Visible = true

        HomeButton.BackgroundColor3 = C.Sidebar
        ClientButton.BackgroundColor3 = C.Selected

        HomeIcon.TextColor3 = C.Gray
        ClientIcon.TextColor3 = C.Accent

        HomeText.TextColor3 = C.Text
        ClientText.TextColor3 = C.White

    end
end

HomeButton.MouseButton1Click:Connect(function()
    SelectTab("Home")
end)

ClientButton.MouseButton1Click:Connect(function()
    SelectTab("Client")
end)

------------------------------------------------------------
-- CHARACTER RESPAWN HANDLING
------------------------------------------------------------

Player.CharacterAdded:Connect(function(character)

    task.wait(0.5)

    local Humanoid = character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpPower
    end

    if FlyEnabled then
        task.wait(0.2)
        StartFly()
    end

end)

------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------

local Dragging = false
local DragStart = nil
local StartPosition = nil

local DragZone = Create("Frame", {
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 50),
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

    local Delta = input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,

        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )

end)

------------------------------------------------------------
-- RIGHT SHIFT TOGGLE
------------------------------------------------------------

local Visible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then

        Visible = not Visible
        Main.Visible = Visible

    end

end)

------------------------------------------------------------
-- LOADING ANIMATION
------------------------------------------------------------

task.spawn(function()

    local Steps = {
        {
            Progress = 0.15,
            Text = "Initializing..."
        },

        {
            Progress = 0.35,
            Text = "Loading interface..."
        },

        {
            Progress = 0.55,
            Text = "Setting up UI..."
        },

        {
            Progress = 0.75,
            Text = "Loading client options..."
        },

        {
            Progress = 1,
            Text = "Complete!"
        }
    }

    for _, Step in ipairs(Steps) do

        local Progress = Step.Progress

        LoadStatus.Text = Step.Text
        LoadPercent.Text = math.floor(Progress * 100) .. "%"

        Tween(BarFill, 0.4, {
            Size = UDim2.fromScale(Progress, 1)
        })

        task.wait(0.45)

    end

    task.wait(0.3)

    --------------------------------------------------------
    -- FADE OUT
    --------------------------------------------------------

    Tween(Loading, 0.4, {
        BackgroundTransparency = 1
    })

    Tween(LoadLogo, 0.3, {
        BackgroundTransparency = 1,
        TextTransparency = 1
    })

    Tween(LoadImage, 0.3, {
        ImageTransparency = 1
    })

    Tween(LoadTitle, 0.3, {
        TextTransparency = 1
    })

    Tween(LoadStatus, 0.3, {
        TextTransparency = 1
    })

    Tween(LoadPercent, 0.3, {
        TextTransparency = 1
    })

    Tween(BarBG, 0.3, {
        BackgroundTransparency = 1
    })

    Tween(BarFill, 0.3, {
        BackgroundTransparency = 1
    })

    task.wait(0.4)

    Loading:Destroy()

    --------------------------------------------------------
    -- SHOW MAIN UI
    --------------------------------------------------------

    Main.Visible = true

    Main.Size = UDim2.fromOffset(740, 470)

    Tween(Main, 0.4, {
        Size = UDim2.fromOffset(780, 500),
        Position = UDim2.fromScale(0.5, 0.5)
    })

end)
