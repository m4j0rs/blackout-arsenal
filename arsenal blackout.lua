wait(1)
if game.PlaceId ~= 286090429 then return end

-- ============================================================
-- BLACKOUT GUI | RED EDITION | ARSENAL
-- ============================================================

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local VirtualInputManager= game:GetService("VirtualInputManager")
local LocalPlayer        = Players.LocalPlayer
local Camera             = workspace.CurrentCamera

-- ============================================================
-- THEME TABLE  (RED is default)
-- ============================================================
local THEMES = {
    RED    = { accent = Color3.fromRGB(230, 30, 45),   dim = Color3.fromRGB(120, 15, 22),   border = Color3.fromRGB(34, 20, 22) },
    PURPLE = { accent = Color3.fromRGB(175, 90, 255),  dim = Color3.fromRGB(80, 40, 120),   border = Color3.fromRGB(40, 24, 55) },
    BLUE   = { accent = Color3.fromRGB(65, 130, 255),  dim = Color3.fromRGB(30, 60, 120),   border = Color3.fromRGB(22, 30, 48) },
    GREEN  = { accent = Color3.fromRGB(65, 220, 125),  dim = Color3.fromRGB(30, 110, 60),   border = Color3.fromRGB(20, 40, 28) },
    ORANGE = { accent = Color3.fromRGB(245, 130, 30),  dim = Color3.fromRGB(120, 60, 15),   border = Color3.fromRGB(45, 28, 15) },
    PINK   = { accent = Color3.fromRGB(255, 90, 180),  dim = Color3.fromRGB(130, 40, 90),   border = Color3.fromRGB(45, 22, 35) },
    WHITE  = { accent = Color3.fromRGB(235, 235, 235), dim = Color3.fromRGB(120, 120, 120), border = Color3.fromRGB(40, 40, 45) },
}
local currentTheme = "RED"

local BG          = Color3.fromRGB(6, 6, 7)
local BG_ITEM     = Color3.fromRGB(13, 13, 15)
local BG_HOVER    = Color3.fromRGB(22, 14, 16)
local TEXT        = Color3.fromRGB(255, 255, 255)
local TEXT_DIM    = Color3.fromRGB(170, 170, 178)

-- Mutable theme globals (RED by default)
local ACCENT      = THEMES.RED.accent
local ACCENT_DIM  = THEMES.RED.dim
local BORDER      = THEMES.RED.border
local TEXT_ON     = THEMES.RED.accent

-- Track every themed element so we can recolor on theme change
local ThemedElements = {
    windows   = {},
    toggles   = {},
    buttons   = {},
    dropdowns = {},
    sections  = {},
}

-- ============================================================
-- STATE
-- ============================================================
local aimbotEnabled = false
local silentAimEnabled = false
local triggerBotEnabled = false
local aimPart = "Head"
local aimKey = "Right Click"
local aimSmoothing = 0.15
local fovRadius = 125
local aiming = false
local triggerDelay = 0.05
local lastTriggerTime = 0

local espEnabled = false
local nameESPEnabled = false
local tracerEnabled = false
local wallCheckEnabled = true
local espShowTeam = false
local espRgbEnabled = false
local espType = "Box+Skeleton"
local espColor = THEMES.RED.accent
local espSize = 2
local espDistance = 2000
local espRenderColor = espColor

local fovEnabled = true
local fovColor = THEMES.RED.accent
local fovThickness = 2
local fovSides = 64
local fovFilled = false

local crosshairEnabled = false
local crosshairSize = 8
local crosshairThickness = 2

local speedHackEnabled = false
local speedValue = 100
local flyEnabled = false
local flySpeed = 50
local antiAimEnabled = false

local rgbGunEnabled = false
local themeGunColorEnabled = true
local rapidFireEnabled = false
local noRecoilEnabled = false

local espObjects = {}

local rgbTrackedParts = {}
local rgbOriginalProperties = {}
local rgbRainbowConnection = nil
local rgbArmsConnections = {}
local rgbCameraConnection = nil
local rgbCurrentColor = Color3.new(1, 1, 1)
local gunModConnection = nil
local originalWeaponValues = {}
local cachedWeaponValues = {}
local gunModsDirty = true
local lastGunModRefresh = 0
local GUN_MOD_REFRESH_INTERVAL = 0.20

local bodyVelocity, bodyGyro, flyAttachment = nil, nil, nil
local noclipConnection = nil
local savedCollision = {}

-- ============================================================
-- FAST LOADING SPLASH
-- ============================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "BlackoutLoader"
LoadGui.ResetOnSpawn = false
LoadGui.IgnoreGuiInset = true
LoadGui.DisplayOrder = 2147483647
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local LoadBG = Instance.new("Frame")
LoadBG.Size = UDim2.new(1, 0, 1, 0)
LoadBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadBG.BorderSizePixel = 0
LoadBG.BackgroundTransparency = 1
LoadBG.Parent = LoadGui

local LoadCenter = Instance.new("Frame")
LoadCenter.Size = UDim2.new(0, 400, 0, 160)
LoadCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadCenter.AnchorPoint = Vector2.new(0.5, 0.5)
LoadCenter.BackgroundTransparency = 1
LoadCenter.Parent = LoadBG

local LogoLbl = Instance.new("TextLabel")
LogoLbl.Size = UDim2.new(1, 0, 0, 70)
LogoLbl.BackgroundTransparency = 1
LogoLbl.Text = ""
LogoLbl.Font = Enum.Font.Code
LogoLbl.TextSize = 48
LogoLbl.TextColor3 = ACCENT
LogoLbl.TextTransparency = 1
LogoLbl.TextStrokeTransparency = 1
LogoLbl.TextStrokeColor3 = Color3.fromRGB(255, 90, 100)
LogoLbl.Parent = LoadCenter

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1, 0, 0, 20)
SubLbl.Position = UDim2.new(0, 0, 0, 76)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "LOADING // PLEASE WAIT"
SubLbl.Font = Enum.Font.Code
SubLbl.TextSize = 12
SubLbl.TextColor3 = ACCENT_DIM
SubLbl.TextTransparency = 1
SubLbl.Parent = LoadCenter

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0, 320, 0, 4)
BarBg.Position = UDim2.new(0.5, -160, 0, 112)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
BarBg.BorderSizePixel = 0
BarBg.BackgroundTransparency = 1
BarBg.Parent = LoadCenter
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = ACCENT
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local BarGlow = Instance.new("UIStroke")
BarGlow.Color = Color3.fromRGB(255, 90, 100)
BarGlow.Thickness = 1
BarGlow.Transparency = 0.4
BarGlow.Parent = BarFill

local PctLbl = Instance.new("TextLabel")
PctLbl.Size = UDim2.new(1, 0, 0, 14)
PctLbl.Position = UDim2.new(0, 0, 0, 122)
PctLbl.BackgroundTransparency = 1
PctLbl.Text = "0%"
PctLbl.Font = Enum.Font.Code
PctLbl.TextSize = 10
PctLbl.TextColor3 = TEXT_DIM
PctLbl.TextTransparency = 1
PctLbl.Parent = LoadCenter

local Scanlines = Instance.new("Frame")
Scanlines.Size = UDim2.new(1, 0, 1, 0)
Scanlines.BackgroundTransparency = 1
Scanlines.Parent = LoadBG

for i = 0, 60 do
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0, i * 14)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 0.97
    Line.BorderSizePixel = 0
    Line.Parent = Scanlines
end

local function RunLoadingSequence()
    TweenService:Create(LoadBG, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    task.wait(0.05)
    local text = "BLACKOUT"
    LogoLbl.Text = ""
    TweenService:Create(LogoLbl, TweenInfo.new(0.15), {TextTransparency = 0, TextStrokeTransparency = 0.4}):Play()
    TweenService:Create(SubLbl, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
    TweenService:Create(BarBg,  TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    TweenService:Create(PctLbl, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
    for i = 1, #text do
        LogoLbl.Text = string.sub(text, 1, i)
        task.wait(0.02)
    end
    local steps = 15
    for i = 0, steps do
        local pct = i / steps
        BarFill.Size = UDim2.new(pct, 0, 1, 0)
        PctLbl.Text = math.floor(pct * 100) .. "%"
        task.wait(0.6 / steps)
    end
    task.wait(0.05)
    local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LogoLbl, fadeInfo, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    TweenService:Create(SubLbl, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg,  fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(PctLbl, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(BarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarGlow, fadeInfo, {Transparency = 1}):Play()
    local bgTween = TweenService:Create(LoadBG, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    bgTween:Play()
    bgTween.Completed:Wait()
    LoadGui:Destroy()
end

-- ============================================================
-- ROOT  (always on top of everything)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackoutGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 2147483647
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- DROPDOWN SYSTEM
-- ============================================================
local DropdownLayer = Instance.new("Frame")
DropdownLayer.Size = UDim2.fromScale(1, 1)
DropdownLayer.BackgroundTransparency = 1
DropdownLayer.BorderSizePixel = 0
DropdownLayer.Visible = false
DropdownLayer.ZIndex = 5000
DropdownLayer.Parent = ScreenGui

local DropdownMenu = Instance.new("Frame")
DropdownMenu.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
DropdownMenu.BorderSizePixel = 0
DropdownMenu.Visible = false
DropdownMenu.ZIndex = 5001
DropdownMenu.Parent = DropdownLayer
Instance.new("UICorner", DropdownMenu).CornerRadius = UDim.new(0, 5)
local DStroke = Instance.new("UIStroke", DropdownMenu)
DStroke.Color = ACCENT_DIM
DStroke.Thickness = 1

local DropdownScroll = Instance.new("ScrollingFrame")
DropdownScroll.Position = UDim2.fromOffset(4, 4)
DropdownScroll.Size = UDim2.new(1, -8, 1, -8)
DropdownScroll.BackgroundTransparency = 1
DropdownScroll.BorderSizePixel = 0
DropdownScroll.ScrollBarThickness = 3
DropdownScroll.ScrollBarImageColor3 = ACCENT
DropdownScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownScroll.ZIndex = 5002
DropdownScroll.Parent = DropdownMenu

local DropdownList = Instance.new("UIListLayout")
DropdownList.Padding = UDim.new(0, 3)
DropdownList.SortOrder = Enum.SortOrder.LayoutOrder
DropdownList.Parent = DropdownScroll

local activeDropdown = nil

local function closeDropdown()
    activeDropdown = nil
    DropdownMenu.Visible = false
    DropdownLayer.Visible = false
    for _, child in ipairs(DropdownScroll:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

DropdownLayer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        closeDropdown()
    end
end)

-- ============================================================
-- THEME APPLIER
-- ============================================================
local ApplyTheme -- forward declare

ApplyTheme = function(name)
    local t = THEMES[name]
    if not t then return end
    currentTheme = name
    ACCENT     = t.accent
    ACCENT_DIM = t.dim
    BORDER     = t.border
    TEXT_ON    = t.accent

    -- Windows
    for _, w in ipairs(ThemedElements.windows) do
        if w.mainStroke then w.mainStroke.Color = BORDER end
        if w.glow then w.glow.BackgroundColor3 = ACCENT end
        if w.divider then w.divider.BackgroundColor3 = BORDER end
        if w.titleDot then w.titleDot.BackgroundColor3 = ACCENT end
        if w.scroll then w.scroll.ScrollBarImageColor3 = ACCENT_DIM end
    end

    -- Toggles: re-render with the fresh colors
    for _, tog in ipairs(ThemedElements.toggles) do
        if tog.render then pcall(tog.render) end
    end

    -- Buttons
    for _, b in ipairs(ThemedElements.buttons) do
        if b.stroke then b.stroke.Color = BORDER end
        if b.bar then b.bar.BackgroundColor3 = BORDER end
        if b.label then b.label.TextColor3 = TEXT end
    end

    -- Dropdowns
    for _, d in ipairs(ThemedElements.dropdowns) do
        if d.stroke then d.stroke.Color = BORDER end
        if d.bar then d.bar.BackgroundColor3 = BORDER end
        if d.valueTxt then d.valueTxt.TextColor3 = TEXT_ON end
    end

    -- Sections
    for _, s in ipairs(ThemedElements.sections) do
        if s then s.TextColor3 = ACCENT_DIM end
    end

    -- Dropdown popup
    if DStroke then DStroke.Color = ACCENT_DIM end
    if DropdownScroll then DropdownScroll.ScrollBarImageColor3 = ACCENT end

    -- FOV circle + crosshair
    if FOVGuiStroke then FOVGuiStroke.Color = ACCENT end
    if FOVGuiFill then FOVGuiFill.BackgroundColor3 = ACCENT end
    if CrosshairHorizontal then CrosshairHorizontal.BackgroundColor3 = ACCENT end
    if CrosshairVertical then CrosshairVertical.BackgroundColor3 = ACCENT end

    -- Default ESP color (only if RGB ESP off)
    if not espRgbEnabled then
        espColor = ACCENT
        espRenderColor = ACCENT
        for _, data in pairs(espObjects) do
            pcall(function()
                data.box.Color = ACCENT
                if data.tracer then data.tracer.Color = ACCENT end
                if data.nameText then data.nameText.Color = ACCENT end
                for _, line in ipairs(data.skeleton) do line.Color = ACCENT end
            end)
        end
    end

    -- FOV color default
    fovColor = ACCENT
    if fovCircle then fovCircle.Color = ACCENT end
    if FOVGuiStroke then FOVGuiStroke.Color = ACCENT end
    if FOVGuiFill then FOVGuiFill.BackgroundColor3 = ACCENT end

    -- RGB gun theme
    if themeGunColorEnabled and not rgbGunEnabled then
        rgbCurrentColor = ACCENT
        for part in pairs(rgbTrackedParts) do
            pcall(function() rgbApply(part) end)
        end
    end
end

-- ============================================================
-- WINDOW BUILDER
-- ============================================================
local AllWindows = {}

local function CreateWindow(title, posX, posY)
    local Win = {}
    local WIDTH = 230

    local Main = Instance.new("Frame")
    Main.Name = title
    Main.Size = UDim2.new(0, WIDTH, 0, 0)
    Main.Position = UDim2.new(0, posX, 0, posY)
    Main.BackgroundColor3 = BG
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = BORDER
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 1)
    Glow.BackgroundColor3 = ACCENT
    Glow.BorderSizePixel = 0
    Glow.Parent = Main
    local GlowGrad = Instance.new("UIGradient")
    GlowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    GlowGrad.Parent = Glow

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = BG
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local TitleDot = Instance.new("Frame")
    TitleDot.Size = UDim2.new(0, 5, 0, 5)
    TitleDot.Position = UDim2.new(0, 11, 0.5, -2)
    TitleDot.BackgroundColor3 = ACCENT
    TitleDot.BorderSizePixel = 0
    TitleDot.Parent = Header
    Instance.new("UICorner", TitleDot).CornerRadius = UDim.new(1, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 22, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = TEXT
    TitleLbl.Font = Enum.Font.Code
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Header

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    MinimizeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    MinimizeBtn.BackgroundColor3 = BG_ITEM
    MinimizeBtn.Text = "–"
    MinimizeBtn.TextColor3 = TEXT_DIM
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 14
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = Header
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 3)

    MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = ACCENT}):Play()
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = TEXT_DIM}):Play()
    end)

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -16, 0, 1)
    Divider.Position = UDim2.new(0, 8, 0, 30)
    Divider.BackgroundColor3 = BORDER
    Divider.BorderSizePixel = 0
    Divider.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "Scroll"
    Scroll.Size = UDim2.new(1, 0, 0, 0)
    Scroll.Position = UDim2.new(0, 0, 0, 31)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = ACCENT_DIM
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Scroll.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 3)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 6)
    Pad.PaddingBottom = UDim.new(0, 8)
    Pad.PaddingLeft = UDim.new(0, 7)
    Pad.PaddingRight = UDim.new(0, 7)
    Pad.Parent = Scroll

    table.insert(ThemedElements.windows, {
        main = Main, mainStroke = MainStroke, glow = Glow,
        divider = Divider, titleDot = TitleDot, scroll = Scroll,
    })

    local function CreateSection(text)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 0, 16)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = "── " .. string.upper(text)
        Lbl.TextColor3 = ACCENT_DIM
        Lbl.Font = Enum.Font.Code
        Lbl.TextSize = 9
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Scroll
        table.insert(ThemedElements.sections, Lbl)
        return Lbl
    end

    local function CreateToggle(name, defaultState, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        local StatusTxt = Instance.new("TextLabel")
        StatusTxt.Size = UDim2.new(0, 30, 1, 0)
        StatusTxt.Position = UDim2.new(1, -36, 0, 0)
        StatusTxt.BackgroundTransparency = 1
        StatusTxt.Text = "OFF"
        StatusTxt.TextColor3 = TEXT_DIM
        StatusTxt.Font = Enum.Font.Code
        StatusTxt.TextSize = 10
        StatusTxt.TextXAlignment = Enum.TextXAlignment.Right
        StatusTxt.Parent = Btn

        local state = defaultState or false

        local function Render(animate)
            local tColor  = state and ACCENT or BORDER
            local tText   = state and TEXT_ON or TEXT
            local tStatus = state and "ON" or "OFF"
            local tStatC  = state and ACCENT or TEXT_DIM
            local tBg     = state and Color3.fromRGB(20, 10, 12) or BG_ITEM
            if animate then
                TweenService:Create(Bar,   TweenInfo.new(0.15), {BackgroundColor3 = tColor}):Play()
                TweenService:Create(Stroke,TweenInfo.new(0.15), {Color = tColor}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = tText}):Play()
                TweenService:Create(Btn,   TweenInfo.new(0.15), {BackgroundColor3 = tBg}):Play()
            else
                Bar.BackgroundColor3  = tColor
                Stroke.Color          = tColor
                Label.TextColor3      = tText
                Btn.BackgroundColor3  = tBg
            end
            StatusTxt.Text = tStatus
            StatusTxt.TextColor3 = tStatC
        end

        Render(false)

        Btn.MouseEnter:Connect(function()
            if not state then
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not state then
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
            end
        end)

        Btn.MouseButton1Click:Connect(function()
            state = not state
            Render(true)
            if callback then
                local ok, err = pcall(callback, state)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)

        table.insert(ThemedElements.toggles, {
            btn = Btn, stroke = Stroke, bar = Bar, label = Label, statusTxt = StatusTxt,
            render = function() Render(false) end,
        })

        return Btn
    end

    local function CreateButton(name, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = ACCENT}):Play()
            TweenService:Create(Bar, TweenInfo.new(0.1), {BackgroundColor3 = ACCENT}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = BORDER}):Play()
            TweenService:Create(Bar, TweenInfo.new(0.1), {BackgroundColor3 = BORDER}):Play()
        end)

        Btn.MouseButton1Click:Connect(function()
            Bar.BackgroundColor3 = TEXT_ON
            Label.TextColor3 = TEXT_ON
            task.delay(0.15, function()
                Bar.BackgroundColor3 = ACCENT
                Label.TextColor3 = TEXT
            end)
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)

        table.insert(ThemedElements.buttons, { btn = Btn, stroke = Stroke, bar = Bar, label = Label })

        return Btn
    end

    local function CreateDropdown(label, value, options, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(label)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        local ValueTxt = Instance.new("TextLabel")
        ValueTxt.Size = UDim2.new(0.4, 0, 1, 0)
        ValueTxt.Position = UDim2.new(0.55, 0, 0, 0)
        ValueTxt.BackgroundTransparency = 1
        ValueTxt.Text = tostring(value)
        ValueTxt.TextColor3 = TEXT_ON
        ValueTxt.Font = Enum.Font.Code
        ValueTxt.TextSize = 10
        ValueTxt.TextXAlignment = Enum.TextXAlignment.Right
        ValueTxt.Parent = Btn

        local currentValue = value

        local function updateValue(v)
            currentValue = v
            ValueTxt.Text = tostring(v)
            if callback then
                local ok, err = pcall(callback, v)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end

        local function openMenu()
            closeDropdown()
            activeDropdown = Btn
            DropdownLayer.Visible = true
            local absPos = Btn.AbsolutePosition
            local absSize = Btn.AbsoluteSize
            local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
            local menuWidth = math.max(absSize.X, 180)
            local rowHeight = 26
            local menuHeight = math.min(#options, 7) * rowHeight + 10
            local x = absPos.X
            if x + menuWidth > viewport.X - 8 then x = viewport.X - menuWidth - 8 end
            local y = absPos.Y + absSize.Y + 5
            if y + menuHeight > viewport.Y - 8 then y = absPos.Y - menuHeight - 5 end
            if y < 8 then y = 8 end
            DropdownMenu.Position = UDim2.fromOffset(x, y)
            DropdownMenu.Size = UDim2.fromOffset(menuWidth, menuHeight)
            DropdownMenu.Visible = true
            for i, opt in ipairs(options) do
                local o = Instance.new("TextButton")
                o.Size = UDim2.new(1, -2, 0, 23)
                o.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
                o.BorderSizePixel = 0
                o.AutoButtonColor = false
                o.Text = "  " .. tostring(opt)
                o.TextColor3 = (opt == currentValue) and ACCENT or TEXT
                o.Font = Enum.Font.Code
                o.TextSize = 10
                o.TextXAlignment = Enum.TextXAlignment.Left
                o.LayoutOrder = i
                o.ZIndex = 5003
                o.Parent = DropdownScroll
                Instance.new("UICorner", o).CornerRadius = UDim.new(0, 3)
                o.MouseEnter:Connect(function()
                    TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
                end)
                o.MouseLeave:Connect(function()
                    TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(16, 16, 20)}):Play()
                end)
                o.MouseButton1Click:Connect(function()
                    updateValue(opt)
                    closeDropdown()
                end)
            end
        end

        Btn.MouseButton1Click:Connect(openMenu)
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
        end)

        table.insert(ThemedElements.dropdowns, { btn = Btn, stroke = Stroke, bar = Bar, label = Label, valueTxt = ValueTxt })

        return {
            Button = Btn,
            SetValue = function(v) currentValue = v; ValueTxt.Text = tostring(v) end,
            GetValue = function() return currentValue end,
            SetVisible = function(v) Btn.Visible = v end
        }
    end

    do
        local dragging, startPos, startInput
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                startInput = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - startInput
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
                if activeDropdown then closeDropdown() end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local minimized = false
    local MAX_CONTENT_HEIGHT = 400

    local function UpdateSize()
        local targetHeight
        if minimized then
            targetHeight = 31
        else
            local contentH = Layout.AbsoluteContentSize.Y + 16
            if contentH > MAX_CONTENT_HEIGHT then contentH = MAX_CONTENT_HEIGHT end
            targetHeight = 31 + contentH
            Scroll.Size = UDim2.new(1, 0, 0, contentH)
            Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
        end
        TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, WIDTH, 0, targetHeight)}):Play()
    end

    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MinimizeBtn.Text = minimized and "+" or "–"
        UpdateSize()
    end)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not minimized then UpdateSize() end
    end)

    task.defer(function()
        task.wait(0.05)
        UpdateSize()
    end)

    Win.CreateSection = CreateSection
    Win.CreateToggle = CreateToggle
    Win.CreateButton = CreateButton
    Win.CreateDropdown = CreateDropdown
    Win.Main = Main
    table.insert(AllWindows, Main)
    return Win
end

-- ============================================================
-- DRAWINGS (FOV circle)
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = fovThickness
fovCircle.Transparency = 1
fovCircle.Color = fovColor
fovCircle.Visible = false
fovCircle.Filled = fovFilled
fovCircle.NumSides = fovSides
fovCircle.Radius = fovRadius
fovCircle.Position = Vector2.new(0, 0)

local function getMouseScreenPosition()
    local m = UserInputService:GetMouseLocation()
    return Vector2.new(m.X, m.Y)
end

-- ============================================================
-- HELPERS
-- ============================================================
local function getSharedRGBColor()
    local color = Color3.fromHSV((os.clock() * 0.25) % 1, 1, 1)
    rgbCurrentColor = color
    return color
end

local function isVisible(targetPart)
    if not wallCheckEnabled then return true end
    local char = LocalPlayer.Character
    if not char or not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function getClosestPlayer()
    local target = nil
    local bestDistance = fovRadius
    local mouseLoc = getMouseScreenPosition()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                local root = character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and root then
                    local allowedTeam = (player.Team ~= LocalPlayer.Team) or player.Team == nil or espShowTeam
                    if allowedTeam then
                        local part = character:FindFirstChild(aimPart) or root
                        local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dx = mouseLoc.X - screenPos.X
                            local dy = mouseLoc.Y - screenPos.Y
                            local d2 = dx * dx + dy * dy
                            local visible = (not wallCheckEnabled) or isVisible(part)
                            if visible and d2 < bestDistance * bestDistance then
                                bestDistance = math.sqrt(d2)
                                target = part
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

local function getTriggerTarget()
    if not triggerBotEnabled then return nil end
    local character = LocalPlayer.Character
    if not character then return nil end
    local mousePosition = getMouseScreenPosition()
    local function allowed(targetPlayer, model)
        if not targetPlayer or targetPlayer == LocalPlayer then return false end
        local hum = model and model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local sameTeam = targetPlayer.Team ~= nil and targetPlayer.Team == LocalPlayer.Team
        if sameTeam and not espShowTeam then return false end
        return true
    end
    local ray = Camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = true
    local result = workspace:Raycast(ray.Origin, ray.Direction * 4096, params)
    if result and result.Instance then
        local model = result.Instance:FindAncestorOfClass("Model")
        local targetPlayer = model and Players:GetPlayerFromCharacter(model)
        if allowed(targetPlayer, model) then
            if not wallCheckEnabled or isVisible(result.Instance) then
                return targetPlayer, result.Instance
            end
        end
    end
    return nil
end

local remoteCache = {}

local function findFireRemote()
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildWhichIsA("Tool")
        if tool then
            if remoteCache[tool] and remoteCache[tool].Parent then
                return remoteCache[tool]
            end
            for _, child in ipairs(tool:GetChildren()) do
                if child:IsA("RemoteEvent") then
                    remoteCache[tool] = child
                    return child
                end
            end
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("RemoteEvent") then
                    remoteCache[tool] = child
                    return child
                end
            end
        end
    end

    local candidates = {
        "FireWeapon", "FireGun", "Shoot", "Fire", "GunFire",
        "WeaponFire", "FireServer", "HandleFire", "Attack"
    }
    for _, name in ipairs(candidates) do
        local found = ReplicatedStorage:FindFirstChild(name, true)
        if found and found:IsA("RemoteEvent") then
            return found
        end
    end
    return nil
end

local function triggerShoot()
    if not triggerBotEnabled then return end
    local currentTime = os.clock()
    if currentTime - lastTriggerTime < triggerDelay then return end

    local targetPlayer, targetPart = getTriggerTarget()
    if not targetPlayer or not targetPart then return end

    local character = LocalPlayer.Character
    if not character then return end

    lastTriggerTime = currentTime

    local remote = findFireRemote()
    if remote then
        local originCF = Camera.CFrame
        pcall(function() remote:FireServer(originCF, targetPart.Position) end)
        pcall(function() remote:FireServer(originCF) end)
        pcall(function() remote:FireServer(targetPart) end)
    end

    local mouse = getMouseScreenPosition()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
    end)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
    end)
end

-- ============================================================
-- ESP
-- ============================================================
local function createESP(v)
    if v == LocalPlayer then return end
    if espObjects[v] then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = espSize
    box.Transparency = 1
    box.Filled = false

    local skeleton = {}
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = espColor
    tracer.Thickness = 1
    tracer.Transparency = 1

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = espColor
    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameText.Text = ""

    for _ = 1, 20 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espColor
        line.Thickness = espSize
        line.Transparency = 1
        table.insert(skeleton, line)
    end
    espObjects[v] = {box = box, skeleton = skeleton, tracer = tracer, nameText = nameText}
end

local function removeESP(v)
    local data = espObjects[v]
    if data then
        pcall(function() data.box:Remove() end)
        pcall(function() data.tracer:Remove() end)
        pcall(function() data.nameText:Remove() end)
        for _, line in ipairs(data.skeleton) do
            pcall(function() line:Remove() end)
        end
        espObjects[v] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do createESP(player) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

local function setSkeletonVisible(data, visible)
    for _, line in ipairs(data.skeleton) do
        line.Visible = visible
    end
end

local function drawSkeleton(data, character)
    if not character or not character.Parent then return end

    local needRebuild = false
    if data.skeletonCharacter ~= character or not data.skeletonParts or #data.skeletonParts == 0 then
        needRebuild = true
    else
        for _, pair in ipairs(data.skeletonParts) do
            local a, b = pair[1], pair[2]
            if not a or not b or not a:IsDescendantOf(character) or not b:IsDescendantOf(character) then
                needRebuild = true
                break
            end
        end
    end

    if needRebuild then
        data.skeletonCharacter = character
        data.skeletonParts = {}
        local used = {}

        local function addPair(a, b)
            if not a or not b then return end
            if a == b then return end
            if not a:IsA("BasePart") or not b:IsA("BasePart") then return end
            if a.Name == "HumanoidRootPart" or b.Name == "HumanoidRootPart" then return end
            local key = tostring(a) .. "|" .. tostring(b)
            local keyRev = tostring(b) .. "|" .. tostring(a)
            if used[key] or used[keyRev] then return end
            used[key] = true
            used[keyRev] = true
            data.skeletonParts[#data.skeletonParts + 1] = {a, b}
        end

        local hum = character:FindFirstChildOfClass("Humanoid")
        local pairsList
        if hum and hum.RigType == Enum.HumanoidRigType.R6 then
            pairsList = {
                {"Head", "Torso"},
                {"Torso", "Left Arm"},
                {"Torso", "Right Arm"},
                {"Torso", "Left Leg"},
                {"Torso", "Right Leg"}
            }
        else
            pairsList = {
                {"Head", "UpperTorso"},
                {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"LeftLowerArm", "LeftHand"},
                {"UpperTorso", "RightUpperArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"RightLowerArm", "RightHand"},
                {"LowerTorso", "LeftUpperLeg"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"LeftLowerLeg", "LeftFoot"},
                {"LowerTorso", "RightUpperLeg"},
                {"RightUpperLeg", "RightLowerLeg"},
                {"RightLowerLeg", "RightFoot"}
            }
        end
        for _, pair in ipairs(pairsList) do
            addPair(character:FindFirstChild(pair[1]), character:FindFirstChild(pair[2]))
        end

        for _, joint in ipairs(character:GetDescendants()) do
            if joint:IsA("Motor6D") then
                addPair(joint.Part0, joint.Part1)
            end
        end
    end

    local needed = #data.skeletonParts
    while #data.skeleton < needed do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espRenderColor
        line.Thickness = espSize
        line.Transparency = 1
        data.skeleton[#data.skeleton + 1] = line
    end

    local lineIndex = 0
    for _, pair in ipairs(data.skeletonParts) do
        local a, b = pair[1], pair[2]
        if a and b and a.Parent and b.Parent then
            lineIndex += 1
            local pa, oa = Camera:WorldToViewportPoint(a.Position)
            local pb, ob = Camera:WorldToViewportPoint(b.Position)
            local line = data.skeleton[lineIndex]
            if line then
                line.From = Vector2.new(pa.X, pa.Y)
                line.To = Vector2.new(pb.X, pb.Y)
                line.Color = espRenderColor
                line.Thickness = espSize
                line.Visible = pa.Z > 0 and pb.Z > 0 and (oa or ob)
            end
        end
    end
    for i = lineIndex + 1, #data.skeleton do
        data.skeleton[i].Visible = false
    end
end

-- ============================================================
-- MOVEMENT
-- ============================================================
local function enableNoclip(character)
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    table.clear(savedCollision)
    noclipConnection = RunService.Stepped:Connect(function()
        if not flyEnabled or not character or not character.Parent then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if savedCollision[part] == nil then savedCollision[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip(character)
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if character then
        for part, wasCollidable in pairs(savedCollision) do
            if part and part.Parent then part.CanCollide = wasCollidable end
        end
    end
    table.clear(savedCollision)
end

-- ============================================================
-- GUN MODS
-- ============================================================
local function rgbGetArms()
    local camera = workspace.CurrentCamera
    return camera and camera:FindFirstChild("Arms") or nil
end

local rgbExcludedNames = {
    LeftArm=true, RightArm=true, ["Left Arm"]=true, ["Right Arm"]=true,
    LeftUpperArm=true, RightUpperArm=true, LeftLowerArm=true, RightLowerArm=true,
    LeftHand=true, RightHand=true, UpperTorso=true, LowerTorso=true, Torso=true,
    HumanoidRootPart=true, Head=true, LeftFoot=true, RightFoot=true,
    LeftUpperLeg=true, RightUpperLeg=true, LeftLowerLeg=true, RightLowerLeg=true,
    LeftLeg=true, RightLeg=true
}

local function rgbInsideCSSArms(part, arms)
    local current = part.Parent
    while current and current ~= arms do
        if current.Name == "CSSArms" then return true end
        current = current.Parent
    end
    return false
end

local function rgbShouldExclude(part, arms)
    if not part or not part:IsA("BasePart") or not arms or not part:IsDescendantOf(arms) then return true end
    if part.Name == "CSSArms" or rgbInsideCSSArms(part, arms) then return true end
    return rgbExcludedNames[part.Name] == true
end

local function rgbGetWeaponParts()
    local arms = rgbGetArms()
    local parts = {}
    if not arms then return parts end
    local function scan(container)
        for _, child in ipairs(container:GetChildren()) do
            if child.Name ~= "CSSArms" then
                if child:IsA("BasePart") and not rgbShouldExclude(child, arms) then
                    table.insert(parts, child)
                end
                if #child:GetChildren() > 0 then scan(child) end
            end
        end
    end
    scan(arms)
    return parts
end

local function rgbApply(part)
    if not part or not part.Parent then return end
    local color = rgbGunEnabled and rgbCurrentColor or ACCENT
    pcall(function()
        part.Material = Enum.Material.ForceField
        part.Color = color
    end)
    if part:IsA("MeshPart") then
        pcall(function() part.VertexColor = Vector3.new(color.R, color.G, color.B) end)
    end
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("SpecialMesh") then
            pcall(function() child.VertexColor = Vector3.new(color.R, color.G, color.B) end)
        elseif child:IsA("Texture") or child:IsA("Decal") then
            pcall(function() child.Color3 = color end)
        elseif child:IsA("SurfaceAppearance") then
            pcall(function() child.Color = color end)
        end
    end
end

local function rgbTrackPart(part)
    local arms = rgbGetArms()
    if not arms or rgbShouldExclude(part, arms) or rgbTrackedParts[part] then return end
    local meshVertexColor = nil
    if part:IsA("MeshPart") then
        pcall(function() meshVertexColor = part.VertexColor end)
    end
    local specialMeshColors, textureColors, surfaceColors = {}, {}, {}
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("SpecialMesh") then
            pcall(function() specialMeshColors[child] = child.VertexColor end)
        elseif child:IsA("Texture") or child:IsA("Decal") then
            pcall(function() textureColors[child] = child.Color3 end)
        elseif child:IsA("SurfaceAppearance") then
            pcall(function() surfaceColors[child] = child.Color end)
        end
    end
    rgbTrackedParts[part] = true
    rgbOriginalProperties[part] = {
        Color=part.Color, Material=part.Material, Transparency=part.Transparency,
        Reflectance=part.Reflectance, MeshVertexColor=meshVertexColor,
        SpecialMeshColors=specialMeshColors, TextureColors=textureColors, SurfaceColors=surfaceColors
    }
    rgbApply(part)
end

local function rgbTrackAll()
    for _, part in ipairs(rgbGetWeaponParts()) do rgbTrackPart(part) end
end

local function rgbRestore()
    for part, props in pairs(rgbOriginalProperties) do
        if part and part.Parent then
            pcall(function()
                part.Color = props.Color
                part.Material = props.Material
                part.Transparency = props.Transparency
                part.Reflectance = props.Reflectance
            end)
            if part:IsA("MeshPart") and props.MeshVertexColor then
                pcall(function() part.VertexColor = props.MeshVertexColor end)
            end
            for mesh, color in pairs(props.SpecialMeshColors) do
                if mesh and mesh.Parent then pcall(function() mesh.VertexColor = color end) end
            end
            for texture, color in pairs(props.TextureColors) do
                if texture and texture.Parent then pcall(function() texture.Color3 = color end) end
            end
            for surface, color in pairs(props.SurfaceColors) do
                if surface and surface.Parent then pcall(function() surface.Color = color end) end
            end
        end
    end
    table.clear(rgbTrackedParts)
    table.clear(rgbOriginalProperties)
end

local function rgbDisconnectArms()
    for _, connection in ipairs(rgbArmsConnections) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
    table.clear(rgbArmsConnections)
end

local function rgbStop()
    if rgbRainbowConnection then
        rgbRainbowConnection:Disconnect()
        rgbRainbowConnection = nil
    end
    rgbDisconnectArms()
    rgbRestore()
end

local function rgbStartForArms(arms)
    if not (rgbGunEnabled or themeGunColorEnabled) or not arms then return end
    rgbDisconnectArms()
    rgbRestore()
    rgbTrackAll()
    table.insert(rgbArmsConnections, arms.DescendantAdded:Connect(function(descendant)
        if (rgbGunEnabled or themeGunColorEnabled) and descendant:IsA("BasePart") and rgbGetArms() == arms then
            rgbTrackPart(descendant)
        end
    end))
    table.insert(rgbArmsConnections, arms.AncestryChanged:Connect(function(_, parent)
        if not parent then
            rgbDisconnectArms()
            rgbRestore()
        end
    end))
end

local function rgbStart()
    if not (rgbGunEnabled or themeGunColorEnabled) then return end
    if rgbRainbowConnection then
        rgbRainbowConnection:Disconnect()
        rgbRainbowConnection = nil
    end
    if rgbGunEnabled then
        rgbRainbowConnection = RunService.RenderStepped:Connect(function()
            if not rgbGunEnabled then return end
            local arms = rgbGetArms()
            if not arms then return end
            if next(rgbTrackedParts) == nil then rgbStartForArms(arms) end
            getSharedRGBColor()
            for part in pairs(rgbTrackedParts) do
                if part and part.Parent then
                    rgbApply(part)
                else
                    rgbTrackedParts[part] = nil
                    rgbOriginalProperties[part] = nil
                end
            end
        end)
    end
    local arms = rgbGetArms()
    if arms then rgbStartForArms(arms) end
end

local function rgbWatchCamera()
    if rgbCameraConnection then
        rgbCameraConnection:Disconnect()
        rgbCameraConnection = nil
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local function onArms(child)
        if child.Name == "Arms" and (rgbGunEnabled or themeGunColorEnabled) then
            rgbStartForArms(child)
        end
    end
    rgbCameraConnection = camera.ChildAdded:Connect(onArms)
    local arms = camera:FindFirstChild("Arms")
    if arms and (rgbGunEnabled or themeGunColorEnabled) then rgbStartForArms(arms) end
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or Camera
    rgbWatchCamera()
end)

local function refreshGunAppearance()
    if rgbGunEnabled or themeGunColorEnabled then
        rgbStart()
        rgbWatchCamera()
        local arms = rgbGetArms()
        if arms then
            rgbStartForArms(arms)
            if not rgbGunEnabled then
                for part in pairs(rgbTrackedParts) do rgbApply(part) end
            end
        end
    else
        rgbStop()
    end
end

local function restoreGunModValues()
    for valueObject, originalValue in pairs(originalWeaponValues) do
        if valueObject and valueObject.Parent then
            pcall(function() valueObject.Value = originalValue end)
        end
    end
    table.clear(originalWeaponValues)
end

local function cacheGunModObjects()
    table.clear(cachedWeaponValues)
    if rapidFireEnabled or noRecoilEnabled then
        local weapons = ReplicatedStorage:FindFirstChild("Weapons")
        if weapons then
            for _, valueObject in ipairs(weapons:GetDescendants()) do
                if valueObject:IsA("ValueBase") then
                    if (rapidFireEnabled and (valueObject.Name == "Auto" or valueObject.Name == "FireRate"))
                        or (noRecoilEnabled and (valueObject.Name == "RecoilControl" or valueObject.Name == "MaxSpread")) then
                        table.insert(cachedWeaponValues, valueObject)
                    end
                end
            end
        end
    end
    gunModsDirty = false
end

local function applyGunMods()
    if gunModsDirty then cacheGunModObjects() end
    for _, valueObject in ipairs(cachedWeaponValues) do
        if valueObject and valueObject.Parent then
            if rapidFireEnabled and valueObject.Name == "Auto" then
                if originalWeaponValues[valueObject] == nil then originalWeaponValues[valueObject] = valueObject.Value end
                pcall(function() valueObject.Value = true end)
            elseif rapidFireEnabled and valueObject.Name == "FireRate" then
                if originalWeaponValues[valueObject] == nil then originalWeaponValues[valueObject] = valueObject.Value end
                pcall(function() valueObject.Value = 0.02 end)
            elseif noRecoilEnabled and valueObject.Name == "RecoilControl" then
                if originalWeaponValues[valueObject] == nil then originalWeaponValues[valueObject] = valueObject.Value end
                pcall(function() valueObject.Value = 0 end)
            elseif noRecoilEnabled and valueObject.Name == "MaxSpread" then
                if originalWeaponValues[valueObject] == nil then originalWeaponValues[valueObject] = valueObject.Value end
                pcall(function() valueObject.Value = 0 end)
            end
        end
    end
end

local function startGunMods()
    if gunModConnection then gunModConnection:Disconnect(); gunModConnection = nil end
    gunModConnection = RunService.Heartbeat:Connect(function()
        if not (rapidFireEnabled or noRecoilEnabled) then return end
        local now = os.clock()
        if (now - lastGunModRefresh) >= GUN_MOD_REFRESH_INTERVAL then
            lastGunModRefresh = now
            applyGunMods()
        end
    end)
    gunModsDirty = true
    applyGunMods()
end

local function stopGunMods()
    if gunModConnection then gunModConnection:Disconnect(); gunModConnection = nil end
    restoreGunModValues()
    table.clear(cachedWeaponValues)
    gunModsDirty = true
end

local function refreshGunMods()
    if rapidFireEnabled or noRecoilEnabled then
        startGunMods()
    elseif gunModConnection then
        stopGunMods()
    else
        restoreGunModValues()
    end
end

-- ============================================================
-- FOV GUI CIRCLE + CROSSHAIR
-- ============================================================
local FOVScreenGui = Instance.new("ScreenGui")
FOVScreenGui.Name = "BlackoutFOV"
FOVScreenGui.ResetOnSpawn = false
FOVScreenGui.DisplayOrder = 2147483647
FOVScreenGui.IgnoreGuiInset = true
FOVScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
FOVScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVGuiCircle = Instance.new("Frame")
FOVGuiCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGuiCircle.BackgroundTransparency = 1
FOVGuiCircle.BorderSizePixel = 0
FOVGuiCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
FOVGuiCircle.Position = UDim2.fromOffset(0, 0)
FOVGuiCircle.Visible = true
FOVGuiCircle.Parent = FOVScreenGui
Instance.new("UICorner", FOVGuiCircle).CornerRadius = UDim.new(1, 0)

local FOVGuiStroke = Instance.new("UIStroke")
FOVGuiStroke.Color = fovColor
FOVGuiStroke.Thickness = fovThickness
FOVGuiStroke.Parent = FOVGuiCircle

local FOVGuiFill = Instance.new("Frame")
FOVGuiFill.Size = UDim2.fromScale(1, 1)
FOVGuiFill.BackgroundColor3 = fovColor
FOVGuiFill.BackgroundTransparency = 1
FOVGuiFill.BorderSizePixel = 0
FOVGuiFill.Parent = FOVGuiCircle
Instance.new("UICorner", FOVGuiFill).CornerRadius = UDim.new(1, 0)

local CrosshairRoot = Instance.new("Frame")
CrosshairRoot.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairRoot.Position = UDim2.fromScale(0.5, 0.5)
CrosshairRoot.Size = UDim2.fromOffset(1, 1)
CrosshairRoot.BackgroundTransparency = 1
CrosshairRoot.BorderSizePixel = 0
CrosshairRoot.ZIndex = 950
CrosshairRoot.Visible = false
CrosshairRoot.Parent = FOVScreenGui

local CrosshairHorizontal = Instance.new("Frame")
CrosshairHorizontal.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairHorizontal.Position = UDim2.fromScale(0.5, 0.5)
CrosshairHorizontal.Size = UDim2.fromOffset(crosshairSize * 2 + 4, crosshairThickness)
CrosshairHorizontal.BackgroundColor3 = ACCENT
CrosshairHorizontal.BorderSizePixel = 0
CrosshairHorizontal.ZIndex = 951
CrosshairHorizontal.Parent = CrosshairRoot
Instance.new("UICorner", CrosshairHorizontal).CornerRadius = UDim.new(0, 2)

local CrosshairVertical = Instance.new("Frame")
CrosshairVertical.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairVertical.Position = UDim2.fromScale(0.5, 0.5)
CrosshairVertical.Size = UDim2.fromOffset(crosshairThickness, crosshairSize * 2 + 4)
CrosshairVertical.BackgroundColor3 = ACCENT
CrosshairVertical.BorderSizePixel = 0
CrosshairVertical.ZIndex = 951
CrosshairVertical.Parent = CrosshairRoot
Instance.new("UICorner", CrosshairVertical).CornerRadius = UDim.new(0, 2)

-- ============================================================
-- RUN LOADER, THEN BUILD PANELS
-- ============================================================
RunLoadingSequence()

-- ============================================================
-- PANEL 1 — VISUALS
-- ============================================================
local VisualsPanel = CreateWindow("BLACKOUT // VISUALS", 20, 20)

VisualsPanel.CreateSection("esp")
VisualsPanel.CreateToggle("ESP", false, function(s)
    espEnabled = s
end)
VisualsPanel.CreateToggle("NAME ESP", false, function(s)
    nameESPEnabled = s
end)
VisualsPanel.CreateToggle("TRACERS", false, function(s)
    tracerEnabled = s
end)
VisualsPanel.CreateToggle("WALLCHECK", true, function(s)
    wallCheckEnabled = s
end)
VisualsPanel.CreateToggle("SHOW TEAM", false, function(s)
    espShowTeam = s
end)
VisualsPanel.CreateToggle("RGB ESP", false, function(s)
    espRgbEnabled = s
    if not s then espRenderColor = ACCENT end
end)

VisualsPanel.CreateSection("esp style")
VisualsPanel.CreateDropdown("ESP TYPE", "Box+Skeleton",
    {"Box", "Filled", "Skeleton", "Box+Skeleton"}, function(v)
    espType = v
end)
VisualsPanel.CreateDropdown("ESP COLOR", "RED",
    {"RED","BLACK","BLUE","WHITE","GREEN","PURPLE","YELLOW","CYAN"}, function(v)
    local colors = {
        RED=Color3.fromRGB(255,45,65), BLUE=Color3.fromRGB(65,130,255),
        WHITE=Color3.fromRGB(245,245,245), GREEN=Color3.fromRGB(65,220,125),
        PURPLE=Color3.fromRGB(170,80,255), YELLOW=Color3.fromRGB(245,205,55),
        CYAN=Color3.fromRGB(50,220,220), BLACK=Color3.fromRGB(0,0,0)
    }
    espColor = colors[v] or espColor
    if not espRgbEnabled then
        espRenderColor = espColor
        for _, data in pairs(espObjects) do
            pcall(function()
                data.box.Color = espColor
                if data.tracer then data.tracer.Color = espColor end
                if data.nameText then data.nameText.Color = espColor end
                for _, line in ipairs(data.skeleton) do line.Color = espColor end
            end)
        end
    end
end)
VisualsPanel.CreateDropdown("ESP THICKNESS", 2,
    {1,1.5,2,3,4,5,6}, function(v)
    espSize = tonumber(v) or espSize
    for _, data in pairs(espObjects) do
        pcall(function()
            data.box.Thickness = espSize
            for _, line in ipairs(data.skeleton) do line.Thickness = espSize end
        end)
    end
end)
VisualsPanel.CreateDropdown("ESP DISTANCE", 2000,
    {250,500,750,1000,1500,2000,3000,5000,10000}, function(v)
    espDistance = tonumber(v) or espDistance
end)

-- ============================================================
-- PANEL 2 — FOV
-- ============================================================
local FOVPanel = CreateWindow("BLACKOUT // FOV", 260, 20)

FOVPanel.CreateSection("fov circle")
FOVPanel.CreateToggle("FOV CIRCLE", true, function(s)
    fovEnabled = s
    FOVGuiCircle.Visible = s
end)
FOVPanel.CreateDropdown("FOV RADIUS", 125,
    {75,100,125,150,175,200,225,250}, function(v)
    fovRadius = math.clamp(tonumber(v) or 125, 1, 400)
    fovCircle.Radius = fovRadius
    FOVGuiCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
end)
FOVPanel.CreateDropdown("FOV COLOR", "RED",
    {"RED","BLACK","BLUE","WHITE","GREEN","PURPLE","YELLOW","CYAN"}, function(v)
    local colors = {
        RED=Color3.fromRGB(255,45,65), BLUE=Color3.fromRGB(65,130,255),
        WHITE=Color3.fromRGB(245,245,245), GREEN=Color3.fromRGB(65,220,125),
        PURPLE=Color3.fromRGB(170,80,255), YELLOW=Color3.fromRGB(245,205,55),
        CYAN=Color3.fromRGB(50,220,220), BLACK=Color3.fromRGB(0,0,0)
    }
    fovColor = colors[v] or fovColor
    fovCircle.Color = fovColor
    FOVGuiStroke.Color = fovColor
    FOVGuiFill.BackgroundColor3 = fovColor
end)
FOVPanel.CreateDropdown("FOV THICKNESS", 2,
    {1,2,3,4,5}, function(v)
    fovThickness = tonumber(v) or fovThickness
    fovCircle.Thickness = fovThickness
    FOVGuiStroke.Thickness = fovThickness
end)
FOVPanel.CreateDropdown("FOV SIDES", 64,
    {24,32,48,64,96,128}, function(v)
    fovSides = tonumber(v) or fovSides
    fovCircle.NumSides = fovSides
end)
FOVPanel.CreateDropdown("FOV FILL", "OFF",
    {"OFF","ON"}, function(v)
    fovFilled = (v == "ON")
    fovCircle.Filled = fovFilled
    FOVGuiFill.BackgroundTransparency = fovFilled and 0.85 or 1
end)

FOVPanel.CreateSection("crosshair")
FOVPanel.CreateToggle("CROSSHAIR", false, function(s)
    crosshairEnabled = s
    CrosshairRoot.Visible = s
end)
FOVPanel.CreateDropdown("CROSSHAIR SIZE", 8,
    {4,6,8,10,12,16}, function(v)
    crosshairSize = tonumber(v) or crosshairSize
    CrosshairHorizontal.Size = UDim2.fromOffset(crosshairSize * 2 + 4, crosshairThickness)
    CrosshairVertical.Size = UDim2.fromOffset(crosshairThickness, crosshairSize * 2 + 4)
end)

-- ============================================================
-- PANEL 3 — COMBAT
-- ============================================================
local CombatPanel = CreateWindow("BLACKOUT // COMBAT", 500, 20)

CombatPanel.CreateSection("aim")
CombatPanel.CreateToggle("AIMBOT", false, function(s)
    aimbotEnabled = s
    if not s then aiming = false end
end)
local AimKeyDD = CombatPanel.CreateDropdown("AIM KEY", "Right Click",
    {"Shift", "Left Alt", "Right Click"}, function(v)
    aimKey = v
    aiming = false
end)
AimKeyDD.SetVisible(false)

CombatPanel.CreateToggle("SILENT AIM", false, function(s)
    silentAimEnabled = s
end)
CombatPanel.CreateToggle("TRIGGERBOT", false, function(s)
    triggerBotEnabled = s
end)

CombatPanel.CreateSection("targeting")
CombatPanel.CreateDropdown("AIM PART", "Head",
    {"Head", "UpperTorso", "HumanoidRootPart"}, function(v)
    aimPart = v
end)
CombatPanel.CreateDropdown("SMOOTHING", 0.15,
    {0.05,0.10,0.15,0.20,0.30,0.50,0.75,1.00}, function(v)
    aimSmoothing = tonumber(v) or aimSmoothing
end)

-- ============================================================
-- PANEL 4 — GUN MODS
-- ============================================================
local GunModsPanel = CreateWindow("BLACKOUT // GUN MODS", 740, 20)

GunModsPanel.CreateSection("weapon appearance")
GunModsPanel.CreateToggle("RGB GUN MOD", false, function(s)
    rgbGunEnabled = s
    if s then rgbCurrentColor = getSharedRGBColor() end
    refreshGunAppearance()
end)
GunModsPanel.CreateToggle("THEME GUN COLOR", true, function(s)
    themeGunColorEnabled = s
    if s then rgbCurrentColor = ACCENT end
    refreshGunAppearance()
end)

GunModsPanel.CreateSection("combat mods")
GunModsPanel.CreateToggle("RAPID FIRE", false, function(s)
    rapidFireEnabled = s
    gunModsDirty = true
    refreshGunMods()
end)
GunModsPanel.CreateToggle("NO RECOIL", false, function(s)
    noRecoilEnabled = s
    gunModsDirty = true
    refreshGunMods()
end)

-- ============================================================
-- PANEL 5 — MOVEMENT (RISK)
-- ============================================================
local MovementPanel = CreateWindow("BLACKOUT // MOVEMENT (RISK)", 980, 20)

MovementPanel.CreateSection("movement")
MovementPanel.CreateToggle("SPEED HACK", false, function(s)
    speedHackEnabled = s
    if s then
        _G.WS = speedValue
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                hum.WalkSpeed = _G.WS
            end)
            hum.WalkSpeed = _G.WS
        end
    else
        _G.WS = 16
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)
MovementPanel.CreateDropdown("WALK SPEED", 100,
    {16,25,50,75,100,125,150,200}, function(v)
    speedValue = tonumber(v) or speedValue
    _G.WS = speedValue
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and speedHackEnabled then hum.WalkSpeed = speedValue end
end)

MovementPanel.CreateToggle("FLY", false, function(s)
    flyEnabled = s
    local char = LocalPlayer.Character
    if not char then return end
    if s then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            enableNoclip(char)
            flyAttachment = Instance.new("Attachment")
            flyAttachment.Name = "BlackoutFlyAttachment"
            flyAttachment.Parent = rootPart
            bodyVelocity = Instance.new("LinearVelocity")
            bodyVelocity.Attachment0 = flyAttachment
            bodyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
            bodyVelocity.MaxForce = math.huge
            bodyVelocity.VectorVelocity = Vector3.zero
            bodyVelocity.Parent = rootPart
            bodyGyro = Instance.new("AlignOrientation")
            bodyGyro.Attachment0 = flyAttachment
            bodyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
            bodyGyro.RigidityEnabled = true
            bodyGyro.MaxTorque = math.huge
            bodyGyro.CFrame = rootPart.CFrame
            bodyGyro.Parent = rootPart
        end
    else
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end
        disableNoclip(char)
    end
end)
MovementPanel.CreateDropdown("FLY SPEED", 50,
    {25,50,75,100,150,200}, function(v)
    flySpeed = tonumber(v) or flySpeed
end)

MovementPanel.CreateSection("misc")
MovementPanel.CreateToggle("ANTI-AIM", false, function(s)
    antiAimEnabled = s
end)

-- ============================================================
-- PANEL 6 — THEME
-- ============================================================
local ThemePanel = CreateWindow("BLACKOUT // THEME", 1220, 20)

ThemePanel.CreateSection("theme")
ThemePanel.CreateDropdown("THEME COLOR", "RED",
    {"RED", "PURPLE", "BLUE", "GREEN", "ORANGE", "PINK", "WHITE"}, function(v)
    ApplyTheme(v)
end)

-- Apply RED once everything exists so all elements are properly synced.
ApplyTheme("RED")

-- ============================================================
-- AIM INPUT
-- ============================================================
local function isAimInput(input)
    if aimKey == "Shift" then
        return input.KeyCode == Enum.KeyCode.LeftShift
    elseif aimKey == "Left Alt" then
        return input.KeyCode == Enum.KeyCode.LeftAlt
    elseif aimKey == "Right Click" then
        return input.UserInputType == Enum.UserInputType.MouseButton2
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isAimInput(input) and aimbotEnabled then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isAimInput(input) then
        aiming = false
    end
end)

-- ============================================================
-- TRIGGERBOT LOOP (own thread — never yields RenderStepped)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.05)
        if triggerBotEnabled then
            pcall(triggerShoot)
        end
    end
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if speedHackEnabled then
        _G.WS = speedValue
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                hum.WalkSpeed = _G.WS
            end)
            hum.WalkSpeed = _G.WS
        end
    end
    if flyEnabled then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            flyAttachment = Instance.new("Attachment")
            flyAttachment.Name = "BlackoutFlyAttachment"
            flyAttachment.Parent = rootPart
            bodyVelocity = Instance.new("LinearVelocity")
            bodyVelocity.Attachment0 = flyAttachment
            bodyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
            bodyVelocity.MaxForce = math.huge
            bodyVelocity.VectorVelocity = Vector3.zero
            bodyVelocity.Parent = rootPart
            bodyGyro = Instance.new("AlignOrientation")
            bodyGyro.Attachment0 = flyAttachment
            bodyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
            bodyGyro.RigidityEnabled = true
            bodyGyro.MaxTorque = math.huge
            bodyGyro.CFrame = rootPart.CFrame
            bodyGyro.Parent = rootPart
        end
    end
end)

-- ============================================================
-- FLY MOVEMENT LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not flyEnabled or not bodyVelocity then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += rootPart.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= rootPart.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= rootPart.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += rootPart.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move += Vector3.new(0, -1, 0) end
    if move.Magnitude > 0 then
        bodyVelocity.VectorVelocity = move.Unit * flySpeed
    else
        bodyVelocity.VectorVelocity = Vector3.zero
    end
    if bodyGyro then
        local look = Camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0 then
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLook.Unit)
        end
    end
end)

-- ============================================================
-- MAIN RENDER LOOP  (MUST NOT YIELD)
-- ============================================================
RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize
    local mousePosition = getMouseScreenPosition()

    local sharedRenderColor = espRgbEnabled and getSharedRGBColor() or nil
    local fovRenderColor = sharedRenderColor or fovColor

    fovCircle.Position = mousePosition
    fovCircle.Radius = math.max(1, fovRadius)
    fovCircle.Color = fovRenderColor
    fovCircle.Thickness = fovThickness
    fovCircle.NumSides = fovSides
    fovCircle.Filled = fovFilled
    fovCircle.Visible = false

    FOVGuiCircle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
    FOVGuiCircle.Size = UDim2.fromOffset(math.max(1, fovRadius) * 2, math.max(1, fovRadius) * 2)
    FOVGuiCircle.Visible = fovEnabled
    FOVGuiStroke.Color = fovRenderColor
    FOVGuiStroke.Thickness = fovThickness
    FOVGuiFill.BackgroundColor3 = fovRenderColor
    FOVGuiFill.BackgroundTransparency = fovFilled and 0.85 or 1

    local target = nil
    if aiming and (aimbotEnabled or silentAimEnabled) then
        target = getClosestPlayer()
    end

    if aiming and target then
        if aimbotEnabled then
            local desired = CFrame.new(Camera.CFrame.Position, target.Position)
            local alpha = math.clamp(aimSmoothing, 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
        end
        if silentAimEnabled and not aimbotEnabled then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local dx = (targetPos.X - mousePosition.X) * math.clamp(aimSmoothing, 0.01, 1)
            local dy = (targetPos.Y - mousePosition.Y) * math.clamp(aimSmoothing, 0.01, 1)
            if mousemoverel then
                pcall(function() mousemoverel(dx, dy) end)
            end
        end
    end

    espRenderColor = sharedRenderColor or espColor

    for p, data in pairs(espObjects) do
        local box = data.box
        local tracer = data.tracer
        local nameText = data.nameText

        box.Color = espRenderColor
        tracer.Color = espRenderColor
        nameText.Color = espRenderColor
        tracer.Visible = false
        nameText.Visible = false

        local showSkeleton = espType == "Skeleton" or espType == "Box+Skeleton"
        if not showSkeleton then
            setSkeletonVisible(data, false)
        end

        if espEnabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 and (espShowTeam or p.Team ~= LocalPlayer.Team or p.Team == nil) then
            local character = p.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            if distance <= espDistance then
                local head = character:FindFirstChild("Head") or hrp
                local headPoint, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                local rootPoint, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)

                if tracerEnabled and rootOnScreen and rootPoint.Z > 0 then
                    tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
                    tracer.To = Vector2.new(rootPoint.X, rootPoint.Y)
                    tracer.Color = espRenderColor
                    tracer.Thickness = 1
                    tracer.Visible = true
                end

                if nameESPEnabled and headOnScreen and headPoint.Z > 0 then
                    nameText.Text = p.DisplayName or p.Name
                    nameText.Position = Vector2.new(headPoint.X, headPoint.Y - 18)
                    nameText.Color = espRenderColor
                    nameText.Size = 13
                    nameText.Center = true
                    nameText.Outline = true
                    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
                    nameText.Visible = true
                end

                local showBox = espType == "Box" or espType == "Filled" or espType == "Box+Skeleton"

                box.Visible = false

                if showSkeleton then
                    drawSkeleton(data, character)
                end

                if showBox then
                    local headPart = character:FindFirstChild("Head")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local cf, size

                    if headPart and rootPart then
                        local headPos = headPart.Position
                        local rootPos = rootPart.Position
                        local topY = headPos.Y + 0.5
                        local bottomY = rootPos.Y - 2.5
                        local height = topY - bottomY
                        local centerY = (topY + bottomY) / 2
                        local center = Vector3.new(
                            (headPos.X + rootPos.X) / 2,
                            centerY,
                            (headPos.Z + rootPos.Z) / 2
                        )
                        cf = CFrame.new(center)
                        size = Vector3.new(3.5, height, 2.5)
                    else
                        cf, size = character:GetBoundingBox()
                    end

                    local corners = {
                        Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
                        Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
                        Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
                        Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
                        Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
                        Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
                        Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
                        Vector3.new( size.X/2,  size.Y/2,  size.Z/2)
                    }

                    local minX, minY = math.huge, math.huge
                    local maxX, maxY = -math.huge, -math.huge
                    local anyOnScreen = false
                    for _, corner in ipairs(corners) do
                        local point, visible = Camera:WorldToViewportPoint(cf:PointToWorldSpace(corner))
                        if point.Z > 0 then
                            anyOnScreen = anyOnScreen or visible
                            minX = math.min(minX, point.X)
                            minY = math.min(minY, point.Y)
                            maxX = math.max(maxX, point.X)
                            maxY = math.max(maxY, point.Y)
                        end
                    end
                    if anyOnScreen and minX < maxX and minY < maxY then
                        local padX, padY = 2, 3
                        local width2, height2 = (maxX-minX)+padX*2, (maxY-minY)+padY*2
                        box.Size = Vector2.new(width2, height2)
                        box.Position = Vector2.new(minX-padX, minY-padY)
                        box.Visible = true
                        box.Color = espRenderColor
                        box.Thickness = espSize
                        box.Filled = (espType == "Filled")
                        box.Transparency = (espType == "Filled") and 0.2 or 1
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            else
                box.Visible = false
                setSkeletonVisible(data, false)
            end
        else
            box.Visible = false
            setSkeletonVisible(data, false)
        end
    end
end)

-- ============================================================
-- OPEN BY DEFAULT + KEYBIND
-- ============================================================
ScreenGui.Enabled = true

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ============================================================
-- INIT GUN MODS
-- ============================================================
if themeGunColorEnabled then
    rgbCurrentColor = ACCENT
    refreshGunAppearance()
end

print("[Blackout] Loaded. RightShift = toggle GUI")