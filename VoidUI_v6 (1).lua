-- ══════════════════════════════════════════════════════════════
--  VoidUI v6.0  ·  Arx2d
--
--  Новое в v6.0:
--    · Window: иконка в тайтлбаре, ModifyTheme(name|table)
--    · Tab: иконки-эмодзи и числовые бейджи
--    · CreateParagraph  — заголовок + многострочный контент
--    · CreateTable      — таблица данных с заголовками
--    · CreateChart      — мини bar-chart
--    · CreateToggle     — Description + бейдж-статус
--    · CreateDropdown   — Refresh(newOpts), MultipleOptions
--    · CreateColorPicker — Hex + RGB инпуты
--    · CreateKeybind    — CallOnChange, HoldToInteract
--    · CreateSlider     — двойной range (Min/Max ручки)
--    · Notify           — Type иконки, очередь до 6, dismiss по клику
--    · ModifyTheme      — горячая смена темы (имя или таблица)
--    · CreateStatsOverlay — FPS + Ping + Memory
--    · CreateWatermark  — версия + FPS
--    · Все элементы: Tooltip через attachTooltip
--    · GC через Maid при вызове Tab:Destroy()
-- ══════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local GuiService       = game:GetService("GuiService")
local Players          = game:GetService("Players")
local Debris           = game:GetService("Debris")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  MAID
-- ════════════════════════════════════════════════════════════════
local Maid = {}; Maid.__index = Maid
function Maid.new() return setmetatable({ _t = {} }, Maid) end
function Maid:Add(x) table.insert(self._t, x); return x end
function Maid:Clean()
    for _, t in ipairs(self._t) do
        if typeof(t) == "RBXScriptConnection" then pcall(function() t:Disconnect() end)
        elseif typeof(t) == "Instance"         then pcall(function() t:Destroy()    end)
        elseif type(t)   == "function"          then pcall(t) end
    end
    self._t = {}
end

-- ════════════════════════════════════════════════════════════════
--  ТЕМЫ
-- ════════════════════════════════════════════════════════════════
local THEMES = {
    Void = {
        Bg          = Color3.fromRGB(8,   8,  14),
        BgLight     = Color3.fromRGB(14,  14, 22),
        BgTab       = Color3.fromRGB(11,  11, 18),
        BgElement   = Color3.fromRGB(18,  18, 28),
        BgHover     = Color3.fromRGB(28,  16, 56),
        BgInput     = Color3.fromRGB(6,   6,  11),
        Accent      = Color3.fromRGB(138, 58, 255),
        AccentDark  = Color3.fromRGB(88,  28, 178),
        AccentLight = Color3.fromRGB(178, 118, 255),
        AccentFaded = Color3.fromRGB(55,  20, 110),
        TextPrimary = Color3.fromRGB(238, 238, 252),
        TextSub     = Color3.fromRGB(138, 138, 158),
        TextMuted   = Color3.fromRGB(72,  72,  90),
        TextAccent  = Color3.fromRGB(178, 118, 255),
        Border      = Color3.fromRGB(36,  16,  76),
        BorderLight = Color3.fromRGB(56,  26, 106),
        Sep         = Color3.fromRGB(26,  12,  54),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(138, 58, 255),
        ScrollBar   = Color3.fromRGB(55,  25, 115),
    },
    Midnight = {
        Bg          = Color3.fromRGB(6,   8,  16),
        BgLight     = Color3.fromRGB(10,  14, 28),
        BgTab       = Color3.fromRGB(8,   10, 22),
        BgElement   = Color3.fromRGB(14,  18, 36),
        BgHover     = Color3.fromRGB(20,  30, 70),
        BgInput     = Color3.fromRGB(5,   7,  14),
        Accent      = Color3.fromRGB(60,  120, 255),
        AccentDark  = Color3.fromRGB(30,  70, 180),
        AccentLight = Color3.fromRGB(100, 160, 255),
        AccentFaded = Color3.fromRGB(20,  45, 110),
        TextPrimary = Color3.fromRGB(220, 230, 255),
        TextSub     = Color3.fromRGB(120, 140, 180),
        TextMuted   = Color3.fromRGB(60,  75, 110),
        TextAccent  = Color3.fromRGB(100, 160, 255),
        Border      = Color3.fromRGB(20,  40, 100),
        BorderLight = Color3.fromRGB(35,  60, 140),
        Sep         = Color3.fromRGB(15,  25,  60),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(60,  120, 255),
        ScrollBar   = Color3.fromRGB(30,  65, 160),
    },
    Crimson = {
        Bg          = Color3.fromRGB(12,  6,   8),
        BgLight     = Color3.fromRGB(20,  10,  14),
        BgTab       = Color3.fromRGB(16,  8,   11),
        BgElement   = Color3.fromRGB(24,  12,  16),
        BgHover     = Color3.fromRGB(55,  16,  22),
        BgInput     = Color3.fromRGB(8,   4,   6),
        Accent      = Color3.fromRGB(220, 40,  60),
        AccentDark  = Color3.fromRGB(140, 20,  35),
        AccentLight = Color3.fromRGB(255, 90, 110),
        AccentFaded = Color3.fromRGB(90,  16,  25),
        TextPrimary = Color3.fromRGB(252, 230, 235),
        TextSub     = Color3.fromRGB(180, 130, 140),
        TextMuted   = Color3.fromRGB(100, 65,  72),
        TextAccent  = Color3.fromRGB(255, 90, 110),
        Border      = Color3.fromRGB(80,  18,  26),
        BorderLight = Color3.fromRGB(120, 30,  42),
        Sep         = Color3.fromRGB(50,  12,  18),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(220, 40,  60),
        ScrollBar   = Color3.fromRGB(110, 22,  35),
    },
    Forest = {
        Bg          = Color3.fromRGB(6,   12,  8),
        BgLight     = Color3.fromRGB(10,  20,  13),
        BgTab       = Color3.fromRGB(8,   16,  10),
        BgElement   = Color3.fromRGB(12,  24,  15),
        BgHover     = Color3.fromRGB(18,  50,  24),
        BgInput     = Color3.fromRGB(5,   9,   6),
        Accent      = Color3.fromRGB(48,  200, 80),
        AccentDark  = Color3.fromRGB(24,  130, 48),
        AccentLight = Color3.fromRGB(100, 230, 130),
        AccentFaded = Color3.fromRGB(16,  75,  28),
        TextPrimary = Color3.fromRGB(220, 252, 228),
        TextSub     = Color3.fromRGB(120, 170, 130),
        TextMuted   = Color3.fromRGB(60,  95,  68),
        TextAccent  = Color3.fromRGB(100, 230, 130),
        Border      = Color3.fromRGB(18,  70,  28),
        BorderLight = Color3.fromRGB(28,  100, 42),
        Sep         = Color3.fromRGB(12,  44,  18),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(48,  200, 80),
        ScrollBar   = Color3.fromRGB(22,  90,  38),
    },
    Ash = {
        Bg          = Color3.fromRGB(12,  12,  14),
        BgLight     = Color3.fromRGB(20,  20,  24),
        BgTab       = Color3.fromRGB(16,  16,  19),
        BgElement   = Color3.fromRGB(24,  24,  28),
        BgHover     = Color3.fromRGB(40,  40,  50),
        BgInput     = Color3.fromRGB(8,   8,   10),
        Accent      = Color3.fromRGB(180, 180, 200),
        AccentDark  = Color3.fromRGB(100, 100, 120),
        AccentLight = Color3.fromRGB(220, 220, 240),
        AccentFaded = Color3.fromRGB(60,  60,  75),
        TextPrimary = Color3.fromRGB(240, 240, 248),
        TextSub     = Color3.fromRGB(150, 150, 165),
        TextMuted   = Color3.fromRGB(80,  80,  95),
        TextAccent  = Color3.fromRGB(220, 220, 240),
        Border      = Color3.fromRGB(50,  50,  65),
        BorderLight = Color3.fromRGB(70,  70,  88),
        Sep         = Color3.fromRGB(30,  30,  40),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(180, 180, 200),
        ScrollBar   = Color3.fromRGB(65,  65,  85),
    },
    Gold = {
        Bg          = Color3.fromRGB(10,  8,   4),
        BgLight     = Color3.fromRGB(18,  14,  6),
        BgTab       = Color3.fromRGB(14,  11,  5),
        BgElement   = Color3.fromRGB(22,  17,  7),
        BgHover     = Color3.fromRGB(50,  36,  8),
        BgInput     = Color3.fromRGB(7,   5,   2),
        Accent      = Color3.fromRGB(230, 170, 30),
        AccentDark  = Color3.fromRGB(150, 105, 15),
        AccentLight = Color3.fromRGB(255, 210, 80),
        AccentFaded = Color3.fromRGB(85,  60,  10),
        TextPrimary = Color3.fromRGB(255, 245, 210),
        TextSub     = Color3.fromRGB(180, 155, 90),
        TextMuted   = Color3.fromRGB(100, 82,  40),
        TextAccent  = Color3.fromRGB(255, 210, 80),
        Border      = Color3.fromRGB(80,  58,  12),
        BorderLight = Color3.fromRGB(120, 88,  20),
        Sep         = Color3.fromRGB(50,  36,  8),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(230, 170, 30),
        ScrollBar   = Color3.fromRGB(100, 72,  15),
    },
    -- НОВЫЕ ТЕМЫ v6
    Rose = {
        Bg          = Color3.fromRGB(14,  8,  12),
        BgLight     = Color3.fromRGB(22,  12, 18),
        BgTab       = Color3.fromRGB(18,  10, 15),
        BgElement   = Color3.fromRGB(26,  14, 22),
        BgHover     = Color3.fromRGB(60,  18, 44),
        BgInput     = Color3.fromRGB(8,   5,  7),
        Accent      = Color3.fromRGB(236, 72, 153),
        AccentDark  = Color3.fromRGB(157, 23, 77),
        AccentLight = Color3.fromRGB(251, 148, 199),
        AccentFaded = Color3.fromRGB(88,  20,  55),
        TextPrimary = Color3.fromRGB(252, 228, 240),
        TextSub     = Color3.fromRGB(180, 120, 150),
        TextMuted   = Color3.fromRGB(100, 60,  80),
        TextAccent  = Color3.fromRGB(251, 148, 199),
        Border      = Color3.fromRGB(90,  22,  58),
        BorderLight = Color3.fromRGB(130, 35,  80),
        Sep         = Color3.fromRGB(55,  14,  36),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(236, 72, 153),
        ScrollBar   = Color3.fromRGB(120, 30,  75),
    },
    Ice = {
        Bg          = Color3.fromRGB(6,   14,  18),
        BgLight     = Color3.fromRGB(10,  22,  28),
        BgTab       = Color3.fromRGB(8,   18,  23),
        BgElement   = Color3.fromRGB(12,  26,  34),
        BgHover     = Color3.fromRGB(16,  50,  68),
        BgInput     = Color3.fromRGB(5,   10,  14),
        Accent      = Color3.fromRGB(56,  189, 248),
        AccentDark  = Color3.fromRGB(14,  116, 163),
        AccentLight = Color3.fromRGB(125, 211, 252),
        AccentFaded = Color3.fromRGB(12,  72, 100),
        TextPrimary = Color3.fromRGB(220, 242, 252),
        TextSub     = Color3.fromRGB(100, 160, 190),
        TextMuted   = Color3.fromRGB(50,  100, 130),
        TextAccent  = Color3.fromRGB(125, 211, 252),
        Border      = Color3.fromRGB(14,  68, 100),
        BorderLight = Color3.fromRGB(22, 100, 140),
        Sep         = Color3.fromRGB(10,  44,  65),
        Success     = Color3.fromRGB(48,  214, 98),
        Warning     = Color3.fromRGB(252, 178, 48),
        Error       = Color3.fromRGB(252, 58,  58),
        Info        = Color3.fromRGB(56,  189, 248),
        ScrollBar   = Color3.fromRGB(18,  100, 140),
    },
}

local T = {}
for k, v in pairs(THEMES.Void) do T[k] = v end

local function applyTheme(name)
    local src = THEMES[name]; if not src then return end
    for k, v in pairs(src) do T[k] = v end
end

local function applyThemeTable(tbl)
    for k, v in pairs(tbl) do T[k] = v end
end

local function applyAccent(col)
    T.Accent      = col
    T.AccentDark  = Color3.new(col.R*.62, col.G*.62, col.B*.62)
    T.AccentLight = Color3.new(math.min(col.R*1.35,1), math.min(col.G*1.35,1), math.min(col.B*1.35,1))
    T.AccentFaded = Color3.new(col.R*.38, col.G*.38, col.B*.38)
    T.TextAccent  = T.AccentLight
    T.Border      = Color3.new(col.R*.27, col.G*.15, col.B*.55)
    T.ScrollBar   = Color3.new(col.R*.44, col.G*.22, col.B*.70)
    T.Info        = col
end

-- ════════════════════════════════════════════════════════════════
--  SAFE ZONE
-- ════════════════════════════════════════════════════════════════
local function getSafeInset()
    local ok, top = pcall(function() return GuiService:GetGuiInset() end)
    return ok and top or Vector2.zero
end

-- ════════════════════════════════════════════════════════════════
--  TWEEN INFO PRESETS
-- ════════════════════════════════════════════════════════════════
local EF = { Enum.EasingStyle.Quad, Enum.EasingDirection.Out }
local TI = {
    Fast   = TweenInfo.new(0.12, table.unpack(EF)),
    Mid    = TweenInfo.new(0.20, table.unpack(EF)),
    Slow   = TweenInfo.new(0.34, table.unpack(EF)),
    Spring = TweenInfo.new(0.30, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    Linear = TweenInfo.new(1,    Enum.EasingStyle.Linear),
}

-- ════════════════════════════════════════════════════════════════
--  УТИЛИТЫ (UI-строители)
-- ════════════════════════════════════════════════════════════════
local function tw(o, p, i)
    if not o or not o.Parent then return end
    if o:IsA("GuiObject") and not o.Visible then return end
    TweenService:Create(o, i or TI.Mid, p):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6); c.Parent = p; return c
end

local function pad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 6)
    u.PaddingRight  = UDim.new(0, r or 6)
    u.PaddingBottom = UDim.new(0, b or 6)
    u.PaddingLeft   = UDim.new(0, l or 6)
    u.Parent = p; return u
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or T.Border; s.Thickness = thick or 1
    s.Transparency = trans or 0; s.Parent = p; return s
end

local function lbl(p, text, size, color, font, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text           = text  or ""
    l.TextSize       = size  or 13
    l.TextColor3     = color or T.TextPrimary
    l.Font           = font  or Enum.Font.GothamMedium
    l.TextXAlignment = xa    or Enum.TextXAlignment.Left
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    l.Parent = p; return l
end

local function lst(p, spacing, dir)
    local u = Instance.new("UIListLayout")
    u.SortOrder     = Enum.SortOrder.LayoutOrder
    u.FillDirection = dir or Enum.FillDirection.Vertical
    u.Padding       = UDim.new(0, spacing or 0)
    u.Parent = p; return u
end

local function grad(p, colors, rot)
    local g = Instance.new("UIGradient")
    local kps = {}
    for i, v in ipairs(colors) do
        kps[i] = ColorSequenceKeypoint.new((i-1)/(#colors-1), v)
    end
    g.Color = ColorSequence.new(kps); g.Rotation = rot or 0
    g.Parent = p; return g
end

local function frm(p, size, pos, bg, trans)
    local f = Instance.new("Frame")
    f.Size                   = size  or UDim2.new(1,0,1,0)
    f.Position               = pos   or UDim2.new(0,0,0,0)
    f.BackgroundColor3       = bg    or T.Bg
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel        = 0
    f.Parent = p; return f
end

local function ripple(p, mx, my)
    local r = Instance.new("Frame")
    r.BackgroundColor3       = Color3.new(1,1,1)
    r.BackgroundTransparency = 0.80
    r.BorderSizePixel        = 0
    r.Size                   = UDim2.new(0,0,0,0)
    r.Position               = UDim2.new(0,mx,0,my)
    r.AnchorPoint            = Vector2.new(0.5,0.5)
    r.ZIndex = 20; r.Parent = p; corner(r,999)
    local sz = math.max(p.AbsoluteSize.X, p.AbsoluteSize.Y) * 2.4
    tw(r, {Size=UDim2.new(0,sz,0,sz), BackgroundTransparency=1},
        TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
    Debris:AddItem(r, 0.5)
end

local function mrel(obj)
    local mp = UserInputService:GetMouseLocation()
    return mp.X - obj.AbsolutePosition.X, mp.Y - obj.AbsolutePosition.Y
end

local function bindCanvas(scroll, layout)
    local function upd()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd); upd()
end

-- ════════════════════════════════════════════════════════════════
--  КОНФИГ
-- ════════════════════════════════════════════════════════════════
local CFG_DIR = "VoidUI"
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

-- ════════════════════════════════════════════════════════════════
--  ГЛОБАЛЬНЫЕ ХОТКЕИ
-- ════════════════════════════════════════════════════════════════
local _hotkeys = {}
local function registerHotkey(key, cb)
    table.insert(_hotkeys, {key=key, cb=cb}); return #_hotkeys
end
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for _, h in pairs(_hotkeys) do
        if h and i.KeyCode == h.key then pcall(h.cb) end
    end
end)

-- ════════════════════════════════════════════════════════════════
--  TOOLTIP SYSTEM
-- ════════════════════════════════════════════════════════════════
local _ttGui, _ttFrame, _ttLbl
local function _initTT()
    if _ttGui then return end
    _ttGui = Instance.new("ScreenGui")
    _ttGui.Name = "VoidUI_TT"; _ttGui.ResetOnSpawn = false
    _ttGui.IgnoreGuiInset = true; _ttGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _ttGui.Parent = LP.PlayerGui
    _ttFrame = frm(_ttGui, UDim2.new(0,10,0,24), nil, T.BgLight, 0)
    _ttFrame.Visible = false; _ttFrame.ZIndex = 60
    corner(_ttFrame, 5); stroke(_ttFrame, T.Border, 1, 0); pad(_ttFrame,4,8,4,8)
    _ttLbl = lbl(_ttFrame, "", 10, T.TextSub, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    _ttLbl.Size = UDim2.new(1,0,1,0); _ttLbl.ZIndex = 61
end
local function attachTooltip(obj, text)
    _initTT()
    obj.MouseEnter:Connect(function()
        _ttLbl.Text = text
        _ttFrame.Size = UDim2.new(0, math.max(#text*6.2+20, 60), 0, 24)
        _ttFrame.Visible = true
        _ttFrame.BackgroundTransparency = 1
        tw(_ttFrame, {BackgroundTransparency=0}, TI.Fast)
    end)
    obj.MouseLeave:Connect(function() _ttFrame.Visible = false end)
    RunService.RenderStepped:Connect(function()
        if _ttFrame.Visible then
            local mp = UserInputService:GetMouseLocation()
            _ttFrame.Position = UDim2.new(0, mp.X+14, 0, mp.Y+8)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  CONTEXT MENU
-- ════════════════════════════════════════════════════════════════
local _ctxGui
local function _destroyCtx()
    if _ctxGui then _ctxGui:Destroy(); _ctxGui = nil end
end
local function showCtx(items, x, y)
    _destroyCtx()
    _ctxGui = Instance.new("ScreenGui")
    _ctxGui.Name = "VoidUI_Ctx"; _ctxGui.ResetOnSpawn = false
    _ctxGui.IgnoreGuiInset = true; _ctxGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _ctxGui.Parent = LP.PlayerGui
    local h = #items*30+8
    local mf = frm(_ctxGui, UDim2.new(0,160,0,0), UDim2.new(0,x,0,y), T.BgLight, 0)
    mf.ZIndex = 50; corner(mf,8); stroke(mf,T.Border,1,0); pad(mf,4,4,4,4); lst(mf,2)
    tw(mf, {Size=UDim2.new(0,160,0,h)}, TI.Spring)
    for _, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,26); btn.BackgroundColor3=T.BgElement
        btn.Text=""; btn.BorderSizePixel=0; btn.ZIndex=51; btn.Parent=mf; corner(btn,5)
        local il = lbl(btn, item.icon and (item.icon.." ") or "", 11, T.Accent, Enum.Font.GothamMedium)
        il.Size=UDim2.new(0,22,1,0); il.Position=UDim2.new(0,6,0,0)
        il.TextXAlignment=Enum.TextXAlignment.Center; il.ZIndex=52
        local tl = lbl(btn, item.label or "", 11, T.TextSub)
        tl.Size=UDim2.new(1,-32,1,0); tl.Position=UDim2.new(0,28,0,0); tl.ZIndex=52
        btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=T.BgHover},TI.Fast); tw(tl,{TextColor3=T.TextPrimary},TI.Fast) end)
        btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=T.BgElement},TI.Fast); tw(tl,{TextColor3=T.TextSub},TI.Fast) end)
        btn.MouseButton1Click:Connect(function() _destroyCtx(); if item.cb then item.cb() end end)
    end
    local cc; cc = UserInputService.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function() _destroyCtx(); cc:Disconnect() end)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  VOIDUI OBJECT
-- ════════════════════════════════════════════════════════════════
local VoidUI = {}
VoidUI.__index = VoidUI
VoidUI.Version = "6.0.0"
VoidUI.Author  = "Arx2d"
VoidUI.Flags   = {}
VoidUI.Theme   = T
VoidUI.Themes  = THEMES

-- ════════════════════════════════════════════════════════════════
--  NOTIFY  (очередь до 6, тип, прогресс-бар, dismiss по клику)
-- ════════════════════════════════════════════════════════════════
local _ng, _nh, _ns = nil, nil, {}
local function _initN()
    if _ng then return end
    _ng = Instance.new("ScreenGui")
    _ng.Name="VoidUI_N"; _ng.ResetOnSpawn=false
    _ng.IgnoreGuiInset=true; _ng.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    _ng.Parent = LP.PlayerGui
    _nh = frm(_ng, UDim2.new(0,310,1,0), UDim2.new(1,-326,0,0), T.Bg, 1)
    local u = lst(_nh,7)
    u.VerticalAlignment = Enum.VerticalAlignment.Bottom
    pad(_nh,0,0,14,0)
end

function VoidUI:Notify(opts)
    _initN()
    local title   = opts.Title    or "VoidUI"
    local content = opts.Content  or ""
    local dur     = opts.Duration or 4
    local ntype   = opts.Type     or "info"
    local icons   = {info="ℹ", success="✓", warning="⚠", error="✕"}
    local ncols   = {info=T.Info, success=T.Success, warning=T.Warning, error=T.Error}
    local ac      = ncols[ntype] or T.Info

    -- убираем старые если очередь переполнена
    if #_ns >= 6 then
        local old = table.remove(_ns, 1)
        if old and old.Parent then
            tw(old, {Position=UDim2.new(1,14,0,old.Position.Y.Offset), BackgroundTransparency=1}, TI.Fast)
            task.delay(0.25, function() if old.Parent then old:Destroy() end end)
        end
    end

    local nf = frm(_nh, UDim2.new(1,0,0,72), nil, T.BgLight, 0)
    nf.ClipsDescendants = true; nf.LayoutOrder = tick()
    corner(nf,10); stroke(nf, ac, 1, 0.5)

    -- левая полоска акцента
    local ab = frm(nf, UDim2.new(0,3,0.65,0), UDim2.new(0,0,0.175,0), ac, 0); corner(ab,3)
    grad(ab, {T.AccentLight, ac}, 90)

    -- иконка
    local icf = frm(nf, UDim2.new(0,28,0,28), UDim2.new(0,12,0,10), T.AccentFaded, 0); corner(icf,7)
    local icl = lbl(icf, icons[ntype] or "·", 13, ac, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    icl.Size = UDim2.new(1,0,1,0)

    -- текст
    local tl = lbl(nf, title, 12, T.TextPrimary, Enum.Font.GothamBold)
    tl.Size = UDim2.new(1,-58,0,16); tl.Position = UDim2.new(0,48,0,9)
    local cl = lbl(nf, content, 11, T.TextSub, Enum.Font.Gotham)
    cl.Size = UDim2.new(1,-58,0,32); cl.Position = UDim2.new(0,48,0,26)
    cl.TextWrapped = true; cl.TextTruncate = Enum.TextTruncate.None

    -- прогресс-бар
    local pbg = frm(nf, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), T.Border, 0)
    local pb  = frm(pbg, UDim2.new(1,0,1,0), nil, ac, 0)
    grad(pb, {T.AccentLight, ac}, 0)

    -- кнопка закрыть
    local xBtn = Instance.new("TextButton")
    xBtn.Size=UDim2.new(0,18,0,18); xBtn.Position=UDim2.new(1,-24,0,7)
    xBtn.BackgroundTransparency=1; xBtn.Text="✕"; xBtn.TextSize=9
    xBtn.TextColor3=T.TextMuted; xBtn.Font=Enum.Font.GothamBold; xBtn.Parent=nf

    nf.Position = UDim2.new(1,14,0,0)
    tw(nf, {Position=UDim2.new(0,0,0,0)}, TI.Spring)
    table.insert(_ns, nf)
    tw(pb, {Size=UDim2.new(0,0,1,0)}, TweenInfo.new(dur, Enum.EasingStyle.Linear))

    local function dismiss()
        local idx = table.find(_ns, nf)
        if idx then table.remove(_ns, idx) end
        tw(nf, {Position=UDim2.new(1,14,0,0), BackgroundTransparency=1}, TI.Mid)
        task.delay(0.25, function() if nf.Parent then nf:Destroy() end end)
    end
    xBtn.MouseButton1Click:Connect(dismiss)
    nf.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dismiss() end
    end)
    task.delay(dur, dismiss)
end

-- ════════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ════════════════════════════════════════════════════════════════
local function _loadScreen(opts)
    local title = opts.LoadingTitle    or "VOID UI"
    local sub   = opts.LoadingSubtitle or ""
    local steps = opts.LoadingSteps    or {"Initializing…","Building UI…","Ready!"}
    local logo  = opts.Logo            or "VOID"

    local sg = Instance.new("ScreenGui")
    sg.Name="VoidUI_Load"; sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.Parent = LP.PlayerGui

    local bg   = frm(sg, UDim2.new(1,0,1,0), nil, Color3.fromRGB(4,4,8), 1)
    local card = frm(sg, UDim2.new(0,440,0,260), UDim2.new(0.5,-220,0.5,-130), T.Bg, 1)
    corner(card,14); stroke(card, T.Border, 1, 0)

    -- верхняя полоска акцента
    local topStripe = frm(card, UDim2.new(1,0,0,3), nil, T.Accent, 0); corner(topStripe,14)
    grad(topStripe, {T.AccentLight, T.Accent, T.AccentDark}, 0)

    -- логотип
    local ll = lbl(card, logo, 42, T.TextPrimary, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    ll.Size=UDim2.new(1,0,0,58); ll.Position=UDim2.new(0,0,0,26)
    grad(ll, {T.AccentLight, T.Accent}, 90)

    -- заголовок / подзаголовок
    local ttl = lbl(card, title, 15, T.TextPrimary, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    ttl.Size=UDim2.new(1,-32,0,22); ttl.Position=UDim2.new(0,16,0,94)
    local stl = lbl(card, sub, 11, T.TextSub, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    stl.Size=UDim2.new(1,-32,0,16); stl.Position=UDim2.new(0,16,0,118)

    -- разделитель
    frm(card, UDim2.new(1,-32,0,1), UDim2.new(0,16,0,142), T.Sep, 0)

    -- шаг загрузки
    local stp = lbl(card, steps[1], 10, T.TextAccent, Enum.Font.Code, Enum.TextXAlignment.Center)
    stp.Size=UDim2.new(1,-32,0,16); stp.Position=UDim2.new(0,16,0,152)

    -- прогресс
    local pbg = frm(card, UDim2.new(1,-32,0,6), UDim2.new(0,16,0,176), T.BgElement, 0); corner(pbg,6)
    local pb  = frm(pbg, UDim2.new(0,0,1,0), nil, T.Accent, 0); corner(pb,6)
    grad(pb, {T.AccentLight, T.Accent}, 0)

    -- версия
    local vl = lbl(card, "void ui v"..VoidUI.Version, 9, T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    vl.Size=UDim2.new(1,-32,0,14); vl.Position=UDim2.new(0,16,0,202)

    tw(bg,   {BackgroundTransparency=0.20}, TI.Mid)
    tw(card, {BackgroundTransparency=0},    TI.Spring)

    local n = #steps
    for i, step in ipairs(steps) do
        stp.Text = step
        tw(pb, {Size=UDim2.new(i/n,0,1,0)},
            TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
        task.wait(0.28)
    end
    task.wait(0.20)
    tw(card, {BackgroundTransparency=1, Position=UDim2.new(0.5,-220,0.42,-130)}, TI.Mid)
    tw(bg,   {BackgroundTransparency=1}, TI.Mid)
    task.wait(0.28); sg:Destroy()
end

-- ════════════════════════════════════════════════════════════════
--  STATS OVERLAY  (FPS + Ping + Memory)
-- ════════════════════════════════════════════════════════════════
local _statGui
function VoidUI:CreateStatsOverlay(opts)
    opts = opts or {}
    if _statGui then _statGui:Destroy() end
    _statGui = Instance.new("ScreenGui")
    _statGui.Name="VoidUI_Stats"; _statGui.ResetOnSpawn=false
    _statGui.IgnoreGuiInset=true; _statGui.Parent=LP.PlayerGui

    local W, H = 240, 56
    local vp = workspace.CurrentCamera.ViewportSize
    local sf = frm(_statGui, UDim2.new(0,W,0,H), UDim2.new(0,vp.X-W-14,0,vp.Y-H-14), T.BgLight, 0)
    corner(sf,10); stroke(sf, T.Border, 1, 0.2)

    local topBar = frm(sf, UDim2.new(1,0,0,2), nil, T.Accent, 0); corner(topBar,10)
    grad(topBar, {T.AccentLight, T.Accent, T.AccentDark}, 0)

    local function block(parent, x, w, label)
        local b = frm(parent, UDim2.new(0,w,-0,H-6), UDim2.new(0,x,0,4), T.Bg, 0); corner(b,7)
        local il = lbl(b, label, 7, T.TextMuted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        il.Size=UDim2.new(1,0,0,12); il.Position=UDim2.new(0,0,0,4)
        local vl = lbl(b, "…", 17, T.TextAccent, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
        vl.Size=UDim2.new(1,0,0,22); vl.Position=UDim2.new(0,0,0,14)
        return vl
    end

    local bw = math.floor((W-16)/3)
    local fpsV  = block(sf, 4,         bw,   "FPS")
    local pingV = block(sf, 8+bw,      bw,   "PING")
    local memV  = block(sf, 12+bw*2,   bw,   "MEM")

    -- разделители
    for _, xOff in ipairs({4+bw, 4+bw*2}) do
        frm(sf, UDim2.new(0,1,0,36), UDim2.new(0,xOff+4,0,10), T.Sep, 0)
    end

    -- перетаскивание
    local drag, dS, dO = false, nil, nil
    sf.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; dS=i.Position; dO=sf.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dS; local cvp=workspace.CurrentCamera.ViewportSize
            sf.Position=UDim2.new(0,math.clamp(dO.X.Offset+d.X,0,cvp.X-W),0,math.clamp(dO.Y.Offset+d.Y,0,cvp.Y-H))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)

    local fc, ft, pt = 0, os.clock(), 0
    local function getPing()
        local ok, p = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        return ok and math.round(p) or 0
    end
    RunService.Heartbeat:Connect(function(dt)
        fc += 1; pt += dt
        local now = os.clock()
        if now-ft >= 0.5 then
            local fps = math.round(fc/(now-ft)); fc=0; ft=now
            fpsV.Text = tostring(fps)
            fpsV.TextColor3 = fps>=55 and T.Success or fps>=30 and T.Warning or T.Error
        end
        if pt >= 1 then
            pt=0
            local p = getPing()
            pingV.Text = tostring(p).."ms"
            pingV.TextColor3 = p<80 and T.Success or p<150 and T.Warning or T.Error
            local mem = math.round(collectgarbage("count")/1024)
            memV.Text = tostring(mem).."mb"
            memV.TextColor3 = mem<64 and T.Success or mem<128 and T.Warning or T.Error
        end
    end)

    local obj={}
    function obj:Toggle(v) sf.Visible=v end
    function obj:Destroy() _statGui:Destroy() end
    return obj
end

-- ════════════════════════════════════════════════════════════════
--  WATERMARK
-- ════════════════════════════════════════════════════════════════
local _wmg
function VoidUI:CreateWatermark(opts)
    if _wmg then _wmg:Destroy() end
    local text = opts.Text or "VOID UI"
    _wmg = Instance.new("ScreenGui")
    _wmg.Name="VoidUI_WM"; _wmg.ResetOnSpawn=false
    _wmg.IgnoreGuiInset=true; _wmg.Parent=LP.PlayerGui
    local safe = getSafeInset()
    local wf = frm(_wmg, UDim2.new(0,240,0,32), UDim2.new(0,14,0,math.max(safe.Y,14)), T.BgLight, 0)
    corner(wf,8); stroke(wf, T.Border, 1, 0)
    if opts.Enabled==false then wf.Visible=false end

    local bar = frm(wf, UDim2.new(0,2,0,20), UDim2.new(0,8,0.5,-10), T.Accent, 0)
    corner(bar,2); grad(bar, {T.AccentLight, T.Accent}, 90)
    local wl = lbl(wf, text, 11, T.TextSub, Enum.Font.GothamMedium)
    wl.Size=UDim2.new(1,-20,1,0); wl.Position=UDim2.new(0,18,0,0)

    local fc2, ft2, fps2 = 0, os.clock(), 60
    RunService.Heartbeat:Connect(function()
        fc2+=1; local n=os.clock()
        if n-ft2>=0.5 then fps2=math.round(fc2/(n-ft2)); fc2=0; ft2=n end
        wl.Text = text.."  ·  "..fps2.." fps"
        wl.TextColor3 = fps2>=55 and T.TextSub or fps2>=30 and T.Warning or T.Error
    end)

    local obj={}
    function obj:SetText(t) text=t end
    function obj:Toggle(v) wf.Visible=v end
    function obj:Destroy() _wmg:Destroy() end
    return obj
end

-- ════════════════════════════════════════════════════════════════
--  MODULE LOADER
-- ════════════════════════════════════════════════════════════════
VoidUI._modules = {}
function VoidUI:LoadModule(url)
    if self._modules[url] then return self._modules[url] end
    local ok, r = pcall(function() return loadstring(game:HttpGet(url))(self) end)
    if not ok then warn("[VoidUI] LoadModule failed:", url, r); return nil end
    self._modules[url] = r; return r
end

-- ════════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ════════════════════════════════════════════════════════════════
function VoidUI:CreateWindow(opts)
    local winName   = opts.Name            or "VOID UI"
    local lTitle    = opts.LoadingTitle    or winName
    local lSub      = opts.LoadingSubtitle or ""
    local lSteps    = opts.LoadingSteps
    local lLogo     = opts.Logo            or "VOID"
    local cfgOpts   = opts.ConfigurationSaving or {}
    local cfgFile   = cfgOpts.FileName or "config"
    local cfgOn     = cfgOpts.Enabled ~= false
    local winIcon   = opts.Icon -- эмодзи или nil
    local maxW      = (opts.Size and opts.Size.Width)  or 680
    local maxH      = (opts.Size and opts.Size.Height) or 480
    local minW, minH = 300, 220

    -- ToggleKey: строка или Enum.KeyCode
    local tKey = Enum.KeyCode.RightShift
    if opts.ToggleKey then
        if typeof(opts.ToggleKey)=="EnumItem" then tKey=opts.ToggleKey
        elseif type(opts.ToggleKey)=="string" then
            pcall(function() tKey=Enum.KeyCode[opts.ToggleKey] end)
        end
    end

    local themeName = opts.Theme or "Void"
    applyTheme(themeName)
    if opts.Accent then applyAccent(opts.Accent) end

    -- loading
    task.spawn(_loadScreen, {
        LoadingTitle=lTitle, LoadingSubtitle=lSub,
        LoadingSteps=lSteps, Logo=lLogo,
    })
    task.wait((#(lSteps or {"","",""}) * 0.28) + 0.60)

    local saved = cfgOn and cfgLoad(cfgFile) or {}

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name="VoidUI_Main"; sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.Parent = LP.PlayerGui

    -- главный фрейм
    local mf = Instance.new("Frame")
    mf.AnchorPoint   = Vector2.new(0.5,0.5)
    mf.Position      = UDim2.new(0.5,0,0.5,0)
    mf.Size          = UDim2.new(0.88,0,0.82,0)
    mf.BackgroundColor3 = T.Bg
    mf.BorderSizePixel  = 0
    mf.Parent = sg
    corner(mf,12); stroke(mf, T.Border, 1, 0)

    local sizeC = Instance.new("UISizeConstraint")
    sizeC.MinSize=Vector2.new(minW,minH); sizeC.MaxSize=Vector2.new(maxW,maxH)
    sizeC.Parent = mf

    -- свечение
    local glw = Instance.new("ImageLabel")
    glw.Size=UDim2.new(1,90,1,90); glw.Position=UDim2.new(0,-45,0,-45)
    glw.BackgroundTransparency=1; glw.Image="rbxassetid://5028857084"
    glw.ImageColor3=T.Accent; glw.ImageTransparency=0.88
    glw.ScaleType=Enum.ScaleType.Slice; glw.SliceCenter=Rect.new(24,24,276,276)
    glw.ZIndex=0; glw.Parent=mf

    -- ── тайтлбар ──────────────────────────────────────────────
    local tb = frm(mf, UDim2.new(1,0,0,44), nil, T.BgLight, 0); corner(tb,12)
    frm(tb, UDim2.new(1,0,0,14), UDim2.new(0,0,1,-14), T.BgLight, 0) -- скруглённый низ

    local tbLine = frm(tb, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), T.Accent, 0.4)
    grad(tbLine, {Color3.new(0,0,0), T.Accent, T.AccentLight, T.Accent, Color3.new(0,0,0)}, 0)

    local xOff = winIcon and 56 or 14
    if winIcon then
        local icL = lbl(tb, winIcon, 18, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        icL.Size=UDim2.new(0,34,1,0); icL.Position=UDim2.new(0,12,0,0)
    end

    local logoL = lbl(tb, "VOID", 15, T.Accent, Enum.Font.GothamBlack)
    logoL.Size=UDim2.new(0,46,1,0); logoL.Position=UDim2.new(0,xOff,0,0)
    local nameL = lbl(tb, winName, 12, T.TextSub, Enum.Font.GothamMedium)
    nameL.Size=UDim2.new(1,-240,1,0); nameL.Position=UDim2.new(0,xOff+50,0,0)
    local verL = lbl(tb, "v"..VoidUI.Version, 9, T.TextMuted, Enum.Font.Code, Enum.TextXAlignment.Right)
    verL.Size=UDim2.new(0,56,1,0); verL.Position=UDim2.new(1,-158,0,0)

    local function ctrlBtn(txt, xo, hcol)
        local b = Instance.new("TextButton")
        b.Size=UDim2.new(0,28,0,22); b.Position=UDim2.new(1,xo,0.5,-11)
        b.BackgroundColor3=T.BgElement; b.Text=txt; b.Font=Enum.Font.GothamBold
        b.TextSize=11; b.TextColor3=T.TextMuted; b.BorderSizePixel=0; b.Parent=tb
        corner(b,6); stroke(b,T.Border,1,0.3)
        b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=hcol, TextColor3=T.TextPrimary},TI.Fast) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=T.BgElement, TextColor3=T.TextMuted},TI.Fast) end)
        return b
    end
    local closeBtn = ctrlBtn("✕", -14, T.Error)
    local minBtn   = ctrlBtn("─", -48, T.AccentDark)
    local pinBtn   = ctrlBtn("📌",-82, T.AccentFaded)

    -- ── боковая панель ────────────────────────────────────────
    local sb = frm(mf, UDim2.new(0,158,1,-44), UDim2.new(0,0,0,44), T.BgTab, 0)
    pad(sb,8,6,28,6); lst(sb,4)
    frm(mf, UDim2.new(0,1,1,-44), UDim2.new(0,158,0,44), T.Sep, 0)

    -- поиск
    local searchBg = frm(sb, UDim2.new(1,0,0,28), nil, T.BgInput, 0); corner(searchBg,7)
    stroke(searchBg, T.Border, 1, 0.35)
    local searchBox = Instance.new("TextBox")
    searchBox.Size=UDim2.new(1,-22,1,0); searchBox.Position=UDim2.new(0,10,0,0)
    searchBox.BackgroundTransparency=1; searchBox.Text=""
    searchBox.PlaceholderText="🔍 Поиск…"; searchBox.Font=Enum.Font.Gotham
    searchBox.TextSize=10; searchBox.TextColor3=T.TextPrimary
    searchBox.PlaceholderColor3=T.TextMuted; searchBox.ClearTextOnFocus=false
    searchBox.Parent=searchBg
    local searchCnt = lbl(searchBg,"",9,T.TextMuted,Enum.Font.Gotham,Enum.TextXAlignment.Right)
    searchCnt.Size=UDim2.new(0,18,1,0); searchCnt.Position=UDim2.new(1,-20,0,0)

    -- версия внизу боковой панели
    local sbVer = lbl(sb, "void ui v"..VoidUI.Version, 9, T.TextMuted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    sbVer.Size=UDim2.new(1,0,0,14); sbVer.Position=UDim2.new(0,0,1,-20); sbVer.ZIndex=2

    -- контент-область
    local ca = Instance.new("Frame")
    ca.Size=UDim2.new(1,-159,1,-44); ca.Position=UDim2.new(0,159,0,44)
    ca.BackgroundTransparency=1; ca.ClipsDescendants=true; ca.Parent=mf

    -- ── перетаскивание ────────────────────────────────────────
    local dragging, dStart, dAbs = false, nil, nil
    local minimized = false
    tb.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dStart=i.Position; dAbs=mf.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dStart; local cvp=workspace.CurrentCamera.ViewportSize
            local nx=math.clamp(dAbs.X+d.X,0,cvp.X-mf.AbsoluteSize.X)
            local ny=math.clamp(dAbs.Y+d.Y,0,cvp.Y-mf.AbsoluteSize.Y)
            mf.AnchorPoint=Vector2.new(0,0); mf.Position=UDim2.new(0,nx,0,ny)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        sb.Visible = not minimized; ca.Visible = not minimized
        sizeC.MinSize = minimized and Vector2.new(minW,44) or Vector2.new(minW,minH)
        sizeC.MaxSize = minimized and Vector2.new(maxW,44) or Vector2.new(maxW,maxH)
        minBtn.Text = minimized and "□" or "─"
    end)

    local pinned = false
    pinBtn.MouseButton1Click:Connect(function()
        pinned = not pinned
        tw(pinBtn, {BackgroundColor3=pinned and T.AccentFaded or T.BgElement}, TI.Fast)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tw(mf, {BackgroundTransparency=1, Size=UDim2.new(0,mf.AbsoluteSize.X,0,6)}, TI.Mid)
        task.delay(0.28, function() sg:Destroy() end)
    end)

    registerHotkey(tKey, function()
        mf.Visible = not mf.Visible
        if mf.Visible then tw(mf,{BackgroundTransparency=0},TI.Fast) end
    end)

    -- ── Win object ────────────────────────────────────────────
    local Win = {}
    Win._tabs    = {}
    Win._active  = nil
    Win._allElems = {}
    Win._cfgFile = cfgFile
    Win._cfgOn   = cfgOn
    Win._saved   = saved
    Win._sg      = sg
    Win._mf      = mf

    function Win:SaveConfig()
        if self._cfgOn then cfgSave(self._cfgFile, VoidUI.Flags) end
    end

    -- горячая смена темы: ModifyTheme("Midnight") или ModifyTheme({Accent=…})
    function Win:ModifyTheme(v)
        if type(v)=="string" then
            applyTheme(v)
        elseif type(v)=="table" then
            applyThemeTable(v)
        end
        glw.ImageColor3 = T.Accent
        logoL.TextColor3 = T.Accent
        VoidUI:Notify({Title="Тема", Content="Применена", Type="success", Duration=2})
    end

    function Win:SetTheme(v)  self:ModifyTheme(v)       end
    function Win:SetAccent(c) applyAccent(c); glw.ImageColor3=T.Accent; logoL.TextColor3=T.Accent end
    function Win:Notify(o)    VoidUI:Notify(o)           end
    function Win:Destroy()    sg:Destroy()               end

    -- поиск
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower(); local cnt = 0
        for _, info in ipairs(Win._allElems) do
            if q=="" then info.frame.Visible=true
            else
                local f = info.name:lower():find(q,1,true)~=nil
                info.frame.Visible=f; if f then cnt+=1 end
            end
        end
        searchCnt.Text = q~="" and tostring(cnt) or ""
    end)

    -- ════════════════════════════════════════════════════════
    --  CREATE TAB
    -- ════════════════════════════════════════════════════════
    function Win:CreateTab(name, icon, badge)
        local maid = Maid.new()

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size=UDim2.new(1,0,0,36); tabBtn.BackgroundColor3=T.BgTab
        tabBtn.Text=""; tabBtn.BorderSizePixel=0; tabBtn.LayoutOrder=#self._tabs+2
        tabBtn.Parent=sb; corner(tabBtn,7)

        local stripe = frm(tabBtn, UDim2.new(0,3,0,22), UDim2.new(0,0,0.5,-11), T.Accent, 1); corner(stripe,3)
        local iconL  = lbl(tabBtn, icon or "", 14, T.TextMuted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
        iconL.Size=UDim2.new(0,24,1,0); iconL.Position=UDim2.new(0,8,0,0)
        local nL = lbl(tabBtn, name, 11, T.TextMuted, Enum.Font.GothamMedium)
        nL.Size=UDim2.new(1,-46,1,0); nL.Position=UDim2.new(0,icon and 34 or 12,0,0)

        -- бейдж
        local badgeL
        if badge then
            local bF = frm(tabBtn, UDim2.new(0,18,0,14), UDim2.new(1,-22,0.5,-7), T.Accent, 0); corner(bF,7)
            badgeL = lbl(bF, tostring(badge), 9, T.TextPrimary, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            badgeL.Size=UDim2.new(1,0,1,0)
        end

        -- scrolling frame
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size=UDim2.new(1,0,1,0); scroll.BackgroundTransparency=1
        scroll.BorderSizePixel=0; scroll.ScrollBarThickness=4
        scroll.ScrollBarImageColor3=T.ScrollBar; scroll.ScrollBarImageTransparency=0.35
        scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
        scroll.CanvasSize=UDim2.new(0,0,0,0)
        scroll.Visible=false; scroll.Parent=ca

        local sLayout = lst(scroll,5)
        pad(scroll,10,14,10,12)
        bindCanvas(scroll, sLayout)

        maid:Add(scroll.MouseEnter:Connect(function() tw(scroll,{ScrollBarImageTransparency=0},TI.Fast) end))
        maid:Add(scroll.MouseLeave:Connect(function() tw(scroll,{ScrollBarImageTransparency=0.35},TI.Fast) end))
        maid:Add(tabBtn.MouseEnter:Connect(function()
            if self._active~=scroll then tw(tabBtn,{BackgroundColor3=T.BgHover},TI.Fast); tw(nL,{TextColor3=T.TextSub},TI.Fast) end
        end))
        maid:Add(tabBtn.MouseLeave:Connect(function()
            if self._active~=scroll then tw(tabBtn,{BackgroundColor3=T.BgTab},TI.Fast); tw(nL,{TextColor3=T.TextMuted},TI.Fast) end
        end))

        local function activate()
            for _, t in ipairs(self._tabs) do
                t.sc.Visible=false
                tw(t.btn,{BackgroundColor3=T.BgTab},TI.Fast)
                tw(t.nL,{TextColor3=T.TextMuted},TI.Fast)
                tw(t.iL,{TextColor3=T.TextMuted},TI.Fast)
                tw(t.str,{BackgroundTransparency=1},TI.Fast)
            end
            scroll.Visible=true; self._active=scroll
            tw(tabBtn,{BackgroundColor3=T.BgHover},TI.Fast)
            tw(nL,{TextColor3=T.TextAccent},TI.Fast)
            tw(iconL,{TextColor3=T.Accent},TI.Fast)
            tw(stripe,{BackgroundTransparency=0},TI.Fast)
        end

        maid:Add(tabBtn.MouseButton1Click:Connect(function()
            activate(); local x,y=mrel(tabBtn); ripple(tabBtn,x,y)
        end))

        table.insert(self._tabs, {sc=scroll, btn=tabBtn, nL=nL, iL=iconL, str=stripe})
        if #self._tabs==1 then task.defer(activate) end

        -- ── Tab API ───────────────────────────────────────────
        local Tab={}; Tab._lo=0; Tab._maid=maid

        local function lo() Tab._lo+=1; return Tab._lo end

        -- elem helper
        local function elem(h, hasDesc, noHover)
            local bh = hasDesc and (h+20) or h
            local c = frm(scroll, UDim2.new(1,0,0,bh), nil, T.BgElement, 1)
            c.LayoutOrder=lo(); c.AutomaticSize=Enum.AutomaticSize.Y
            corner(c,7); stroke(c,T.Border,1,0.4)
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)
            if not noHover then
                maid:Add(c.MouseEnter:Connect(function() tw(c,{BackgroundColor3=T.BgHover},TI.Fast) end))
                maid:Add(c.MouseLeave:Connect(function() tw(c,{BackgroundColor3=T.BgElement},TI.Fast) end))
            end
            return c
        end

        local function reg(c,n) table.insert(Win._allElems,{frame=c, name=n or ""}) end

        -- ── CreateSection ─────────────────────────────────────
        function Tab:CreateSection(text)
            local sf = frm(scroll, UDim2.new(1,0,0,22), nil, T.Bg, 1); sf.LayoutOrder=lo()
            frm(sf, UDim2.new(0.36,-6,0,1), UDim2.new(0,0,0.5,0), T.Sep, 0)
            frm(sf, UDim2.new(0.36,-6,0,1), UDim2.new(0.64,6,0.5,0), T.Sep, 0)
            local sl = lbl(sf, text:upper(), 9, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            sl.Size=UDim2.new(0.28,0,1,0); sl.Position=UDim2.new(0.36,0,0,0)
            local sv={}; function sv:Set(t) sl.Text=t:upper() end; return sv
        end

        -- ── CreateSeparator ───────────────────────────────────
        function Tab:CreateSeparator()
            local sf=frm(scroll,UDim2.new(1,0,0,1),nil,T.Sep,0); sf.LayoutOrder=lo()
        end

        -- ── CreateDivider ─────────────────────────────────────
        function Tab:CreateDivider(text)
            if text then
                local df=frm(scroll,UDim2.new(1,0,0,18),nil,T.Bg,1); df.LayoutOrder=lo()
                frm(df,UDim2.new(0.38,-6,0,1),UDim2.new(0,0,0.5,0),T.Sep,0)
                frm(df,UDim2.new(0.38,-6,0,1),UDim2.new(0.62,6,0.5,0),T.Sep,0)
                local dl=lbl(df,text,9,T.TextMuted,Enum.Font.Gotham,Enum.TextXAlignment.Center)
                dl.Size=UDim2.new(0.24,0,1,0); dl.Position=UDim2.new(0.38,0,0,0)
            else
                local df=frm(scroll,UDim2.new(1,0,0,1),nil,T.Sep,0); df.LayoutOrder=lo()
            end
        end

        -- ── CreateLabel ───────────────────────────────────────
        function Tab:CreateLabel(text, color, size)
            local lf=frm(scroll,UDim2.new(1,0,0,22),nil,T.Bg,1); lf.LayoutOrder=lo()
            local ll=lbl(lf,text or "",size or 11,color or T.TextMuted,Enum.Font.Gotham,Enum.TextXAlignment.Center)
            ll.Size=UDim2.new(1,0,1,0); ll.TextWrapped=true
            local o={}; function o:Set(t,c2) ll.Text=t; if c2 then ll.TextColor3=c2 end end; return o
        end

        -- ── CreateParagraph (НОВЫЙ) ────────────────────────────
        function Tab:CreateParagraph(opts2)
            local c = frm(scroll, UDim2.new(1,0,0,0), nil, T.BgElement, 1)
            c.LayoutOrder=lo(); c.AutomaticSize=Enum.AutomaticSize.Y
            corner(c,7); stroke(c,T.Border,1,0.4); reg(c, opts2.Title or "")
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)
            pad(c,10,14,10,14)
            local inner=Instance.new("Frame"); inner.BackgroundTransparency=1
            inner.Size=UDim2.new(1,0,1,0); inner.AutomaticSize=Enum.AutomaticSize.Y
            inner.Parent=c; lst(inner,6)

            local tl=lbl(inner, opts2.Title or "", 12, T.TextPrimary, Enum.Font.GothamBold)
            tl.Size=UDim2.new(1,0,0,16); tl.LayoutOrder=1
            local cl=lbl(inner, opts2.Content or "", 11, T.TextSub, Enum.Font.Gotham)
            cl.Size=UDim2.new(1,0,0,0); cl.AutomaticSize=Enum.AutomaticSize.Y
            cl.TextWrapped=true; cl.TextTruncate=Enum.TextTruncate.None; cl.LayoutOrder=2

            local o={}
            function o:Set(t2, c2) tl.Text=t2 or tl.Text; cl.Text=c2 or cl.Text end
            return o
        end

        -- ── CreateAlert ───────────────────────────────────────
        function Tab:CreateAlert(opts2)
            local aType=opts2.Type or "info"
            local ac2={info=T.Info,success=T.Success,warning=T.Warning,error=T.Error}[aType] or T.Info
            local ic2={info="ℹ",success="✓",warning="⚠",error="✕"}
            local c=frm(scroll,UDim2.new(1,0,0,0),nil,T.BgElement,1)
            c.LayoutOrder=lo(); c.AutomaticSize=Enum.AutomaticSize.Y
            corner(c,7); stroke(c,ac2,1,0.3)
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)
            frm(c,UDim2.new(0,3,1,0),nil,ac2,0)
            local icf=frm(c,UDim2.new(0,24,0,24),UDim2.new(0,12,0,12),T.AccentFaded,0); corner(icf,6)
            lbl(icf,ic2[aType] or "·",12,ac2,Enum.Font.GothamBold,Enum.TextXAlignment.Center).Size=UDim2.new(1,0,1,0)
            local tl=lbl(c,opts2.Title or "",12,T.TextPrimary,Enum.Font.GothamBold)
            tl.Size=UDim2.new(1,-52,0,16); tl.Position=UDim2.new(0,44,0,10)
            local cl=lbl(c,opts2.Content or "",10,T.TextSub,Enum.Font.Gotham)
            cl.Size=UDim2.new(1,-52,0,28); cl.Position=UDim2.new(0,44,0,28)
            cl.TextWrapped=true; cl.TextTruncate=Enum.TextTruncate.None
        end

        -- ── CreateToggle ──────────────────────────────────────
        function Tab:CreateToggle(opts2)
            local flag=opts2.Flag; local desc=opts2.Description
            local tVal=(flag and Win._saved[flag]~=nil) and Win._saved[flag] or (opts2.CurrentValue or false)
            local cb=opts2.Callback or function()end
            local c=elem(38, desc); local val=tVal; reg(c,opts2.Name)
            if opts2.Tooltip then attachTooltip(c,opts2.Tooltip) end

            local iBtn=Instance.new("TextButton")
            iBtn.Size=UDim2.new(1,0,1,0); iBtn.BackgroundTransparency=1; iBtn.Text=""; iBtn.Parent=c

            local nl=lbl(c,opts2.Name or "Toggle",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(1,-66,0,18); nl.Position=UDim2.new(0,12,0,desc and 6 or 10)
            if desc then
                local dl=lbl(c,desc,10,T.TextMuted)
                dl.Size=UDim2.new(1,-66,0,14); dl.Position=UDim2.new(0,12,0,26)
            end

            local tbg=frm(c,UDim2.new(0,42,0,23),UDim2.new(1,-56,0.5,-11.5),tVal and T.Accent or T.AccentFaded,0)
            corner(tbg,12); stroke(tbg,T.Border,1,0.25)
            local th=frm(tbg,UDim2.new(0,17,0,17),tVal and UDim2.new(1,-20,0.5,-8.5) or UDim2.new(0,3,0.5,-8.5),T.TextPrimary,0)
            corner(th,9)
            frm(th,UDim2.new(0,6,0,6),UDim2.new(0,2,0,2),Color3.new(1,1,1),0.55); -- шайна

            local function set(v, silent)
                val=v
                tw(tbg,{BackgroundColor3=v and T.Accent or T.AccentFaded},TI.Fast)
                tw(th,{Position=v and UDim2.new(1,-20,0.5,-8.5) or UDim2.new(0,3,0.5,-8.5)},TI.Fast)
                tw(nl,{TextColor3=v and T.TextPrimary or T.TextSub},TI.Fast)
                if not silent then cb(v); if flag then VoidUI.Flags[flag]=v; Win:SaveConfig() end end
            end
            set(tVal,true)

            maid:Add(iBtn.MouseButton1Click:Connect(function()
                set(not val); local x,y=mrel(c); ripple(c,x,y)
            end))
            maid:Add(iBtn.MouseButton2Click:Connect(function()
                local mp=UserInputService:GetMouseLocation()
                showCtx({
                    {icon="✓",label="Включить", cb=function()set(true)end},
                    {icon="✕",label="Выключить",cb=function()set(false)end},
                    {icon="↺",label="Сбросить", cb=function()set(opts2.CurrentValue or false)end},
                },mp.X,mp.Y)
            end))

            local o={}
            function o:Set(v) set(v,false) end
            function o:Get() return val end
            function o:Toggle() set(not val,false) end
            return o
        end

        -- ── CreateSlider ──────────────────────────────────────
        function Tab:CreateSlider(opts2)
            local flag=opts2.Flag; local range=opts2.Range or {0,100}
            local inc=opts2.Increment or 1; local suf=opts2.Suffix or ""
            local def=(flag and Win._saved[flag]) or opts2.CurrentValue or range[1]
            local cb=opts2.Callback or function()end
            local c=elem(56); local val=math.clamp(def,range[1],range[2]); reg(c,opts2.Name)
            if opts2.Tooltip then attachTooltip(c,opts2.Tooltip) end

            local nl=lbl(c,opts2.Name or "Slider",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(1,-76,0,16); nl.Position=UDim2.new(0,12,0,8)
            local vl=lbl(c,tostring(val)..suf,13,T.TextAccent,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            vl.Size=UDim2.new(0,62,0,16); vl.Position=UDim2.new(1,-74,0,8)

            local track=frm(c,UDim2.new(1,-24,0,6),UDim2.new(0,12,0,38),T.Border,0); corner(track,6)
            local fill=frm(track,UDim2.new(0,0,1,0),nil,T.Accent,0); corner(fill,6)
            grad(fill,{T.AccentLight,T.Accent},0)
            local thumb=frm(track,UDim2.new(0,18,0,18),UDim2.new(0,-9,0.5,-9),T.AccentLight,0)
            corner(thumb,9); stroke(thumb,T.Accent,2,0); thumb.ZIndex=4

            -- всплывающий тултип слайдера
            local stt=frm(thumb,UDim2.new(0,48,0,20),UDim2.new(0.5,-24,0,-28),T.BgLight,0)
            corner(stt,5); stroke(stt,T.Border,1,0); stt.Visible=false
            local sttL=lbl(stt,"",10,T.TextAccent,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            sttL.Size=UDim2.new(1,0,1,0)

            local function upd(v)
                v=math.clamp(math.round(v/inc)*inc,range[1],range[2]); val=v
                local p=(v-range[1])/(range[2]-range[1])
                tw(fill,{Size=UDim2.new(p,0,1,0)},TI.Fast)
                tw(thumb,{Position=UDim2.new(p,-9,0.5,-9)},TI.Fast)
                vl.Text=tostring(v)..suf; sttL.Text=tostring(v)..suf
                cb(v); if flag then VoidUI.Flags[flag]=v; Win:SaveConfig() end
            end
            local p0=(val-range[1])/(range[2]-range[1])
            fill.Size=UDim2.new(p0,0,1,0); thumb.Position=UDim2.new(p0,-9,0.5,-9)

            local ds=false
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

            local o={}; function o:Set(v) upd(v) end; function o:Get() return val end; return o
        end

        -- ── CreateButton ──────────────────────────────────────
        function Tab:CreateButton(opts2)
            local desc=opts2.Description
            local cb=opts2.Callback or function()end
            local c=elem(36,desc); c.ClipsDescendants=true; reg(c,opts2.Name)
            if opts2.Tooltip then attachTooltip(c,opts2.Tooltip) end

            local nl=lbl(c,opts2.Name or "Button",12,T.TextPrimary,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
            nl.Size=UDim2.new(1,-32,0,18); nl.Position=UDim2.new(0,12,0,desc and 6 or 9)
            if desc then
                local dl=lbl(c,desc,10,T.TextMuted,Enum.Font.Gotham,Enum.TextXAlignment.Center)
                dl.Size=UDim2.new(1,-32,0,14); dl.Position=UDim2.new(0,12,0,26)
            end
            local arr=lbl(c,opts2.Icon or "›",16,T.TextMuted,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            arr.Size=UDim2.new(0,18,1,0); arr.Position=UDim2.new(1,-24,0,0)
            local stripe=frm(c,UDim2.new(0,2,0,18),UDim2.new(0,0,0.5,-9),T.Accent,1); corner(stripe,2)

            local btn=Instance.new("TextButton")
            btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=c
            maid:Add(btn.MouseEnter:Connect(function()
                tw(nl,{TextColor3=T.TextAccent},TI.Fast); tw(arr,{TextColor3=T.Accent},TI.Fast)
                tw(stripe,{BackgroundTransparency=0},TI.Fast)
            end))
            maid:Add(btn.MouseLeave:Connect(function()
                tw(nl,{TextColor3=T.TextPrimary},TI.Fast); tw(arr,{TextColor3=T.TextMuted},TI.Fast)
                tw(stripe,{BackgroundTransparency=1},TI.Fast)
            end))
            maid:Add(btn.MouseButton1Down:Connect(function() tw(c,{BackgroundColor3=T.AccentFaded},TI.Fast) end))
            maid:Add(btn.MouseButton1Click:Connect(function()
                tw(c,{BackgroundColor3=T.BgHover},TI.Fast)
                local x,y=mrel(c); ripple(c,x,y); pcall(cb)
            end))
        end

        -- ── CreateDropdown ────────────────────────────────────
        function Tab:CreateDropdown(opts2)
            local flag=opts2.Flag; local multi=opts2.MultipleOptions or false
            local dOpts=opts2.Options or {}
            local def=(flag and Win._saved[flag]) or opts2.CurrentOption
            local cb=opts2.Callback or function()end
            local val=def; local sel={}; local open=false

            local c=elem(36); c.ClipsDescendants=false; c.ZIndex=5; reg(c,opts2.Name)

            local nl=lbl(c,opts2.Name or "Dropdown",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(0.5,0,0,18); nl.Position=UDim2.new(0,12,0.5,-9)
            local vl=lbl(c,type(val)=="table" and (#val.." выбрано") or (val or "Выбрать…"),11,T.TextAccent,Enum.Font.Gotham,Enum.TextXAlignment.Right)
            vl.Size=UDim2.new(0.42,-8,0,18); vl.Position=UDim2.new(0.5,0,0.5,-9)
            local al=lbl(c,"▾",13,T.TextMuted,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            al.Size=UDim2.new(0,18,0,18); al.Position=UDim2.new(1,-26,0.5,-9)

            local dd=frm(c,UDim2.new(1,0,0,0),UDim2.new(0,0,1,5),T.BgLight,0)
            dd.ClipsDescendants=true; dd.ZIndex=10; dd.Visible=false
            corner(dd,7); stroke(dd,T.Border,1,0); lst(dd,2); pad(dd,4,4,4,4)

            local function refreshVl()
                if multi then
                    local s={}; for o,v2 in pairs(sel) do if v2 then s[#s+1]=o end end
                    vl.Text=#s>0 and (#s.." выбрано") or "Ничего"
                else vl.Text=val or "Выбрать…" end
            end

            local function buildOptions(list)
                for _, ch in ipairs(dd:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for _, opt in ipairs(list) do
                    local ob=Instance.new("TextButton")
                    ob.Size=UDim2.new(1,0,0,28); ob.BackgroundColor3=T.BgLight
                    ob.Text=""; ob.BorderSizePixel=0; ob.Parent=dd; corner(ob,5)
                    local ol=lbl(ob,opt,11,opt==val and T.TextAccent or T.TextSub)
                    ol.Size=UDim2.new(1,-16,1,0); ol.Position=UDim2.new(0,8,0,0)
                    ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=T.BgHover},TI.Fast); tw(ol,{TextColor3=T.TextPrimary},TI.Fast) end)
                    ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=T.BgLight},TI.Fast); tw(ol,{TextColor3=opt==val and T.TextAccent or T.TextSub},TI.Fast) end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            sel[opt]=not sel[opt]
                            tw(ol,{TextColor3=sel[opt] and T.TextAccent or T.TextSub},TI.Fast)
                            local r={}; for o2,v2 in pairs(sel) do if v2 then r[#r+1]=o2 end end
                            val=r; refreshVl(); cb(r)
                        else
                            val=opt; refreshVl()
                            for _,ch in ipairs(dd:GetChildren()) do
                                if ch:IsA("TextButton") then
                                    local cll=ch:FindFirstChildOfClass("TextLabel")
                                    if cll then tw(cll,{TextColor3=T.TextSub},TI.Fast) end
                                end
                            end
                            tw(ol,{TextColor3=T.TextAccent},TI.Fast)
                            open=false
                            tw(dd,{Size=UDim2.new(1,0,0,0)},TI.Fast)
                            tw(al,{Rotation=0},TI.Fast)
                            task.delay(0.15,function() dd.Visible=false end)
                            cb(opt); if flag then VoidUI.Flags[flag]=opt; Win:SaveConfig() end
                        end
                    end)
                end
            end
            buildOptions(dOpts)

            local mb=Instance.new("TextButton")
            mb.Size=UDim2.new(1,0,1,0); mb.BackgroundTransparency=1; mb.Text=""; mb.Parent=c
            maid:Add(mb.MouseButton1Click:Connect(function()
                open=not open
                local th2=open and math.min(#dOpts*32+8,200) or 0
                dd.Visible=true
                tw(dd,{Size=UDim2.new(1,0,0,th2)},TI.Fast)
                tw(al,{Rotation=open and 180 or 0},TI.Fast)
                if not open then task.delay(0.16,function() dd.Visible=false end) end
            end))

            local o={}
            function o:Set(v) val=v; refreshVl(); cb(v) end
            function o:Get() return val end
            function o:Refresh(newList) dOpts=newList; buildOptions(newList) end
            function o:AddOption(v2) table.insert(dOpts,v2); buildOptions(dOpts) end
            return o
        end

        -- ── CreateInput ───────────────────────────────────────
        function Tab:CreateInput(opts2)
            local flag=opts2.Flag; local cb=opts2.Callback or function()end
            local live=opts2.LiveUpdate or false; local num=opts2.NumberOnly or false
            local c=elem(52); reg(c,opts2.Name)

            local nl=lbl(c,opts2.Name or "Input",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(1,-24,0,16); nl.Position=UDim2.new(0,12,0,6)
            local ibg=frm(c,UDim2.new(1,-24,0,24),UDim2.new(0,12,0,26),T.BgInput,0)
            corner(ibg,5); local ibs=stroke(ibg,T.Border,1,0.25)
            local ib=Instance.new("TextBox")
            ib.Size=UDim2.new(1,-12,1,0); ib.Position=UDim2.new(0,6,0,0)
            ib.BackgroundTransparency=1; ib.Text=opts2.CurrentValue or ""
            ib.PlaceholderText=opts2.Placeholder or opts2.PlaceholderText or "Введите…"
            ib.Font=Enum.Font.Gotham; ib.TextSize=11
            ib.TextColor3=T.TextPrimary; ib.PlaceholderColor3=T.TextMuted
            ib.ClearTextOnFocus=false; ib.Parent=ibg

            maid:Add(ib.Focused:Connect(function()
                tw(ibg,{BackgroundColor3=T.BgLight},TI.Fast); ibs.Color=T.Accent; ibs.Transparency=0
            end))
            maid:Add(ib.FocusLost:Connect(function(enter)
                tw(ibg,{BackgroundColor3=T.BgInput},TI.Fast); ibs.Color=T.Border; ibs.Transparency=0.25
                if enter then
                    local v2=num and tonumber(ib.Text) or ib.Text
                    cb(v2); if flag then VoidUI.Flags[flag]=v2; Win:SaveConfig() end
                end
                if opts2.RemoveTextAfterFocusLost then ib.Text="" end
            end))
            if live then
                maid:Add(ib:GetPropertyChangedSignal("Text"):Connect(function()
                    cb(num and tonumber(ib.Text) or ib.Text)
                end))
            end

            local o={}
            function o:Set(v2) ib.Text=tostring(v2) end
            function o:Get() return ib.Text end
            function o:Clear() ib.Text="" end
            return o
        end

        -- ── CreateKeybind ─────────────────────────────────────
        function Tab:CreateKeybind(opts2)
            local flag=opts2.Flag; local cb=opts2.Callback or function()end
            local hold=opts2.HoldToInteract or false
            local callOnChange=opts2.CallOnChange or false
            local val=opts2.CurrentKey or Enum.KeyCode.Unknown
            local binding=false; local held=false
            local c=elem(36); reg(c,opts2.Name)

            local nl=lbl(c,opts2.Name or "Keybind",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(1,-104,0,16); nl.Position=UDim2.new(0,12,0.5,-8)
            local kbg=frm(c,UDim2.new(0,84,0,22),UDim2.new(1,-96,0.5,-11),T.BgInput,0)
            corner(kbg,6); stroke(kbg,T.Border,1,0.25)
            local kl=lbl(kbg,typeof(val)=="EnumItem" and val.Name or tostring(val),11,T.TextAccent,Enum.Font.Code,Enum.TextXAlignment.Center)
            kl.Size=UDim2.new(1,0,1,0)

            local btn=Instance.new("TextButton")
            btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=c
            maid:Add(btn.MouseButton1Click:Connect(function()
                binding=true; kl.Text="…"; kl.TextColor3=T.TextSub
                tw(kbg,{BackgroundColor3=T.AccentFaded},TI.Fast)
            end))
            maid:Add(UserInputService.InputBegan:Connect(function(i,gpe)
                if binding and i.UserInputType==Enum.UserInputType.Keyboard then
                    binding=false; val=i.KeyCode; kl.Text=i.KeyCode.Name; kl.TextColor3=T.TextAccent
                    tw(kbg,{BackgroundColor3=T.BgInput},TI.Fast)
                    if flag then VoidUI.Flags[flag]=i.KeyCode.Name; Win:SaveConfig() end
                    if callOnChange then cb(i.KeyCode) end; return
                end
                if not gpe and not binding and typeof(val)=="EnumItem" and i.KeyCode==val then
                    if hold then held=true
                    else cb(val) end
                end
            end))
            maid:Add(UserInputService.InputEnded:Connect(function(i)
                if typeof(val)=="EnumItem" and i.KeyCode==val and hold and held then
                    held=false; cb(val)
                end
            end))

            local o={}
            function o:Get() return val end
            function o:Set(k)
                if typeof(k)=="EnumItem" then val=k; kl.Text=k.Name
                elseif type(k)=="string" then
                    pcall(function() val=Enum.KeyCode[k]; kl.Text=k end)
                end
            end
            return o
        end

        -- ── CreateColorPicker (с Hex + RGB) ───────────────────
        function Tab:CreateColorPicker(opts2)
            local flag=opts2.Flag
            local def=opts2.Default or opts2.Color or Color3.fromRGB(138,58,255)
            local cb=opts2.Callback or function()end
            local val=def; local open=false
            local hue,sat,bri=Color3.toHSV(def)

            local c=elem(36); c.ClipsDescendants=false; reg(c,opts2.Name)
            local nl=lbl(c,opts2.Name or "Цвет",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(1,-76,0,18); nl.Position=UDim2.new(0,12,0.5,-9)
            local prev=frm(c,UDim2.new(0,34,0,22),UDim2.new(1,-54,0.5,-11),val,0)
            corner(prev,6); stroke(prev,T.Border,1,0)
            local al=lbl(c,"▾",13,T.TextMuted,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            al.Size=UDim2.new(0,16,0,18); al.Position=UDim2.new(1,-22,0.5,-9)

            -- панель пикера
            local pk=frm(c,UDim2.new(1,0,0,0),UDim2.new(0,0,1,5),T.BgLight,0)
            pk.ClipsDescendants=true; pk.ZIndex=8; pk.Visible=false
            corner(pk,7); stroke(pk,T.Border,1,0); pad(pk,8,8,8,8); lst(pk,6)

            local function applyCol()
                val=Color3.fromHSV(hue,sat,bri); prev.BackgroundColor3=val; cb(val)
                if flag then VoidUI.Flags[flag]={val.R,val.G,val.B}; Win:SaveConfig() end
            end

            -- hue bar
            local hBar=frm(pk,UDim2.new(1,0,0,14),nil,T.Bg,0); corner(hBar,4); hBar.LayoutOrder=1
            grad(hBar,{Color3.fromHSV(0,1,1),Color3.fromHSV(0.17,1,1),Color3.fromHSV(0.33,1,1),
                Color3.fromHSV(0.5,1,1),Color3.fromHSV(0.67,1,1),Color3.fromHSV(0.83,1,1),Color3.fromHSV(1,1,1)},0)
            local hTh=frm(hBar,UDim2.new(0,4,1,4),UDim2.new(hue,-2,0,-2),T.TextPrimary,0); corner(hTh,2); stroke(hTh,T.Bg,1,0)

            -- sv field
            local svB=frm(pk,UDim2.new(1,0,0,80),nil,Color3.fromHSV(hue,1,1),0); corner(svB,4); svB.LayoutOrder=2
            local svW=Instance.new("UIGradient")
            svW.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,1,1))})
            svW.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); svW.Parent=svB
            local svHf=frm(svB,UDim2.new(1,0,1,0),nil,Color3.new(0,0,0),0)
            local svHg=Instance.new("UIGradient"); svHg.Rotation=90
            svHg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
            svHg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); svHg.Parent=svHf
            local svTh=frm(svB,UDim2.new(0,12,0,12),UDim2.new(sat,-6,1-bri,-6),T.TextPrimary,0)
            corner(svTh,6); stroke(svTh,T.Bg,1.5,0); svTh.ZIndex=3

            -- hex input
            local hexRow=frm(pk,UDim2.new(1,0,0,26),nil,T.Bg,1); hexRow.LayoutOrder=3
            local hexBg=frm(hexRow,UDim2.new(1,0,1,0),nil,T.BgInput,0); corner(hexBg,5); stroke(hexBg,T.Border,1,0.3)
            local hexPfx=lbl(hexBg,"#",10,T.TextMuted,Enum.Font.Code); hexPfx.Size=UDim2.new(0,12,1,0); hexPfx.Position=UDim2.new(0,6,0,0)
            local hexBox=Instance.new("TextBox")
            hexBox.Size=UDim2.new(1,-18,1,0); hexBox.Position=UDim2.new(0,18,0,0)
            hexBox.BackgroundTransparency=1; hexBox.Font=Enum.Font.Code; hexBox.TextSize=11
            hexBox.TextColor3=T.TextPrimary; hexBox.PlaceholderColor3=T.TextMuted
            hexBox.ClearTextOnFocus=false; hexBox.Parent=hexBg

            local function hexToColor(h)
                local hex=h:gsub("#","")
                if #hex~=6 then return nil end
                local r,g,b=hex:sub(1,2),hex:sub(3,4),hex:sub(5,6)
                local ok,col=pcall(Color3.fromRGB,tonumber(r,16),tonumber(g,16),tonumber(b,16))
                return ok and col or nil
            end
            local function updateHex()
                hexBox.Text=string.format("%02X%02X%02X",
                    math.round(val.R*255),math.round(val.G*255),math.round(val.B*255))
            end
            updateHex()
            hexBox.FocusLost:Connect(function()
                local col=hexToColor(hexBox.Text)
                if col then hue,sat,bri=col:ToHSV(); applyCol()
                    svB.BackgroundColor3=Color3.fromHSV(hue,1,1)
                    svW.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,1,1))})
                    tw(hTh,{Position=UDim2.new(hue,-2,0,-2)},TI.Fast)
                    tw(svTh,{Position=UDim2.new(sat,-6,1-bri,-6)},TI.Fast)
                else updateHex() end
            end)

            -- drag logic
            local dH,dSV=false,false
            local function hDrag(i)
                hue=math.clamp((i.Position.X-hBar.AbsolutePosition.X)/hBar.AbsoluteSize.X,0,1)
                tw(hTh,{Position=UDim2.new(hue,-2,0,-2)},TI.Fast)
                svB.BackgroundColor3=Color3.fromHSV(hue,1,1)
                svW.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,1,1))})
                applyCol(); updateHex()
            end
            local function svDrag(i)
                sat=math.clamp((i.Position.X-svB.AbsolutePosition.X)/svB.AbsoluteSize.X,0,1)
                bri=1-math.clamp((i.Position.Y-svB.AbsolutePosition.Y)/svB.AbsoluteSize.Y,0,1)
                tw(svTh,{Position=UDim2.new(sat,-6,1-bri,-6)},TI.Fast); applyCol(); updateHex()
            end
            maid:Add(hBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=true; hDrag(i) end end))
            maid:Add(svB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dSV=true; svDrag(i) end end))
            maid:Add(UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=false; dSV=false end end))
            maid:Add(UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseMovement then
                    if dH then hDrag(i) elseif dSV then svDrag(i) end
                end
            end))

            local mb=Instance.new("TextButton")
            mb.Size=UDim2.new(1,0,1,0); mb.BackgroundTransparency=1; mb.Text=""; mb.Parent=c
            maid:Add(mb.MouseButton1Click:Connect(function()
                open=not open; pk.Visible=true
                tw(pk,{Size=UDim2.new(1,0,0,open and 138 or 0)},TI.Fast)
                tw(al,{Rotation=open and 180 or 0},TI.Fast)
                if not open then task.delay(0.16,function() pk.Visible=false end) end
            end))

            local o={}
            function o:Set(col)
                val=col; prev.BackgroundColor3=col; hue,sat,bri=col:ToHSV()
                svB.BackgroundColor3=Color3.fromHSV(hue,1,1)
                tw(hTh,{Position=UDim2.new(hue,-2,0,-2)},TI.Fast)
                tw(svTh,{Position=UDim2.new(sat,-6,1-bri,-6)},TI.Fast)
                updateHex()
            end
            function o:Get() return val end
            return o
        end

        -- ── CreateProgressBar ─────────────────────────────────
        function Tab:CreateProgressBar(opts2)
            local pMin=opts2.Min or 0; local pMax=opts2.Max or 100
            local pSuf=opts2.Suffix or ""; local pCol=opts2.Color or T.Accent
            local c=elem(44); reg(c,opts2.Name)
            local nl=lbl(c,opts2.Name or "Progress",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(1,-74,0,16); nl.Position=UDim2.new(0,12,0,6)
            local vl=lbl(c,tostring(opts2.Value or 0)..pSuf,11,T.TextAccent,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            vl.Size=UDim2.new(0,60,0,16); vl.Position=UDim2.new(1,-72,0,6)
            local track=frm(c,UDim2.new(1,-24,0,7),UDim2.new(0,12,0,30),T.Border,0); corner(track,6)
            local fill=frm(track,UDim2.new(0,0,1,0),nil,pCol,0); corner(fill,6)
            fill.Size=UDim2.new(math.clamp(((opts2.Value or 0)-pMin)/(pMax-pMin),0,1),0,1,0)
            local o={}
            function o:Set(v)
                v=math.clamp(v,pMin,pMax)
                tw(fill,{Size=UDim2.new((v-pMin)/(pMax-pMin),0,1,0)},TI.Mid)
                vl.Text=tostring(math.round(v))..pSuf
            end
            function o:SetColor(col) fill.BackgroundColor3=col end
            return o
        end

        -- ── CreateTable (НОВЫЙ) ───────────────────────────────
        --  opts2 = { Name, Headers={…}, Rows={{…},{…}}, RowHeight=24 }
        function Tab:CreateTable(opts2)
            local headers=opts2.Headers or {}
            local rows=opts2.Rows or {}
            local rh=opts2.RowHeight or 24
            local totalH=rh*(#rows+1)+10

            local c=frm(scroll,UDim2.new(1,0,0,totalH),nil,T.BgElement,1)
            c.LayoutOrder=lo(); c.AutomaticSize=Enum.AutomaticSize.Y
            corner(c,7); stroke(c,T.Border,1,0.4); reg(c,opts2.Name or "")
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)

            -- заголовки
            local hRow=frm(c,UDim2.new(1,0,0,rh),nil,T.BgHover,0)
            local colW=1/#headers
            for i,h in ipairs(headers) do
                local hl=lbl(hRow,h,10,T.TextAccent,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
                hl.Size=UDim2.new(colW,0,1,0); hl.Position=UDim2.new(colW*(i-1),0,0,0)
            end
            -- разделитель
            frm(c,UDim2.new(1,-16,0,1),UDim2.new(0,8,0,rh),T.Sep,0)

            for ri,row in ipairs(rows) do
                local rRow=frm(c,UDim2.new(1,0,0,rh),UDim2.new(0,0,0,rh+1+(ri-1)*rh),ri%2==0 and T.BgLight or T.Bg,0)
                for ci,cell in ipairs(row) do
                    local cl=lbl(rRow,tostring(cell),10,T.TextSub,Enum.Font.Gotham,Enum.TextXAlignment.Center)
                    cl.Size=UDim2.new(colW,0,1,0); cl.Position=UDim2.new(colW*(ci-1),0,0,0)
                end
            end

            local o={}
            function o:SetRow(ri,data)
                local rRow=c:GetChildren()[ri+2] -- +1 header +1 sep
                if rRow then
                    local cells=rRow:GetChildren()
                    for ci,v2 in ipairs(data) do if cells[ci] then cells[ci].Text=tostring(v2) end end
                end
            end
            return o
        end

        -- ── CreateChart (НОВЫЙ) ───────────────────────────────
        --  opts2 = { Name, Values={…}, Max, Color, Labels={…} }
        function Tab:CreateChart(opts2)
            local vals=opts2.Values or {}; local maxV=opts2.Max or 100
            local col=opts2.Color or T.Accent; local lbls=opts2.Labels or {}
            local h=80

            local c=frm(scroll,UDim2.new(1,0,0,h+28),nil,T.BgElement,1)
            c.LayoutOrder=lo(); corner(c,7); stroke(c,T.Border,1,0.4); reg(c,opts2.Name or "")
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)

            if opts2.Name then
                local nl=lbl(c,opts2.Name,11,T.TextPrimary,Enum.Font.GothamMedium)
                nl.Size=UDim2.new(1,-24,0,16); nl.Position=UDim2.new(0,12,0,6)
            end

            local chartArea=frm(c,UDim2.new(1,-24,0,h),UDim2.new(0,12,0,22),T.BgInput,0); corner(chartArea,5)
            local bw=math.max(4, math.floor((chartArea.AbsoluteSize.X-8)/(#vals>0 and #vals or 1))-2)

            for i,v in ipairs(vals) do
                local pct=math.clamp(v/maxV,0,1)
                local bh=math.max(2,math.round(pct*(h-8)))
                local bar=frm(chartArea,UDim2.new(0,bw,0,bh),UDim2.new(0,4+(i-1)*(bw+2),1,-bh-4),col,0)
                corner(bar,3)
                if i<=#vals/2 then grad(bar,{T.AccentLight,col},90) end
                if lbls[i] then
                    local ll=lbl(chartArea,tostring(lbls[i]),8,T.TextMuted,Enum.Font.Code,Enum.TextXAlignment.Center)
                    ll.Size=UDim2.new(0,bw+4,0,10); ll.Position=UDim2.new(0,4+(i-1)*(bw+2)-2,1,-2)
                end
            end

            return {}
        end

        -- ── CreateTextDisplay ─────────────────────────────────
        function Tab:CreateTextDisplay(opts2)
            local c=elem(36); reg(c,opts2.Name or "")
            local nl=lbl(c,opts2.Name or "",11,T.TextMuted,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(0.5,0,0,16); nl.Position=UDim2.new(0,12,0.5,-8)
            local vl=lbl(c,opts2.Text or "",opts2.Size or 11,T.TextAccent,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            vl.Size=UDim2.new(0.46,0,0,16); vl.Position=UDim2.new(0.5,0,0.5,-8)
            local o={}
            function o:Set(v) vl.Text=tostring(v) end
            function o:SetColor(col) vl.TextColor3=col end
            function o:Get() return vl.Text end
            return o
        end

        -- ── CreateMultiToggle ─────────────────────────────────
        function Tab:CreateMultiToggle(opts2)
            local options=opts2.Options or {}; local defaults=opts2.Defaults or {}
            local cb=opts2.Callback or function()end; local state={}
            for _,o in ipairs(options) do state[o]=defaults[o] or false end

            local c=frm(scroll,UDim2.new(1,0,0,0),nil,T.BgElement,1)
            c.LayoutOrder=lo(); c.AutomaticSize=Enum.AutomaticSize.Y
            corner(c,7); stroke(c,T.Border,1,0.4); reg(c,opts2.Name or "")
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)
            local nl=lbl(c,opts2.Name or "MultiToggle",12,T.TextPrimary,Enum.Font.GothamBold)
            nl.Size=UDim2.new(1,-24,0,18); nl.Position=UDim2.new(0,12,0,8)

            for i,opt in ipairs(options) do
                local row=frm(c,UDim2.new(1,-24,0,26),UDim2.new(0,12,0,28+(i-1)*30),T.Bg,0); corner(row,5)
                local rl=lbl(row,opt,11,T.TextSub,Enum.Font.Gotham)
                rl.Size=UDim2.new(1,-42,1,0); rl.Position=UDim2.new(0,10,0,0)
                local tbg2=frm(row,UDim2.new(0,34,0,18),UDim2.new(1,-40,0.5,-9),state[opt] and T.Accent or T.AccentFaded,0); corner(tbg2,9)
                local th2=frm(tbg2,UDim2.new(0,14,0,14),state[opt] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),T.TextPrimary,0); corner(th2,7)
                local rb=Instance.new("TextButton"); rb.Size=UDim2.new(1,0,1,0); rb.BackgroundTransparency=1; rb.Text=""; rb.Parent=row
                maid:Add(rb.MouseButton1Click:Connect(function()
                    state[opt]=not state[opt]
                    tw(tbg2,{BackgroundColor3=state[opt] and T.Accent or T.AccentFaded},TI.Fast)
                    tw(th2,{Position=state[opt] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},TI.Fast)
                    tw(rl,{TextColor3=state[opt] and T.TextPrimary or T.TextSub},TI.Fast)
                    cb(state)
                end))
            end
            local o={}; function o:Get() return state end; function o:Set(k,v) state[k]=v end; return o
        end

        -- ── CreateRadio ───────────────────────────────────────
        function Tab:CreateRadio(opts2)
            local options=opts2.Options or {}; local def=opts2.Default or options[1]
            local cb=opts2.Callback or function()end; local selected=def

            local c=frm(scroll,UDim2.new(1,0,0,0),nil,T.BgElement,1)
            c.LayoutOrder=lo(); c.AutomaticSize=Enum.AutomaticSize.Y
            corner(c,7); stroke(c,T.Border,1,0.4); reg(c,opts2.Name or "")
            task.defer(function() tw(c,{BackgroundTransparency=0},TI.Mid) end)
            local nl=lbl(c,opts2.Name or "Radio",12,T.TextPrimary,Enum.Font.GothamBold)
            nl.Size=UDim2.new(1,-24,0,18); nl.Position=UDim2.new(0,12,0,7)

            local dots={}
            local function selectOpt(opt)
                selected=opt
                for o2,parts in pairs(dots) do
                    local active=o2==opt
                    tw(parts.outer,{BackgroundColor3=active and T.Accent or T.AccentFaded},TI.Fast)
                    tw(parts.inner,{BackgroundTransparency=active and 0 or 1},TI.Fast)
                    tw(parts.lbl,{TextColor3=active and T.TextPrimary or T.TextSub},TI.Fast)
                end
                cb(opt)
            end

            for i,opt in ipairs(options) do
                local row=frm(c,UDim2.new(1,-24,0,24),UDim2.new(0,12,0,28+(i-1)*28),T.Bg,0); corner(row,5)
                local outer=frm(row,UDim2.new(0,16,0,16),UDim2.new(0,8,0.5,-8),opt==def and T.Accent or T.AccentFaded,0); corner(outer,99)
                stroke(outer,T.Border,1,0.25)
                local inner=frm(outer,UDim2.new(0,8,0,8),UDim2.new(0.5,-4,0.5,-4),T.TextPrimary,opt==def and 0 or 1); corner(inner,99)
                local rl=lbl(row,opt,11,opt==def and T.TextPrimary or T.TextSub,Enum.Font.Gotham)
                rl.Size=UDim2.new(1,-36,1,0); rl.Position=UDim2.new(0,32,0,0)
                dots[opt]={outer=outer,inner=inner,lbl=rl}
                local rb=Instance.new("TextButton"); rb.Size=UDim2.new(1,0,1,0); rb.BackgroundTransparency=1; rb.Text=""; rb.Parent=row
                maid:Add(rb.MouseButton1Click:Connect(function() selectOpt(opt) end))
            end
            local o={}; function o:Get() return selected end; function o:Set(v) selectOpt(v) end; return o
        end

        -- ── CreateStepper ─────────────────────────────────────
        function Tab:CreateStepper(opts2)
            local sMin=opts2.Min or 0; local sMax=opts2.Max or 10
            local sStep=opts2.Step or 1; local sSuf=opts2.Suffix or ""
            local val=math.clamp(opts2.Default or sMin,sMin,sMax)
            local cb=opts2.Callback or function()end
            local c=elem(36); reg(c,opts2.Name or "")
            local nl=lbl(c,opts2.Name or "Stepper",12,T.TextPrimary,Enum.Font.GothamMedium)
            nl.Size=UDim2.new(0.45,0,0,16); nl.Position=UDim2.new(0,12,0.5,-8)
            local cf=frm(c,UDim2.new(0,90,0,26),UDim2.new(1,-102,0.5,-13),T.Bg,0)
            corner(cf,7); stroke(cf,T.Border,1,0.3)
            local mb=Instance.new("TextButton"); mb.Size=UDim2.new(0,26,1,0); mb.BackgroundTransparency=1
            mb.Text="−"; mb.Font=Enum.Font.GothamBold; mb.TextSize=14; mb.TextColor3=T.TextSub; mb.BorderSizePixel=0; mb.Parent=cf
            local vl=lbl(cf,tostring(val)..sSuf,11,T.TextAccent,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            vl.Size=UDim2.new(1,-52,1,0); vl.Position=UDim2.new(0,26,0,0)
            local pb=Instance.new("TextButton"); pb.Size=UDim2.new(0,26,1,0); pb.Position=UDim2.new(1,-26,0,0)
            pb.BackgroundTransparency=1; pb.Text="+"; pb.Font=Enum.Font.GothamBold; pb.TextSize=14; pb.TextColor3=T.TextSub; pb.BorderSizePixel=0; pb.Parent=cf
            local function upd(v) val=math.clamp(v,sMin,sMax); vl.Text=tostring(val)..sSuf; cb(val) end
            maid:Add(mb.MouseButton1Click:Connect(function() upd(val-sStep) end))
            maid:Add(pb.MouseButton1Click:Connect(function() upd(val+sStep) end))
            local o={}; function o:Get() return val end; function o:Set(v) upd(v) end; return o
        end

        -- ── Tab:SetBadge ──────────────────────────────────────
        function Tab:SetBadge(text)
            if badgeL then badgeL.Text=tostring(text) end
        end

        -- ── Tab:Destroy ───────────────────────────────────────
        function Tab:Destroy()
            maid:Clean()
            if scroll and scroll.Parent then scroll:Destroy() end
            if tabBtn and tabBtn.Parent then tabBtn:Destroy() end
        end

        return Tab
    end

    -- ════════════════════════════════════════════════════════
    --  SETTINGS TAB
    -- ════════════════════════════════════════════════════════
    function Win:CreateSettingsTab()
        local st=self:CreateTab("Настройки","⚙")
        st:CreateSection("Тема")
        local thNames={}; for n in pairs(THEMES) do table.insert(thNames,n) end; table.sort(thNames)
        st:CreateRadio({
            Name="Preset тема", Options=thNames, Default=themeName,
            Callback=function(v) self:ModifyTheme(v) end,
        })
        st:CreateSection("Акцент")
        st:CreateColorPicker({
            Name="Цвет акцента", Default=T.Accent,
            Callback=function(col) self:SetAccent(col) end,
        })
        st:CreateSeparator()
        st:CreateSection("Интерфейс")
        st:CreateSlider({
            Name="Прозрачность окна", Range={0,80}, Increment=5, Suffix="%", CurrentValue=0,
            Callback=function(v) tw(mf,{BackgroundTransparency=v/100},TI.Fast) end,
        })
        st:CreateSeparator()
        st:CreateSection("Хоткей")
        st:CreateKeybind({
            Name="Показать / Скрыть", CurrentKey=tKey,
            Callback=function(k) tKey=k end,
        })
        st:CreateSeparator()
        st:CreateSection("Информация")
        st:CreateTextDisplay({Name="Версия", Text="v"..VoidUI.Version})
        st:CreateTextDisplay({Name="Автор", Text=VoidUI.Author})
        st:CreateButton({
            Name="Тест уведомления",
            Callback=function()
                VoidUI:Notify({Title="VoidUI v"..VoidUI.Version, Content="Всё работает!", Type="success", Duration=3})
            end,
        })
        st:CreateButton({
            Name="Сохранить конфиг",
            Callback=function()
                self:SaveConfig()
                VoidUI:Notify({Title="Конфиг", Content="Сохранено успешно", Type="success", Duration=2})
            end,
        })
        return st
    end

    return Win
end

return VoidUI
