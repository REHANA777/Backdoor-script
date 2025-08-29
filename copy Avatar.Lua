-- Clone & Copy Avatar GUI
-- Client-side only

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "CloneCopyAvatarGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 56, 0, 56)
toggle.Position = UDim2.new(0, 16, 0.5, -28)
toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggle.Text = "Copy\nAva"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 140)
panel.Position = UDim2.new(0, 84, 0.5, -70)
panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
panel.BackgroundTransparency = 0.35
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 180, 0, 32)
box.Position = UDim2.new(0, 20, 0, 20)
box.PlaceholderText = "Masukin Username..."
box.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
box.TextColor3 = Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.Parent = panel
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(0, 84, 0, 30)
btnCopy.Position = UDim2.new(0, 20, 0, 70)
btnCopy.Text = "Copy"
btnCopy.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
btnCopy.TextColor3 = Color3.new(1, 1, 1)
btnCopy.Parent = panel
Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 6)

local btnUncopy = Instance.new("TextButton")
btnUncopy.Size = UDim2.new(0, 84, 0, 30)
btnUncopy.Position = UDim2.new(0, 116, 0, 70)
btnUncopy.Text = "Uncopy"
btnUncopy.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
btnUncopy.TextColor3 = Color3.new(1, 1, 1)
btnUncopy.Visible = false
btnUncopy.Parent = panel
Instance.new("UICorner", btnUncopy).CornerRadius = UDim.new(0, 6)

-- Logic
local originalDesc
local lastCopiedDesc

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function saveOriginal()
    if not originalDesc then
        local hum = getHumanoid()
        local desc = hum:GetAppliedDescription()
        originalDesc = Instance.new("HumanoidDescription")
        originalDesc:ApplyDescription(desc)
    end
end

local function applyDesc(desc)
    local hum = getHumanoid()
    hum:ApplyDescription(desc, Enum.AssetTypeVerification.ClientOnly)
end

local function copyFromClone(username)
    local target = Players:FindFirstChild(username)
    if not target or not target.Character then
        warn("Player tidak ditemukan di server:", username)
        return
    end

    saveOriginal()

    -- clone dulu
    local clone = target.Character:Clone()
    clone.Parent = workspace
    clone:MoveTo(player.Character:GetPivot().Position + Vector3.new(5, 0, 0))

    -- ambil desc dari clone
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        local desc = hum:GetAppliedDescription()
        lastCopiedDesc = Instance.new("HumanoidDescription")
        lastCopiedDesc:ApplyDescription(desc)
        applyDesc(lastCopiedDesc)
        btnUncopy.Visible = true
    end

    -- auto hapus clone biar ga numpuk
    game:GetService("Debris"):AddItem(clone, 10)
end

local function uncopy()
    if originalDesc then
        applyDesc(originalDesc)
    end
    btnUncopy.Visible = false
end

-- Events
toggle.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

btnCopy.MouseButton1Click:Connect(function()
    copyFromClone(box.Text)
end)

btnUncopy.MouseButton1Click:Connect(function()
    uncopy()
end)

box.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        copyFromClone(box.Text)
    end
end)