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
-- SETTINGS
------------------------------------------------------------

local LoadingImageId = "110712703042870"

local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local DefaultGravity = 196.2

local WalkSpeed = DefaultWalkSpeed
local JumpPower = DefaultJumpPower
local Gravity = DefaultGravity
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
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius or 8)
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

local function Tween(obj,time,props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function Humanoid()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function Root()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

------------------------------------------------------------
-- GUI
------------------------------------------------------------

local Gui = Create("ScreenGui",{
    Name="RHub",
    ResetOnSpawn=false,
    IgnoreGuiInset=true,
    DisplayOrder=999,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling
},PlayerGui)

------------------------------------------------------------
-- LOADING
------------------------------------------------------------

local Loading = Create("Frame",{
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(320,190),
    BackgroundColor3=C.Panel,
    BorderSizePixel=0,
    ZIndex=50
},Gui)

Corner(Loading,12)
Stroke(Loading,C.Border)

local HasImage = LoadingImageId ~= ""

local LoadImage = Create("ImageLabel",{
    AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,16),
    Size=UDim2.fromOffset(48,48),
    BackgroundTransparency=1,
    Image=LoadingImageId,
    ImageTransparency=HasImage and 0 or 1,
    ZIndex=51
},Loading)

Corner(LoadImage,10)

local LoadLogo = Create("TextLabel",{
    AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,16),
    Size=UDim2.fromOffset(48,48),
    BackgroundColor3=C.Accent,
    Text="R",
    TextColor3=Color3.fromRGB(12,16,24),
    TextSize=24,
    Font=Enum.Font.GothamBlack,
    Visible=not HasImage,
    ZIndex=51
},Loading)

Corner(LoadLogo,10)

local LoadTitle = Create("TextLabel",{
    AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,72),
    Size=UDim2.fromOffset(260,25),
    BackgroundTransparency=1,
    Text="R Hub",
    TextColor3=C.White,
    TextSize=18,
    Font=Enum.Font.GothamBold,
    ZIndex=51
},Loading)

local LoadStatus = Create("TextLabel",{
    AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,98),
    Size=UDim2.fromOffset(260,18),
    BackgroundTransparency=1,
    Text="Loading...",
    TextColor3=C.Gray,
    TextSize=12,
    Font=Enum.Font.Gotham,
    ZIndex=51
},Loading)

local BarBG = Create("Frame",{
    AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,128),
    Size=UDim2.fromOffset(250,7),
    BackgroundColor3=Color3.fromRGB(40,44,55),
    BorderSizePixel=0,
    ZIndex=51
},Loading)

Corner(BarBG,4)

local BarFill = Create("Frame",{
    Size=UDim2.fromScale(0,1),
    BackgroundColor3=C.Accent,
    BorderSizePixel=0,
    ZIndex=52
},BarBG)

Corner(BarFill,4)

local LoadPercent = Create("TextLabel",{
    AnchorPoint=Vector2.new(.5,0),
    Position=UDim2.new(.5,0,0,143),
    Size=UDim2.fromOffset(250,18),
    BackgroundTransparency=1,
    Text="0%",
    TextColor3=C.Gray,
    TextSize=11,
    Font=Enum.Font.GothamMedium,
    ZIndex=51
},Loading)

------------------------------------------------------------
-- MAIN
------------------------------------------------------------

local Main = Create("Frame",{
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(780,500),
    BackgroundColor3=C.Main,
    BorderSizePixel=0,
    Visible=false
},Gui)

Corner(Main,12)
Stroke(Main,C.Border)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------

local Sidebar = Create("Frame",{
    Size=UDim2.new(0,200,1,0),
    BackgroundColor3=C.Sidebar,
    BorderSizePixel=0
},Main)

Corner(Sidebar,12)

Create("Frame",{
    Position=UDim2.new(1,-14,0,0),
    Size=UDim2.new(0,14,1,0),
    BackgroundColor3=C.Sidebar,
    BorderSizePixel=0
},Sidebar)

local Logo = Create("Frame",{
    Size=UDim2.new(1,0,0,58),
    BackgroundTransparency=1
},Sidebar)

local LogoBadge = Create("TextLabel",{
    Position=UDim2.fromOffset(16,13),
    Size=UDim2.fromOffset(34,34),
    BackgroundColor3=C.Accent,
    Text="R",
    TextColor3=Color3.fromRGB(12,16,24),
    TextSize=16,
    Font=Enum.Font.GothamBlack
},Logo)

Corner(LogoBadge,8)

Create("TextLabel",{
    Position=UDim2.fromOffset(58,18),
    Size=UDim2.fromOffset(120,24),
    BackgroundTransparency=1,
    Text="R Hub",
    TextColor3=C.White,
    TextSize=18,
    Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left
},Logo)

local SideScroll = Create("ScrollingFrame",{
    Position=UDim2.fromOffset(0,58),
    Size=UDim2.new(1,0,1,-114),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.AccentDark,
    AutomaticCanvasSize=Enum.AutomaticSize.Y
},Sidebar)

Create("UIListLayout",{
    Padding=UDim.new(0,4),
    SortOrder=Enum.SortOrder.LayoutOrder
},SideScroll)

Create("UIPadding",{
    PaddingLeft=UDim.new(0,10),
    PaddingRight=UDim.new(0,10),
    PaddingTop=UDim.new(0,4),
    PaddingBottom=UDim.new(0,8)
},SideScroll)

------------------------------------------------------------
-- TAB CREATOR
------------------------------------------------------------

local function Tab(name,icon,order)
    local b=Create("TextButton",{
        Size=UDim2.new(1,0,0,36),
        BackgroundColor3=C.Sidebar,
        Text="",
        AutoButtonColor=false,
        LayoutOrder=order
    },SideScroll)

    Corner(b,8)

    local ind=Create("Frame",{
        Position=UDim2.fromOffset(0,8),
        Size=UDim2.fromOffset(3,20),
        BackgroundColor3=C.Accent,
        Visible=false
    },b)

    Corner(ind,2)

    local ic=Create("TextLabel",{
        Position=UDim2.fromOffset(14,0),
        Size=UDim2.fromOffset(22,36),
        BackgroundTransparency=1,
        Text=icon,
        TextColor3=C.Gray,
        TextSize=15,
        Font=Enum.Font.GothamBold
    },b)

    local tx=Create("TextLabel",{
        Position=UDim2.fromOffset(40,0),
        Size=UDim2.new(1,-48,1,0),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=C.Text,
        TextSize=13,
        Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left
    },b)

    return b,ind,ic,tx
end

local HomeButton,HomeIndicator,HomeIcon,HomeText =
    Tab("Home","⌂",1)

local ClientButton,ClientIndicator,ClientIcon,ClientText =
    Tab("Client Options","⚙",2)

local GameButton,GameIndicator,GameIcon,GameText =
    Tab("Game Options","☀",3)

------------------------------------------------------------
-- USER BAR
------------------------------------------------------------

local UserBar = Create("Frame",{
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,0,1,0),
    Size=UDim2.new(1,0,0,56),
    BackgroundColor3=Color3.fromRGB(25,27,35)
},Sidebar)

local Avatar=Create("TextLabel",{
    Position=UDim2.fromOffset(14,10),
    Size=UDim2.fromOffset(36,36),
    BackgroundColor3=C.AccentDark,
    Text=string.sub(Player.DisplayName,1,1):upper(),
    TextColor3=C.White,
    TextSize=15,
    Font=Enum.Font.GothamBold
},UserBar)

Corner(Avatar,18)

Create("TextLabel",{
    Position=UDim2.fromOffset(58,11),
    Size=UDim2.new(1,-70,0,17),
    BackgroundTransparency=1,
    Text=Player.DisplayName,
    TextColor3=C.White,
    TextSize=13,
    Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left
},UserBar)

Create("TextLabel",{
    Position=UDim2.fromOffset(58,29),
    Size=UDim2.new(1,-70,0,15),
    BackgroundTransparency=1,
    Text="@"..Player.Name,
    TextColor3=C.Gray,
    TextSize=11,
    Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left
},UserBar)

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------

local Content=Create("Frame",{
    Position=UDim2.fromOffset(200,0),
    Size=UDim2.new(1,-200,1,0),
    BackgroundColor3=C.Main,
    BorderSizePixel=0
},Main)

local function Page(name)
    local p=Create("ScrollingFrame",{
        Name=name,
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=4,
        ScrollBarImageColor3=C.AccentDark,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false
    },Content)

    Create("UIListLayout",{
        Padding=UDim.new(0,12),
        SortOrder=Enum.SortOrder.LayoutOrder
    },p)

    Create("UIPadding",{
        PaddingLeft=UDim.new(0,16),
        PaddingRight=UDim.new(0,16),
        PaddingTop=UDim.new(0,16),
        PaddingBottom=UDim.new(0,20)
    },p)

    return p
end

local Home=Page("Home")
local ClientPage=Page("ClientOptions")
local GamePage=Page("GameOptions")

------------------------------------------------------------
-- PANEL
------------------------------------------------------------

local function Panel(parent,height,order)
    local p=Create("Frame",{
        Size=UDim2.new(1,0,0,height),
        BackgroundColor3=C.Panel,
        BorderSizePixel=0,
        LayoutOrder=order
    },parent)

    Corner(p,10)
    Stroke(p,C.Border)

    return p
end

------------------------------------------------------------
-- HOME
------------------------------------------------------------

local HP=Panel(Home,190,1)

Create("TextLabel",{
    Position=UDim2.fromOffset(14,14),
    Size=UDim2.new(1,-28,0,24),
    BackgroundTransparency=1,
    Text="Home",
    TextColor3=C.White,
    TextSize=18,
    Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left
},HP)

Create("TextLabel",{
    Position=UDim2.fromOffset(14,45),
    Size=UDim2.new(1,-28,0,20),
    BackgroundTransparency=1,
    Text="Welcome to R Hub.",
    TextColor3=C.Text,
    TextSize=13,
    Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left
},HP)

Create("TextLabel",{
    Position=UDim2.fromOffset(14,73),
    Size=UDim2.new(1,-28,0,18),
    BackgroundTransparency=1,
    Text="Client and game options are available in the sidebar.",
    TextColor3=C.Gray,
    TextSize=12,
    Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left
},HP)

Create("TextLabel",{
    Position=UDim2.fromOffset(14,99),
    Size=UDim2.new(1,-28,0,18),
    BackgroundTransparency=1,
    Text="Right Shift  •  Toggle UI",
    TextColor3=C.GrayDark,
    TextSize=11,
    Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left
},HP)

local DestroyButton=Create("TextButton",{
    Position=UDim2.fromOffset(14,130),
    Size=UDim2.new(1,-28,0,42),
    BackgroundColor3=C.Red,
    BorderSizePixel=0,
    Text="Destroy UI",
    TextColor3=C.White,
    TextSize=13,
    Font=Enum.Font.GothamBold,
    AutoButtonColor=false
},HP)

Corner(DestroyButton,8)

DestroyButton.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local function Toggle(parent,title,desc,order,callback)
    local f=Panel(parent,66,order)

    Create("TextLabel",{
        Position=UDim2.fromOffset(14,10),
        Size=UDim2.new(1,-90,0,20),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=C.White,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    },f)

    Create("TextLabel",{
        Position=UDim2.fromOffset(14,32),
        Size=UDim2.new(1,-90,0,18),
        BackgroundTransparency=1,
        Text=desc,
        TextColor3=C.Gray,
        TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left
    },f)

    local b=Create("TextButton",{
        AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-14,.5,0),
        Size=UDim2.fromOffset(48,26),
        BackgroundColor3=Color3.fromRGB(55,58,70),
        Text="OFF",
        TextColor3=C.Gray,
        TextSize=10,
        Font=Enum.Font.GothamBold,
        AutoButtonColor=false
    },f)

    Corner(b,13)

    local enabled=false

    b.MouseButton1Click:Connect(function()
        enabled=not enabled

        if enabled then
            b.BackgroundColor3=C.Accent
            b.Text="ON"
            b.TextColor3=Color3.fromRGB(10,18,25)
        else
            b.BackgroundColor3=Color3.fromRGB(55,58,70)
            b.Text="OFF"
            b.TextColor3=C.Gray
        end

        callback(enabled)
    end)

    return f
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

local function Slider(parent,title,min,max,default,order,callback)
    local f=Panel(parent,82,order)

    local label=Create("TextLabel",{
        Position=UDim2.fromOffset(14,10),
        Size=UDim2.new(1,-28,0,20),
        BackgroundTransparency=1,
        Text=title..": "..default,
        TextColor3=C.White,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    },f)

    local track=Create("Frame",{
        Position=UDim2.new(0,14,0,48),
        Size=UDim2.new(1,-28,0,6),
        BackgroundColor3=Color3.fromRGB(48,52,63)
    },f)

    Corner(track,4)

    local fill=Create("Frame",{
        Size=UDim2.fromScale((default-min)/(max-min),1),
        BackgroundColor3=C.Accent
    },track)

    Corner(fill,4)

    local knob=Create("Frame",{
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale((default-min)/(max-min),.5),
        Size=UDim2.fromOffset(14,14),
        BackgroundColor3=C.White
    },track)

    Corner(knob,7)

    local dragging=false

    local function set(x)
        local pct=math.clamp(
            (x-track.AbsolutePosition.X)/track.AbsoluteSize.X,
            0,1
        )

        local value=math.floor(min+(max-min)*pct+.5)
        local p=(value-min)/(max-min)

        fill.Size=UDim2.fromScale(p,1)
        knob.Position=UDim2.fromScale(p,.5)
        label.Text=title..": "..value

        callback(value)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            set(i.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch
        ) then
            set(i.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
end

------------------------------------------------------------
-- CLIENT OPTIONS
------------------------------------------------------------

Toggle(ClientPage,"Infinite Jump",
    "Jump continuously without touching the ground.",2,
    function(v)
        InfiniteJump=v
    end)

Slider(ClientPage,"Walk Speed",16,200,16,3,
    function(v)
        WalkSpeed=v
        local h=Humanoid()
        if h then h.WalkSpeed=v end
    end)

Slider(ClientPage,"Jump Power",50,200,50,4,
    function(v)
        JumpPower=v
        local h=Humanoid()
        if h then
            h.UseJumpPower=true
            h.JumpPower=v
        end
    end)

Slider(ClientPage,"Gravity",20,300,196,5,
    function(v)
        Gravity=v
        workspace.Gravity=v
    end)

------------------------------------------------------------
-- FLY
------------------------------------------------------------

local FlyConnection
local FlyVelocity
local FlyGyro

local function StopFly()
    FlyEnabled=false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection=nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity=nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro=nil
    end

    local h=Humanoid()
    if h then h.PlatformStand=false end
end

local function StartFly()
    StopFly()

    local r=Root()
    local h=Humanoid()

    if not r or not h then return end

    FlyEnabled=true
    h.PlatformStand=true

    FlyVelocity=Instance.new("BodyVelocity")
    FlyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
    FlyVelocity.Parent=r

    FlyGyro=Instance.new("BodyGyro")
    FlyGyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
    FlyGyro.P=9000
    FlyGyro.Parent=r

    FlyConnection=RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not r.Parent then
            StopFly()
            return
        end

        local cam=workspace.CurrentCamera
        local dir=Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir+=cam.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir-=cam.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir+=cam.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir-=cam.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir+=Vector3.yAxis
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir-=Vector3.yAxis
        end

        if dir.Magnitude>0 then
            dir=dir.Unit
        end

        FlyVelocity.Velocity=dir*FlySpeed
        FlyGyro.CFrame=cam.CFrame
    end)
end

Toggle(ClientPage,"Fly",
    "WASD to move • Space up • Left Ctrl down.",6,
    function(v)
        if v then
            StartFly()
        else
            StopFly()
        end
    end)

Slider(ClientPage,"Fly Speed",20,200,60,7,
    function(v)
        FlySpeed=v
    end)

------------------------------------------------------------
-- GAME OPTIONS HEADER
------------------------------------------------------------

local GH=Panel(GamePage,72,1)

Create("TextLabel",{
    Position=UDim2.fromOffset(14,12),
    Size=UDim2.new(1,-28,0,24),
    BackgroundTransparency=1,
    Text="Game Options",
    TextColor3=C.White,
    TextSize=18,
    Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left
},GH)

Create("TextLabel",{
    Position=UDim2.fromOffset(14,39),
    Size=UDim2.new(1,-28,0,18),
    BackgroundTransparency=1,
    Text="Local lighting and environment controls.",
    TextColor3=C.Gray,
    TextSize=12,
    Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left
},GH)

------------------------------------------------------------
-- TIME CONTROL
------------------------------------------------------------

local OriginalClockTime=Lighting.ClockTime
local OriginalBrightness=Lighting.Brightness
local OriginalAmbient=Lighting.Ambient
local OriginalOutdoor=Lighting.OutdoorAmbient

local TimeLock=nil
local FullBright=false

local function StopTimeLock()
    if TimeLock then
        TimeLock:Disconnect()
        TimeLock=nil
    end
end

local function SetTime(hour)
    StopTimeLock()
    Lighting.ClockTime=hour

    TimeLock=RunService.Heartbeat:Connect(function()
        if math.abs(Lighting.ClockTime-hour)>.05 then
            Lighting.ClockTime=hour
        end
    end)
end

local function GameButton(parent,title,desc,order,callback)
    local f=Panel(parent,66,order)

    Create("TextLabel",{
        Position=UDim2.fromOffset(14,10),
        Size=UDim2.new(1,-150,0,20),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=C.White,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    },f)

    Create("TextLabel",{
        Position=UDim2.fromOffset(14,32),
        Size=UDim2.new(1,-150,0,18),
        BackgroundTransparency=1,
        Text=desc,
        TextColor3=C.Gray,
        TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left
    },f)

    local b=Create("TextButton",{
        AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-14,.5,0),
        Size=UDim2.fromOffset(110,32),
        BackgroundColor3=C.Selected,
        BorderSizePixel=0,
        Text=title,
        TextColor3=C.White,
        TextSize=11,
        Font=Enum.Font.GothamBold,
        AutoButtonColor=false
    },f)

    Corner(b,8)

    b.MouseButton1Click:Connect(callback)

    return f
end

------------------------------------------------------------
-- DAY / NIGHT PRESETS
------------------------------------------------------------

GameButton(GamePage,"Always Day",
    "Locks the local time around noon.",2,
    function()
        SetTime(12)
    end)

GameButton(GamePage,"Always Night",
    "Locks the local time around midnight.",3,
    function()
        SetTime(0)
    end)

GameButton(GamePage,"Sunrise",
    "Sets the local time to sunrise.",4,
    function()
        SetTime(6)
    end)

GameButton(GamePage,"Sunset",
    "Sets the local time to sunset.",5,
    function()
        SetTime(18)
    end)

GameButton(GamePage,"Midnight",
    "Sets the local time to midnight.",6,
    function()
        SetTime(0)
    end)

------------------------------------------------------------
-- FULL BRIGHT
------------------------------------------------------------

Toggle(GamePage,"Full Bright",
    "Maximizes local brightness and ambient light.",7,
    function(v)
        FullBright=v

        if v then
            Lighting.Brightness=3
            Lighting.Ambient=Color3.new(1,1,1)
            Lighting.OutdoorAmbient=Color3.new(1,1,1)
        else
            Lighting.Brightness=OriginalBrightness
            Lighting.Ambient=OriginalAmbient
            Lighting.OutdoorAmbient=OriginalOutdoor
        end
    end)

------------------------------------------------------------
-- CUSTOM TIME
------------------------------------------------------------

Slider(GamePage,"Time Of Day",0,24,math.floor(Lighting.ClockTime),8,
    function(v)
        StopTimeLock()
        Lighting.ClockTime=v
    end)

------------------------------------------------------------
-- RESET LIGHTING
------------------------------------------------------------

local ResetLighting=Create("TextButton",{
    Size=UDim2.new(1,0,0,44),
    BackgroundColor3=C.Selected,
    BorderSizePixel=0,
    Text="Reset Lighting",
    TextColor3=C.White,
    TextSize=13,
    Font=Enum.Font.GothamBold,
    AutoButtonColor=false,
    LayoutOrder=9
},GamePage)

Corner(ResetLighting,10)
Stroke(ResetLighting,C.Border)

ResetLighting.MouseButton1Click:Connect(function()
    StopTimeLock()

    Lighting.ClockTime=OriginalClockTime
    Lighting.Brightness=OriginalBrightness
    Lighting.Ambient=OriginalAmbient
    Lighting.OutdoorAmbient=OriginalOutdoor
end)

------------------------------------------------------------
-- TAB SWITCHING
------------------------------------------------------------

local function SelectTab(tab)

    Home.Visible=tab=="Home"
    ClientPage.Visible=tab=="Client"
    GamePage.Visible=tab=="Game"

    local buttons={
        {HomeButton,HomeIndicator,HomeIcon,HomeText,tab=="Home"},
        {ClientButton,ClientIndicator,ClientIcon,ClientText,tab=="Client"},
        {GameButton,GameIndicator,GameIcon,GameText,tab=="Game"}
    }

    for _,x in ipairs(buttons) do
        local b,ind,icon,text,selected=table.unpack(x)

        ind.Visible=selected
        b.BackgroundColor3=selected and C.Selected or C.Sidebar
        icon.TextColor3=selected and C.Accent or C.Gray
        text.TextColor3=selected and C.White or C.Text
    end
end

HomeButton.MouseButton1Click:Connect(function()
    SelectTab("Home")
end)

ClientButton.MouseButton1Click:Connect(function()
    SelectTab("Client")
end)

GameButton.MouseButton1Click:Connect(function()
    SelectTab("Game")
end)

SelectTab("Home")

------------------------------------------------------------
-- INFINITE JUMP
------------------------------------------------------------

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        local h=Humanoid()
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

------------------------------------------------------------
-- RESPAWN
------------------------------------------------------------

Player.CharacterAdded:Connect(function()
    task.wait(.5)

    local h=Humanoid()

    if h then
        h.WalkSpeed=WalkSpeed
        h.UseJumpPower=true
        h.JumpPower=JumpPower
    end

    if FlyEnabled then
        task.wait(.2)
        StartFly()
    end
end)

------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------

local Dragging=false
local DragStart
local StartPosition

local DragZone=Create("Frame",{
    Position=UDim2.fromOffset(0,0),
    Size=UDim2.new(1,0,0,50),
    BackgroundTransparency=1,
    Active=true,
    ZIndex=10
},Main)

DragZone.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
    or input.UserInputType==Enum.UserInputType.Touch then

        Dragging=true
        DragStart=input.Position
        StartPosition=Main.Position

        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then
                Dragging=false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not Dragging then return end

    if input.UserInputType~=Enum.UserInputType.MouseMovement
    and input.UserInputType~=Enum.UserInputType.Touch then
        return
    end

    local delta=input.Position-DragStart

    Main.Position=UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset+delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset+delta.Y
    )
end)

------------------------------------------------------------
-- RIGHT SHIFT
------------------------------------------------------------

local Visible=true

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end

    if input.KeyCode==Enum.KeyCode.RightShift then
        Visible=not Visible
        Main.Visible=Visible
    end
end)

------------------------------------------------------------
-- LOADING ANIMATION
------------------------------------------------------------

task.spawn(function()

    local steps={
        {0.15,"Initializing..."},
        {0.35,"Loading interface..."},
        {0.55,"Loading client options..."},
        {0.75,"Loading game options..."},
        {1,"Complete!"}
    }

    for _,step in ipairs(steps) do
        LoadStatus.Text=step[2]
        LoadPercent.Text=math.floor(step[1]*100).."%"

        Tween(BarFill,.4,{
            Size=UDim2.fromScale(step[1],1)
        })

        task.wait(.45)
    end

    task.wait(.3)

    Tween(Loading,.4,{BackgroundTransparency=1})
    Tween(LoadLogo,.3,{
        BackgroundTransparency=1,
        TextTransparency=1
    })
    Tween(LoadImage,.3,{ImageTransparency=1})
    Tween(LoadTitle,.3,{TextTransparency=1})
    Tween(LoadStatus,.3,{TextTransparency=1})
    Tween(LoadPercent,.3,{TextTransparency=1})
    Tween(BarBG,.3,{BackgroundTransparency=1})
    Tween(BarFill,.3,{BackgroundTransparency=1})

    task.wait(.4)

    Loading:Destroy()

    Main.Visible=true
    Main.Size=UDim2.fromOffset(740,470)

    Tween(Main,.4,{
        Size=UDim2.fromOffset(780,500),
        Position=UDim2.fromScale(.5,.5)
    })
end)
