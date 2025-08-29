-- Copy Avatar GUI (client-side only, siap di-loadstring)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "CopyAvatarGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

-- Toggle button (ikon lingkaran hitam kecil, teks "Copy Avatar")
local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 56, 0, 56)
toggle.Position = UDim2.new(0, 16, 0.5, -28)
toggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggle.Text = "Copy\nAvatar"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true
toggle.AutoButtonColor = true
toggle.BorderSizePixel = 0
toggle.ZIndex = 2
toggle.Parent = gui
local tgCorner = Instance.new("UICorner", toggle); tgCorner.CornerRadius = UDim.new(1,0)

-- Panel kecil saat dibuka
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 220, 0, 140)
panel.Position = UDim2.new(0, 84, 0.5, -70)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.35
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local pCorner = Instance.new("UICorner", panel); pCorner.CornerRadius = UDim.new(0,12)

-- TextBox username (abu-abu)
local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 180, 0, 32)
box.Position = UDim2.new(0, 20, 0, 20)
box.PlaceholderText = "Masukin Username..."
box.Text = ""
box.BackgroundColor3 = Color3.fromRGB(80,80,80)
box.TextColor3 = Color3.new(1,1,1)
box.ClearTextOnFocus = false
box.BorderSizePixel = 0
box.Parent = panel
local bCorner = Instance.new("UICorner", box); bCorner.CornerRadius = UDim.new(0,6)

-- Tombol Copy (hijau)
local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(0, 84, 0, 30)
btnCopy.Position = UDim2.new(0, 20, 0, 70)
btnCopy.Text = "Copy"
btnCopy.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
btnCopy.TextColor3 = Color3.new(1,1,1)
btnCopy.BorderSizePixel = 0
btnCopy.Parent = panel
local cCorner = Instance.new("UICorner", btnCopy); cCorner.CornerRadius = UDim.new(0,6)

-- Tombol Uncopy (merah) — muncul setelah sukses copy
local btnUncopy = Instance.new("TextButton")
btnUncopy.Size = UDim2.new(0, 84, 0, 30)
btnUncopy.Position = UDim2.new(0, 116, 0, 70)
btnUncopy.Text = "Uncopy"
btnUncopy.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
btnUncopy.TextColor3 = Color3.new(1,1,1)
btnUncopy.BorderSizePixel = 0
btnUncopy.Visible = false
btnUncopy.Parent = panel
local uCorner = Instance.new("UICorner", btnUncopy); uCorner.CornerRadius = UDim.new(0,6)

-- ===== LOGIC =====
local originalDesc :: HumanoidDescription? = nil
local lastCopiedDesc :: HumanoidDescription? = nil

local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("Humanoid")
end

-- Simpan deskripsi asli sekali saja
local function ensureOriginalSaved()
	local hum = getHumanoid()
	if not originalDesc then
		local ok, desc = pcall(function()
			return hum:GetAppliedDescription()
		end)
		if ok and desc then
			originalDesc = Instance.new("HumanoidDescription")
			originalDesc:ApplyDescription(desc)
		end
	end
end

-- Apply description client-only
local function applyDescriptionClient(desc: HumanoidDescription)
	local hum = getHumanoid()
	local ok, err = pcall(function()
		hum:ApplyDescription(desc, Enum.AssetTypeVerification.ClientOnly)
	end)
	if not ok then
		warn("Gagal apply description:", err)
	end
end

local function copyAvatarByUsername(username: string)
	if not username or username == "" then return end
	local okId, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(username)
	end)
	if not okId then
		warn("Username nggak ketemu:", username)
		return
	end

	local okDesc, targetDesc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not okDesc then
		warn("Gagal ambil HumanoidDescription target")
		return
	end

	ensureOriginalSaved()

	lastCopiedDesc = Instance.new("HumanoidDescription")
	lastCopiedDesc:ApplyDescription(targetDesc)

	applyDescriptionClient(lastCopiedDesc)
	btnUncopy.Visible = true
end

local function uncopyAvatar()
	if originalDesc then
		applyDescriptionClient(originalDesc)
	end
	btnUncopy.Visible = false
end

-- Respawn handler
player.CharacterAdded:Connect(function()
	if lastCopiedDesc then
		task.defer(function()
			applyDescriptionClient(lastCopiedDesc)
			btnUncopy.Visible = true
		end)
	else
		btnUncopy.Visible = false
	end
end)

-- ===== EVENTS =====
toggle.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

btnCopy.MouseButton1Click:Connect(function()
	copyAvatarByUsername(box.Text)
end)

btnUncopy.MouseButton1Click:Connect(function()
	uncopyAvatar()
end)

box.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		copyAvatarByUsername(box.Text)
	end
end)