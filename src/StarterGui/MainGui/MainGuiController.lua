--[[
	MainGuiController.lua
	🎮 UBICACIÓN EN ROBLOX: StarterGui > MainGui > (agregar como LocalScript dentro de MainGui)
	Controlador de interfaz gráfica
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local screenGui = script.Parent
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Referencias de UI
local lobbyScreen
local inGameScreen
local endRoundScreen
local shopFrame
local inventoryFrame
local achievementsFrame

local isShopOpen = false
local isInventoryOpen = false
local isAchievementsOpen = false

-- Crear pantalla de lobby
local function CreateLobbyScreen()
	lobbyScreen = Instance.new("Frame")
	lobbyScreen.Name = "LobbyScreen"
	lobbyScreen.Size = UDim2.new(1, 0, 1, 0)
	lobbyScreen.BackgroundColor3 = GameConfig.COLORS.DARK
	lobbyScreen.BorderSizePixel = 0
	lobbyScreen.Parent = screenGui
	
	-- Título
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 100)
	title.BackgroundTransparency = 1
	title.Text = "🌍 El Mundo se Reinicia"
	title.TextSize = 48
	title.TextColor3 = GameConfig.COLORS.PRIMARY
	title.Font = Enum.Font.GothamBold
	title.Parent = lobbyScreen
	
	-- Botón para unirse
	local joinButton = Instance.new("TextButton")
	joinButton.Name = "JoinButton"
	joinButton.Size = UDim2.new(0, 200, 0, 60)
	joinButton.Position = UDim2.new(0.5, -100, 0.5, 0)
	joinButton.BackgroundColor3 = GameConfig.COLORS.PRIMARY
	joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	joinButton.TextSize = 24
	joinButton.Font = Enum.Font.GothamBold
	joinButton.Text = "JUGAR"
	joinButton.Parent = lobbyScreen
	
	-- Efecto hover
	joinButton.MouseEnter:Connect(function()
		local tween = TweenService:Create(joinButton, TweenInfo.new(0.2), {BackgroundColor3 = GameConfig.COLORS.SECONDARY})
		tween:Play()
	end)
	
	joinButton.MouseLeave:Connect(function()
		local tween = TweenService:Create(joinButton, TweenInfo.new(0.2), {BackgroundColor3 = GameConfig.COLORS.PRIMARY})
		tween:Play()
	end)
	
	-- Etiqueta de estado
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 50)
	statusLabel.Position = UDim2.new(0, 0, 0.7, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Esperando jugadores..."
	statusLabel.TextSize = 18
	statusLabel.TextColor3 = GameConfig.COLORS.LIGHT
	statusLabel.Parent = lobbyScreen
	
	return joinButton
end

-- Crear pantalla de juego
local function CreateInGameScreen()
	inGameScreen = Instance.new("Frame")
	inGameScreen.Name = "InGameScreen"
	inGameScreen.Size = UDim2.new(1, 0, 1, 0)
	inGameScreen.BackgroundTransparency = 1
	inGameScreen.Visible = false
	inGameScreen.Parent = screenGui
	
	-- Temporizador (arriba a la izquierda)
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(0, 150, 0, 60)
	timerLabel.Position = UDim2.new(0, 20, 0, 20)
	timerLabel.BackgroundColor3 = GameConfig.COLORS.DARK
	timerLabel.BackgroundTransparency = 0.3
	timerLabel.TextColor3 = GameConfig.COLORS.SUCCESS
	timerLabel.TextSize = 40
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.Text = "05:00"
	timerLabel.BorderSizePixel = 0
	timerLabel.Parent = inGameScreen
	
	-- Panel de misiones (arriba a la derecha)
	local missionPanel = Instance.new("Frame")
	missionPanel.Name = "MissionPanel"
	missionPanel.Size = UDim2.new(0, 300, 0, 150)
	missionPanel.Position = UDim2.new(1, -320, 0, 20)
	missionPanel.AnchorPoint = Vector2.new(0, 0)
	missionPanel.BackgroundColor3 = GameConfig.COLORS.DARK
	missionPanel.BackgroundTransparency = 0.3
	missionPanel.BorderSizePixel = 0
	missionPanel.Parent = inGameScreen
	
	-- Título de misión
	local missionTitle = Instance.new("TextLabel")
	missionTitle.Name = "MissionTitle"
	missionTitle.Size = UDim2.new(1, 0, 0, 40)
	missionTitle.BackgroundTransparency = 1
	missionTitle.Text = "Misión"
	missionTitle.TextColor3 = GameConfig.COLORS.PRIMARY
	missionTitle.TextSize = 18
	missionTitle.Font = Enum.Font.GothamBold
	missionTitle.Parent = missionPanel
	
	-- Descripción de misión
	local missionDesc = Instance.new("TextLabel")
	missionDesc.Name = "MissionDescription"
	missionDesc.Size = UDim2.new(1, -10, 0, 60)
	missionDesc.Position = UDim2.new(0, 5, 0, 45)
	missionDesc.BackgroundTransparency = 1
	missionDesc.Text = "Descripción"
	missionDesc.TextColor3 = GameConfig.COLORS.LIGHT
	missionDesc.TextSize = 14
	missionDesc.TextWrapped = true
	missionDesc.Parent = missionPanel
	
	-- Barra de progreso
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBg"
	progressBg.Size = UDim2.new(1, -10, 0, 15)
	progressBg.Position = UDim2.new(0, 5, 1, -20)
	progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = missionPanel
	
	local progressBar = Instance.new("Frame")
	progressBar.Name = "MissionProgress"
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.BackgroundColor3 = GameConfig.COLORS.SUCCESS
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBg
	
	-- Monedas (abajo a la izquierda)
	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(0, 150, 0, 50)
	coinsLabel.Position = UDim2.new(0, 20, 1, -70)
	coinsLabel.BackgroundColor3 = GameConfig.COLORS.DARK
	coinsLabel.BackgroundTransparency = 0.3
	coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinsLabel.TextSize = 24
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.Text = "💰 0"
	coinsLabel.BorderSizePixel = 0
	coinsLabel.Parent = inGameScreen
	
	-- Botones de UI (abajo a la derecha)
	local shopButton = Instance.new("ImageButton")
	shopButton.Name = "ShopButton"
	shopButton.Size = UDim2.new(0, 60, 0, 60)
	shopButton.Position = UDim2.new(1, -200, 1, -80)
	shopButton.BackgroundColor3 = GameConfig.COLORS.PRIMARY
	shopButton.BorderSizePixel = 0
	shopButton.Parent = inGameScreen
	
	-- Etiqueta de estado
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 30)
	statusLabel.Position = UDim2.new(0, 0, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = GameConfig.COLORS.SUCCESS
	statusLabel.TextSize = 16
	statusLabel.Parent = inGameScreen
	
	return {statusLabel = statusLabel}
end

-- Crear pantalla de fin de ronda
local function CreateEndRoundScreen()
	endRoundScreen = Instance.new("Frame")
	endRoundScreen.Name = "EndRoundScreen"
	endRoundScreen.Size = UDim2.new(1, 0, 1, 0)
	endRoundScreen.BackgroundColor3 = GameConfig.COLORS.DARK
	endRoundScreen.BackgroundTransparency = 0.1
	endRoundScreen.Visible = false
	endRoundScreen.Parent = screenGui
	
	-- Panel central
	local panel = Instance.new("Frame")
	panel.Name = "ResultsPanel"
	panel.Size = UDim2.new(0, 400, 0, 300)
	panel.Position = UDim2.new(0.5, -200, 0.5, -150)
	panel.BackgroundColor3 = GameConfig.COLORS.PRIMARY
	panel.BorderSizePixel = 0
	panel.Parent = endRoundScreen
	
	-- Título
	local resultsLabel = Instance.new("TextLabel")
	resultsLabel.Name = "ResultsLabel"
	resultsLabel.Size = UDim2.new(1, 0, 0, 60)
	resultsLabel.BackgroundTransparency = 1
	resultsLabel.Text = "Resultados de Ronda"
	resultsLabel.TextSize = 28
	resultsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	resultsLabel.Font = Enum.Font.GothamBold
	resultsLabel.Parent = panel
	
	-- Recompensas
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Name = "RewardLabel"
	rewardLabel.Size = UDim2.new(1, 0, 0, 100)
	rewardLabel.Position = UDim2.new(0, 0, 0, 70)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Text = "Monedas: +100\nXP: +50"
	rewardLabel.TextSize = 18
	rewardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rewardLabel.TextWrapped = true
	rewardLabel.Parent = panel
	
	-- Botón siguiente ronda
	local nextButton = Instance.new("TextButton")
	nextButton.Name = "NextRoundButton"
	nextButton.Size = UDim2.new(0.8, 0, 0, 50)
	nextButton.Position = UDim2.new(0.1, 0, 1, -60)
	nextButton.BackgroundColor3 = GameConfig.COLORS.SUCCESS
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextSize = 18
	nextButton.Font = Enum.Font.GothamBold
	nextButton.Text = "SIGUIENTE RONDA"
	nextButton.BorderSizePixel = 0
	nextButton.Parent = panel
end

-- Crear todas las pantallas
CreateLobbyScreen()
CreateInGameScreen()
CreateEndRoundScreen()

print("[MainGuiController] GUI creada exitosamente")