--[[
╔══════════════════════════════════════════════════════════════╗
║                    NEXUS UI  v1.0                            ║
║              Inspired by Rayfield Interface Suite            ║
║                                                              ║
║  Features:                                                   ║
║  · CreateWindow  — loading screen, drag, minimize, close     ║
║  · CreateTab     — icon support, tab switching               ║
║  · CreateSection — visual dividers                           ║
║  · CreateButton  — ripple, hover, error state               ║
║  · CreateToggle  — animated switch                           ║
║  · CreateSlider  — smooth drag with tooltip                  ║
║  · CreateInput   — focus states, live update                 ║
║  · CreateDropdown — animated open/close                      ║
║  · CreateKeybind — press to bind                             ║
║  · CreateColorPicker — HSV + Hex                            ║
║  · CreateLabel   — icon + text                               ║
║  · CreateParagraph — title + body                            ║
║  · Notify        — queue, types, progress bar               ║
║  · Themes        — Default, Ocean, Amethyst, Crimson,        ║
║                    Amber, Midnight, Sakura, Neon             ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local Debris           = game:GetService("Debris")

local LP = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  ICONS (SVG-encoded as Roblox-compatible image data URLs)
--  Since Roblox uses rbxassetid, we use unicode symbols as icons
--  These map to clean icon names for use in the library
-- ══════════════════════════════════════════════════════════════
local Icons = {
    -- Navigation & UI
    home          = "🏠",
    settings      = "⚙",
    search        = "🔍",
    close         = "✕",
    minimize      = "─",
    maximize      = "□",
    pin           = "📌",
    menu          = "☰",
    back          = "←",
    forward       = "→",
    up            = "↑",
    down          = "↓",
    chevronDown   = "▾",
    chevronUp     = "▴",
    chevronRight  = "▸",
    -- Actions
    play          = "▶",
    pause         = "⏸",
    stop          = "⏹",
    refresh       = "↺",
    save          = "💾",
    copy          = "📋",
    edit          = "✏",
    delete        = "🗑",
    add           = "+",
    remove        = "−",
    check         = "✓",
    cross         = "✕",
    -- Status
    info          = "ℹ",
    warning       = "⚠",
    error         = "⊘",
    success       = "✓",
    star          = "★",
    heart         = "♥",
    lock          = "🔒",
    unlock        = "🔓",
    eye           = "👁",
    eyeOff        = "👁‍🗨",
    -- Categories
    game          = "🎮",
    player        = "👤",
    world         = "🌐",
    shield        = "🛡",
    sword         = "⚔",
    magic         = "✨",
    fire          = "🔥",
    lightning     = "⚡",
    target        = "🎯",
    key           = "🔑",
    -- Misc
    dot           = "•",
    diamond       = "◆",
    circle        = "○",
    square        = "□",
    triangle      = "△",
}

-- ══════════════════════════════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════════════════════════════
local THEMES = {
    Default = {
        Background          = Color3.fromRGB(25, 25, 25),
        Topbar              = Color3.fromRGB(34, 34, 34),
        TabBackground       = Color3.fromRGB(30, 30, 30),
        TabSelected         = Color3.fromRGB(50, 138, 220),
        TabText             = Color3.fromRGB(170, 170, 170),
        TabTextSelected     = Color3.fromRGB(255, 255, 255),
        ElementBackground   = Color3.fromRGB(35, 35, 35),
        ElementHover        = Color3.fromRGB(42, 42, 42),
        ElementStroke       = Color3.fromRGB(50, 50, 50),
        TextPrimary         = Color3.fromRGB(240, 240, 240),
        TextSecondary       = Color3.fromRGB(160, 160, 160),
        TextMuted           = Color3.fromRGB(100, 100, 100),
        Accent              = Color3.fromRGB(50, 138, 220),
        AccentDark          = Color3.fromRGB(30, 100, 170),
        AccentLight         = Color3.fromRGB(90, 170, 255),
        ToggleOn            = Color3.fromRGB(0, 146, 214),
        ToggleOff           = Color3.fromRGB(80, 80, 80),
        SliderFill          = Color3.fromRGB(50, 138, 220),
        InputBackground     = Color3.fromRGB(30, 30, 30),
        InputStroke         = Color3.fromRGB(65, 65, 65),
        NotifyBackground    = Color3.fromRGB(28, 28, 28),
        Success             = Color3.fromRGB(46, 204, 113),
        Warning             = Color3.fromRGB(241, 196, 15),
        Error               = Color3.fromRGB(231, 76, 60),
        Shadow              = Color3.fromRGB(10, 10, 10),
        Divider             = Color3.fromRGB(45, 45, 45),
    },
    Ocean = {
        Background          = Color3.fromRGB(15, 28, 38),
        Topbar              = Color3.fromRGB(20, 38, 52),
        TabBackground       = Color3.fromRGB(18, 34, 46),
        TabSelected         = Color3.fromRGB(0, 150, 180),
        TabText             = Color3.fromRGB(120, 160, 180),
        TabTextSelected     = Color3.fromRGB(220, 245, 255),
        ElementBackground   = Color3.fromRGB(22, 42, 58),
        ElementHover        = Color3.fromRGB(28, 52, 70),
        ElementStroke       = Color3.fromRGB(35, 65, 88),
        TextPrimary         = Color3.fromRGB(220, 240, 255),
        TextSecondary       = Color3.fromRGB(120, 165, 195),
        TextMuted           = Color3.fromRGB(70, 110, 140),
        Accent              = Color3.fromRGB(0, 180, 220),
        AccentDark          = Color3.fromRGB(0, 120, 160),
        AccentLight         = Color3.fromRGB(80, 220, 255),
        ToggleOn            = Color3.fromRGB(0, 180, 220),
        ToggleOff           = Color3.fromRGB(40, 75, 100),
        SliderFill          = Color3.fromRGB(0, 170, 210),
        InputBackground     = Color3.fromRGB(18, 34, 46),
        InputStroke         = Color3.fromRGB(40, 75, 100),
        NotifyBackground    = Color3.fromRGB(18, 35, 48),
        Success             = Color3.fromRGB(46, 204, 113),
        Warning             = Color3.fromRGB(241, 196, 15),
        Error               = Color3.fromRGB(231, 76, 60),
        Shadow              = Color3.fromRGB(5, 12, 18),
        Divider             = Color3.fromRGB(30, 58, 78),
    },
    Amethyst = {
        Background          = Color3.fromRGB(22, 15, 35),
        Topbar              = Color3.fromRGB(32, 20, 48),
        TabBackground       = Color3.fromRGB(28, 18, 44),
        TabSelected         = Color3.fromRGB(148, 80, 220),
        TabText             = Color3.fromRGB(160, 120, 200),
        TabTextSelected     = Color3.fromRGB(240, 220, 255),
        ElementBackground   = Color3.fromRGB(35, 22, 55),
        ElementHover        = Color3.fromRGB(44, 28, 68),
        ElementStroke       = Color3.fromRGB(65, 40, 95),
        TextPrimary         = Color3.fromRGB(238, 228, 255),
        TextSecondary       = Color3.fromRGB(160, 130, 200),
        TextMuted           = Color3.fromRGB(100, 75, 140),
        Accent              = Color3.fromRGB(160, 90, 240),
        AccentDark          = Color3.fromRGB(110, 55, 180),
        AccentLight         = Color3.fromRGB(200, 150, 255),
        ToggleOn            = Color3.fromRGB(160, 90, 240),
        ToggleOff           = Color3.fromRGB(70, 45, 105),
        SliderFill          = Color3.fromRGB(150, 80, 230),
        InputBackground     = Color3.fromRGB(28, 18, 44),
        InputStroke         = Color3.fromRGB(75, 48, 110),
        NotifyBackground    = Color3.fromRGB(28, 18, 45),
        Success             = Color3.fromRGB(46, 204, 113),
        Warning             = Color3.fromRGB(241, 196, 15),
        Error               = Color3.fromRGB(231, 76, 60),
        Shadow              = Color3.fromRGB(8, 5, 15),
        Divider             = Color3.fromRGB(55, 35, 80),
    },
    Crimson = {
        Background          = Color3.fromRGB(28, 10, 12),
        Topbar              = Color3.fromRGB(40, 14, 17),
        TabBackground       = Color3.fromRGB(34, 12, 15),
        TabSelected         = Color3.fromRGB(200, 40, 55),
        TabText             = Color3.fromRGB(180, 100, 110),
        TabTextSelected     = Color3.fromRGB(255, 230, 232),
        ElementBackground   = Color3.fromRGB(42, 15, 18),
        ElementHover        = Color3.fromRGB(55, 20, 24),
        ElementStroke       = Color3.fromRGB(80, 28, 34),
        TextPrimary         = Color3.fromRGB(255, 228, 230),
        TextSecondary       = Color3.fromRGB(200, 140, 148),
        TextMuted           = Color3.fromRGB(130, 75, 82),
        Accent              = Color3.fromRGB(220, 50, 65),
        AccentDark          = Color3.fromRGB(160, 28, 40),
        AccentLight         = Color3.fromRGB(255, 100, 115),
        ToggleOn            = Color3.fromRGB(220, 50, 65),
        ToggleOff           = Color3.fromRGB(90, 30, 36),
        SliderFill          = Color3.fromRGB(210, 45, 60),
        InputBackground     = Color3.fromRGB(34, 12, 15),
        InputStroke         = Color3.fromRGB(90, 32, 38),
        NotifyBackground    = Color3.fromRGB(36, 12, 16),
        Success             = Color3.fromRGB(46, 204, 113),
        Warning             = Color3.fromRGB(241, 196, 15),
        Error               = Color3.fromRGB(231, 76, 60),
        Shadow              = Color3.fromRGB(8, 2, 3),
        Divider             = Color3.fromRGB(68, 24, 30),
    },
    Amber = {
        Background          = Color3.fromRGB(28, 20, 10),
        Topbar              = Color3.fromRGB(40, 28, 12),
        TabBackground       = Color3.fromRGB(34, 24, 10),
        TabSelected         = Color3.fromRGB(210, 150, 40),
        TabText             = Color3.fromRGB(180, 140, 80),
        TabTextSelected     = Color3.fromRGB(255, 245, 210),
        ElementBackground   = Color3.fromRGB(42, 30, 14),
        ElementHover        = Color3.fromRGB(55, 40, 18),
        ElementStroke       = Color3.fromRGB(85, 62, 28),
        TextPrimary         = Color3.fromRGB(255, 245, 215),
        TextSecondary       = Color3.fromRGB(200, 170, 100),
        TextMuted           = Color3.fromRGB(135, 110, 60),
        Accent              = Color3.fromRGB(225, 165, 45),
        AccentDark          = Color3.fromRGB(170, 120, 25),
        AccentLight         = Color3.fromRGB(255, 210, 80),
        ToggleOn            = Color3.fromRGB(225, 165, 45),
        ToggleOff           = Color3.fromRGB(90, 65, 22),
        SliderFill          = Color3.fromRGB(215, 155, 40),
        InputBackground     = Color3.fromRGB(34, 24, 10),
        InputStroke         = Color3.fromRGB(95, 70, 30),
        NotifyBackground    = Color3.fromRGB(36, 26, 12),
        Success             = Color3.fromRGB(46, 204, 113),
        Warning             = Color3.fromRGB(241, 196, 15),
        Error               = Color3.fromRGB(231, 76, 60),
        Shadow              = Color3.fromRGB(8, 6, 2),
        Divider             = Color3.fromRGB(72, 52, 22),
    },
    Midnight = {
        Background          = Color3.fromRGB(8, 10, 16),
        Topbar              = Color3.fromRGB(12, 15, 24),
        TabBackground       = Color3.fromRGB(10, 13, 20),
        TabSelected         = Color3.fromRGB(60, 100, 200),
        TabText             = Color3.fromRGB(100, 120, 170),
        TabTextSelected     = Color3.fromRGB(220, 230, 255),
        ElementBackground   = Color3.fromRGB(14, 18, 28),
        ElementHover        = Color3.fromRGB(18, 24, 38),
        ElementStroke       = Color3.fromRGB(28, 38, 60),
        TextPrimary         = Color3.fromRGB(218, 225, 248),
        TextSecondary       = Color3.fromRGB(130, 148, 200),
        TextMuted           = Color3.fromRGB(70, 85, 130),
        Accent              = Color3.fromRGB(80, 130, 230),
        AccentDark          = Color3.fromRGB(45, 85, 175),
        AccentLight         = Color3.fromRGB(120, 170, 255),
        ToggleOn            = Color3.fromRGB(75, 125, 225),
        ToggleOff           = Color3.fromRGB(35, 48, 80),
        SliderFill          = Color3.fromRGB(70, 120, 220),
        InputBackground     = Color3.fromRGB(10, 14, 22),
        InputStroke         = Color3.fromRGB(32, 45, 75),
        NotifyBackground    = Color3.fromRGB(12, 16, 26),
        Success             = Color3.fromRGB(46, 204, 113),
        Warning             = Color3.fromRGB(241, 196, 15),
        Error               = Color3.fromRGB(231, 76, 60),
        Shadow              = Color3.fromRGB(2, 3, 6),
        Divider             = Color3.fromRGB(22, 30, 50),
    },
    Sakura = {
        Background          = Color3.fromRGB(255, 242, 248),
        Topbar              = Color3.fromRGB(248, 224, 236),
        TabBackground       = Color3.fromRGB(250, 232, 242),
        TabSelected         = Color3.fromRGB(220, 110, 155),
        TabText             = Color3.fromRGB(180, 110, 145),
        TabTextSelected     = Color3.fromRGB(255, 240, 248),
        ElementBackground   = Color3.fromRGB(255, 236, 246),
        ElementHover        = Color3.fromRGB(248, 220, 236),
        ElementStroke       = Color3.fromRGB(230, 195, 218),
        TextPrimary         = Color3.fromRGB(80, 40, 60),
        TextSecondary       = Color3.fromRGB(160, 100, 135),
        TextMuted           = Color3.fromRGB(200, 155, 180),
        Accent              = Color3.fromRGB(228, 120, 165),
        AccentDark          = Color3.fromRGB(185, 80, 125),
        AccentLight         = Color3.fromRGB(255, 170, 205),
        ToggleOn            = Color3.fromRGB(225, 115, 160),
        ToggleOff           = Color3.fromRGB(210, 175, 195),
        SliderFill          = Color3.fromRGB(220, 110, 155),
        InputBackground     = Color3.fromRGB(255, 236, 246),
        InputStroke         = Color3.fromRGB(220, 185, 208),
        NotifyBackground    = Color3.fromRGB(255, 238, 248),
        Success             = Color3.fromRGB(46, 160, 100),
        Warning             = Color3.fromRGB(200, 155, 20),
        Error               = Color3.fromRGB(200, 70, 80),
        Shadow              = Color3.fromRGB(200, 160, 185),
        Divider             = Color3.fromRGB(225, 192, 214),
    },
    Neon = {
        Background          = Color3.fromRGB(5, 5, 8),
        Topbar              = Color3.fromRGB(8, 8, 14),
        TabBackground       = Color3.fromRGB(6, 6, 10),
        TabSelected         = Color3.fromRGB(0, 255, 180),
        TabText             = Color3.fromRGB(80, 180, 140),
        TabTextSelected     = Color3.fromRGB(5, 5, 8),
        ElementBackground   = Color3.fromRGB(8, 8, 14),
        ElementHover        = Color3.fromRGB(12, 14, 22),
        ElementStroke       = Color3.fromRGB(0, 80, 60),
        TextPrimary         = Color3.fromRGB(200, 255, 240),
        TextSecondary       = Color3.fromRGB(0, 200, 150),
        TextMuted           = Color3.fromRGB(0, 100, 80),
        Accent              = Color3.fromRGB(0, 255, 180),
        AccentDark          = Color3.fromRGB(0, 180, 120),
        AccentLight         = Color3.fromRGB(100, 255, 220),
        ToggleOn            = Color3.fromRGB(0, 255, 180),
        ToggleOff           = Color3.fromRGB(0, 60, 45),
        SliderFill          = Color3.fromRGB(0, 240, 170),
        InputBackground     = Color3.fromRGB(6, 8, 12),
        InputStroke         = Color3.fromRGB(0, 100, 75),
        NotifyBackground    = Color3.fromRGB(6, 8, 14),
        Success             = Color3.fromRGB(0, 255, 180),
        Warning             = Color3.fromRGB(255, 220, 0),
        Error               = Color3.fromRGB(255, 50, 80),
        Shadow              = Color3.fromRGB(0, 20, 15),
        Divider             = Color3.fromRGB(0, 60, 45),
    },
}

-- ══════════════════════════════════════════════════════════════
--  MAID (GC helper)
-- ══════════════════════════════════════════════════════════════
local Maid = {}; Maid.__index = Maid
function Maid.new() return setmetatable({_t={}}, Maid) end
function Maid:Add(x) table.insert(self._t, x); return x end
function Maid:Clean()
    for _, t in ipairs(self._t) do
        if typeof(t)=="RBXScriptConnection" then pcall(function() t:Disconnect() end)
        elseif typeof(t)=="Instance"         then pcall(function() t:Destroy() end)
        elseif type(t)=="function"           then pcall(t) end
    end
    self._t = {}
end

-- ══════════════════════════════════════════════════════════════
--  TWEEN PRESETS
-- ══════════════════════════════════════════════════════════════
local function TI(t, style, dir)
    return TweenInfo.new(t or 0.2,
        style or Enum.EasingStyle.Exponential,
        dir   or Enum.EasingDirection.Out)
end
local TI_FAST   = TI(0.15)
local TI_MID    = TI(0.25)
local TI_SLOW   = TI(0.45)
local TI_SPRING = TI(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tw(obj, props, info)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, info or TI_MID, props):Play()
end

-- ══════════════════════════════════════════════════════════════
--  UI HELPERS
-- ══════════════════════════════════════════════════════════════
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p; return c
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color; s.Thickness = thick or 1
    s.Transparency = trans or 0; s.Parent = p; return s
end

local function pad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.Parent = p; return u
end

local function lst(p, spacing, dir)
    local u = Instance.new("UIListLayout")
    u.SortOrder     = Enum.SortOrder.LayoutOrder
    u.FillDirection = dir or Enum.FillDirection.Vertical
    u.Padding       = UDim.new(0, spacing or 0)
    u.Parent = p; return u
end

local function frm(p, size, pos, bg, trans)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = bg or Color3.fromRGB(30,30,30)
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = p; return f
end

local function lbl(p, text, size, color, font, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text or ""; l.TextSize = size or 13
    l.TextColor3 = color or Color3.new(1,1,1)
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = p; return l
end

local function grad(p, colors, rot)
    local g = Instance.new("UIGradient")
    local kps = {}
    for i, v in ipairs(colors) do
        kps[i] = ColorSequenceKeypoint.new((i-1)/(#colors-1), v)
    end
    g.Color = ColorSequence.new(kps)
    g.Rotation = rot or 0; g.Parent = p; return g
end

local function bindCanvas(scroll, layout)
    local function upd()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd); upd()
end

local function ripple(parent, x, y)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = Color3.new(1,1,1)
    r.BackgroundTransparency = 0.75
    r.BorderSizePixel = 0
    r.Size = UDim2.new(0,0,0,0)
    r.Position = UDim2.new(0,x,0,y)
    r.AnchorPoint = Vector2.new(0.5,0.5)
    r.ZIndex = 20; r.Parent = parent; corner(r, 999)
    local sz = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    tw(r, {Size=UDim2.new(0,sz,0,sz), BackgroundTransparency=1},
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
    Debris:AddItem(r, 0.55)
end

local function mrel(obj)
    local mp = UserInputService:GetMouseLocation()
    return mp.X - obj.AbsolutePosition.X, mp.Y - obj.AbsolutePosition.Y
end

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════
local CFG_DIR = "NexusUI"
local function cfgSave(name, data)
    pcall(function()
        if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        writefile(CFG_DIR.."/"..name..".json", HttpService:JSONEncode(data))
    end)
end
local function cfgLoad(name)
    local ok, r = pcall(function()
        return HttpService:JSONDecode(readfile(CFG_DIR.."/"..name..".json"))
    end)
    return ok and r or {}
end

-- ══════════════════════════════════════════════════════════════
--  GLOBAL HOTKEYS
-- ══════════════════════════════════════════════════════════════
local _hotkeys = {}
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _, h in pairs(_hotkeys) do
        if h and i.KeyCode == h.key then pcall(h.cb) end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  LIBRARY OBJECT
-- ══════════════════════════════════════════════════════════════
local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.Version = "1.0.0"
NexusUI.Flags   = {}
NexusUI.Icons   = Icons

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════
local _ng, _nh, _ns = nil, nil, {}

local function _initNotify()
    if _ng then return end
    _ng = Instance.new("ScreenGui")
    _ng.Name = "NexusUI_Notify"
    _ng.ResetOnSpawn = false
    _ng.IgnoreGuiInset = true
    _ng.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _ng.Parent = LP.PlayerGui

    _nh = frm(_ng, UDim2.new(0, 320, 1, -10), UDim2.new(1, -330, 0, 0), Color3.new(), 1)
    local ul = lst(_nh, 8)
    ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
    pad(_nh, 0, 0, 16, 0)
end

function NexusUI:Notify(opts)
    _initNotify()
    local title   = opts.Title    or "NexusUI"
    local content = opts.Content  or ""
    local dur     = opts.Duration or 4
    local ntype   = opts.Type     or "info"

    local iconMap = {info=Icons.info, success=Icons.success, warning=Icons.warning, error=Icons.error}
    local colMap  = {info=Color3.fromRGB(60,140,220), success=Color3.fromRGB(46,204,113),
                     warning=Color3.fromRGB(241,196,15), error=Color3.fromRGB(231,76,60)}
    local ac = colMap[ntype] or colMap.info
    local ic = iconMap[ntype] or Icons.info

    if #_ns >= 5 then
        local old = table.remove(_ns, 1)
        if old and old.Parent then
            tw(old, {Position=UDim2.new(1,20,0,old.Position.Y.Offset), BackgroundTransparency=1}, TI_FAST)
            task.delay(0.2, function() if old and old.Parent then old:Destroy() end end)
        end
    end

    local T = opts.Theme or {
        NotifyBackground = Color3.fromRGB(28,28,28),
        TextPrimary      = Color3.fromRGB(240,240,240),
        TextSecondary    = Color3.fromRGB(160,160,160),
        ElementStroke    = Color3.fromRGB(50,50,50),
    }

    local nf = frm(_nh, UDim2.new(1,0,0,74), nil, T.NotifyBackground, 0)
    nf.ClipsDescendants = true
    nf.LayoutOrder = tick()
    corner(nf, 10)
    stroke(nf, T.ElementStroke, 1, 0.4)

    -- accent left bar
    local ab = frm(nf, UDim2.new(0,3,0.7,0), UDim2.new(0,0,0.15,0), ac, 0)
    corner(ab, 3)

    -- icon bg
    local icf = frm(nf, UDim2.new(0,30,0,30), UDim2.new(0,14,0,12), ac, 0.85)
    corner(icf, 8)
    frm(icf, UDim2.new(1,0,1,0), nil, ac, 0.7)
    local icl = lbl(icf, ic, 14, ac, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    icl.Size = UDim2.new(1,0,1,0)

    -- texts
    local tl = lbl(nf, title, 13, T.TextPrimary, Enum.Font.GothamBold)
    tl.Size = UDim2.new(1,-62,0,16); tl.Position = UDim2.new(0,52,0,10)
    local cl = lbl(nf, content, 11, T.TextSecondary, Enum.Font.Gotham)
    cl.Size = UDim2.new(1,-62,0,30); cl.Position = UDim2.new(0,52,0,28)
    cl.TextWrapped = true; cl.TextTruncate = Enum.TextTruncate.None

    -- close btn
    local xb = Instance.new("TextButton")
    xb.Size=UDim2.new(0,18,0,18); xb.Position=UDim2.new(1,-24,0,8)
    xb.BackgroundTransparency=1; xb.Text="✕"; xb.TextSize=9
    xb.TextColor3=T.TextSecondary; xb.Font=Enum.Font.GothamBold; xb.Parent=nf

    -- progress bar
    local pbg = frm(nf, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), Color3.fromRGB(40,40,40), 0)
    local pb  = frm(pbg, UDim2.new(1,0,1,0), nil, ac, 0)

    nf.Position = UDim2.new(1,20,0,0)
    tw(nf, {Position=UDim2.new(0,0,0,0)}, TI_SPRING)
    table.insert(_ns, nf)
    tw(pb, {Size=UDim2.new(0,0,1,0)}, TweenInfo.new(dur, Enum.EasingStyle.Linear))

    local function dismiss()
        local idx = table.find(_ns, nf)
        if idx then table.remove(_ns, idx) end
        tw(nf, {Position=UDim2.new(1,20,0,0), BackgroundTransparency=1}, TI_MID)
        task.delay(0.3, function() if nf and nf.Parent then nf:Destroy() end end)
    end
    xb.MouseButton1Click:Connect(dismiss)
    nf.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dismiss() end
    end)
    task.delay(dur, dismiss)
end

-- ══════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ══════════════════════════════════════════════════════════════
local function showLoading(opts, theme)
    local T = theme
    local title = opts.LoadingTitle    or "NEXUS UI"
    local sub   = opts.LoadingSubtitle or ""
    local steps = opts.LoadingSteps    or {"Initializing…", "Loading components…", "Ready!"}
    local logo  = opts.Logo            or "NEXUS"

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusUI_Loading"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = LP.PlayerGui

    local overlay = frm(sg, UDim2.new(1,0,1,0), nil, Color3.fromRGB(0,0,0), 0.5)

    local card = frm(sg, UDim2.new(0,480,0,280), UDim2.new(0.5,-240,0.5,-140), T.Background, 1)
    corner(card, 14)
    stroke(card, T.ElementStroke, 1, 0.3)

    -- top accent line
    local topBar = frm(card, UDim2.new(1,0,0,3), nil, T.Accent, 0)
    corner(topBar, 14)
    grad(topBar, {T.AccentLight, T.Accent, T.AccentDark}, 0)

    -- glow effect
    local glw = Instance.new("ImageLabel")
    glw.Size = UDim2.new(1,60,0,120); glw.Position = UDim2.new(0,-30,0,-40)
    glw.BackgroundTransparency = 1
    glw.Image = "rbxassetid://5028857084"
    glw.ImageColor3 = T.Accent; glw.ImageTransparency = 0.92
    glw.ScaleType = Enum.ScaleType.Slice
    glw.SliceCenter = Rect.new(24,24,276,276)
    glw.Parent = card

    -- logo text
    local ll = lbl(card, logo, 48, T.Accent, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    ll.Size = UDim2.new(1,0,0,62); ll.Position = UDim2.new(0,0,0,22)

    -- title
    local ttl = lbl(card, title, 15, T.TextPrimary, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    ttl.Size = UDim2.new(1,-40,0,22); ttl.Position = UDim2.new(0,20,0,94)

    -- subtitle
    local stl = lbl(card, sub, 11, T.TextSecondary, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    stl.Size = UDim2.new(1,-40,0,16); stl.Position = UDim2.new(0,20,0,118)

    -- divider
    frm(card, UDim2.new(1,-40,0,1), UDim2.new(0,20,0,144), T.Divider, 0)

    -- step
    local stp = lbl(card, steps[1], 10, T.Accent, Enum.Font.Code, Enum.TextXAlignment.Center)
    stp.Size = UDim2.new(1,-40,0,14); stp.Position = UDim2.new(0,20,0,156)

    -- progress bar
    local pbg = frm(card, UDim2.new(1,-40,0,5), UDim2.new(0,20,0,178), T.ElementBackground, 0)
    corner(pbg, 6)
    stroke(pbg, T.ElementStroke, 1, 0.5)
    local pb = frm(pbg, UDim2.new(0,0,1,0), nil, T.Accent, 0)
    corner(pb, 6)
    grad(pb, {T.AccentLight, T.Accent}, 0)

    -- dots animation
    local dotsContainer = frm(card, UDim2.new(1,0,0,16), UDim2.new(0,0,0,200), Color3.new(), 1)
    local dotsList = lst(dotsContainer, 6, Enum.FillDirection.Horizontal)
    dotsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local dots = {}
    for i = 1, 3 do
        local d = frm(dotsContainer, UDim2.new(0,6,0,6), nil, T.Accent, 0.5)
        d.LayoutOrder = i; corner(d, 99)
        table.insert(dots, d)
    end

    -- version
    local vl = lbl(card, "nexus ui v"..NexusUI.Version, 9, T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    vl.Size = UDim2.new(1,-40,0,12); vl.Position = UDim2.new(0,20,0,224)

    -- animate in
    tw(overlay, {BackgroundTransparency=0.65}, TI_MID)
    tw(card, {BackgroundTransparency=0}, TI_SPRING)

    -- dot animation loop
    local dotConn
    local dotIdx = 1
    dotConn = RunService.Heartbeat:Connect(function()
        local t2 = tick()
        for i, d in ipairs(dots) do
            local phase = ((t2*2) + (i-1)*0.4) % 1
            tw(d, {BackgroundTransparency = 0.2 + 0.7*(1-math.abs(math.sin(math.pi*phase)))}, TI_FAST)
        end
    end)

    -- steps
    local n = #steps
    for i, step in ipairs(steps) do
        stp.Text = step
        tw(pb, {Size=UDim2.new(i/n,0,1,0)},
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
        task.wait(0.32)
    end
    task.wait(0.25)

    dotConn:Disconnect()
    tw(card, {BackgroundTransparency=1, Position=UDim2.new(0.5,-240,0.44,-140)}, TI_MID)
    tw(overlay, {BackgroundTransparency=1}, TI_MID)
    task.wait(0.35); sg:Destroy()
end

-- ══════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function NexusUI:CreateWindow(opts)
    local winName   = opts.Name            or "NEXUS UI"
    local lTitle    = opts.LoadingTitle    or winName
    local lSub      = opts.LoadingSubtitle or ""
    local lSteps    = opts.LoadingSteps
    local lLogo     = opts.Logo            or "NEX"
    local cfgOpts   = opts.ConfigurationSaving or {}
    local cfgFile   = cfgOpts.FileName or "config"
    local cfgOn     = cfgOpts.Enabled ~= false
    local winIcon   = opts.Icon
    local maxW      = (opts.Size and opts.Size.Width)  or 580
    local maxH      = (opts.Size and opts.Size.Height) or 460

    -- Theme
    local themeName = opts.Theme or "Default"
    local T = {}
    local src = THEMES[themeName] or THEMES.Default
    for k,v in pairs(src) do T[k] = v end
    if opts.Accent then
        T.Accent      = opts.Accent
        T.AccentDark  = Color3.new(opts.Accent.R*.65, opts.Accent.G*.65, opts.Accent.B*.65)
        T.AccentLight = Color3.new(math.min(opts.Accent.R*1.35,1), math.min(opts.Accent.G*1.35,1), math.min(opts.Accent.B*1.35,1))
        T.ToggleOn    = opts.Accent
        T.SliderFill  = opts.Accent
        T.TabSelected = opts.Accent
    end

    -- Toggle key
    local tKey = Enum.KeyCode.RightShift
    if opts.ToggleKey then
        if typeof(opts.ToggleKey)=="EnumItem" then tKey=opts.ToggleKey
        elseif type(opts.ToggleKey)=="string" then
            pcall(function() tKey=Enum.KeyCode[opts.ToggleKey] end)
        end
    end

    -- Loading screen
    task.spawn(showLoading, {
        LoadingTitle=lTitle, LoadingSubtitle=lSub,
        LoadingSteps=lSteps, Logo=lLogo,
    }, T)
    task.wait((#(lSteps or {"","",""}) * 0.32) + 0.70)

    local saved = cfgOn and cfgLoad(cfgFile) or {}

    -- ── ScreenGui ────────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusUI_Main"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = LP.PlayerGui

    -- ── Main frame ───────────────────────────────────────────
    local mf = Instance.new("Frame")
    mf.AnchorPoint = Vector2.new(0.5,0.5)
    mf.Position    = UDim2.new(0.5,0,0.5,0)
    mf.Size        = UDim2.new(0,maxW,0,maxH)
    mf.BackgroundColor3 = T.Background
    mf.BorderSizePixel  = 0
    mf.ClipsDescendants = false
    mf.Parent = sg
    corner(mf, 12)

    -- outer stroke
    local mfStroke = stroke(mf, T.ElementStroke, 1, 0.2)

    -- shadow layer
    local shadowF = Instance.new("Frame")
    shadowF.Size = UDim2.new(1,20,1,20)
    shadowF.Position = UDim2.new(0,-10,0,8)
    shadowF.BackgroundColor3 = T.Shadow
    shadowF.BackgroundTransparency = 0.55
    shadowF.BorderSizePixel = 0
    shadowF.ZIndex = 0; shadowF.Parent = sg
    corner(shadowF, 16)

    -- glow
    local glwF = Instance.new("Frame")
    glwF.Size = UDim2.new(0,maxW+80,0,maxH+80)
    glwF.AnchorPoint = Vector2.new(0.5,0.5)
    glwF.Position = UDim2.new(0.5,0,0.5,0)
    glwF.BackgroundTransparency = 1
    glwF.ZIndex = 0; glwF.Parent = sg
    local glw = Instance.new("ImageLabel")
    glw.Size = UDim2.new(1,0,1,0)
    glw.BackgroundTransparency = 1
    glw.Image = "rbxassetid://5028857084"
    glw.ImageColor3 = T.Accent; glw.ImageTransparency = 0.90
    glw.ScaleType = Enum.ScaleType.Slice
    glw.SliceCenter = Rect.new(24,24,276,276)
    glw.ZIndex = 0; glw.Parent = glwF

    -- ── Topbar ────────────────────────────────────────────────
    local tb = frm(mf, UDim2.new(1,0,0,46), nil, T.Topbar, 0)
    corner(tb, 12)
    frm(tb, UDim2.new(1,0,0,16), UDim2.new(0,0,1,-16), T.Topbar, 0)

    -- topbar bottom separator
    local tbSep = frm(tb, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), T.Accent, 0.5)
    grad(tbSep, {Color3.new(0,0,0), T.Accent, T.AccentLight, T.Accent, Color3.new(0,0,0)}, 0)

    -- icon
    local xOff = 14
    if winIcon then
        local icL = lbl(tb, tostring(winIcon), 16, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        icL.Size = UDim2.new(0,30,1,0); icL.Position = UDim2.new(0,12,0,0)
        xOff = 46
    end

    -- title
    local logoL = lbl(tb, "NEXUS", 14, T.Accent, Enum.Font.GothamBlack)
    logoL.Size = UDim2.new(0,50,1,0); logoL.Position = UDim2.new(0,xOff,0,0)
    local nameL = lbl(tb, winName, 12, T.TextSecondary, Enum.Font.GothamMedium)
    nameL.Size = UDim2.new(1,-220,1,0); nameL.Position = UDim2.new(0,xOff+54,0,0)

    -- control buttons
    local function ctrlBtn(icon, xo, hcol)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,26,0,22)
        b.Position = UDim2.new(1,xo,0.5,-11)
        b.BackgroundColor3 = T.ElementBackground
        b.Text = icon; b.Font = Enum.Font.GothamBold
        b.TextSize = 10; b.TextColor3 = T.TextMuted
        b.BorderSizePixel = 0; b.Parent = tb
        corner(b, 6)
        stroke(b, T.ElementStroke, 1, 0.4)
        b.MouseEnter:Connect(function()
            tw(b, {BackgroundColor3=hcol, TextColor3=T.TabTextSelected}, TI_FAST)
        end)
        b.MouseLeave:Connect(function()
            tw(b, {BackgroundColor3=T.ElementBackground, TextColor3=T.TextMuted}, TI_FAST)
        end)
        return b
    end
    local closeBtn = ctrlBtn("✕", -12, T.Error)
    local minBtn   = ctrlBtn("─", -44, T.AccentDark)

    -- version label
    local verL = lbl(tb, "v"..NexusUI.Version, 8, T.TextMuted, Enum.Font.Code, Enum.TextXAlignment.Right)
    verL.Size = UDim2.new(0,50,1,0); verL.Position = UDim2.new(1,-102,0,0)

    -- ── Tab list (left sidebar) ───────────────────────────────
    local sb = frm(mf, UDim2.new(0,150,1,-46), UDim2.new(0,0,0,46), T.TabBackground, 0)
    pad(sb, 8, 6, 8, 6); lst(sb, 3)
    -- separator line
    frm(mf, UDim2.new(0,1,1,-46), UDim2.new(0,150,0,46), T.Divider, 0)

    -- search bar
    local searchBg = frm(sb, UDim2.new(1,0,0,30), nil, T.InputBackground, 0)
    corner(searchBg, 7); stroke(searchBg, T.InputStroke, 1, 0.3)
    local searchIcon = lbl(searchBg, Icons.search, 10, T.TextMuted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
    searchIcon.Size = UDim2.new(0,20,1,0); searchIcon.Position = UDim2.new(0,4,0,0)
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1,-26,1,0); searchBox.Position = UDim2.new(0,22,0,0)
    searchBox.BackgroundTransparency = 1; searchBox.Text = ""
    searchBox.PlaceholderText = "Search…"; searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10; searchBox.TextColor3 = T.TextPrimary
    searchBox.PlaceholderColor3 = T.TextMuted; searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchBg

    -- sidebar version tag
    local sbver = Instance.new("TextLabel")
    sbver.Size = UDim2.new(1,0,0,12)
    sbver.Position = UDim2.new(0,0,1,-14)
    sbver.BackgroundTransparency = 1
    sbver.Text = "nexus ui · v"..NexusUI.Version
    sbver.TextSize = 8; sbver.Font = Enum.Font.Gotham
    sbver.TextColor3 = T.TextMuted
    sbver.TextXAlignment = Enum.TextXAlignment.Center
    sbver.Parent = sb

    -- ── Content area ─────────────────────────────────────────
    local ca = Instance.new("Frame")
    ca.Size = UDim2.new(1,-151,1,-46); ca.Position = UDim2.new(0,151,0,46)
    ca.BackgroundTransparency = 1; ca.ClipsDescendants = true; ca.Parent = mf

    -- ── Drag ─────────────────────────────────────────────────
    local dragging, dStart, dAbs = false, nil, nil
    local minimized = false

    tb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dStart = i.Position; dAbs = mf.AbsolutePosition
            mf.AnchorPoint = Vector2.new(0,0)
            mf.Position = UDim2.new(0,dAbs.X,0,dAbs.Y)
            glwF.AnchorPoint = Vector2.new(0,0)
            glwF.Position = UDim2.new(0,dAbs.X-40,0,dAbs.Y-40)
            shadowF.AnchorPoint = Vector2.new(0,0)
            shadowF.Position = UDim2.new(0,dAbs.X-10,0,dAbs.Y+8)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            local cvp = workspace.CurrentCamera.ViewportSize
            local nx = math.clamp(dAbs.X+d.X, 0, cvp.X-mf.AbsoluteSize.X)
            local ny = math.clamp(dAbs.Y+d.Y, 0, cvp.Y-mf.AbsoluteSize.Y)
            mf.Position    = UDim2.new(0,nx,0,ny)
            glwF.Position  = UDim2.new(0,nx-40,0,ny-40)
            shadowF.Position = UDim2.new(0,nx-10,0,ny+8)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- minimize
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        sb.Visible = not minimized; ca.Visible = not minimized
        local nh = minimized and 46 or maxH
        tw(mf, {Size=UDim2.new(0,maxW,0,nh)}, TI_SPRING)
        minBtn.Text = minimized and "□" or "─"
    end)

    -- close
    closeBtn.MouseButton1Click:Connect(function()
        tw(mf, {BackgroundTransparency=1, Size=UDim2.new(0,mf.AbsoluteSize.X,0,4)}, TI_MID)
        tw(glwF, {BackgroundTransparency=1}, TI_MID)
        tw(shadowF, {BackgroundTransparency=1}, TI_MID)
        task.delay(0.35, function() sg:Destroy() end)
    end)

    -- toggle hotkey
    table.insert(_hotkeys, {key=tKey, cb=function()
        mf.Visible = not mf.Visible
        glwF.Visible = mf.Visible; shadowF.Visible = mf.Visible
        if mf.Visible then
            mf.BackgroundTransparency = 1
            tw(mf, {BackgroundTransparency=0}, TI_FAST)
        end
    end})

    -- ── Win object ───────────────────────────────────────────
    local Win = {}
    Win._tabs     = {}
    Win._active   = nil
    Win._allElems = {}
    Win._cfgFile  = cfgFile
    Win._cfgOn    = cfgOn
    Win._saved    = saved
    Win._sg       = sg
    Win._mf       = mf
    Win._theme    = T

    function Win:SaveConfig()
        if self._cfgOn then cfgSave(self._cfgFile, NexusUI.Flags) end
    end

    function Win:Notify(o)
        o.Theme = T
        NexusUI:Notify(o)
    end

    function Win:Destroy() sg:Destroy() end

    function Win:SetTheme(name)
        local src2 = THEMES[name] or THEMES.Default
        for k,v in pairs(src2) do T[k] = v end
        glw.ImageColor3 = T.Accent
        logoL.TextColor3 = T.Accent
        self:Notify({Title="Theme", Content="Applied: "..name, Type="success", Duration=2})
    end

    function Win:SetAccent(col)
        T.Accent      = col
        T.AccentDark  = Color3.new(col.R*.65, col.G*.65, col.B*.65)
        T.AccentLight = Color3.new(math.min(col.R*1.35,1), math.min(col.G*1.35,1), math.min(col.B*1.35,1))
        T.ToggleOn    = col; T.SliderFill = col; T.TabSelected = col
        glw.ImageColor3 = col; logoL.TextColor3 = col
    end

    -- search
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower(); local cnt = 0
        for _, info in ipairs(Win._allElems) do
            if q == "" then info.frame.Visible = true
            else
                local f = info.name:lower():find(q, 1, true) ~= nil
                info.frame.Visible = f; if f then cnt += 1 end
            end
        end
    end)

    -- ════════════════════════════════════════════════════════
    --  CREATE TAB
    -- ════════════════════════════════════════════════════════
    function Win:CreateTab(name, icon, badge)
        local maid = Maid.new()

        -- tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1,0,0,36)
        tabBtn.BackgroundColor3 = T.TabBackground
        tabBtn.Text = ""; tabBtn.BorderSizePixel = 0
        tabBtn.LayoutOrder = #self._tabs + 2
        tabBtn.Parent = sb
        corner(tabBtn, 7)

        -- active stripe
        local stripe = frm(tabBtn, UDim2.new(0,3,0,20), UDim2.new(0,0,0.5,-10), T.TabSelected, 1)
        corner(stripe, 3)

        -- icon label
        local iconL = lbl(tabBtn, icon or "", 13, T.TabText, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
        iconL.Size = UDim2.new(0,22,1,0); iconL.Position = UDim2.new(0,8,0,0)

        -- name label
        local nL = lbl(tabBtn, name, 11, T.TabText, Enum.Font.GothamMedium)
        nL.Size = UDim2.new(1,-42,1,0)
        nL.Position = UDim2.new(0, icon and 32 or 10, 0, 0)

        -- badge
        if badge then
            local bF = frm(tabBtn, UDim2.new(0,18,0,14), UDim2.new(1,-22,0.5,-7), T.TabSelected, 0)
            corner(bF, 7)
            local bL = lbl(bF, tostring(badge), 8, T.TabTextSelected, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            bL.Size = UDim2.new(1,0,1,0)
        end

        -- scroll content
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1,0,1,0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = T.TabSelected
        scroll.ScrollBarImageTransparency = 0.4
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.Visible = false; scroll.Parent = ca

        local sLayout = lst(scroll, 4)
        pad(scroll, 10, 12, 10, 12)
        bindCanvas(scroll, sLayout)

        maid:Add(scroll.MouseEnter:Connect(function()
            tw(scroll, {ScrollBarImageTransparency=0.1}, TI_FAST)
        end))
        maid:Add(scroll.MouseLeave:Connect(function()
            tw(scroll, {ScrollBarImageTransparency=0.4}, TI_FAST)
        end))

        local function activate()
            for _, t in ipairs(self._tabs) do
                t.sc.Visible = false
                tw(t.btn, {BackgroundColor3=T.TabBackground}, TI_FAST)
                tw(t.nL,  {TextColor3=T.TabText}, TI_FAST)
                tw(t.iL,  {TextColor3=T.TabText}, TI_FAST)
                tw(t.str, {BackgroundTransparency=1}, TI_FAST)
            end
            scroll.Visible = true; self._active = scroll
            tw(tabBtn, {BackgroundColor3=T.ElementHover}, TI_FAST)
            tw(nL,     {TextColor3=T.TabTextSelected}, TI_FAST)
            tw(iconL,  {TextColor3=T.TabSelected}, TI_FAST)
            tw(stripe, {BackgroundTransparency=0}, TI_FAST)
        end

        maid:Add(tabBtn.MouseEnter:Connect(function()
            if self._active ~= scroll then
                tw(tabBtn, {BackgroundColor3=T.ElementHover}, TI_FAST)
                tw(nL, {TextColor3=T.TextSecondary}, TI_FAST)
            end
        end))
        maid:Add(tabBtn.MouseLeave:Connect(function()
            if self._active ~= scroll then
                tw(tabBtn, {BackgroundColor3=T.TabBackground}, TI_FAST)
                tw(nL, {TextColor3=T.TabText}, TI_FAST)
            end
        end))
        maid:Add(tabBtn.MouseButton1Click:Connect(function()
            activate()
            local x,y = mrel(tabBtn); ripple(tabBtn,x,y)
        end))

        table.insert(self._tabs, {sc=scroll, btn=tabBtn, nL=nL, iL=iconL, str=stripe})
        if #self._tabs == 1 then task.defer(activate) end

        -- ── Tab API ──────────────────────────────────────────
        local Tab = {}; Tab._lo = 0; Tab._maid = maid

        local function lo() Tab._lo += 1; return Tab._lo end

        local function elem(h, noHover)
            local c = frm(scroll, UDim2.new(1,0,0,h), nil, T.ElementBackground, 1)
            c.LayoutOrder = lo()
            c.AutomaticSize = Enum.AutomaticSize.Y
            corner(c, 8)
            stroke(c, T.ElementStroke, 1, 0.35)
            task.defer(function() tw(c, {BackgroundTransparency=0}, TI_MID) end)
            if not noHover then
                maid:Add(c.MouseEnter:Connect(function()
                    tw(c, {BackgroundColor3=T.ElementHover}, TI_FAST)
                end))
                maid:Add(c.MouseLeave:Connect(function()
                    tw(c, {BackgroundColor3=T.ElementBackground}, TI_FAST)
                end))
            end
            return c
        end

        local function reg(c, n)
            table.insert(Win._allElems, {frame=c, name=n or ""})
        end

        -- ── CreateSection ────────────────────────────────────
        function Tab:CreateSection(text)
            local sf = frm(scroll, UDim2.new(1,0,0,24), nil, Color3.new(), 1)
            sf.LayoutOrder = lo()
            local line1 = frm(sf, UDim2.new(0.3,-6,0,1), UDim2.new(0,0,0.5,0), T.Divider, 0)
            local line2 = frm(sf, UDim2.new(0.3,-6,0,1), UDim2.new(0.7,6,0.5,0), T.Divider, 0)
            local sl = lbl(sf, text:upper(), 9, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            sl.Size = UDim2.new(0.4,0,1,0); sl.Position = UDim2.new(0.3,0,0,0)
            local sv = {}; function sv:Set(t2) sl.Text = t2:upper() end; return sv
        end

        -- ── CreateSeparator ──────────────────────────────────
        function Tab:CreateSeparator()
            local sf = frm(scroll, UDim2.new(1,0,0,1), nil, T.Divider, 0)
            sf.LayoutOrder = lo()
        end

        -- ── CreateLabel ──────────────────────────────────────
        function Tab:CreateLabel(text, icon2, color)
            local lf = frm(scroll, UDim2.new(1,0,0,32), nil, Color3.new(), 1)
            lf.LayoutOrder = lo()
            local ll
            if icon2 then
                local il = lbl(lf, tostring(icon2), 13, color or T.Accent, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
                il.Size = UDim2.new(0,24,1,0); il.Position = UDim2.new(0,10,0,0)
                ll = lbl(lf, text or "", 11, color or T.TextSecondary, Enum.Font.Gotham)
                ll.Size = UDim2.new(1,-38,1,0); ll.Position = UDim2.new(0,36,0,0)
            else
                ll = lbl(lf, text or "", 11, color or T.TextSecondary, Enum.Font.Gotham, Enum.TextXAlignment.Center)
                ll.Size = UDim2.new(1,0,1,0)
                ll.TextWrapped = true
            end
            local o = {}; function o:Set(t2, c2) ll.Text = t2; if c2 then ll.TextColor3 = c2 end end; return o
        end

        -- ── CreateParagraph ──────────────────────────────────
        function Tab:CreateParagraph(opts2)
            local c = frm(scroll, UDim2.new(1,0,0,0), nil, T.ElementBackground, 1)
            c.LayoutOrder = lo(); c.AutomaticSize = Enum.AutomaticSize.Y
            corner(c,8); stroke(c,T.ElementStroke,1,0.35); reg(c, opts2.Title or "")
            task.defer(function() tw(c,{BackgroundTransparency=0},TI_MID) end)
            pad(c,10,14,10,14)
            local inner = Instance.new("Frame")
            inner.BackgroundTransparency=1; inner.Size=UDim2.new(1,0,1,0)
            inner.AutomaticSize=Enum.AutomaticSize.Y; inner.Parent=c; lst(inner,5)
            local tl = lbl(inner, opts2.Title or "", 12, T.TextPrimary, Enum.Font.GothamBold)
            tl.Size = UDim2.new(1,0,0,16); tl.LayoutOrder = 1
            local cl = lbl(inner, opts2.Content or "", 11, T.TextSecondary, Enum.Font.Gotham)
            cl.Size = UDim2.new(1,0,0,0); cl.AutomaticSize = Enum.AutomaticSize.Y
            cl.TextWrapped = true; cl.TextTruncate = Enum.TextTruncate.None; cl.LayoutOrder = 2
            local o = {}; function o:Set(t2,c2) tl.Text=t2 or tl.Text; cl.Text=c2 or cl.Text end; return o
        end

        -- ── CreateButton ─────────────────────────────────────
        function Tab:CreateButton(opts2)
            local desc = opts2.Description
            local cb   = opts2.Callback or function() end
            local h    = desc and 54 or 36
            local c    = elem(h); c.ClipsDescendants = true; reg(c, opts2.Name)

            local iconStr = opts2.Icon and tostring(opts2.Icon) or Icons.chevronRight
            local il = lbl(c, iconStr, 12, T.TabSelected, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            il.Size = UDim2.new(0,20,1,0); il.Position = UDim2.new(1,-28,0,0)

            local nl = lbl(c, opts2.Name or "Button", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(1,-42,0,16); nl.Position = UDim2.new(0,12,0, desc and 8 or 10)
            if desc then
                local dl = lbl(c, desc, 10, T.TextMuted, Enum.Font.Gotham)
                dl.Size = UDim2.new(1,-42,0,14); dl.Position = UDim2.new(0,12,0,27)
            end

            -- left accent bar (appears on hover)
            local bar = frm(c, UDim2.new(0,2,0,18), UDim2.new(0,0,0.5,-9), T.TabSelected, 1)
            corner(bar,2)

            local btn = Instance.new("TextButton")
            btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=c

            maid:Add(btn.MouseEnter:Connect(function()
                tw(nl,  {TextColor3=T.AccentLight}, TI_FAST)
                tw(il,  {TextColor3=T.AccentLight}, TI_FAST)
                tw(bar, {BackgroundTransparency=0}, TI_FAST)
            end))
            maid:Add(btn.MouseLeave:Connect(function()
                tw(nl,  {TextColor3=T.TextPrimary}, TI_FAST)
                tw(il,  {TextColor3=T.TabSelected}, TI_FAST)
                tw(bar, {BackgroundTransparency=1}, TI_FAST)
            end))
            maid:Add(btn.MouseButton1Down:Connect(function()
                tw(c, {BackgroundColor3=T.AccentDark}, TI_FAST)
            end))
            maid:Add(btn.MouseButton1Click:Connect(function()
                tw(c, {BackgroundColor3=T.ElementHover}, TI_FAST)
                local x,y = mrel(c); ripple(c,x,y)
                local ok, err = pcall(cb)
                if not ok then
                    tw(c, {BackgroundColor3=Color3.fromRGB(80,0,0)}, TI_FAST)
                    nl.Text = "Error!"
                    task.delay(0.8, function()
                        tw(c, {BackgroundColor3=T.ElementBackground}, TI_MID)
                        nl.Text = opts2.Name or "Button"
                    end)
                end
            end))

            local o = {}; function o:Set(n) nl.Text = n end; return o
        end

        -- ── CreateToggle ──────────────────────────────────────
        function Tab:CreateToggle(opts2)
            local flag = opts2.Flag; local desc = opts2.Description
            local tVal = (flag and Win._saved[flag]~=nil) and Win._saved[flag] or (opts2.CurrentValue or false)
            local cb   = opts2.Callback or function() end
            local h    = desc and 54 or 36
            local c    = elem(h); local val = tVal; reg(c, opts2.Name)

            local iBtn = Instance.new("TextButton")
            iBtn.Size=UDim2.new(1,0,1,0); iBtn.BackgroundTransparency=1; iBtn.Text=""; iBtn.Parent=c

            local nl = lbl(c, opts2.Name or "Toggle", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(1,-68,0,16); nl.Position = UDim2.new(0,12,0, desc and 8 or 10)
            if desc then
                local dl = lbl(c, desc, 10, T.TextMuted, Enum.Font.Gotham)
                dl.Size = UDim2.new(1,-68,0,14); dl.Position = UDim2.new(0,12,0,27)
            end

            -- toggle track
            local track = frm(c, UDim2.new(0,40,0,22), UDim2.new(1,-52,0.5,-11), tVal and T.ToggleOn or T.ToggleOff, 0)
            corner(track, 11)
            stroke(track, T.ElementStroke, 1, 0.2)

            -- toggle thumb
            local thumb = frm(track, UDim2.new(0,16,0,16),
                tVal and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                Color3.new(1,1,1), 0)
            corner(thumb, 9)
            -- thumb shine
            local shine = frm(thumb, UDim2.new(0,5,0,5), UDim2.new(0,2,0,2), Color3.new(1,1,1), 0.6)
            corner(shine, 99)

            local function set(v, silent)
                val = v
                tw(track, {BackgroundColor3 = v and T.ToggleOn or T.ToggleOff}, TI_FAST)
                tw(thumb, {Position = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, TI_FAST)
                tw(nl,    {TextColor3 = v and T.TextPrimary or T.TextSecondary}, TI_FAST)
                if not silent then cb(v); if flag then NexusUI.Flags[flag]=v; Win:SaveConfig() end end
            end
            set(tVal, true)

            maid:Add(iBtn.MouseButton1Click:Connect(function()
                set(not val); local x,y = mrel(c); ripple(c,x,y)
            end))

            local o = {}
            function o:Set(v)    set(v, false)   end
            function o:Get()     return val       end
            function o:Toggle()  set(not val, false) end
            return o
        end

        -- ── CreateSlider ──────────────────────────────────────
        function Tab:CreateSlider(opts2)
            local flag = opts2.Flag
            local range = opts2.Range or {0, 100}
            local inc   = opts2.Increment or 1
            local suf   = opts2.Suffix or ""
            local def   = (flag and Win._saved[flag]) or opts2.CurrentValue or range[1]
            local cb    = opts2.Callback or function() end
            local c     = elem(opts2.Description and 62 or 52); local val = math.clamp(def, range[1], range[2])
            reg(c, opts2.Name)

            local nl = lbl(c, opts2.Name or "Slider", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(1,-80,0,16); nl.Position = UDim2.new(0,12,0,8)
            local vl = lbl(c, tostring(val)..suf, 13, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            vl.Size = UDim2.new(0,66,0,16); vl.Position = UDim2.new(1,-78,0,8)

            if opts2.Description then
                local dl = lbl(c, opts2.Description, 10, T.TextMuted, Enum.Font.Gotham)
                dl.Size = UDim2.new(1,-24,0,12); dl.Position = UDim2.new(0,12,0,26)
            end

            local yOff = opts2.Description and 44 or 32
            local track = frm(c, UDim2.new(1,-24,0,5), UDim2.new(0,12,0,yOff), T.ElementStroke, 0)
            corner(track, 6)
            local fill = frm(track, UDim2.new(0,0,1,0), nil, T.SliderFill, 0); corner(fill, 6)
            grad(fill, {T.AccentLight, T.SliderFill}, 0)
            local thumb = frm(track, UDim2.new(0,16,0,16), UDim2.new(0,-8,0.5,-8), T.AccentLight, 0)
            corner(thumb, 9)
            stroke(thumb, T.Accent, 2, 0)
            thumb.ZIndex = 4

            -- tooltip
            local stt = frm(thumb, UDim2.new(0,50,0,20), UDim2.new(0.5,-25,0,-28), T.Topbar, 0)
            corner(stt,6); stroke(stt,T.ElementStroke,1,0); stt.Visible=false
            local sttL = lbl(stt,"",10,T.Accent,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            sttL.Size = UDim2.new(1,0,1,0)

            local function upd(v)
                v = math.clamp(math.round(v/inc)*inc, range[1], range[2]); val = v
                local p = (v-range[1])/(range[2]-range[1])
                tw(fill,  {Size=UDim2.new(p,0,1,0)}, TI_FAST)
                tw(thumb, {Position=UDim2.new(p,-8,0.5,-8)}, TI_FAST)
                vl.Text = tostring(v)..suf; sttL.Text = tostring(v)..suf
                cb(v); if flag then NexusUI.Flags[flag]=v; Win:SaveConfig() end
            end
            local p0 = (val-range[1])/(range[2]-range[1])
            fill.Size = UDim2.new(p0,0,1,0); thumb.Position = UDim2.new(p0,-8,0.5,-8)

            local ds = false
            local function pct(x) return math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1) end

            maid:Add(thumb.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true; stt.Visible=true end
            end))
            maid:Add(track.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    ds=true; stt.Visible=true
                    upd(range[1]+(range[2]-range[1])*pct(i.Position.X))
                end
            end))
            maid:Add(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false; stt.Visible=false end
            end))
            maid:Add(UserInputService.InputChanged:Connect(function(i)
                if ds and i.UserInputType==Enum.UserInputType.MouseMovement then
                    upd(range[1]+(range[2]-range[1])*pct(i.Position.X))
                end
            end))

            local o = {}; function o:Set(v) upd(v) end; function o:Get() return val end; return o
        end

        -- ── CreateInput ───────────────────────────────────────
        function Tab:CreateInput(opts2)
            local flag = opts2.Flag; local cb = opts2.Callback or function() end
            local live = opts2.LiveUpdate or false; local num = opts2.NumberOnly or false
            local c    = elem(54); reg(c, opts2.Name)

            local nl = lbl(c, opts2.Name or "Input", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(1,-24,0,16); nl.Position = UDim2.new(0,12,0,6)

            local ibg = frm(c, UDim2.new(1,-24,0,24), UDim2.new(0,12,0,26), T.InputBackground, 0)
            corner(ibg,6); local ibs = stroke(ibg, T.InputStroke, 1, 0.2)

            local ib = Instance.new("TextBox")
            ib.Size = UDim2.new(1,-14,1,0); ib.Position = UDim2.new(0,7,0,0)
            ib.BackgroundTransparency = 1; ib.Text = opts2.CurrentValue or ""
            ib.PlaceholderText = opts2.PlaceholderText or "Enter value…"
            ib.Font = Enum.Font.Gotham; ib.TextSize = 11
            ib.TextColor3 = T.TextPrimary; ib.PlaceholderColor3 = T.TextMuted
            ib.ClearTextOnFocus = false; ib.Parent = ibg

            maid:Add(ib.Focused:Connect(function()
                tw(ibg, {BackgroundColor3=T.ElementHover}, TI_FAST)
                ibs.Color = T.Accent; ibs.Transparency = 0
            end))
            maid:Add(ib.FocusLost:Connect(function(enter)
                tw(ibg, {BackgroundColor3=T.InputBackground}, TI_FAST)
                ibs.Color = T.InputStroke; ibs.Transparency = 0.2
                if enter then
                    local v2 = num and tonumber(ib.Text) or ib.Text
                    cb(v2); if flag then NexusUI.Flags[flag]=v2; Win:SaveConfig() end
                end
                if opts2.RemoveTextAfterFocusLost then ib.Text = "" end
            end))
            if live then
                maid:Add(ib:GetPropertyChangedSignal("Text"):Connect(function()
                    cb(num and tonumber(ib.Text) or ib.Text)
                end))
            end

            local o = {}
            function o:Set(v) ib.Text = tostring(v) end
            function o:Get() return ib.Text end
            function o:Clear() ib.Text = "" end
            return o
        end

        -- ── CreateDropdown ────────────────────────────────────
        function Tab:CreateDropdown(opts2)
            local flag  = opts2.Flag
            local dOpts = opts2.Options or {}
            local def   = (flag and Win._saved[flag]) or opts2.CurrentOption
            local cb    = opts2.Callback or function() end
            local multi = opts2.MultipleOptions or false
            local val   = def; local sel = {}; local open = false

            local c = elem(36); c.ClipsDescendants = false; c.ZIndex = 5; reg(c, opts2.Name)

            local nl = lbl(c, opts2.Name or "Dropdown", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(0.5,0,0,18); nl.Position = UDim2.new(0,12,0.5,-9)
            local vl = lbl(c, type(val)=="table" and (#val.." selected") or (val or "Select…"), 11, T.Accent, Enum.Font.Gotham, Enum.TextXAlignment.Right)
            vl.Size = UDim2.new(0.38,-4,0,18); vl.Position = UDim2.new(0.52,0,0.5,-9)
            local al = lbl(c, Icons.chevronDown, 11, T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            al.Size = UDim2.new(0,16,0,18); al.Position = UDim2.new(1,-24,0.5,-9)

            local dd = frm(c, UDim2.new(1,0,0,0), UDim2.new(0,0,1,4), T.Topbar, 0)
            dd.ClipsDescendants = true; dd.ZIndex = 10; dd.Visible = false
            corner(dd,8); stroke(dd,T.ElementStroke,1,0.2); lst(dd,2); pad(dd,4,4,4,4)

            local function refreshVl()
                if multi then
                    local s={}; for o2,v2 in pairs(sel) do if v2 then s[#s+1]=o2 end end
                    vl.Text = #s>0 and (#s.." selected") or "None"
                else vl.Text = val or "Select…" end
            end

            local function buildOptions(list)
                for _,ch in ipairs(dd:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for _, opt in ipairs(list) do
                    local ob = Instance.new("TextButton")
                    ob.Size=UDim2.new(1,0,0,28); ob.BackgroundColor3=T.ElementBackground
                    ob.Text=""; ob.BorderSizePixel=0; ob.Parent=dd; corner(ob,6)
                    stroke(ob, T.ElementStroke, 1, 0.5)
                    local ol = lbl(ob, opt, 11, opt==val and T.Accent or T.TextSecondary)
                    ol.Size = UDim2.new(1,-16,1,0); ol.Position = UDim2.new(0,8,0,0)
                    ob.MouseEnter:Connect(function()
                        tw(ob,{BackgroundColor3=T.ElementHover},TI_FAST)
                        tw(ol,{TextColor3=T.TextPrimary},TI_FAST)
                    end)
                    ob.MouseLeave:Connect(function()
                        tw(ob,{BackgroundColor3=T.ElementBackground},TI_FAST)
                        tw(ol,{TextColor3=opt==val and T.Accent or T.TextSecondary},TI_FAST)
                    end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            sel[opt] = not sel[opt]
                            tw(ol,{TextColor3=sel[opt] and T.Accent or T.TextSecondary},TI_FAST)
                            local r={}; for o3,v3 in pairs(sel) do if v3 then r[#r+1]=o3 end end
                            val=r; refreshVl(); cb(r)
                        else
                            val = opt; refreshVl()
                            for _,ch2 in ipairs(dd:GetChildren()) do
                                if ch2:IsA("TextButton") then
                                    local cll = ch2:FindFirstChildOfClass("TextLabel")
                                    if cll then tw(cll,{TextColor3=T.TextSecondary},TI_FAST) end
                                end
                            end
                            tw(ol,{TextColor3=T.Accent},TI_FAST)
                            open = false
                            tw(dd,{Size=UDim2.new(1,0,0,0)},TI_FAST)
                            tw(al,{Rotation=0},TI_FAST)
                            task.delay(0.18, function() dd.Visible=false end)
                            cb(opt); if flag then NexusUI.Flags[flag]=opt; Win:SaveConfig() end
                        end
                    end)
                end
            end
            buildOptions(dOpts)

            local mb = Instance.new("TextButton")
            mb.Size=UDim2.new(1,0,1,0); mb.BackgroundTransparency=1; mb.Text=""; mb.Parent=c
            maid:Add(mb.MouseButton1Click:Connect(function()
                open = not open
                local th2 = open and math.min(#dOpts*32+8,200) or 0
                dd.Visible = true
                tw(dd,{Size=UDim2.new(1,0,0,th2)},TI_FAST)
                tw(al,{Rotation=open and 180 or 0},TI_FAST)
                if not open then task.delay(0.2, function() dd.Visible=false end) end
            end))

            local o = {}
            function o:Set(v)           val=v; refreshVl(); cb(v)       end
            function o:Get()            return val                        end
            function o:Refresh(list)    dOpts=list; buildOptions(list)   end
            function o:AddOption(v2)    table.insert(dOpts,v2); buildOptions(dOpts) end
            return o
        end

        -- ── CreateKeybind ─────────────────────────────────────
        function Tab:CreateKeybind(opts2)
            local flag = opts2.Flag; local cb = opts2.Callback or function() end
            local val  = opts2.CurrentKey or Enum.KeyCode.Unknown
            local hold = opts2.HoldToInteract or false
            local binding = false; local held = false
            local c = elem(36); reg(c, opts2.Name)

            local nl = lbl(c, opts2.Name or "Keybind", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(1,-106,0,16); nl.Position = UDim2.new(0,12,0.5,-8)

            local kbg = frm(c, UDim2.new(0,88,0,24), UDim2.new(1,-98,0.5,-12), T.InputBackground, 0)
            corner(kbg,7); stroke(kbg,T.InputStroke,1,0.2)
            local kl = lbl(kbg, typeof(val)=="EnumItem" and val.Name or tostring(val), 11, T.Accent, Enum.Font.Code, Enum.TextXAlignment.Center)
            kl.Size = UDim2.new(1,0,1,0)

            local btn = Instance.new("TextButton")
            btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=c

            maid:Add(btn.MouseButton1Click:Connect(function()
                binding=true; kl.Text="…"; kl.TextColor3=T.TextMuted
                tw(kbg,{BackgroundColor3=T.ElementHover},TI_FAST)
            end))
            maid:Add(UserInputService.InputBegan:Connect(function(i,gpe)
                if binding and i.UserInputType==Enum.UserInputType.Keyboard then
                    binding=false; val=i.KeyCode; kl.Text=i.KeyCode.Name; kl.TextColor3=T.Accent
                    tw(kbg,{BackgroundColor3=T.InputBackground},TI_FAST)
                    if flag then NexusUI.Flags[flag]=i.KeyCode.Name; Win:SaveConfig() end
                    if opts2.CallOnChange then cb(i.KeyCode) end; return
                end
                if not gpe and not binding and typeof(val)=="EnumItem" and i.KeyCode==val then
                    if hold then held=true else cb(val) end
                end
            end))
            maid:Add(UserInputService.InputEnded:Connect(function(i)
                if typeof(val)=="EnumItem" and i.KeyCode==val and hold and held then
                    held=false; cb(val)
                end
            end))

            local o = {}
            function o:Get() return val end
            function o:Set(k)
                if typeof(k)=="EnumItem" then val=k; kl.Text=k.Name
                elseif type(k)=="string" then pcall(function() val=Enum.KeyCode[k]; kl.Text=k end) end
            end
            return o
        end

        -- ── CreateColorPicker ─────────────────────────────────
        function Tab:CreateColorPicker(opts2)
            local flag = opts2.Flag
            local def  = opts2.Default or Color3.fromRGB(80, 180, 255)
            local cb   = opts2.Callback or function() end
            local val  = def; local open = false
            local hue, sat, bri = Color3.toHSV(def)

            local c = elem(36); c.ClipsDescendants = false; reg(c, opts2.Name)
            local nl = lbl(c, opts2.Name or "Color", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size = UDim2.new(1,-78,0,18); nl.Position = UDim2.new(0,12,0.5,-9)
            local prev = frm(c, UDim2.new(0,36,0,22), UDim2.new(1,-56,0.5,-11), val, 0)
            corner(prev,7); stroke(prev,T.ElementStroke,1,0)
            local al = lbl(c, Icons.chevronDown, 11, T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            al.Size = UDim2.new(0,16,0,18); al.Position = UDim2.new(1,-20,0.5,-9)

            -- picker panel
            local pk = frm(c, UDim2.new(1,0,0,0), UDim2.new(0,0,1,5), T.Topbar, 0)
            pk.ClipsDescendants=true; pk.ZIndex=8; pk.Visible=false
            corner(pk,10); stroke(pk,T.ElementStroke,1,0.2); pad(pk,8,8,8,8); lst(pk,6)

            local function applyCol()
                val = Color3.fromHSV(hue,sat,bri); prev.BackgroundColor3 = val; cb(val)
                if flag then NexusUI.Flags[flag]={val.R,val.G,val.B}; Win:SaveConfig() end
            end

            -- hue bar
            local hBar = frm(pk,UDim2.new(1,0,0,14),nil,T.ElementBackground,0); corner(hBar,5); hBar.LayoutOrder=1
            grad(hBar,{Color3.fromHSV(0,1,1),Color3.fromHSV(0.17,1,1),Color3.fromHSV(0.33,1,1),
                       Color3.fromHSV(0.5,1,1),Color3.fromHSV(0.67,1,1),Color3.fromHSV(0.83,1,1),Color3.fromHSV(1,1,1)},0)
            local hTh = frm(hBar,UDim2.new(0,4,1,4),UDim2.new(hue,-2,0,-2),Color3.new(1,1,1),0)
            corner(hTh,3); stroke(hTh,Color3.fromRGB(80,80,80),1,0)

            -- sv field
            local svB = frm(pk,UDim2.new(1,0,0,80),nil,Color3.fromHSV(hue,1,1),0); corner(svB,5); svB.LayoutOrder=2
            local svW = Instance.new("UIGradient")
            svW.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,1,1))})
            svW.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); svW.Parent=svB
            local svHf = frm(svB,UDim2.new(1,0,1,0),nil,Color3.new(0,0,0),0)
            local svHg = Instance.new("UIGradient"); svHg.Rotation=90
            svHg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
            svHg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); svHg.Parent=svHf
            local svTh = frm(svB,UDim2.new(0,12,0,12),UDim2.new(sat,-6,1-bri,-6),Color3.new(1,1,1),0)
            corner(svTh,6); stroke(svTh,Color3.fromRGB(80,80,80),1.5,0); svTh.ZIndex=3

            -- hex input row
            local hexRow = frm(pk,UDim2.new(1,0,0,26),nil,Color3.new(),1); hexRow.LayoutOrder=3
            local hexBg = frm(hexRow,UDim2.new(1,0,1,0),nil,T.InputBackground,0); corner(hexBg,6); stroke(hexBg,T.InputStroke,1,0.3)
            local hexPfx = lbl(hexBg,"#",10,T.TextMuted,Enum.Font.Code); hexPfx.Size=UDim2.new(0,14,1,0); hexPfx.Position=UDim2.new(0,6,0,0)
            local hexBox = Instance.new("TextBox")
            hexBox.Size=UDim2.new(1,-20,1,0); hexBox.Position=UDim2.new(0,20,0,0)
            hexBox.BackgroundTransparency=1; hexBox.Font=Enum.Font.Code; hexBox.TextSize=11
            hexBox.TextColor3=T.TextPrimary; hexBox.PlaceholderColor3=T.TextMuted
            hexBox.ClearTextOnFocus=false; hexBox.Parent=hexBg

            local function hexToColor(h2)
                local hex=h2:gsub("#",""); if #hex~=6 then return nil end
                local r,g,b=hex:sub(1,2),hex:sub(3,4),hex:sub(5,6)
                local ok,col=pcall(Color3.fromRGB,tonumber(r,16),tonumber(g,16),tonumber(b,16))
                return ok and col or nil
            end
            local function updateHex()
                hexBox.Text = string.format("%02X%02X%02X",
                    math.round(val.R*255),math.round(val.G*255),math.round(val.B*255))
            end
            updateHex()
            hexBox.FocusLost:Connect(function()
                local col = hexToColor(hexBox.Text)
                if col then
                    hue,sat,bri = col:ToHSV(); applyCol()
                    svB.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                    svW.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,1,1))})
                    tw(hTh,{Position=UDim2.new(hue,-2,0,-2)},TI_FAST)
                    tw(svTh,{Position=UDim2.new(sat,-6,1-bri,-6)},TI_FAST)
                else updateHex() end
            end)

            -- drag
            local dH, dSV = false, false
            local function hDrag(i)
                hue = math.clamp((i.Position.X-hBar.AbsolutePosition.X)/hBar.AbsoluteSize.X,0,1)
                tw(hTh,{Position=UDim2.new(hue,-2,0,-2)},TI_FAST)
                svB.BackgroundColor3=Color3.fromHSV(hue,1,1)
                svW.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,1,1))})
                applyCol(); updateHex()
            end
            local function svDrag(i)
                sat=math.clamp((i.Position.X-svB.AbsolutePosition.X)/svB.AbsoluteSize.X,0,1)
                bri=1-math.clamp((i.Position.Y-svB.AbsolutePosition.Y)/svB.AbsoluteSize.Y,0,1)
                tw(svTh,{Position=UDim2.new(sat,-6,1-bri,-6)},TI_FAST); applyCol(); updateHex()
            end
            maid:Add(hBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=true; hDrag(i) end end))
            maid:Add(svB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dSV=true; svDrag(i) end end))
            maid:Add(UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=false; dSV=false end end))
            maid:Add(UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseMovement then
                    if dH then hDrag(i) elseif dSV then svDrag(i) end
                end
            end))

            local mb = Instance.new("TextButton")
            mb.Size=UDim2.new(1,0,1,0); mb.BackgroundTransparency=1; mb.Text=""; mb.Parent=c
            maid:Add(mb.MouseButton1Click:Connect(function()
                open = not open; pk.Visible = true
                tw(pk,{Size=UDim2.new(1,0,0,open and 142 or 0)},TI_FAST)
                tw(al,{Rotation=open and 180 or 0},TI_FAST)
                if not open then task.delay(0.2, function() pk.Visible=false end) end
            end))

            local o = {}
            function o:Set(col)
                val=col; prev.BackgroundColor3=col; hue,sat,bri=col:ToHSV()
                svB.BackgroundColor3=Color3.fromHSV(hue,1,1)
                tw(hTh,{Position=UDim2.new(hue,-2,0,-2)},TI_FAST)
                tw(svTh,{Position=UDim2.new(sat,-6,1-bri,-6)},TI_FAST)
                updateHex()
            end
            function o:Get() return val end
            return o
        end

        -- ── Tab:Destroy ───────────────────────────────────────
        function Tab:Destroy()
            maid:Clean()
            if scroll and scroll.Parent then scroll:Destroy() end
            if tabBtn and tabBtn.Parent then tabBtn:Destroy() end
        end

        return Tab
    end

    -- ── Built-in Settings Tab ────────────────────────────────
    function Win:CreateSettingsTab()
        local st = self:CreateTab("Settings", Icons.settings)
        st:CreateSection("Theme")
        local thNames = {}; for n in pairs(THEMES) do table.insert(thNames,n) end; table.sort(thNames)
        st:CreateDropdown({
            Name="Preset Theme", Options=thNames, CurrentOption=themeName,
            Callback=function(v) self:SetTheme(v) end,
        })
        st:CreateSection("Accent Color")
        st:CreateColorPicker({
            Name="Accent Color", Default=T.Accent,
            Callback=function(col) self:SetAccent(col) end,
        })
        st:CreateSeparator()
        st:CreateSection("Keybind")
        st:CreateKeybind({
            Name="Toggle UI", CurrentKey=tKey,
            Callback=function(k) tKey=k end,
        })
        st:CreateSeparator()
        st:CreateSection("Info")
        st:CreateLabel("NexusUI v"..NexusUI.Version, Icons.info, T.TextSecondary)
        st:CreateButton({
            Name="Test Notification",
            Callback=function()
                self:Notify({Title="NexusUI", Content="Everything is working correctly!", Type="success", Duration=3})
            end,
        })
        st:CreateButton({
            Name="Save Config",
            Callback=function()
                self:SaveConfig()
                self:Notify({Title="Config", Content="Saved successfully", Type="success", Duration=2})
            end,
        })
        return st
    end

    return Win
end

return NexusUI
