--[[
    R Hub
    UI Only
    Single Tab: Home
    Toggle: Right Shift

    Optional Loading Image:
    local LoadingImageId = "rbxassetid://YOUR_IMAGE_ID"
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
}

------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------

-- Put your image asset ID here.
-- Leave it as "" to use the R logo.
local LoadingImageId = "110712703042870"

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
-- SMALL LOADING SCREEN
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

------------------------------------------------------------
-- LOADING IMAGE
------------------------------------------------------------

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

------------------------------------------------------------
-- DEFAULT R LOGO
------------------------------------------------------------

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

------------------------------------------------------------
-- LOADING TITLE
------------------------------------------------------------

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

------------------------------------------------------------
-- LOADING STATUS
------------------------------------------------------------

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

------------------------------------------------------------
-- LOADING BAR BACKGROUND
------------------------------------------------------------

local BarBG = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),

    Position = UDim2.new(0.5, 0, 0, 128),
    Size = UDim2.fromOffset(250, 7),

    BackgroundColor3 = Color3.fromRGB(40, 44, 55),

    BorderSizePixel = 0,

    ZIndex = 51
}, Loading)

Corner(BarBG, 4)

------------------------------------------------------------
-- LOADING BAR FILL
------------------------------------------------------------

local BarFill = Create("Frame", {
    Size = UDim2.fromScale(0, 1),

    BackgroundColor3 = C.Accent,

    BorderSizePixel = 0,

    ZIndex = 52
}, BarBG)

Corner(BarFill, 4)

------------------------------------------------------------
-- LOADING PERCENTAGE
------------------------------------------------------------

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

-- Sidebar right extension to make the corner look clean
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
    Padding = UDim.new(0, 1),
    SortOrder = Enum.SortOrder.LayoutOrder
}, SideScroll)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),

    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 8)
}, SideScroll)

------------------------------------------------------------
-- HOME TAB
------------------------------------------------------------

local HomeButton = Create("TextButton", {
    Size = UDim2.new(1, 0, 0, 36),

    BackgroundColor3 = C.Selected,
    BackgroundTransparency = 0,

    Text = "",

    AutoButtonColor = false,

    LayoutOrder = 1,

    ZIndex = 4
}, SideScroll)

Corner(HomeButton, 8)

------------------------------------------------------------
-- HOME INDICATOR
------------------------------------------------------------

local Indicator = Create("Frame", {
    Position = UDim2.fromOffset(0, 8),

    Size = UDim2.fromOffset(3, 20),

    BackgroundColor3 = C.Accent,

    BorderSizePixel = 0,

    ZIndex = 5
}, HomeButton)

Corner(Indicator, 2)

------------------------------------------------------------
-- HOME ICON
------------------------------------------------------------

local HomeIcon = Create("TextLabel", {
    Position = UDim2.fromOffset(14, 0),

    Size = UDim2.fromOffset(22, 36),

    BackgroundTransparency = 1,

    Text = "⌂",
    TextColor3 = C.Accent,

    TextSize = 15,
    Font = Enum.Font.GothamBold,

    ZIndex = 5
}, HomeButton)

------------------------------------------------------------
-- HOME TEXT
------------------------------------------------------------

local HomeText = Create("TextLabel", {
    Position = UDim2.fromOffset(40, 0),

    Size = UDim2.new(1, -48, 1, 0),

    BackgroundTransparency = 1,

    Text = "Home",
    TextColor3 = C.White,

    TextSize = 13,
    Font = Enum.Font.GothamMedium,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 5
}, HomeButton)

------------------------------------------------------------
-- HOME HOVER
------------------------------------------------------------

HomeButton.MouseEnter:Connect(function()
    Tween(HomeButton, 0.12, {
        BackgroundColor3 = C.SidebarHov
    })
end)

HomeButton.MouseLeave:Connect(function()
    Tween(HomeButton, 0.12, {
        BackgroundColor3 = C.Selected
    })
end)

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

------------------------------------------------------------
-- AVATAR
------------------------------------------------------------

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

------------------------------------------------------------
-- DISPLAY NAME
------------------------------------------------------------

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

------------------------------------------------------------
-- USERNAME
------------------------------------------------------------

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
    Size = UDim2.new(1, 0, 0, 140),

    BackgroundColor3 = C.Panel,

    BorderSizePixel = 0,

    LayoutOrder = 1,

    ZIndex = 4
}, Home)

Corner(HomePanel, 10)
Stroke(HomePanel, C.Border, 1)

------------------------------------------------------------
-- HOME TITLE
------------------------------------------------------------

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

------------------------------------------------------------
-- HOME DESCRIPTION
------------------------------------------------------------

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

------------------------------------------------------------
-- UI STATUS
------------------------------------------------------------

Create("TextLabel", {
    Position = UDim2.fromOffset(14, 73),

    Size = UDim2.new(1, -28, 0, 18),

    BackgroundTransparency = 1,

    Text = "UI-only interface",

    TextColor3 = C.Gray,

    TextSize = 12,
    Font = Enum.Font.Gotham,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 5
}, HomePanel)

------------------------------------------------------------
-- KEYBIND INFO
------------------------------------------------------------

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
            Text = "Almost ready..."
        },

        {
            Progress = 1,
            Text = "Complete!"
        }
    }

    --------------------------------------------------------
    -- PROGRESS
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- REMOVE LOADING
    --------------------------------------------------------

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