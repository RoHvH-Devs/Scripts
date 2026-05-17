-- vizualizer by hvhash8/cazer not ai
-- v3 shit nigga nigga bloxStrike Soon
-- open source
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")


local config = {
    Enabled = true,
    NumberOfBars = 24,
    Radius = 5,
    MaxHeight = 12,
    LerpSpeed = 0.25,
    BaseHeight = 0.5,
    BarWidth = 0.3,
    DupeAmount = 1,      
    DupeSpacing = 1.5    
}


local presets = {
    {Name = "Classic Mode", Bars = 24, Radius = 5, MaxHeight = 12, Lerp = 0.25, Dupe = 1},
    {Name = "Bass Monster", Bars = 48, Radius = 6, MaxHeight = 25, Lerp = 0.4, Dupe = 1},
    {Name = "Neon Wall", Bars = 32, Radius = 7, MaxHeight = 8, Lerp = 0.2, Dupe = 4},
    {Name = "Tiny Ring", Bars = 12, Radius = 3, MaxHeight = 6, Lerp = 0.3, Dupe = 1},
    {Name = "Heavy Waves", Bars = 72, Radius = 9, MaxHeight = 15, Lerp = 0.15, Dupe = 3}
}
local currentPresetIdx = 1

local visualizerFolder = character:FindFirstChild("VisualizerFolder") or Instance.new("Folder")
visualizerFolder.Name = "VisualizerFolder"
visualizerFolder.Parent = character

local bars = {}

local function clearBars()
    for _, b in pairs(bars) do
        if b.Part then b.Part:Destroy() end
    end
    bars = {}
    visualizerFolder:ClearAllChildren()
end

local function generateBars()
    clearBars()
    if not config.Enabled then return end
    
    for layer = 1, config.DupeAmount do
        for i = 1, config.NumberOfBars do
            local angle = (i / config.NumberOfBars) * math.pi * 2
            
            local bar = Instance.new("Part")
            bar.Name = "Bar_L" .. layer .. "_" .. i
            bar.Shape = Enum.PartType.Block
            bar.Material = Enum.Material.Neon
            bar.CanCollide = false
            bar.Anchored = true
            bar.Size = Vector3.new(config.BarWidth, config.BaseHeight, config.BarWidth)
            bar.Color = Color3.fromHSV((i / config.NumberOfBars) + (layer * 0.1), 1, 1)
            bar.Parent = visualizerFolder
            
            table.insert(bars, {
                Part = bar, 
                Angle = angle, 
                Layer = layer, 
                CurrentHeight = config.BaseHeight
            })
        end
    end
end

local function findActiveSound()
    if not character then return nil end
    for _, desc in pairs(character:GetDescendants()) do
        if desc:IsA("Sound") and desc.IsPlaying then return desc end
    end
    for _, desc in pairs(workspace:GetDescendants()) do
        if desc:IsA("Sound") and desc.IsPlaying and (desc.Parent:IsA("Tool") or desc.Parent:FindFirstChild("HumanoidRootPart")) then
            return desc
        end
    end
    return nil
end


local renderConnection
renderConnection = RunService.Heartbeat:Connect(function()
    if not character or not character:Parent or not rootPart then
        renderConnection:Disconnect()
        clearBars()
        return
    end
    
    if not config.Enabled then 
        if #bars > 0 then clearBars() end
        return 
    end
    if #bars == 0 then generateBars() end
    
    local sound = findActiveSound()
    local loudness = sound and sound.PlaybackLoudness or 0
    local targetHeight = config.BaseHeight + ((loudness / 1000) * config.MaxHeight)
    
    for _, barData in pairs(bars) do
        local bar = barData.Part
        if bar and bar.Parent then
            local angle = barData.Angle
            local layer = barData.Layer
            
            barData.CurrentHeight = barData.CurrentHeight + (targetHeight - barData.CurrentHeight) * config.LerpSpeed
            
            local waveFactor = loudness / 1000
            bar.Color = Color3.fromHSV((angle / (math.pi * 2)) + (waveFactor * 0.15) + (layer * 0.05), 0.9, 0.6 + (waveFactor * 0.4))
            
            local heightOffset = (layer - 1) * config.DupeSpacing
            local offset = Vector3.new(
                math.sin(angle) * config.Radius, 
                (barData.CurrentHeight / 2) - 2 + heightOffset, 
                math.cos(angle) * config.Radius
            )
            
            bar.Size = Vector3.new(config.BarWidth, barData.CurrentHeight, config.BarWidth)
            bar.CFrame = CFrame.new(rootPart.Position + offset) * CFrame.Angles(0, angle, 0)
        end
    end
end)

generateBars()



local oldGui = CoreGui:FindFirstChild("VisualizerGuiV3")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisualizerGuiV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 410)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
}
UIGradient.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "🎵 Visualizer v3"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 19
Title.BorderSizePixel = 0
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)


local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

local function createButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 15
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local ToggleBtn = createButton("Status: ON", 60, Color3.fromRGB(38, 99, 71))
ToggleBtn.MouseButton1Click:Connect(function()
    config.Enabled = not config.Enabled
    if config.Enabled then
        ToggleBtn.Text = "Status: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(38, 99, 71)
        generateBars()
    else
        ToggleBtn.Text = "Status: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(110, 37, 37)
        clearBars()
    end
end)

local PresetBtn = createButton("Preset: " .. presets[currentPresetIdx].Name, 110, Color3.fromRGB(60, 50, 100))
PresetBtn.MouseButton1Click:Connect(function()
    currentPresetIdx = currentPresetIdx + 1
    if currentPresetIdx > #presets then currentPresetIdx = 1 end
    
    local p = presets[currentPresetIdx]
    PresetBtn.Text = "Preset: " .. p.Name
    
    config.NumberOfBars = p.Bars
    config.Radius = p.Radius
    config.MaxHeight = p.MaxHeight
    config.LerpSpeed = p.Lerp
    config.DupeAmount = p.Dupe
    
    _G.updateMenuTexts()
    generateBars()
end)

local DupeBtn = createButton("Dupe Amount: " .. config.DupeAmount, 160, Color3.fromRGB(45, 65, 90))
DupeBtn.MouseButton1Click:Connect(function()
    config.DupeAmount = config.DupeAmount + 1
    if config.DupeAmount > 6 then config.DupeAmount = 1 end
    DupeBtn.Text = "Dupe Amount: " .. config.DupeAmount
    generateBars()
end)

local BarsBtn = createButton("Bars count: " .. config.NumberOfBars, 210)
BarsBtn.MouseButton1Click:Connect(function()
    config.NumberOfBars = config.NumberOfBars == 24 and 48 or config.NumberOfBars == 48 and 72 or config.NumberOfBars == 72 and 12 or 24
    BarsBtn.Text = "Bars count: " .. config.NumberOfBars
    generateBars()
end)

local RadiusBtn = createButton("Radius: " .. config.Radius, 260)
RadiusBtn.MouseButton1Click:Connect(function()
    config.Radius = config.Radius + 2
    if config.Radius > 13 then config.Radius = 3 end
    RadiusBtn.Text = "Radius: " .. config.Radius
end)

local HeightBtn = createButton("Max Height: " .. config.MaxHeight, 310)
HeightBtn.MouseButton1Click:Connect(function()
    config.MaxHeight = config.MaxHeight + 5
    if config.MaxHeight > 30 then config.MaxHeight = 5 end
    HeightBtn.Text = "Max Height: " .. config.MaxHeight
end)

_G.updateMenuTexts = function()
    BarsBtn.Text = "Bars count: " .. config.NumberOfBars
    RadiusBtn.Text = "Radius: " .. config.Radius
    HeightBtn.Text = "Max Height: " .. config.MaxHeight
    DupeBtn.Text = "Dupe Amount: " .. config.DupeAmount
end

local CloseBtn = createButton("Minimize Menu", 360, Color3.fromRGB(30, 30, 30))
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 45, 0, 45)
    OpenBtn.Position = UDim2.new(0, 15, 0.5, -22)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    OpenBtn.Text = "🎵"
    OpenBtn.TextSize = 22
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Thickness = 1.5
    stroke.Parent = OpenBtn
    
    OpenBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenBtn:Destroy()
    end)
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    visualizerFolder = Instance.new("Folder")
    visualizerFolder.Name = "VisualizerFolder"
    visualizerFolder.Parent = character
    generateBars()
end)
