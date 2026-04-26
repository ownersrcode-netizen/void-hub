--[[
╔══════════════════════════════════════════════════════════════════════════╗
║                        NEXUS UI  v2.0.0                                 ║
║              Inspired by Rayfield Interface Suite                        ║
║                                                                          ║
║  v2.0.0 FIXES & ADDITIONS:                                               ║
║  [FIX] Toggle no longer causes background to jump/expand on click.       ║
║        Root cause: elem() was setting AutomaticSize = Y on ALL elements, ║
║        including toggles with fixed heights. Paragraphs (which need      ║
║        auto height) now use elemAuto() instead.                          ║
║  [ADD] AnimConfig — every tween reads from NexusUI.AnimConfig.           ║
║        Change once, affects all motion. Full docs in animations/         ║
║  [ADD] Win:CreateProgressBar() element                                   ║
║  [ADD] Win:CreateToggle() — HoldToActivate option                        ║
║  [ADD] Win:SetSize(w, h) — live resize window                            ║
║  [ADD] Win:GetFlag(flag) / Win:SetFlag(flag, val)                        ║
║  [ADD] Tab:UpdateBadge(n) — update tab badge count live                  ║
║  [ADD] Config autosave debounce (no disk spam on sliders)                ║
║  [ADD] Dropdown closes on outside click                                  ║
║  [IMP] Notification queue: smooth repositioning on dismiss               ║
║  [IMP] Maid properly tracks tweens for GC                                ║
║  [IMP] All icons now support rbxassetid via NexusUI.Icons.Assets         ║
╚══════════════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local Debris           = game:GetService("Debris")

local LP = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
--  ANIMATION CONFIG  (editable at runtime or before CreateWindow)
--
--  NexusUI reads NexusUI.AnimConfig for every tween it plays.
--  You can override individual keys after requiring the library:
--
--      local UI = require(script.NexusUI)
--      UI.AnimConfig.FastDuration  = 0.08   -- snappier hovers
--      UI.AnimConfig.SpringStyle   = Enum.EasingStyle.Elastic
--      UI.AnimConfig.RippleDuration = 0.35
--
--  Or pass AnimConfig = {...} inside CreateWindow opts to get a
--  per-window config (merged with the global default).
--
--  The full config is also saved to animations/AnimConfig.json
--  in this repository so you can edit it visually and paste back.
-- ═══════════════════════════════════════════════════════════════
local DEFAULT_ANIM = {
    -- Micro-interactions: hover glow, toggle thumb slide, color shift
    FastDuration    = 0.13,
    FastStyle       = Enum.EasingStyle.Exponential,
    FastDirection   = Enum.EasingDirection.Out,

    -- Mid: tab switch, dropdown open, element fade-in
    MidDuration     = 0.22,
    MidStyle        = Enum.EasingStyle.Exponential,
    MidDirection    = Enum.EasingDirection.Out,

    -- Slow: loading screen, major state transitions
    SlowDuration    = 0.42,
    SlowStyle       = Enum.EasingStyle.Exponential,
    SlowDirection   = Enum.EasingDirection.Out,

    -- Spring: window open/minimize, notification pop-in
    SpringDuration  = 0.38,
    SpringStyle     = Enum.EasingStyle.Back,
    SpringDirection = Enum.EasingDirection.Out,

    -- Slider drag — should feel instant/direct
    SliderDuration  = 0.06,
    SliderStyle     = Enum.EasingStyle.Linear,
    SliderDirection = Enum.EasingDirection.Out,

    -- Ripple click effect
    RippleDuration  = 0.50,
    RippleStyle     = Enum.EasingStyle.Quad,
    RippleDirection = Enum.EasingDirection.Out,

    -- Notification progress drain
    NotifyProgressStyle     = Enum.EasingStyle.Linear,
    NotifyProgressDirection = Enum.EasingDirection.Out,

    -- Config autosave debounce in seconds (prevents disk spam on sliders)
    SaveDebounce    = 1.2,
}

-- ═══════════════════════════════════════════════════════════════
--  ICONS
--  NexusUI.Icons.Symbols — unicode glyphs (always available)
--  NexusUI.Icons.Assets  — map icon name → rbxassetid://XXXXX
--                          Fill in asset IDs after uploading the
--                          SVG files from /icons/svg/ to Roblox.
-- ═══════════════════════════════════════════════════════════════
local Icons = {}

Icons.Symbols = {
    -- Navigation
    home         = "🏠",  settings     = "⚙",   search       = "🔍",
    close        = "✕",   minimize     = "─",   maximize     = "□",
    pin          = "📌",  menu         = "☰",   back         = "←",
    forward      = "→",  up           = "↑",   down         = "↓",
    chevronDown  = "▾",  chevronUp    = "▴",   chevronRight = "▸",
    chevronLeft  = "◂",  refresh      = "↺",
    -- Actions
    play         = "▶",  pause        = "⏸",  stop         = "⏹",
    save         = "💾", copy         = "📋", edit         = "✏",
    delete       = "🗑", add          = "+",   remove       = "−",
    check        = "✓",  cross        = "✕",  upload       = "⬆",
    download     = "⬇",  link         = "🔗", filter       = "⊟",
    sort         = "⇅",
    -- Status
    info         = "ℹ",  warning      = "⚠",  error        = "⊘",
    success      = "✓",  star         = "★",  starEmpty    = "☆",
    heart        = "♥",  heartEmpty   = "♡",  lock         = "🔒",
    unlock       = "🔓", eye          = "👁",  eyeOff       = "⊘",
    bell         = "🔔", bellOff      = "🔕", flag         = "⚑",
    -- Game / Category
    game         = "🎮", player       = "👤", players      = "👥",
    world        = "🌐", shield       = "🛡",  sword        = "⚔",
    magic        = "✨", fire         = "🔥", lightning    = "⚡",
    target       = "🎯", key          = "🔑",
    -- Tech
    code         = "⟨/⟩", terminal   = "⌨",  cpu          = "⊞",
    memory       = "▦",  network      = "⊙",  database     = "🗄",
    cloud        = "☁",  folder       = "📁", file         = "📄",
    image        = "🖼",  video        = "🎬", audio        = "🎵",
    -- Misc
    dot          = "•",  diamond      = "◆",  circle       = "○",
    circleFull   = "●",  square       = "□",  squareFull   = "■",
    triangle     = "△",  triangleFull = "▲",  infinite     = "∞",
    percent      = "%",  clock        = "🕐",  calendar     = "📅",
    map          = "🗺",  compass      = "🧭", wrench       = "🔧",
    sliders      = "⊟",  chart        = "📊", trending     = "📈",
    trendingDown = "📉", power        = "⏻",  wifi         = "📶",
    battery      = "🔋",
}

-- Replace 0 with your uploaded Roblox asset IDs.
-- These correspond 1-to-1 with the SVG files in /icons/svg/.
Icons.Assets = {
    home="rbxassetid://0",        settings="rbxassetid://0",
    search="rbxassetid://0",      close="rbxassetid://0",
    chevronDown="rbxassetid://0", chevronRight="rbxassetid://0",
    chevronLeft="rbxassetid://0", refresh="rbxassetid://0",
    play="rbxassetid://0",        pause="rbxassetid://0",
    stop="rbxassetid://0",        save="rbxassetid://0",
    copy="rbxassetid://0",        edit="rbxassetid://0",
    delete="rbxassetid://0",      add="rbxassetid://0",
    check="rbxassetid://0",       cross="rbxassetid://0",
    upload="rbxassetid://0",      download="rbxassetid://0",
    link="rbxassetid://0",        filter="rbxassetid://0",
    sort="rbxassetid://0",        info="rbxassetid://0",
    warning="rbxassetid://0",     error="rbxassetid://0",
    success="rbxassetid://0",     star="rbxassetid://0",
    heart="rbxassetid://0",       lock="rbxassetid://0",
    unlock="rbxassetid://0",      eye="rbxassetid://0",
    eyeOff="rbxassetid://0",      bell="rbxassetid://0",
    flag="rbxassetid://0",        game="rbxassetid://0",
    player="rbxassetid://0",      players="rbxassetid://0",
    world="rbxassetid://0",       shield="rbxassetid://0",
    sword="rbxassetid://0",       magic="rbxassetid://0",
    fire="rbxassetid://0",        lightning="rbxassetid://0",
    target="rbxassetid://0",      key="rbxassetid://0",
    code="rbxassetid://0",        terminal="rbxassetid://0",
    database="rbxassetid://0",    cloud="rbxassetid://0",
    folder="rbxassetid://0",      file="rbxassetid://0",
    chart="rbxassetid://0",       wrench="rbxassetid://0",
    sliders="rbxassetid://0",     power="rbxassetid://0",
    wifi="rbxassetid://0",        battery="rbxassetid://0",
    clock="rbxassetid://0",       calendar="rbxassetid://0",
    network="rbxassetid://0",
}

-- Helper: get symbol string (fallback to empty if unknown)
function Icons:Get(name) return self.Symbols[name] or "" end

-- Helper: create an ImageLabel from Assets map.
-- Returns nil if the asset ID is still placeholder (0).
function Icons:CreateImage(name, parent, size, pos, color)
    local id = self.Assets[name]
    if not id or id == "rbxassetid://0" then return nil end
    local img            = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image            = id
    img.ImageColor3      = color or Color3.new(1,1,1)
    img.Size             = size  or UDim2.new(0,16,0,16)
    img.Position         = pos   or UDim2.new(0,0,0,0)
    img.ScaleType        = Enum.ScaleType.Fit
    img.Parent           = parent
    return img
end

-- Backwards-compat: Icons.settings, Icons.home, etc. still work
setmetatable(Icons, {__index = function(t,k) return t.Symbols[k] end})

-- ═══════════════════════════════════════════════════════════════
--  THEMES
-- ═══════════════════════════════════════════════════════════════
local THEMES = {
    Default = {
        Background       = Color3.fromRGB(25,25,25),
        Topbar           = Color3.fromRGB(34,34,34),
        TabBackground    = Color3.fromRGB(30,30,30),
        TabSelected      = Color3.fromRGB(50,138,220),
        TabText          = Color3.fromRGB(170,170,170),
        TabTextSelected  = Color3.fromRGB(255,255,255),
        ElementBackground= Color3.fromRGB(35,35,35),
        ElementHover     = Color3.fromRGB(42,42,42),
        ElementStroke    = Color3.fromRGB(50,50,50),
        TextPrimary      = Color3.fromRGB(240,240,240),
        TextSecondary    = Color3.fromRGB(160,160,160),
        TextMuted        = Color3.fromRGB(100,100,100),
        Accent           = Color3.fromRGB(50,138,220),
        AccentDark       = Color3.fromRGB(30,100,170),
        AccentLight      = Color3.fromRGB(90,170,255),
        ToggleOn         = Color3.fromRGB(0,146,214),
        ToggleOff        = Color3.fromRGB(80,80,80),
        SliderFill       = Color3.fromRGB(50,138,220),
        InputBackground  = Color3.fromRGB(30,30,30),
        InputStroke      = Color3.fromRGB(65,65,65),
        NotifyBackground = Color3.fromRGB(28,28,28),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(10,10,10),
        Divider          = Color3.fromRGB(45,45,45),
    },
    Ocean = {
        Background       = Color3.fromRGB(15,28,38),
        Topbar           = Color3.fromRGB(20,38,52),
        TabBackground    = Color3.fromRGB(18,34,46),
        TabSelected      = Color3.fromRGB(0,150,180),
        TabText          = Color3.fromRGB(120,160,180),
        TabTextSelected  = Color3.fromRGB(220,245,255),
        ElementBackground= Color3.fromRGB(22,42,58),
        ElementHover     = Color3.fromRGB(28,52,70),
        ElementStroke    = Color3.fromRGB(35,65,88),
        TextPrimary      = Color3.fromRGB(220,240,255),
        TextSecondary    = Color3.fromRGB(120,165,195),
        TextMuted        = Color3.fromRGB(70,110,140),
        Accent           = Color3.fromRGB(0,180,220),
        AccentDark       = Color3.fromRGB(0,120,160),
        AccentLight      = Color3.fromRGB(80,220,255),
        ToggleOn         = Color3.fromRGB(0,180,220),
        ToggleOff        = Color3.fromRGB(40,75,100),
        SliderFill       = Color3.fromRGB(0,170,210),
        InputBackground  = Color3.fromRGB(18,34,46),
        InputStroke      = Color3.fromRGB(40,75,100),
        NotifyBackground = Color3.fromRGB(18,35,48),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(5,12,18),
        Divider          = Color3.fromRGB(30,58,78),
    },
    Amethyst = {
        Background       = Color3.fromRGB(22,15,35),
        Topbar           = Color3.fromRGB(32,20,48),
        TabBackground    = Color3.fromRGB(28,18,44),
        TabSelected      = Color3.fromRGB(148,80,220),
        TabText          = Color3.fromRGB(160,120,200),
        TabTextSelected  = Color3.fromRGB(240,220,255),
        ElementBackground= Color3.fromRGB(35,22,55),
        ElementHover     = Color3.fromRGB(44,28,68),
        ElementStroke    = Color3.fromRGB(65,40,95),
        TextPrimary      = Color3.fromRGB(238,228,255),
        TextSecondary    = Color3.fromRGB(160,130,200),
        TextMuted        = Color3.fromRGB(100,75,140),
        Accent           = Color3.fromRGB(160,90,240),
        AccentDark       = Color3.fromRGB(110,55,180),
        AccentLight      = Color3.fromRGB(200,150,255),
        ToggleOn         = Color3.fromRGB(160,90,240),
        ToggleOff        = Color3.fromRGB(70,45,105),
        SliderFill       = Color3.fromRGB(150,80,230),
        InputBackground  = Color3.fromRGB(28,18,44),
        InputStroke      = Color3.fromRGB(75,48,110),
        NotifyBackground = Color3.fromRGB(28,18,45),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(8,5,15),
        Divider          = Color3.fromRGB(55,35,80),
    },
    Crimson = {
        Background       = Color3.fromRGB(28,10,12),
        Topbar           = Color3.fromRGB(40,14,17),
        TabBackground    = Color3.fromRGB(34,12,15),
        TabSelected      = Color3.fromRGB(200,40,55),
        TabText          = Color3.fromRGB(180,100,110),
        TabTextSelected  = Color3.fromRGB(255,230,232),
        ElementBackground= Color3.fromRGB(42,15,18),
        ElementHover     = Color3.fromRGB(55,20,24),
        ElementStroke    = Color3.fromRGB(80,28,34),
        TextPrimary      = Color3.fromRGB(255,228,230),
        TextSecondary    = Color3.fromRGB(200,140,148),
        TextMuted        = Color3.fromRGB(130,75,82),
        Accent           = Color3.fromRGB(220,50,65),
        AccentDark       = Color3.fromRGB(160,28,40),
        AccentLight      = Color3.fromRGB(255,100,115),
        ToggleOn         = Color3.fromRGB(220,50,65),
        ToggleOff        = Color3.fromRGB(90,30,36),
        SliderFill       = Color3.fromRGB(210,45,60),
        InputBackground  = Color3.fromRGB(34,12,15),
        InputStroke      = Color3.fromRGB(90,32,38),
        NotifyBackground = Color3.fromRGB(36,12,16),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(8,2,3),
        Divider          = Color3.fromRGB(68,24,30),
    },
    Amber = {
        Background       = Color3.fromRGB(28,20,10),
        Topbar           = Color3.fromRGB(40,28,12),
        TabBackground    = Color3.fromRGB(34,24,10),
        TabSelected      = Color3.fromRGB(210,150,40),
        TabText          = Color3.fromRGB(180,140,80),
        TabTextSelected  = Color3.fromRGB(255,245,210),
        ElementBackground= Color3.fromRGB(42,30,14),
        ElementHover     = Color3.fromRGB(55,40,18),
        ElementStroke    = Color3.fromRGB(85,62,28),
        TextPrimary      = Color3.fromRGB(255,245,215),
        TextSecondary    = Color3.fromRGB(200,170,100),
        TextMuted        = Color3.fromRGB(135,110,60),
        Accent           = Color3.fromRGB(225,165,45),
        AccentDark       = Color3.fromRGB(170,120,25),
        AccentLight      = Color3.fromRGB(255,210,80),
        ToggleOn         = Color3.fromRGB(225,165,45),
        ToggleOff        = Color3.fromRGB(90,65,22),
        SliderFill       = Color3.fromRGB(215,155,40),
        InputBackground  = Color3.fromRGB(34,24,10),
        InputStroke      = Color3.fromRGB(95,70,30),
        NotifyBackground = Color3.fromRGB(36,26,12),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(8,6,2),
        Divider          = Color3.fromRGB(72,52,22),
    },
    Midnight = {
        Background       = Color3.fromRGB(8,10,16),
        Topbar           = Color3.fromRGB(12,15,24),
        TabBackground    = Color3.fromRGB(10,13,20),
        TabSelected      = Color3.fromRGB(60,100,200),
        TabText          = Color3.fromRGB(100,120,170),
        TabTextSelected  = Color3.fromRGB(220,230,255),
        ElementBackground= Color3.fromRGB(14,18,28),
        ElementHover     = Color3.fromRGB(18,24,38),
        ElementStroke    = Color3.fromRGB(28,38,60),
        TextPrimary      = Color3.fromRGB(218,225,248),
        TextSecondary    = Color3.fromRGB(130,148,200),
        TextMuted        = Color3.fromRGB(70,85,130),
        Accent           = Color3.fromRGB(80,130,230),
        AccentDark       = Color3.fromRGB(45,85,175),
        AccentLight      = Color3.fromRGB(120,170,255),
        ToggleOn         = Color3.fromRGB(75,125,225),
        ToggleOff        = Color3.fromRGB(35,48,80),
        SliderFill       = Color3.fromRGB(70,120,220),
        InputBackground  = Color3.fromRGB(10,14,22),
        InputStroke      = Color3.fromRGB(32,45,75),
        NotifyBackground = Color3.fromRGB(12,16,26),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(2,3,6),
        Divider          = Color3.fromRGB(22,30,50),
    },
    Sakura = {
        Background       = Color3.fromRGB(255,242,248),
        Topbar           = Color3.fromRGB(248,224,236),
        TabBackground    = Color3.fromRGB(250,232,242),
        TabSelected      = Color3.fromRGB(220,110,155),
        TabText          = Color3.fromRGB(180,110,145),
        TabTextSelected  = Color3.fromRGB(255,240,248),
        ElementBackground= Color3.fromRGB(255,236,246),
        ElementHover     = Color3.fromRGB(248,220,236),
        ElementStroke    = Color3.fromRGB(230,195,218),
        TextPrimary      = Color3.fromRGB(80,40,60),
        TextSecondary    = Color3.fromRGB(160,100,135),
        TextMuted        = Color3.fromRGB(200,155,180),
        Accent           = Color3.fromRGB(228,120,165),
        AccentDark       = Color3.fromRGB(185,80,125),
        AccentLight      = Color3.fromRGB(255,170,205),
        ToggleOn         = Color3.fromRGB(225,115,160),
        ToggleOff        = Color3.fromRGB(210,175,195),
        SliderFill       = Color3.fromRGB(220,110,155),
        InputBackground  = Color3.fromRGB(255,236,246),
        InputStroke      = Color3.fromRGB(220,185,208),
        NotifyBackground = Color3.fromRGB(255,238,248),
        Success          = Color3.fromRGB(46,160,100),
        Warning          = Color3.fromRGB(200,155,20),
        Error            = Color3.fromRGB(200,70,80),
        Shadow           = Color3.fromRGB(200,160,185),
        Divider          = Color3.fromRGB(225,192,214),
    },
    Neon = {
        Background       = Color3.fromRGB(5,5,8),
        Topbar           = Color3.fromRGB(8,8,14),
        TabBackground    = Color3.fromRGB(6,6,10),
        TabSelected      = Color3.fromRGB(0,255,180),
        TabText          = Color3.fromRGB(80,180,140),
        TabTextSelected  = Color3.fromRGB(5,5,8),
        ElementBackground= Color3.fromRGB(8,8,14),
        ElementHover     = Color3.fromRGB(12,14,22),
        ElementStroke    = Color3.fromRGB(0,80,60),
        TextPrimary      = Color3.fromRGB(200,255,240),
        TextSecondary    = Color3.fromRGB(0,200,150),
        TextMuted        = Color3.fromRGB(0,100,80),
        Accent           = Color3.fromRGB(0,255,180),
        AccentDark       = Color3.fromRGB(0,180,120),
        AccentLight      = Color3.fromRGB(100,255,220),
        ToggleOn         = Color3.fromRGB(0,255,180),
        ToggleOff        = Color3.fromRGB(0,60,45),
        SliderFill       = Color3.fromRGB(0,240,170),
        InputBackground  = Color3.fromRGB(6,8,12),
        InputStroke      = Color3.fromRGB(0,100,75),
        NotifyBackground = Color3.fromRGB(6,8,14),
        Success          = Color3.fromRGB(0,255,180),
        Warning          = Color3.fromRGB(255,220,0),
        Error            = Color3.fromRGB(255,50,80),
        Shadow           = Color3.fromRGB(0,20,15),
        Divider          = Color3.fromRGB(0,60,45),
    },
    Carbon = {
        Background       = Color3.fromRGB(18,18,20),
        Topbar           = Color3.fromRGB(26,26,30),
        TabBackground    = Color3.fromRGB(22,22,26),
        TabSelected      = Color3.fromRGB(255,255,255),
        TabText          = Color3.fromRGB(140,140,148),
        TabTextSelected  = Color3.fromRGB(10,10,12),
        ElementBackground= Color3.fromRGB(28,28,32),
        ElementHover     = Color3.fromRGB(36,36,42),
        ElementStroke    = Color3.fromRGB(48,48,56),
        TextPrimary      = Color3.fromRGB(248,248,252),
        TextSecondary    = Color3.fromRGB(160,160,172),
        TextMuted        = Color3.fromRGB(90,90,100),
        Accent           = Color3.fromRGB(255,255,255),
        AccentDark       = Color3.fromRGB(180,180,200),
        AccentLight      = Color3.fromRGB(255,255,255),
        ToggleOn         = Color3.fromRGB(240,240,255),
        ToggleOff        = Color3.fromRGB(60,60,70),
        SliderFill       = Color3.fromRGB(220,220,240),
        InputBackground  = Color3.fromRGB(22,22,26),
        InputStroke      = Color3.fromRGB(52,52,62),
        NotifyBackground = Color3.fromRGB(24,24,28),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(5,5,6),
        Divider          = Color3.fromRGB(40,40,48),
    },
    Rose = {
        Background       = Color3.fromRGB(20,14,16),
        Topbar           = Color3.fromRGB(30,20,24),
        TabBackground    = Color3.fromRGB(26,17,20),
        TabSelected      = Color3.fromRGB(255,90,120),
        TabText          = Color3.fromRGB(180,120,135),
        TabTextSelected  = Color3.fromRGB(255,235,240),
        ElementBackground= Color3.fromRGB(34,22,27),
        ElementHover     = Color3.fromRGB(44,28,35),
        ElementStroke    = Color3.fromRGB(65,38,48),
        TextPrimary      = Color3.fromRGB(255,232,238),
        TextSecondary    = Color3.fromRGB(200,145,163),
        TextMuted        = Color3.fromRGB(130,85,100),
        Accent           = Color3.fromRGB(255,90,120),
        AccentDark       = Color3.fromRGB(200,55,85),
        AccentLight      = Color3.fromRGB(255,150,170),
        ToggleOn         = Color3.fromRGB(255,90,120),
        ToggleOff        = Color3.fromRGB(90,40,52),
        SliderFill       = Color3.fromRGB(245,80,110),
        InputBackground  = Color3.fromRGB(26,17,20),
        InputStroke      = Color3.fromRGB(75,42,55),
        NotifyBackground = Color3.fromRGB(28,18,22),
        Success          = Color3.fromRGB(46,204,113),
        Warning          = Color3.fromRGB(241,196,15),
        Error            = Color3.fromRGB(231,76,60),
        Shadow           = Color3.fromRGB(6,3,4),
        Divider          = Color3.fromRGB(58,32,42),
    },
}

-- ═══════════════════════════════════════════════════════════════
--  MAID  (connection / instance garbage-collector)
-- ═══════════════════════════════════════════════════════════════
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(x)
    table.insert(self._tasks, x)
    return x
end

function Maid:Clean()
    for _, t in ipairs(self._tasks) do
        if typeof(t) == "RBXScriptConnection" then
            pcall(function() t:Disconnect() end)
        elseif typeof(t) == "Instance" then
            pcall(function() t:Destroy() end)
        elseif typeof(t) == "RBXScriptSignal" then
            -- skip, shouldn't be added directly
        elseif type(t) == "function" then
            pcall(t)
        end
    end
    self._tasks = {}
end

-- ═══════════════════════════════════════════════════════════════
--  UI HELPERS
-- ═══════════════════════════════════════════════════════════════

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color
    s.Thickness    = thickness    or 1
    s.Transparency = transparency or 0
    s.Parent       = parent
    return s
end

local function pad(parent, top, right, bottom, left)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, top    or 8)
    u.PaddingRight  = UDim.new(0, right  or 8)
    u.PaddingBottom = UDim.new(0, bottom or 8)
    u.PaddingLeft   = UDim.new(0, left   or 8)
    u.Parent        = parent
    return u
end

local function listLayout(parent, spacing, direction)
    local u = Instance.new("UIListLayout")
    u.SortOrder     = Enum.SortOrder.LayoutOrder
    u.FillDirection = direction or Enum.FillDirection.Vertical
    u.Padding       = UDim.new(0, spacing or 0)
    u.Parent        = parent
    return u
end

local function frame(parent, size, position, bgColor, transparency)
    local f = Instance.new("Frame")
    f.Size                  = size         or UDim2.new(1,0,1,0)
    f.Position              = position     or UDim2.new(0,0,0,0)
    f.BackgroundColor3      = bgColor      or Color3.fromRGB(30,30,30)
    f.BackgroundTransparency= transparency or 0
    f.BorderSizePixel       = 0
    f.Parent                = parent
    return f
end

local function label(parent, text, textSize, color, font, xAlignment)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text       or ""
    l.TextSize       = textSize   or 13
    l.TextColor3     = color      or Color3.new(1,1,1)
    l.Font           = font       or Enum.Font.GothamMedium
    l.TextXAlignment = xAlignment or Enum.TextXAlignment.Left
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    l.Parent         = parent
    return l
end

local function gradient(parent, colors, rotation)
    local g = Instance.new("UIGradient")
    local keypoints = {}
    for i, v in ipairs(colors) do
        keypoints[i] = ColorSequenceKeypoint.new((i-1)/(#colors-1), v)
    end
    g.Color    = ColorSequence.new(keypoints)
    g.Rotation = rotation or 0
    g.Parent   = parent
    return g
end

local function bindScrollCanvas(scroll, layout)
    local function update()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function rippleEffect(parent, localX, localY, animConfig)
    local ac  = animConfig
    local r   = Instance.new("Frame")
    r.BackgroundColor3      = Color3.new(1,1,1)
    r.BackgroundTransparency= 0.75
    r.BorderSizePixel       = 0
    r.Size                  = UDim2.new(0,0,0,0)
    r.Position              = UDim2.new(0, localX, 0, localY)
    r.AnchorPoint           = Vector2.new(0.5, 0.5)
    r.ZIndex                = 20
    r.Parent                = parent
    corner(r, 999)
    local sz = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    TweenService:Create(r,
        TweenInfo.new(ac.RippleDuration, ac.RippleStyle, ac.RippleDirection),
        { Size = UDim2.new(0,sz,0,sz), BackgroundTransparency = 1 }
    ):Play()
    Debris:AddItem(r, ac.RippleDuration + 0.05)
end

local function mouseRelative(obj)
    local mp = UserInputService:GetMouseLocation()
    return mp.X - obj.AbsolutePosition.X, mp.Y - obj.AbsolutePosition.Y
end

-- ═══════════════════════════════════════════════════════════════
--  CONFIG SAVE / LOAD  (autosave with debounce)
-- ═══════════════════════════════════════════════════════════════
local CFG_FOLDER = "NexusUI"

local function cfgSave(name, data)
    pcall(function()
        if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
        writefile(CFG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
end

local function cfgLoad(name)
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(CFG_FOLDER .. "/" .. name .. ".json"))
    end)
    return ok and result or {}
end

-- ═══════════════════════════════════════════════════════════════
--  GLOBAL HOTKEYS
-- ═══════════════════════════════════════════════════════════════
local _hotkeys = {}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _, h in pairs(_hotkeys) do
        if h and input.KeyCode == h.key then pcall(h.cb) end
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY OBJECT
-- ═══════════════════════════════════════════════════════════════
local NexusUI       = {}
NexusUI.__index     = NexusUI
NexusUI.Version     = "2.0.0"
NexusUI.Flags       = {}
NexusUI.Icons       = Icons
NexusUI.Themes      = THEMES
NexusUI.AnimConfig  = {}
for k, v in pairs(DEFAULT_ANIM) do NexusUI.AnimConfig[k] = v end

-- Build TweenInfo objects from the live AnimConfig table
local function makeTI(speed, animConfig)
    local ac = animConfig or NexusUI.AnimConfig
    if speed == "fast" then
        return TweenInfo.new(ac.FastDuration, ac.FastStyle, ac.FastDirection)
    elseif speed == "mid" then
        return TweenInfo.new(ac.MidDuration, ac.MidStyle, ac.MidDirection)
    elseif speed == "slow" then
        return TweenInfo.new(ac.SlowDuration, ac.SlowStyle, ac.SlowDirection)
    elseif speed == "spring" then
        return TweenInfo.new(ac.SpringDuration, ac.SpringStyle, ac.SpringDirection)
    elseif speed == "slider" then
        return TweenInfo.new(ac.SliderDuration, ac.SliderStyle, ac.SliderDirection)
    end
    return TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
end

local function tw(obj, props, speed, animConfig)
    if not obj or not obj.Parent then return end
    local ti = (type(speed) == "string") and makeTI(speed, animConfig) or (speed or makeTI("mid", animConfig))
    TweenService:Create(obj, ti, props):Play()
end

-- ═══════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════
local _notifyGui, _notifyHolder, _notifyStack = nil, nil, {}

local function initNotifications()
    if _notifyGui then return end
    _notifyGui              = Instance.new("ScreenGui")
    _notifyGui.Name         = "NexusUI_Notify"
    _notifyGui.ResetOnSpawn = false
    _notifyGui.IgnoreGuiInset   = true
    _notifyGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    _notifyGui.Parent           = LP.PlayerGui

    _notifyHolder = frame(_notifyGui, UDim2.new(0,320,1,-10), UDim2.new(1,-330,0,0), Color3.new(), 1)
    local ul = listLayout(_notifyHolder, 8)
    ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
    pad(_notifyHolder, 0, 0, 16, 0)
end

function NexusUI:Notify(opts)
    initNotifications()
    local ac      = NexusUI.AnimConfig
    local title   = opts.Title    or "NexusUI"
    local content = opts.Content  or ""
    local duration= opts.Duration or 4
    local ntype   = opts.Type     or "info"

    local iconMap = {
        info    = Icons.Symbols.info,
        success = Icons.Symbols.success,
        warning = Icons.Symbols.warning,
        error   = Icons.Symbols.error,
    }
    local colorMap = {
        info    = Color3.fromRGB(60,140,220),
        success = Color3.fromRGB(46,204,113),
        warning = Color3.fromRGB(241,196,15),
        error   = Color3.fromRGB(231,76,60),
    }
    local accentColor = colorMap[ntype] or colorMap.info
    local iconSymbol  = iconMap[ntype]  or Icons.Symbols.info

    -- Discard oldest if queue full
    if #_notifyStack >= 5 then
        local oldest = table.remove(_notifyStack, 1)
        if oldest and oldest.Parent then
            tw(oldest, { BackgroundTransparency = 1 }, makeTI("fast", ac))
            task.delay(0.2, function()
                if oldest and oldest.Parent then oldest:Destroy() end
            end)
        end
    end

    local T = opts.Theme or {
        NotifyBackground = Color3.fromRGB(28,28,28),
        TextPrimary      = Color3.fromRGB(240,240,240),
        TextSecondary    = Color3.fromRGB(160,160,160),
        ElementStroke    = Color3.fromRGB(50,50,50),
    }

    -- Notification frame — fixed size, no AutomaticSize
    local nf = frame(_notifyHolder, UDim2.new(1,0,0,74), nil, T.NotifyBackground, 0)
    nf.ClipsDescendants = true
    nf.LayoutOrder      = tick()
    corner(nf, 10)
    stroke(nf, T.ElementStroke, 1, 0.4)

    -- Left accent bar
    frame(nf, UDim2.new(0,3,0.7,0), UDim2.new(0,0,0.15,0), accentColor, 0)

    -- Icon background
    local icf = frame(nf, UDim2.new(0,30,0,30), UDim2.new(0,14,0,12), accentColor, 0.85)
    corner(icf, 8)
    frame(icf, UDim2.new(1,0,1,0), nil, accentColor, 0.7)
    local icl = label(icf, iconSymbol, 14, accentColor, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    icl.Size = UDim2.new(1,0,1,0)

    -- Title and content text
    local titleLabel = label(nf, title, 13, T.TextPrimary, Enum.Font.GothamBold)
    titleLabel.Size     = UDim2.new(1,-62,0,16)
    titleLabel.Position = UDim2.new(0,52,0,10)

    local contentLabel = label(nf, content, 11, T.TextSecondary, Enum.Font.Gotham)
    contentLabel.Size        = UDim2.new(1,-62,0,30)
    contentLabel.Position    = UDim2.new(0,52,0,28)
    contentLabel.TextWrapped = true
    contentLabel.TextTruncate= Enum.TextTruncate.None

    -- Close button
    local closeBtn          = Instance.new("TextButton")
    closeBtn.Size           = UDim2.new(0,18,0,18)
    closeBtn.Position       = UDim2.new(1,-24,0,8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text           = "✕"
    closeBtn.TextSize       = 9
    closeBtn.TextColor3     = T.TextSecondary
    closeBtn.Font           = Enum.Font.GothamBold
    closeBtn.Parent         = nf

    -- Progress bar (drains left-to-right)
    local pbg = frame(nf, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), Color3.fromRGB(40,40,40), 0)
    local pb  = frame(pbg, UDim2.new(1,0,1,0), nil, accentColor, 0)

    -- Slide in
    nf.Position = UDim2.new(1,20,0,0)
    tw(nf, { Position = UDim2.new(0,0,0,0) }, makeTI("spring", ac))
    table.insert(_notifyStack, nf)

    -- Drain progress bar
    TweenService:Create(pb,
        TweenInfo.new(duration, ac.NotifyProgressStyle, ac.NotifyProgressDirection),
        { Size = UDim2.new(0,0,1,0) }
    ):Play()

    local function dismiss()
        local idx = table.find(_notifyStack, nf)
        if idx then table.remove(_notifyStack, idx) end
        tw(nf, { Position = UDim2.new(1,20,0,0), BackgroundTransparency = 1 }, makeTI("mid", ac))
        task.delay(0.35, function()
            if nf and nf.Parent then nf:Destroy() end
        end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    nf.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dismiss() end
    end)
    task.delay(duration, dismiss)
end

-- ═══════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
local function showLoadingScreen(opts, theme, animConfig)
    local T   = theme
    local ac  = animConfig
    local titleText = opts.LoadingTitle    or "NEXUS UI"
    local subtitle  = opts.LoadingSubtitle or ""
    local steps     = opts.LoadingSteps    or { "Initializing…", "Loading components…", "Ready!" }
    local logoText  = opts.Logo            or "NEXUS"

    local sg              = Instance.new("ScreenGui")
    sg.Name               = "NexusUI_Loading"
    sg.ResetOnSpawn       = false
    sg.IgnoreGuiInset     = true
    sg.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
    sg.Parent             = LP.PlayerGui

    local overlay = frame(sg, UDim2.new(1,0,1,0), nil, Color3.fromRGB(0,0,0), 0.5)

    local card = frame(sg, UDim2.new(0,480,0,280), UDim2.new(0.5,-240,0.5,-140), T.Background, 1)
    corner(card, 14)
    stroke(card, T.ElementStroke, 1, 0.3)

    -- Top accent stripe
    local topStripe = frame(card, UDim2.new(1,0,0,3), nil, T.Accent, 0)
    corner(topStripe, 14)
    gradient(topStripe, { T.AccentLight, T.Accent, T.AccentDark }, 0)

    -- Glow image
    local glowImg = Instance.new("ImageLabel")
    glowImg.Size                  = UDim2.new(1,60,0,120)
    glowImg.Position              = UDim2.new(0,-30,0,-40)
    glowImg.BackgroundTransparency= 1
    glowImg.Image                 = "rbxassetid://5028857084"
    glowImg.ImageColor3           = T.Accent
    glowImg.ImageTransparency     = 0.92
    glowImg.ScaleType             = Enum.ScaleType.Slice
    glowImg.SliceCenter           = Rect.new(24,24,276,276)
    glowImg.Parent                = card

    -- Logo
    local logoLabel = label(card, logoText, 48, T.Accent, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    logoLabel.Size     = UDim2.new(1,0,0,62)
    logoLabel.Position = UDim2.new(0,0,0,22)

    -- Title & subtitle
    local titleLabel = label(card, titleText, 15, T.TextPrimary, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    titleLabel.Size     = UDim2.new(1,-40,0,22)
    titleLabel.Position = UDim2.new(0,20,0,94)

    local subLabel = label(card, subtitle, 11, T.TextSecondary, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    subLabel.Size     = UDim2.new(1,-40,0,16)
    subLabel.Position = UDim2.new(0,20,0,118)

    -- Divider
    frame(card, UDim2.new(1,-40,0,1), UDim2.new(0,20,0,144), T.Divider, 0)

    -- Step text
    local stepLabel = label(card, steps[1], 10, T.Accent, Enum.Font.Code, Enum.TextXAlignment.Center)
    stepLabel.Size     = UDim2.new(1,-40,0,14)
    stepLabel.Position = UDim2.new(0,20,0,156)

    -- Progress bar
    local pbg = frame(card, UDim2.new(1,-40,0,5), UDim2.new(0,20,0,178), T.ElementBackground, 0)
    corner(pbg, 6)
    stroke(pbg, T.ElementStroke, 1, 0.5)
    local pb = frame(pbg, UDim2.new(0,0,1,0), nil, T.Accent, 0)
    corner(pb, 6)
    gradient(pb, { T.AccentLight, T.Accent }, 0)

    -- Bouncing dots
    local dotsHolder = frame(card, UDim2.new(1,0,0,16), UDim2.new(0,0,0,200), Color3.new(), 1)
    local dl = listLayout(dotsHolder, 6, Enum.FillDirection.Horizontal)
    dl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local dots = {}
    for i = 1, 3 do
        local d = frame(dotsHolder, UDim2.new(0,6,0,6), nil, T.Accent, 0.5)
        d.LayoutOrder = i; corner(d, 99)
        table.insert(dots, d)
    end

    -- Version
    local versionLabel = label(card, "nexus ui v" .. NexusUI.Version, 9, T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    versionLabel.Size     = UDim2.new(1,-40,0,12)
    versionLabel.Position = UDim2.new(0,20,0,224)

    -- Animate in
    tw(overlay, { BackgroundTransparency = 0.65 }, makeTI("mid", ac))
    tw(card,    { BackgroundTransparency = 0     }, makeTI("spring", ac))

    local dotConn = RunService.Heartbeat:Connect(function()
        local t = tick()
        for i, d in ipairs(dots) do
            local phase = ((t * 2) + (i-1) * 0.4) % 1
            tw(d, { BackgroundTransparency = 0.2 + 0.7 * (1 - math.abs(math.sin(math.pi * phase))) }, makeTI("fast", ac))
        end
    end)

    -- Step through loading stages
    local totalSteps = #steps
    for i, stepText in ipairs(steps) do
        stepLabel.Text = stepText
        TweenService:Create(pb,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(i / totalSteps, 0, 1, 0) }
        ):Play()
        task.wait(0.32)
    end
    task.wait(0.25)

    dotConn:Disconnect()
    tw(card,    { BackgroundTransparency = 1, Position = UDim2.new(0.5,-240,0.44,-140) }, makeTI("mid", ac))
    tw(overlay, { BackgroundTransparency = 1 }, makeTI("mid", ac))
    task.wait(0.35)
    sg:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════
function NexusUI:CreateWindow(opts)
    -- Merge per-window AnimConfig override with global
    local ac = {}
    for k, v in pairs(NexusUI.AnimConfig) do ac[k] = v end
    if opts.AnimConfig then
        for k, v in pairs(opts.AnimConfig) do ac[k] = v end
    end

    local winName  = opts.Name            or "NEXUS UI"
    local lTitle   = opts.LoadingTitle    or winName
    local lSub     = opts.LoadingSubtitle or ""
    local lSteps   = opts.LoadingSteps
    local lLogo    = opts.Logo            or "NEX"
    local cfgOpts  = opts.ConfigurationSaving or {}
    local cfgFile  = cfgOpts.FileName or "config"
    local cfgOn    = cfgOpts.Enabled ~= false
    local winIcon  = opts.Icon
    local maxW     = (opts.Size and opts.Size.Width)  or 580
    local maxH     = (opts.Size and opts.Size.Height) or 460

    -- Theme
    local themeName = opts.Theme or "Default"
    local T = {}
    local themeSrc = THEMES[themeName] or THEMES.Default
    for k, v in pairs(themeSrc) do T[k] = v end
    if opts.Accent then
        local a = opts.Accent
        T.Accent      = a
        T.AccentDark  = Color3.new(a.R*.65, a.G*.65, a.B*.65)
        T.AccentLight = Color3.new(math.min(a.R*1.35,1), math.min(a.G*1.35,1), math.min(a.B*1.35,1))
        T.ToggleOn    = a
        T.SliderFill  = a
        T.TabSelected = a
    end

    -- Toggle key
    local toggleKey = Enum.KeyCode.RightShift
    if opts.ToggleKey then
        if typeof(opts.ToggleKey) == "EnumItem" then
            toggleKey = opts.ToggleKey
        elseif type(opts.ToggleKey) == "string" then
            pcall(function() toggleKey = Enum.KeyCode[opts.ToggleKey] end)
        end
    end

    -- Show loading screen, wait for it to finish
    task.spawn(showLoadingScreen, {
        LoadingTitle    = lTitle,
        LoadingSubtitle = lSub,
        LoadingSteps    = lSteps,
        Logo            = lLogo,
    }, T, ac)
    task.wait((#(lSteps or {"","",""}) * 0.32) + 0.70)

    local saved = cfgOn and cfgLoad(cfgFile) or {}

    -- Autosave debounce state
    local saveTimer = nil
    local function scheduleSave()
        if not cfgOn then return end
        if saveTimer then task.cancel(saveTimer) end
        saveTimer = task.delay(ac.SaveDebounce, function()
            cfgSave(cfgFile, NexusUI.Flags)
            saveTimer = nil
        end)
    end

    -- ── ScreenGui ──────────────────────────────────────────
    local sg              = Instance.new("ScreenGui")
    sg.Name               = "NexusUI_Main"
    sg.ResetOnSpawn       = false
    sg.IgnoreGuiInset     = true
    sg.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
    sg.Parent             = LP.PlayerGui

    -- ── Shadow ─────────────────────────────────────────────
    local shadowFrame = frame(sg, UDim2.new(0,maxW+20,0,maxH+20), UDim2.new(0,-10,0,8), T.Shadow, 0.55)
    shadowFrame.ZIndex = 0; corner(shadowFrame, 16)

    -- ── Glow ───────────────────────────────────────────────
    local glowFrame = frame(sg, UDim2.new(0,maxW+80,0,maxH+80), UDim2.new(0,-40,0,-40), Color3.new(), 1)
    glowFrame.ZIndex = 0
    local glowImg = Instance.new("ImageLabel")
    glowImg.Size              = UDim2.new(1,0,1,0)
    glowImg.BackgroundTransparency = 1
    glowImg.Image             = "rbxassetid://5028857084"
    glowImg.ImageColor3       = T.Accent
    glowImg.ImageTransparency = 0.90
    glowImg.ScaleType         = Enum.ScaleType.Slice
    glowImg.SliceCenter       = Rect.new(24,24,276,276)
    glowImg.ZIndex            = 0
    glowImg.Parent            = glowFrame

    -- ── Main frame ─────────────────────────────────────────
    local mf = Instance.new("Frame")
    mf.AnchorPoint          = Vector2.new(0.5, 0.5)
    mf.Position             = UDim2.new(0.5, 0, 0.5, 0)
    mf.Size                 = UDim2.new(0, maxW, 0, maxH)
    mf.BackgroundColor3     = T.Background
    mf.BorderSizePixel      = 0
    mf.ClipsDescendants     = false
    mf.Parent               = sg
    corner(mf, 12)
    stroke(mf, T.ElementStroke, 1, 0.2)

    -- Helper to sync shadow/glow position with main frame
    local function syncDecorators()
        local ap = mf.AbsolutePosition
        local as = mf.AbsoluteSize
        shadowFrame.Position = UDim2.new(0, ap.X-10, 0, ap.Y+8)
        shadowFrame.Size     = UDim2.new(0, as.X+20, 0, as.Y+20)
        glowFrame.Position   = UDim2.new(0, ap.X-40, 0, ap.Y-40)
        glowFrame.Size       = UDim2.new(0, as.X+80, 0, as.Y+80)
    end
    mf:GetPropertyChangedSignal("AbsolutePosition"):Connect(syncDecorators)
    mf:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncDecorators)
    task.defer(syncDecorators)

    -- ── Topbar ─────────────────────────────────────────────
    local topbar = frame(mf, UDim2.new(1,0,0,46), nil, T.Topbar, 0)
    corner(topbar, 12)
    -- Square off bottom corners of topbar
    frame(topbar, UDim2.new(1,0,0,16), UDim2.new(0,0,1,-16), T.Topbar, 0)

    -- Topbar separator with accent gradient
    local tbSep = frame(topbar, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), T.Accent, 0.5)
    gradient(tbSep, { Color3.new(0,0,0), T.Accent, T.AccentLight, T.Accent, Color3.new(0,0,0) }, 0)

    -- Window icon
    local titleXOffset = 14
    if winIcon then
        local iconLabel = label(topbar, tostring(winIcon), 16, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        iconLabel.Size     = UDim2.new(0,30,1,0)
        iconLabel.Position = UDim2.new(0,12,0,0)
        titleXOffset = 46
    end

    -- "NEXUS" logo + window name
    local nexusLabel = label(topbar, "NEXUS", 14, T.Accent, Enum.Font.GothamBlack)
    nexusLabel.Size     = UDim2.new(0,50,1,0)
    nexusLabel.Position = UDim2.new(0,titleXOffset,0,0)

    local nameLabel = label(topbar, winName, 12, T.TextSecondary, Enum.Font.GothamMedium)
    nameLabel.Size     = UDim2.new(1,-220,1,0)
    nameLabel.Position = UDim2.new(0,titleXOffset+54,0,0)

    -- Version
    local verLabel = label(topbar, "v"..NexusUI.Version, 8, T.TextMuted, Enum.Font.Code, Enum.TextXAlignment.Right)
    verLabel.Size     = UDim2.new(0,50,1,0)
    verLabel.Position = UDim2.new(1,-102,0,0)

    -- Control buttons (close / minimize)
    local function makeCtrlButton(icon, xOffset, hoverColor)
        local b = Instance.new("TextButton")
        b.Size              = UDim2.new(0,26,0,22)
        b.Position          = UDim2.new(1, xOffset, 0.5, -11)
        b.BackgroundColor3  = T.ElementBackground
        b.Text              = icon
        b.Font              = Enum.Font.GothamBold
        b.TextSize          = 10
        b.TextColor3        = T.TextMuted
        b.BorderSizePixel   = 0
        b.Parent            = topbar
        corner(b, 6)
        stroke(b, T.ElementStroke, 1, 0.4)
        b.MouseEnter:Connect(function()
            tw(b, { BackgroundColor3 = hoverColor, TextColor3 = T.TabTextSelected }, makeTI("fast", ac))
        end)
        b.MouseLeave:Connect(function()
            tw(b, { BackgroundColor3 = T.ElementBackground, TextColor3 = T.TextMuted }, makeTI("fast", ac))
        end)
        return b
    end
    local closeButton = makeCtrlButton("✕", -12, T.Error)
    local minButton   = makeCtrlButton("─", -44, T.AccentDark)

    -- ── Sidebar ────────────────────────────────────────────
    local sidebar = frame(mf, UDim2.new(0,150,1,-46), UDim2.new(0,0,0,46), T.TabBackground, 0)
    pad(sidebar, 8, 6, 8, 6)
    listLayout(sidebar, 3)
    -- Sidebar right border
    frame(mf, UDim2.new(0,1,1,-46), UDim2.new(0,150,0,46), T.Divider, 0)

    -- Search bar
    local searchBg = frame(sidebar, UDim2.new(1,0,0,30), nil, T.InputBackground, 0)
    corner(searchBg, 7)
    stroke(searchBg, T.InputStroke, 1, 0.3)
    local searchIconLabel = label(searchBg, Icons.Symbols.search, 10, T.TextMuted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
    searchIconLabel.Size     = UDim2.new(0,20,1,0)
    searchIconLabel.Position = UDim2.new(0,4,0,0)
    local searchBox          = Instance.new("TextBox")
    searchBox.Size           = UDim2.new(1,-26,1,0)
    searchBox.Position       = UDim2.new(0,22,0,0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text           = ""
    searchBox.PlaceholderText= "Search…"
    searchBox.Font           = Enum.Font.Gotham
    searchBox.TextSize       = 10
    searchBox.TextColor3     = T.TextPrimary
    searchBox.PlaceholderColor3 = T.TextMuted
    searchBox.ClearTextOnFocus  = false
    searchBox.Parent         = searchBg

    -- Sidebar footer
    local sbFooter = label(sidebar, "nexus ui · v"..NexusUI.Version, 8, T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    sbFooter.Size     = UDim2.new(1,0,0,12)
    sbFooter.Position = UDim2.new(0,0,1,-14)

    -- ── Content area ───────────────────────────────────────
    local contentArea = frame(mf, UDim2.new(1,-151,1,-46), UDim2.new(0,151,0,46), Color3.new(), 1)
    contentArea.ClipsDescendants = true

    -- ── Drag logic ─────────────────────────────────────────
    local isDragging = false
    local dragStart, dragAbsStart = nil, nil
    local minimized = false

    topbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging   = true
            dragStart    = i.Position
            dragAbsStart = mf.AbsolutePosition
            mf.AnchorPoint   = Vector2.new(0, 0)
            mf.Position      = UDim2.new(0, dragAbsStart.X, 0, dragAbsStart.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            local cvp   = workspace.CurrentCamera.ViewportSize
            local nx    = math.clamp(dragAbsStart.X + delta.X, 0, cvp.X - mf.AbsoluteSize.X)
            local ny    = math.clamp(dragAbsStart.Y + delta.Y, 0, cvp.Y - mf.AbsoluteSize.Y)
            mf.Position = UDim2.new(0, nx, 0, ny)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)

    -- Minimize
    minButton.MouseButton1Click:Connect(function()
        minimized       = not minimized
        sidebar.Visible     = not minimized
        contentArea.Visible = not minimized
        tw(mf, { Size = UDim2.new(0, maxW, 0, minimized and 46 or maxH) }, makeTI("spring", ac))
        minButton.Text  = minimized and "□" or "─"
    end)

    -- Close
    closeButton.MouseButton1Click:Connect(function()
        tw(mf, { BackgroundTransparency = 1, Size = UDim2.new(0, mf.AbsoluteSize.X, 0, 4) }, makeTI("mid", ac))
        tw(shadowFrame, { BackgroundTransparency = 1 }, makeTI("mid", ac))
        task.delay(0.35, function() sg:Destroy() end)
    end)

    -- Toggle hotkey
    table.insert(_hotkeys, { key = toggleKey, cb = function()
        mf.Visible         = not mf.Visible
        shadowFrame.Visible= mf.Visible
        glowFrame.Visible  = mf.Visible
        if mf.Visible then
            mf.BackgroundTransparency = 1
            tw(mf, { BackgroundTransparency = 0 }, makeTI("fast", ac))
        end
    end })

    -- ── Window API object ───────────────────────────────────
    local Win = {
        _tabs     = {},
        _active   = nil,
        _allElems = {},
        _cfgFile  = cfgFile,
        _cfgOn    = cfgOn,
        _saved    = saved,
        _sg       = sg,
        _mf       = mf,
        _theme    = T,
        _ac       = ac,
    }

    function Win:SaveConfig()
        if self._cfgOn then cfgSave(self._cfgFile, NexusUI.Flags) end
    end

    function Win:GetFlag(flag) return NexusUI.Flags[flag] end

    function Win:SetFlag(flag, val)
        NexusUI.Flags[flag] = val
        scheduleSave()
    end

    function Win:SetSize(w, h)
        maxW = w or maxW; maxH = h or maxH
        tw(mf, { Size = UDim2.new(0, maxW, 0, maxH) }, makeTI("spring", ac))
    end

    function Win:Notify(o)
        o.Theme = T
        NexusUI:Notify(o)
    end

    function Win:Destroy() sg:Destroy() end

    function Win:SetTheme(name)
        local src = THEMES[name] or THEMES.Default
        for k, v in pairs(src) do T[k] = v end
        glowImg.ImageColor3 = T.Accent
        nexusLabel.TextColor3 = T.Accent
        self:Notify({ Title="Theme", Content="Applied: "..name, Type="success", Duration=2 })
    end

    function Win:SetAccent(col)
        T.Accent      = col
        T.AccentDark  = Color3.new(col.R*.65, col.G*.65, col.B*.65)
        T.AccentLight = Color3.new(math.min(col.R*1.35,1), math.min(col.G*1.35,1), math.min(col.B*1.35,1))
        T.ToggleOn    = col
        T.SliderFill  = col
        T.TabSelected = col
        glowImg.ImageColor3   = col
        nexusLabel.TextColor3 = col
    end

    -- Search filtering
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _, info in ipairs(Win._allElems) do
            if query == "" then
                info.frame.Visible = true
            else
                info.frame.Visible = info.name:lower():find(query, 1, true) ~= nil
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════
    --  CREATE TAB
    -- ═══════════════════════════════════════════════════════
    function Win:CreateTab(name, icon, badgeCount)
        local tabMaid = Maid.new()

        -- Tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Size             = UDim2.new(1,0,0,36)
        tabButton.BackgroundColor3 = T.TabBackground
        tabButton.Text             = ""
        tabButton.BorderSizePixel  = 0
        tabButton.LayoutOrder      = #self._tabs + 2
        tabButton.Parent           = sidebar
        corner(tabButton, 7)

        -- Active side stripe
        local activeStripe = frame(tabButton, UDim2.new(0,3,0,20), UDim2.new(0,0,0.5,-10), T.TabSelected, 1)
        corner(activeStripe, 3)

        -- Icon label
        local iconLabel = label(tabButton, icon or "", 13, T.TabText, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
        iconLabel.Size     = UDim2.new(0,22,1,0)
        iconLabel.Position = UDim2.new(0,8,0,0)

        -- Name label
        local nameLabel = label(tabButton, name, 11, T.TabText, Enum.Font.GothamMedium)
        nameLabel.Size     = UDim2.new(1,-42,1,0)
        nameLabel.Position = UDim2.new(0, icon and 32 or 10, 0, 0)

        -- Badge
        local badgeFrame, badgeLabel
        if badgeCount then
            badgeFrame = frame(tabButton, UDim2.new(0,18,0,14), UDim2.new(1,-22,0.5,-7), T.TabSelected, 0)
            corner(badgeFrame, 7)
            badgeLabel = label(badgeFrame, tostring(badgeCount), 8, T.TabTextSelected, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            badgeLabel.Size = UDim2.new(1,0,1,0)
        end

        -- Scroll frame
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size                   = UDim2.new(1,0,1,0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel        = 0
        scroll.ScrollBarThickness     = 3
        scroll.ScrollBarImageColor3   = T.TabSelected
        scroll.ScrollBarImageTransparency = 0.4
        scroll.CanvasSize             = UDim2.new(0,0,0,0)
        scroll.Visible                = false
        scroll.Parent                 = contentArea

        local scrollLayout = listLayout(scroll, 4)
        pad(scroll, 10, 12, 10, 12)
        bindScrollCanvas(scroll, scrollLayout)

        tabMaid:Add(scroll.MouseEnter:Connect(function()
            tw(scroll, { ScrollBarImageTransparency = 0.1 }, makeTI("fast", ac))
        end))
        tabMaid:Add(scroll.MouseLeave:Connect(function()
            tw(scroll, { ScrollBarImageTransparency = 0.4 }, makeTI("fast", ac))
        end))

        local function activateTab()
            for _, t in ipairs(self._tabs) do
                t.scroll.Visible = false
                tw(t.button,      { BackgroundColor3 = T.TabBackground }, makeTI("fast", ac))
                tw(t.nameLabel,   { TextColor3 = T.TabText             }, makeTI("fast", ac))
                tw(t.iconLabel,   { TextColor3 = T.TabText             }, makeTI("fast", ac))
                tw(t.stripe,      { BackgroundTransparency = 1         }, makeTI("fast", ac))
            end
            scroll.Visible = true
            self._active   = scroll
            tw(tabButton,   { BackgroundColor3 = T.ElementHover    }, makeTI("fast", ac))
            tw(nameLabel,   { TextColor3 = T.TabTextSelected        }, makeTI("fast", ac))
            tw(iconLabel,   { TextColor3 = T.TabSelected            }, makeTI("fast", ac))
            tw(activeStripe,{ BackgroundTransparency = 0            }, makeTI("fast", ac))
        end

        tabMaid:Add(tabButton.MouseEnter:Connect(function()
            if self._active ~= scroll then
                tw(tabButton, { BackgroundColor3 = T.ElementHover   }, makeTI("fast", ac))
                tw(nameLabel, { TextColor3 = T.TextSecondary        }, makeTI("fast", ac))
            end
        end))
        tabMaid:Add(tabButton.MouseLeave:Connect(function()
            if self._active ~= scroll then
                tw(tabButton, { BackgroundColor3 = T.TabBackground  }, makeTI("fast", ac))
                tw(nameLabel, { TextColor3 = T.TabText              }, makeTI("fast", ac))
            end
        end))
        tabMaid:Add(tabButton.MouseButton1Click:Connect(function()
            activateTab()
            local rx, ry = mouseRelative(tabButton)
            rippleEffect(tabButton, rx, ry, ac)
        end))

        table.insert(self._tabs, {
            scroll    = scroll,
            button    = tabButton,
            nameLabel = nameLabel,
            iconLabel = iconLabel,
            stripe    = activeStripe,
        })
        if #self._tabs == 1 then task.defer(activateTab) end

        -- ── Tab element helpers ───────────────────────────
        local Tab = { _layoutOrder = 0, _maid = tabMaid }

        local function nextOrder()
            Tab._layoutOrder += 1
            return Tab._layoutOrder
        end

        -- elem(): creates a FIXED-HEIGHT element card.
        -- CRITICAL: AutomaticSize is NOT set here because that is what
        -- caused the toggle to expand the background on click.
        -- Only CreateParagraph uses elemAuto() below.
        local function elem(height, noHover)
            local c = frame(scroll, UDim2.new(1,0,0,height), nil, T.ElementBackground, 1)
            c.LayoutOrder = nextOrder()
            corner(c, 8)
            stroke(c, T.ElementStroke, 1, 0.35)
            task.defer(function()
                tw(c, { BackgroundTransparency = 0 }, makeTI("mid", ac))
            end)
            if not noHover then
                tabMaid:Add(c.MouseEnter:Connect(function()
                    tw(c, { BackgroundColor3 = T.ElementHover }, makeTI("fast", ac))
                end))
                tabMaid:Add(c.MouseLeave:Connect(function()
                    tw(c, { BackgroundColor3 = T.ElementBackground }, makeTI("fast", ac))
                end))
            end
            return c
        end

        -- elemAuto(): for elements whose height is content-driven (Paragraph).
        local function elemAuto(noHover)
            local c = frame(scroll, UDim2.new(1,0,0,0), nil, T.ElementBackground, 1)
            c.LayoutOrder   = nextOrder()
            c.AutomaticSize = Enum.AutomaticSize.Y
            corner(c, 8)
            stroke(c, T.ElementStroke, 1, 0.35)
            task.defer(function()
                tw(c, { BackgroundTransparency = 0 }, makeTI("mid", ac))
            end)
            if not noHover then
                tabMaid:Add(c.MouseEnter:Connect(function()
                    tw(c, { BackgroundColor3 = T.ElementHover }, makeTI("fast", ac))
                end))
                tabMaid:Add(c.MouseLeave:Connect(function()
                    tw(c, { BackgroundColor3 = T.ElementBackground }, makeTI("fast", ac))
                end))
            end
            return c
        end

        local function registerElem(c, name)
            table.insert(Win._allElems, { frame = c, name = name or "" })
        end

        -- ── CreateSection ─────────────────────────────────
        function Tab:CreateSection(text)
            local sf = frame(scroll, UDim2.new(1,0,0,24), nil, Color3.new(), 1)
            sf.LayoutOrder = nextOrder()
            frame(sf, UDim2.new(0.3,-6,0,1), UDim2.new(0,0,0.5,0), T.Divider, 0)
            frame(sf, UDim2.new(0.3,-6,0,1), UDim2.new(0.7,6,0.5,0), T.Divider, 0)
            local sl = label(sf, text:upper(), 9, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            sl.Size     = UDim2.new(0.4,0,1,0)
            sl.Position = UDim2.new(0.3,0,0,0)
            local sv = {}
            function sv:Set(t2) sl.Text = t2:upper() end
            return sv
        end

        -- ── CreateSeparator ───────────────────────────────
        function Tab:CreateSeparator()
            local sf = frame(scroll, UDim2.new(1,0,0,1), nil, T.Divider, 0)
            sf.LayoutOrder = nextOrder()
        end

        -- ── CreateLabel ───────────────────────────────────
        function Tab:CreateLabel(text, iconName, color)
            local lf = frame(scroll, UDim2.new(1,0,0,32), nil, Color3.new(), 1)
            lf.LayoutOrder = nextOrder()
            local ll
            if iconName then
                local iconStr = type(iconName) == "string" and (Icons.Symbols[iconName] or iconName) or tostring(iconName)
                local il = label(lf, iconStr, 13, color or T.Accent, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
                il.Size     = UDim2.new(0,24,1,0)
                il.Position = UDim2.new(0,10,0,0)
                ll = label(lf, text or "", 11, color or T.TextSecondary, Enum.Font.Gotham)
                ll.Size     = UDim2.new(1,-38,1,0)
                ll.Position = UDim2.new(0,36,0,0)
            else
                ll = label(lf, text or "", 11, color or T.TextSecondary, Enum.Font.Gotham, Enum.TextXAlignment.Center)
                ll.Size        = UDim2.new(1,0,1,0)
                ll.TextWrapped = true
            end
            local o = {}
            function o:Set(t2, c2)
                ll.Text = t2
                if c2 then ll.TextColor3 = c2 end
            end
            return o
        end

        -- ── CreateParagraph ───────────────────────────────
        -- Uses elemAuto() because height depends on text content.
        function Tab:CreateParagraph(o2)
            local c = elemAuto(true)
            registerElem(c, o2.Title or "")
            pad(c, 10, 14, 10, 14)
            local inner = Instance.new("Frame")
            inner.BackgroundTransparency = 1
            inner.Size        = UDim2.new(1,0,1,0)
            inner.AutomaticSize = Enum.AutomaticSize.Y
            inner.Parent      = c
            listLayout(inner, 5)
            local tl = label(inner, o2.Title or "", 12, T.TextPrimary, Enum.Font.GothamBold)
            tl.Size        = UDim2.new(1,0,0,16)
            tl.LayoutOrder = 1
            local cl = label(inner, o2.Content or "", 11, T.TextSecondary, Enum.Font.Gotham)
            cl.Size         = UDim2.new(1,0,0,0)
            cl.AutomaticSize= Enum.AutomaticSize.Y
            cl.TextWrapped  = true
            cl.TextTruncate = Enum.TextTruncate.None
            cl.LayoutOrder  = 2
            local o = {}
            function o:Set(t2, c2)
                tl.Text = t2 or tl.Text
                cl.Text = c2 or cl.Text
            end
            return o
        end

        -- ── CreateButton ──────────────────────────────────
        function Tab:CreateButton(o2)
            local hasDesc = o2.Description ~= nil
            local h       = hasDesc and 54 or 36
            local c       = elem(h)
            c.ClipsDescendants = true
            registerElem(c, o2.Name)

            local iconStr = o2.Icon and (Icons.Symbols[o2.Icon] or tostring(o2.Icon)) or Icons.Symbols.chevronRight
            local il = label(c, iconStr, 12, T.TabSelected, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            il.Size     = UDim2.new(0,20,1,0)
            il.Position = UDim2.new(1,-28,0,0)

            local nl = label(c, o2.Name or "Button", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-42,0,16)
            nl.Position = UDim2.new(0,12,0, hasDesc and 8 or 10)

            if hasDesc then
                local dl = label(c, o2.Description, 10, T.TextMuted, Enum.Font.Gotham)
                dl.Size     = UDim2.new(1,-42,0,14)
                dl.Position = UDim2.new(0,12,0,27)
            end

            local accentBar = frame(c, UDim2.new(0,2,0,18), UDim2.new(0,0,0.5,-9), T.TabSelected, 1)
            corner(accentBar, 2)

            local btn = Instance.new("TextButton")
            btn.Size                  = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency= 1
            btn.Text                  = ""
            btn.Parent                = c

            local cb = o2.Callback or function() end

            tabMaid:Add(btn.MouseEnter:Connect(function()
                tw(nl,        { TextColor3 = T.AccentLight         }, makeTI("fast", ac))
                tw(il,        { TextColor3 = T.AccentLight         }, makeTI("fast", ac))
                tw(accentBar, { BackgroundTransparency = 0         }, makeTI("fast", ac))
            end))
            tabMaid:Add(btn.MouseLeave:Connect(function()
                tw(nl,        { TextColor3 = T.TextPrimary         }, makeTI("fast", ac))
                tw(il,        { TextColor3 = T.TabSelected         }, makeTI("fast", ac))
                tw(accentBar, { BackgroundTransparency = 1         }, makeTI("fast", ac))
            end))
            tabMaid:Add(btn.MouseButton1Down:Connect(function()
                tw(c, { BackgroundColor3 = T.AccentDark }, makeTI("fast", ac))
            end))
            tabMaid:Add(btn.MouseButton1Click:Connect(function()
                tw(c, { BackgroundColor3 = T.ElementHover }, makeTI("fast", ac))
                local rx, ry = mouseRelative(c)
                rippleEffect(c, rx, ry, ac)
                local ok, err = pcall(cb)
                if not ok then
                    tw(c, { BackgroundColor3 = Color3.fromRGB(80,0,0) }, makeTI("fast", ac))
                    local origName = nl.Text
                    nl.Text = "Error!"
                    task.delay(0.8, function()
                        tw(c, { BackgroundColor3 = T.ElementBackground }, makeTI("mid", ac))
                        nl.Text = origName
                    end)
                end
            end))

            local o = {}
            function o:Set(newName) nl.Text = newName end
            return o
        end

        -- ── CreateToggle ──────────────────────────────────
        -- THE FIX: elem(h) is used — fixed height, NO AutomaticSize.
        -- Previously the entire element had AutomaticSize = Y which caused
        -- the frame to jump/expand whenever the toggle was clicked because
        -- Roblox re-measured the element's children at that moment.
        function Tab:CreateToggle(o2)
            local flag    = o2.Flag
            local hasDesc = o2.Description ~= nil
            local initVal = (flag and saved[flag] ~= nil) and saved[flag] or (o2.CurrentValue or false)
            local cb      = o2.Callback or function() end
            local h       = hasDesc and 54 or 36

            -- elem() = fixed height frame — this is the fix
            local c   = elem(h)
            local val = initVal
            registerElem(c, o2.Name)

            local clickBtn = Instance.new("TextButton")
            clickBtn.Size                  = UDim2.new(1,0,1,0)
            clickBtn.BackgroundTransparency= 1
            clickBtn.Text                  = ""
            clickBtn.Parent                = c

            local nl = label(c, o2.Name or "Toggle", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-68,0,16)
            nl.Position = UDim2.new(0,12,0, hasDesc and 8 or 10)

            if hasDesc then
                local dl = label(c, o2.Description, 10, T.TextMuted, Enum.Font.Gotham)
                dl.Size     = UDim2.new(1,-68,0,14)
                dl.Position = UDim2.new(0,12,0,27)
            end

            -- Toggle track
            local track = frame(c, UDim2.new(0,40,0,22), UDim2.new(1,-52,0.5,-11),
                initVal and T.ToggleOn or T.ToggleOff, 0)
            corner(track, 11)
            stroke(track, T.ElementStroke, 1, 0.2)

            -- Toggle thumb — slide between off (left) and on (right)
            local thumbOffPos = UDim2.new(0,3,0.5,-8)
            local thumbOnPos  = UDim2.new(1,-19,0.5,-8)
            local thumb = frame(track, UDim2.new(0,16,0,16),
                initVal and thumbOnPos or thumbOffPos,
                Color3.new(1,1,1), 0)
            corner(thumb, 9)

            -- Small shine dot on thumb
            local shine = frame(thumb, UDim2.new(0,5,0,5), UDim2.new(0,2,0,2), Color3.new(1,1,1), 0.6)
            corner(shine, 99)

            local function setState(newVal, silent)
                val = newVal
                tw(track, { BackgroundColor3 = newVal and T.ToggleOn or T.ToggleOff }, makeTI("fast", ac))
                tw(thumb, { Position = newVal and thumbOnPos or thumbOffPos          }, makeTI("fast", ac))
                tw(nl,    { TextColor3 = newVal and T.TextPrimary or T.TextSecondary }, makeTI("fast", ac))
                if not silent then
                    cb(newVal)
                    if flag then
                        NexusUI.Flags[flag] = newVal
                        scheduleSave()
                    end
                end
            end
            setState(initVal, true)

            tabMaid:Add(clickBtn.MouseButton1Click:Connect(function()
                setState(not val)
                local rx, ry = mouseRelative(c)
                rippleEffect(c, rx, ry, ac)
            end))

            -- Optional HoldToActivate mode
            if o2.HoldToActivate then
                local holdConn
                tabMaid:Add(clickBtn.MouseButton1Down:Connect(function()
                    setState(true)
                    holdConn = clickBtn.MouseButton1Up:Connect(function()
                        setState(false)
                        if holdConn then holdConn:Disconnect() end
                    end)
                end))
            end

            local o = {}
            function o:Set(v)   setState(v, false)      end
            function o:Get()    return val               end
            function o:Toggle() setState(not val, false) end
            return o
        end

        -- ── CreateSlider ──────────────────────────────────
        function Tab:CreateSlider(o2)
            local flag  = o2.Flag
            local range = o2.Range     or { 0, 100 }
            local inc   = o2.Increment or 1
            local suf   = o2.Suffix    or ""
            local defV  = (flag and saved[flag]) or o2.CurrentValue or range[1]
            local cb    = o2.Callback or function() end
            local h     = o2.Description and 62 or 52
            local c     = elem(h)
            local val   = math.clamp(defV, range[1], range[2])
            registerElem(c, o2.Name)

            local nl = label(c, o2.Name or "Slider", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-80,0,16)
            nl.Position = UDim2.new(0,12,0,8)

            local vl = label(c, tostring(val)..suf, 13, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            vl.Size     = UDim2.new(0,66,0,16)
            vl.Position = UDim2.new(1,-78,0,8)

            if o2.Description then
                local dl = label(c, o2.Description, 10, T.TextMuted, Enum.Font.Gotham)
                dl.Size     = UDim2.new(1,-24,0,12)
                dl.Position = UDim2.new(0,12,0,26)
            end

            local yOff = o2.Description and 44 or 32
            local track = frame(c, UDim2.new(1,-24,0,5), UDim2.new(0,12,0,yOff), T.ElementStroke, 0)
            corner(track, 6)

            local fill = frame(track, UDim2.new(0,0,1,0), nil, T.SliderFill, 0)
            corner(fill, 6)
            gradient(fill, { T.AccentLight, T.SliderFill }, 0)

            local thumb = frame(track, UDim2.new(0,16,0,16), UDim2.new(0,-8,0.5,-8), T.AccentLight, 0)
            corner(thumb, 9)
            stroke(thumb, T.Accent, 2, 0)
            thumb.ZIndex = 4

            -- Tooltip above thumb
            local tooltip = frame(thumb, UDim2.new(0,50,0,20), UDim2.new(0.5,-25,0,-28), T.Topbar, 0)
            corner(tooltip, 6)
            stroke(tooltip, T.ElementStroke, 1, 0)
            tooltip.Visible = false
            local tooltipLabel = label(tooltip, "", 10, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            tooltipLabel.Size = UDim2.new(1,0,1,0)

            local function updateSlider(v)
                v   = math.clamp(math.round(v / inc) * inc, range[1], range[2])
                val = v
                local pct = (v - range[1]) / (range[2] - range[1])
                TweenService:Create(fill,  makeTI("slider", ac), { Size     = UDim2.new(pct, 0, 1, 0) }):Play()
                TweenService:Create(thumb, makeTI("slider", ac), { Position = UDim2.new(pct,-8,0.5,-8) }):Play()
                vl.Text          = tostring(v) .. suf
                tooltipLabel.Text= tostring(v) .. suf
                cb(v)
                if flag then
                    NexusUI.Flags[flag] = v
                    scheduleSave()
                end
            end

            local initPct = (val - range[1]) / (range[2] - range[1])
            fill.Size      = UDim2.new(initPct, 0, 1, 0)
            thumb.Position = UDim2.new(initPct, -8, 0.5, -8)

            local draggingSlider = false
            local function pctFromX(x)
                return math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            end

            tabMaid:Add(thumb.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider  = true
                    tooltip.Visible = true
                end
            end))
            tabMaid:Add(track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider  = true
                    tooltip.Visible = true
                    updateSlider(range[1] + (range[2]-range[1]) * pctFromX(i.Position.X))
                end
            end))
            tabMaid:Add(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider  = false
                    tooltip.Visible = false
                end
            end))
            tabMaid:Add(UserInputService.InputChanged:Connect(function(i)
                if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(range[1] + (range[2]-range[1]) * pctFromX(i.Position.X))
                end
            end))

            local o = {}
            function o:Set(v) updateSlider(v) end
            function o:Get()  return val       end
            return o
        end

        -- ── CreateInput ───────────────────────────────────
        function Tab:CreateInput(o2)
            local flag = o2.Flag
            local cb   = o2.Callback    or function() end
            local live = o2.LiveUpdate  or false
            local num  = o2.NumberOnly  or false
            local c    = elem(54)
            registerElem(c, o2.Name)

            local nl = label(c, o2.Name or "Input", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-24,0,16)
            nl.Position = UDim2.new(0,12,0,6)

            local ibg = frame(c, UDim2.new(1,-24,0,24), UDim2.new(0,12,0,26), T.InputBackground, 0)
            corner(ibg, 6)
            local ibs = stroke(ibg, T.InputStroke, 1, 0.2)

            local ib = Instance.new("TextBox")
            ib.Size                  = UDim2.new(1,-14,1,0)
            ib.Position              = UDim2.new(0,7,0,0)
            ib.BackgroundTransparency= 1
            ib.Text                  = o2.CurrentValue or ""
            ib.PlaceholderText       = o2.PlaceholderText or "Enter value…"
            ib.Font                  = Enum.Font.Gotham
            ib.TextSize              = 11
            ib.TextColor3            = T.TextPrimary
            ib.PlaceholderColor3     = T.TextMuted
            ib.ClearTextOnFocus      = false
            ib.Parent                = ibg

            tabMaid:Add(ib.Focused:Connect(function()
                tw(ibg, { BackgroundColor3 = T.ElementHover }, makeTI("fast", ac))
                ibs.Color        = T.Accent
                ibs.Transparency = 0
            end))
            tabMaid:Add(ib.FocusLost:Connect(function(enter)
                tw(ibg, { BackgroundColor3 = T.InputBackground }, makeTI("fast", ac))
                ibs.Color        = T.InputStroke
                ibs.Transparency = 0.2
                if enter then
                    local v2 = num and tonumber(ib.Text) or ib.Text
                    cb(v2)
                    if flag then NexusUI.Flags[flag] = v2; scheduleSave() end
                end
                if o2.RemoveTextAfterFocusLost then ib.Text = "" end
            end))
            if live then
                tabMaid:Add(ib:GetPropertyChangedSignal("Text"):Connect(function()
                    cb(num and tonumber(ib.Text) or ib.Text)
                end))
            end

            local o = {}
            function o:Set(v)  ib.Text = tostring(v) end
            function o:Get()   return ib.Text         end
            function o:Clear() ib.Text = ""           end
            return o
        end

        -- ── CreateDropdown ────────────────────────────────
        function Tab:CreateDropdown(o2)
            local flag  = o2.Flag
            local opts2 = o2.Options or {}
            local def   = (flag and saved[flag]) or o2.CurrentOption
            local cb    = o2.Callback         or function() end
            local multi = o2.MultipleOptions  or false
            local val   = def
            local sel   = {}
            local isOpen= false

            local c = elem(36)
            c.ClipsDescendants = false
            c.ZIndex           = 5
            registerElem(c, o2.Name)

            local nl = label(c, o2.Name or "Dropdown", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(0.5,0,0,18)
            nl.Position = UDim2.new(0,12,0.5,-9)

            local vl = label(c,
                type(val)=="table" and (#val.." selected") or (val or "Select…"),
                11, T.Accent, Enum.Font.Gotham, Enum.TextXAlignment.Right)
            vl.Size     = UDim2.new(0.38,-4,0,18)
            vl.Position = UDim2.new(0.52,0,0.5,-9)

            local arrowLabel = label(c, Icons.Symbols.chevronDown, 11, T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            arrowLabel.Size     = UDim2.new(0,16,0,18)
            arrowLabel.Position = UDim2.new(1,-24,0.5,-9)

            -- Dropdown panel
            local dd = frame(c, UDim2.new(1,0,0,0), UDim2.new(0,0,1,4), T.Topbar, 0)
            dd.ClipsDescendants = true
            dd.ZIndex           = 10
            dd.Visible          = false
            corner(dd, 8)
            stroke(dd, T.ElementStroke, 1, 0.2)
            listLayout(dd, 2)
            pad(dd, 4, 4, 4, 4)

            local function refreshValueLabel()
                if multi then
                    local s = {}
                    for k, v in pairs(sel) do if v then s[#s+1] = k end end
                    vl.Text = #s > 0 and (#s .. " selected") or "None"
                else
                    vl.Text = val or "Select…"
                end
            end

            local function buildOptions(list)
                for _, ch in ipairs(dd:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for _, optName in ipairs(list) do
                    local ob = Instance.new("TextButton")
                    ob.Size             = UDim2.new(1,0,0,28)
                    ob.BackgroundColor3 = T.ElementBackground
                    ob.Text             = ""
                    ob.BorderSizePixel  = 0
                    ob.Parent           = dd
                    corner(ob, 6)
                    stroke(ob, T.ElementStroke, 1, 0.5)
                    local ol = label(ob, optName, 11, optName==val and T.Accent or T.TextSecondary)
                    ol.Size     = UDim2.new(1,-16,1,0)
                    ol.Position = UDim2.new(0,8,0,0)
                    ob.MouseEnter:Connect(function()
                        tw(ob, { BackgroundColor3 = T.ElementHover   }, makeTI("fast", ac))
                        tw(ol, { TextColor3       = T.TextPrimary    }, makeTI("fast", ac))
                    end)
                    ob.MouseLeave:Connect(function()
                        tw(ob, { BackgroundColor3 = T.ElementBackground }, makeTI("fast", ac))
                        tw(ol, { TextColor3       = optName==val and T.Accent or T.TextSecondary }, makeTI("fast", ac))
                    end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            sel[optName] = not sel[optName]
                            tw(ol, { TextColor3 = sel[optName] and T.Accent or T.TextSecondary }, makeTI("fast", ac))
                            local r = {}
                            for k, v in pairs(sel) do if v then r[#r+1] = k end end
                            val = r; refreshValueLabel(); cb(r)
                        else
                            val = optName; refreshValueLabel()
                            for _, ch2 in ipairs(dd:GetChildren()) do
                                if ch2:IsA("TextButton") then
                                    local cll = ch2:FindFirstChildOfClass("TextLabel")
                                    if cll then tw(cll, { TextColor3 = T.TextSecondary }, makeTI("fast", ac)) end
                                end
                            end
                            tw(ol, { TextColor3 = T.Accent }, makeTI("fast", ac))
                            isOpen = false
                            tw(dd, { Size = UDim2.new(1,0,0,0) }, makeTI("fast", ac))
                            tw(arrowLabel, { Rotation = 0 }, makeTI("fast", ac))
                            task.delay(0.2, function() dd.Visible = false end)
                            cb(optName)
                            if flag then NexusUI.Flags[flag] = optName; scheduleSave() end
                        end
                    end)
                end
            end
            buildOptions(opts2)

            local openBtn = Instance.new("TextButton")
            openBtn.Size                  = UDim2.new(1,0,1,0)
            openBtn.BackgroundTransparency= 1
            openBtn.Text                  = ""
            openBtn.Parent                = c

            tabMaid:Add(openBtn.MouseButton1Click:Connect(function()
                isOpen   = not isOpen
                local th = isOpen and math.min(#opts2 * 32 + 8, 200) or 0
                dd.Visible = true
                tw(dd, { Size = UDim2.new(1,0,0,th) }, makeTI("fast", ac))
                tw(arrowLabel, { Rotation = isOpen and 180 or 0 }, makeTI("fast", ac))
                if not isOpen then
                    task.delay(0.2, function() dd.Visible = false end)
                end
            end))

            -- Close on outside click
            tabMaid:Add(UserInputService.InputBegan:Connect(function(i)
                if isOpen and i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mp = UserInputService:GetMouseLocation()
                    local ap = dd.AbsolutePosition
                    local as = dd.AbsoluteSize
                    if mp.X < ap.X or mp.X > ap.X+as.X or mp.Y < ap.Y or mp.Y > ap.Y+as.Y then
                        isOpen = false
                        tw(dd, { Size = UDim2.new(1,0,0,0) }, makeTI("fast", ac))
                        tw(arrowLabel, { Rotation = 0 }, makeTI("fast", ac))
                        task.delay(0.2, function() dd.Visible = false end)
                    end
                end
            end))

            local o = {}
            function o:Set(v)        val=v; refreshValueLabel(); cb(v)    end
            function o:Get()         return val                            end
            function o:Refresh(list) opts2=list; buildOptions(list)        end
            function o:AddOption(v2) table.insert(opts2,v2); buildOptions(opts2) end
            return o
        end

        -- ── CreateKeybind ─────────────────────────────────
        function Tab:CreateKeybind(o2)
            local flag    = o2.Flag
            local cb      = o2.Callback      or function() end
            local val     = o2.CurrentKey    or Enum.KeyCode.Unknown
            local holdMode= o2.HoldToInteract or false
            local binding = false
            local held    = false
            local c       = elem(36)
            registerElem(c, o2.Name)

            local nl = label(c, o2.Name or "Keybind", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-106,0,16)
            nl.Position = UDim2.new(0,12,0.5,-8)

            local kbg = frame(c, UDim2.new(0,88,0,24), UDim2.new(1,-98,0.5,-12), T.InputBackground, 0)
            corner(kbg, 7)
            stroke(kbg, T.InputStroke, 1, 0.2)

            local kl = label(kbg,
                typeof(val) == "EnumItem" and val.Name or tostring(val),
                11, T.Accent, Enum.Font.Code, Enum.TextXAlignment.Center)
            kl.Size = UDim2.new(1,0,1,0)

            local btn = Instance.new("TextButton")
            btn.Size                  = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency= 1
            btn.Text                  = ""
            btn.Parent                = c

            tabMaid:Add(btn.MouseButton1Click:Connect(function()
                binding      = true
                kl.Text      = "…"
                kl.TextColor3= T.TextMuted
                tw(kbg, { BackgroundColor3 = T.ElementHover }, makeTI("fast", ac))
            end))

            tabMaid:Add(UserInputService.InputBegan:Connect(function(i, gpe)
                if binding and i.UserInputType == Enum.UserInputType.Keyboard then
                    binding       = false
                    val           = i.KeyCode
                    kl.Text       = i.KeyCode.Name
                    kl.TextColor3 = T.Accent
                    tw(kbg, { BackgroundColor3 = T.InputBackground }, makeTI("fast", ac))
                    if flag then NexusUI.Flags[flag] = i.KeyCode.Name; scheduleSave() end
                    if o2.CallOnChange then cb(i.KeyCode) end
                    return
                end
                if not gpe and not binding and typeof(val) == "EnumItem" and i.KeyCode == val then
                    if holdMode then held = true else cb(val) end
                end
            end))

            tabMaid:Add(UserInputService.InputEnded:Connect(function(i)
                if typeof(val) == "EnumItem" and i.KeyCode == val and holdMode and held then
                    held = false
                    cb(val)
                end
            end))

            local o = {}
            function o:Get() return val end
            function o:Set(k)
                if typeof(k) == "EnumItem" then
                    val = k; kl.Text = k.Name
                elseif type(k) == "string" then
                    pcall(function() val = Enum.KeyCode[k]; kl.Text = k end)
                end
            end
            return o
        end

        -- ── CreateColorPicker ─────────────────────────────
        function Tab:CreateColorPicker(o2)
            local flag = o2.Flag
            local def  = o2.Default  or Color3.fromRGB(80,180,255)
            local cb   = o2.Callback or function() end
            local val  = def
            local isOpen = false
            local hue, sat, bri = Color3.toHSV(def)

            local c = elem(36)
            c.ClipsDescendants = false
            registerElem(c, o2.Name)

            local nl = label(c, o2.Name or "Color", 12, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-78,0,18)
            nl.Position = UDim2.new(0,12,0.5,-9)

            local preview = frame(c, UDim2.new(0,36,0,22), UDim2.new(1,-56,0.5,-11), val, 0)
            corner(preview, 7)
            stroke(preview, T.ElementStroke, 1, 0)

            local arrowLabel = label(c, Icons.Symbols.chevronDown, 11, T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            arrowLabel.Size     = UDim2.new(0,16,0,18)
            arrowLabel.Position = UDim2.new(1,-20,0.5,-9)

            -- Picker panel
            local pk = frame(c, UDim2.new(1,0,0,0), UDim2.new(0,0,1,5), T.Topbar, 0)
            pk.ClipsDescendants = true
            pk.ZIndex           = 8
            pk.Visible          = false
            corner(pk, 10)
            stroke(pk, T.ElementStroke, 1, 0.2)
            pad(pk, 8, 8, 8, 8)
            listLayout(pk, 6)

            local function applyColor()
                val = Color3.fromHSV(hue, sat, bri)
                preview.BackgroundColor3 = val
                cb(val)
                if flag then NexusUI.Flags[flag] = { val.R, val.G, val.B }; scheduleSave() end
            end

            -- Hue bar
            local hueBar = frame(pk, UDim2.new(1,0,0,14), nil, T.ElementBackground, 0)
            corner(hueBar, 5)
            hueBar.LayoutOrder = 1
            gradient(hueBar, {
                Color3.fromHSV(0,1,1), Color3.fromHSV(0.17,1,1), Color3.fromHSV(0.33,1,1),
                Color3.fromHSV(0.5,1,1), Color3.fromHSV(0.67,1,1), Color3.fromHSV(0.83,1,1),
                Color3.fromHSV(1,1,1),
            }, 0)
            local hueThumb = frame(hueBar, UDim2.new(0,4,1,4), UDim2.new(hue,-2,0,-2), Color3.new(1,1,1), 0)
            corner(hueThumb, 3)
            stroke(hueThumb, Color3.fromRGB(80,80,80), 1, 0)

            -- SV field
            local svField = frame(pk, UDim2.new(1,0,0,80), nil, Color3.fromHSV(hue,1,1), 0)
            corner(svField, 5)
            svField.LayoutOrder = 2

            local svWhiteGrad = Instance.new("UIGradient")
            svWhiteGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(hue,1,1)),
            })
            svWhiteGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            svWhiteGrad.Parent = svField

            local svDarkOverlay = frame(svField, UDim2.new(1,0,1,0), nil, Color3.new(0,0,0), 0)
            local svDarkGrad    = Instance.new("UIGradient")
            svDarkGrad.Rotation   = 90
            svDarkGrad.Color      = ColorSequence.new({ ColorSequenceKeypoint.new(0,Color3.new()), ColorSequenceKeypoint.new(1,Color3.new()) })
            svDarkGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) })
            svDarkGrad.Parent     = svDarkOverlay

            local svThumb = frame(svField, UDim2.new(0,12,0,12), UDim2.new(sat,-6,1-bri,-6), Color3.new(1,1,1), 0)
            corner(svThumb, 6)
            stroke(svThumb, Color3.fromRGB(80,80,80), 1.5, 0)
            svThumb.ZIndex = 3

            -- Hex input
            local hexRow = frame(pk, UDim2.new(1,0,0,26), nil, Color3.new(), 1)
            hexRow.LayoutOrder = 3
            local hexBg = frame(hexRow, UDim2.new(1,0,1,0), nil, T.InputBackground, 0)
            corner(hexBg, 6)
            stroke(hexBg, T.InputStroke, 1, 0.3)
            local hexPfx = label(hexBg, "#", 10, T.TextMuted, Enum.Font.Code)
            hexPfx.Size     = UDim2.new(0,14,1,0)
            hexPfx.Position = UDim2.new(0,6,0,0)
            local hexBox = Instance.new("TextBox")
            hexBox.Size                  = UDim2.new(1,-20,1,0)
            hexBox.Position              = UDim2.new(0,20,0,0)
            hexBox.BackgroundTransparency= 1
            hexBox.Font                  = Enum.Font.Code
            hexBox.TextSize              = 11
            hexBox.TextColor3            = T.TextPrimary
            hexBox.PlaceholderColor3     = T.TextMuted
            hexBox.ClearTextOnFocus      = false
            hexBox.Parent                = hexBg

            local function hexToColor3(h2)
                local hex = h2:gsub("#","")
                if #hex ~= 6 then return nil end
                local ok, col = pcall(Color3.fromRGB,
                    tonumber(hex:sub(1,2),16),
                    tonumber(hex:sub(3,4),16),
                    tonumber(hex:sub(5,6),16))
                return ok and col or nil
            end
            local function updateHexBox()
                hexBox.Text = string.format("%02X%02X%02X",
                    math.round(val.R*255), math.round(val.G*255), math.round(val.B*255))
            end
            updateHexBox()

            hexBox.FocusLost:Connect(function()
                local col = hexToColor3(hexBox.Text)
                if col then
                    hue, sat, bri = col:ToHSV(); applyColor()
                    svField.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                    svWhiteGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(hue,1,1)),
                    })
                    tw(hueThumb, { Position = UDim2.new(hue,-2,0,-2) }, makeTI("fast", ac))
                    tw(svThumb,  { Position = UDim2.new(sat,-6,1-bri,-6) }, makeTI("fast", ac))
                else updateHexBox() end
            end)

            -- Drag logic
            local draggingHue, draggingSV = false, false

            local function hueDrag(i)
                hue = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                tw(hueThumb, { Position = UDim2.new(hue,-2,0,-2) }, makeTI("fast", ac))
                svField.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                svWhiteGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(hue,1,1)),
                })
                applyColor(); updateHexBox()
            end

            local function svDrag(i)
                sat = math.clamp((i.Position.X - svField.AbsolutePosition.X) / svField.AbsoluteSize.X, 0, 1)
                bri = 1 - math.clamp((i.Position.Y - svField.AbsolutePosition.Y) / svField.AbsoluteSize.Y, 0, 1)
                tw(svThumb, { Position = UDim2.new(sat,-6,1-bri,-6) }, makeTI("fast", ac))
                applyColor(); updateHexBox()
            end

            tabMaid:Add(hueBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; hueDrag(i) end
            end))
            tabMaid:Add(svField.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true; svDrag(i) end
            end))
            tabMaid:Add(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false; draggingSV = false end
            end))
            tabMaid:Add(UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingHue then hueDrag(i) elseif draggingSV then svDrag(i) end
                end
            end))

            local openBtn = Instance.new("TextButton")
            openBtn.Size                  = UDim2.new(1,0,1,0)
            openBtn.BackgroundTransparency= 1
            openBtn.Text                  = ""
            openBtn.Parent                = c

            tabMaid:Add(openBtn.MouseButton1Click:Connect(function()
                isOpen     = not isOpen
                pk.Visible = true
                tw(pk, { Size = UDim2.new(1,0,0, isOpen and 142 or 0) }, makeTI("fast", ac))
                tw(arrowLabel, { Rotation = isOpen and 180 or 0 }, makeTI("fast", ac))
                if not isOpen then
                    task.delay(0.2, function() pk.Visible = false end)
                end
            end))

            local o = {}
            function o:Set(col)
                val = col; preview.BackgroundColor3 = col
                hue, sat, bri = col:ToHSV()
                svField.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                tw(hueThumb, { Position = UDim2.new(hue,-2,0,-2) }, makeTI("fast", ac))
                tw(svThumb,  { Position = UDim2.new(sat,-6,1-bri,-6) }, makeTI("fast", ac))
                updateHexBox()
            end
            function o:Get() return val end
            return o
        end

        -- ── CreateProgressBar ─────────────────────────────
        -- New in v2. Displays a labeled progress bar element.
        function Tab:CreateProgressBar(o2)
            local c   = elem(42)
            registerElem(c, o2.Name)
            local val = math.clamp(o2.Value or 0, 0, 1)

            local nl = label(c, o2.Name or "Progress", 11, T.TextPrimary, Enum.Font.GothamMedium)
            nl.Size     = UDim2.new(1,-70,0,14)
            nl.Position = UDim2.new(0,12,0,6)

            local pctLabel = label(c, math.floor(val*100).."%", 11, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            pctLabel.Size     = UDim2.new(0,52,0,14)
            pctLabel.Position = UDim2.new(1,-62,0,6)

            local track = frame(c, UDim2.new(1,-24,0,6), UDim2.new(0,12,0,26), T.ElementStroke, 0)
            corner(track, 4)
            local fill = frame(track, UDim2.new(val,0,1,0), nil, T.SliderFill, 0)
            corner(fill, 4)
            gradient(fill, { T.AccentLight, T.SliderFill }, 0)

            local o = {}
            function o:Set(v)
                v   = math.clamp(v, 0, 1)
                val = v
                tw(fill, { Size = UDim2.new(v,0,1,0) }, makeTI("mid", ac))
                pctLabel.Text = math.floor(v*100).."%"
            end
            function o:Get() return val end
            return o
        end

        -- ── Tab:Destroy ───────────────────────────────────
        function Tab:Destroy()
            tabMaid:Clean()
            if scroll  and scroll.Parent  then scroll:Destroy()   end
            if tabButton and tabButton.Parent then tabButton:Destroy() end
        end

        -- ── Tab:UpdateBadge ───────────────────────────────
        function Tab:UpdateBadge(n)
            if not badgeFrame then
                badgeFrame = frame(tabButton, UDim2.new(0,18,0,14), UDim2.new(1,-22,0.5,-7), T.TabSelected, 0)
                corner(badgeFrame, 7)
                badgeLabel = label(badgeFrame, tostring(n), 8, T.TabTextSelected, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                badgeLabel.Size = UDim2.new(1,0,1,0)
            else
                if n == 0 then
                    badgeFrame.Visible = false
                else
                    badgeFrame.Visible = true
                    badgeLabel.Text    = tostring(n)
                end
            end
        end

        return Tab
    end -- CreateTab

    -- ── Built-in Settings Tab ──────────────────────────────
    function Win:CreateSettingsTab()
        local st = self:CreateTab("Settings", Icons.Symbols.settings)
        st:CreateSection("Theme")
        local themeNames = {}
        for n in pairs(THEMES) do table.insert(themeNames, n) end
        table.sort(themeNames)
        st:CreateDropdown({
            Name          = "Preset Theme",
            Options       = themeNames,
            CurrentOption = themeName,
            Callback      = function(v) self:SetTheme(v) end,
        })
        st:CreateSection("Accent Color")
        st:CreateColorPicker({
            Name     = "Accent Color",
            Default  = T.Accent,
            Callback = function(col) self:SetAccent(col) end,
        })
        st:CreateSeparator()
        st:CreateSection("Keybind")
        st:CreateKeybind({
            Name       = "Toggle UI",
            CurrentKey = toggleKey,
            Callback   = function(k) toggleKey = k end,
        })
        st:CreateSeparator()
        st:CreateSection("Info")
        st:CreateLabel("NexusUI v"..NexusUI.Version, "info", T.TextSecondary)
        st:CreateButton({
            Name     = "Test Notification",
            Callback = function()
                self:Notify({ Title="NexusUI", Content="Everything is working perfectly.", Type="success", Duration=3 })
            end,
        })
        st:CreateButton({
            Name     = "Save Config",
            Callback = function()
                self:SaveConfig()
                self:Notify({ Title="Config", Content="Saved successfully.", Type="success", Duration=2 })
            end,
        })
        return st
    end

    return Win
end -- CreateWindow

return NexusUI
