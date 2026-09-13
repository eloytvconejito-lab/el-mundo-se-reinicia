--[[
	ClientController.lua
	🎮 UBICACIÓN EN ROBLOX: StarterPlayer > StarterCharacterScripts > ClientController
	Controlador principal del cliente - Maneja UI, entrada y sincronización
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("MainGui")

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local RoundTimerEvent = Remotes:WaitForChild("RoundTimer")
local MissionEvent = Remotes:WaitForChild("MissionEvent")
local CoinEvent = Remotes:WaitForChild("CoinEvent")
local ResetEvent = Remotes:WaitForChild("ResetEvent")
local DataUpdateEvent = Remotes:WaitForChild("DataUpdateEvent")
local AchievementEvent = Remotes:WaitForChild("AchievementEvent")

-- Variables locales
local gameState = "LOBBY"
local currentMissions = {}
local playerData = {}
local timeRemaining = 0

-- Obtener referencias de UI
local function GetUIElements()
	local inGameScreen = mainGui:FindFirstChild("InGameScreen")
	if not inGameScreen then return nil end
	
	return {
		timer = inGameScreen:FindFirstChild("TimerLabel"),
		missionPanel = inGameScreen:FindFirstChild("MissionPanel"),
		coinsLabel = inGameScreen:FindFirstChild("CoinsLabel"),
		statusLabel = inGameScreen:FindFirstChild("StatusLabel"),
	}
end

-- Actualizar etiqueta de temporizador
local function UpdateTimerDisplay(seconds)
	timeRemaining = seconds
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	
	local uiElements = GetUIElements()
	if uiElements and uiElements.timer then
		uiElements.timer.Text = string.format("%02d:%02d", minutes, secs)
		
		-- Cambiar color según tiempo restante
		if seconds <= 30 then
			uiElements.timer.TextColor3 = GameConfig.COLORS.DANGER
		elseif seconds <= 60 then
			uiElements.timer.TextColor3 = GameConfig.COLORS.WARNING
		else
			uiElements.timer.TextColor3 = GameConfig.COLORS.SUCCESS
		end
	end
end

-- Actualizar panel de misiones
local function UpdateMissionsDisplay(missions)
	currentMissions = missions
	local uiElements = GetUIElements()
	
	if uiElements and uiElements.missionPanel then
		local missionTitle = uiElements.missionPanel:FindFirstChild("MissionTitle")
		local missionDesc = uiElements.missionPanel:FindFirstChild("MissionDescription")
		local progressBar = uiElements.missionPanel:FindFirstChild("MissionProgress")
		
		if #missions > 0 then
			local mission = missions[1]
			
			if missionTitle then
				missionTitle.Text = mission.name
			end
			
			if missionDesc then
				missionDesc.Text = mission.description
			end
			
			if progressBar then
				local progress = math.min(mission.progress / mission.target, 1)
				progressBar.Size = UDim2.new(progress, 0, 1, 0)
			end
		end
	end
end

-- Actualizar etiqueta de monedas
local function UpdateCoinsDisplay()
	local uiElements = GetUIElements()
	if uiElements and uiElements.coinsLabel then
		uiElements.coinsLabel.Text = "💰 " .. (playerData.totalCoins or 0)
	end
end

-- Actualizar estado
local function UpdateStatusDisplay(status)
	local uiElements = GetUIElements()
	if uiElements and uiElements.statusLabel then
		uiElements.statusLabel.Text = status
	end
end

-- Manejar detección de monedas
local function SetupCoinDetection()
	local char = script.Parent
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	
	if humanoidRootPart then
		local touchConnection
		touchConnection = humanoidRootPart.Touched:Connect(function(hit)
			if hit.Name:match("Coin") then
				-- Enviar evento al servidor
				CoinEvent:FireServer(GameConfig.COIN_PER_COLLECTION)
			end
		end)
	end
end

-- Manejar detección de ubicaciones
local function SetupLocationDetection()
	local char = script.Parent
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	
	if humanoidRootPart then
		local locations = workspace:FindFirstChild("MainMap"):FindFirstChild("MissionLocations")
		if locations then
			for _, location in ipairs(locations:GetChildren()) do
				local touchConnection
				touchConnection = location.Touched:Connect(function(hit)
					if hit.Parent:FindFirstChild("Humanoid") then
						local detectedPlayer = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
						if detectedPlayer == player then
							-- Actualizar progreso de exploración
							MissionEvent:FireServer(1, location.Name)
						end
					end
				end)
			end
		end
	end
end

-- Manejo de eventos de entrada
local function SetupInputHandling()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.E then
			-- Buscar objetos interactuables cerca
			local char = script.Parent
			local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
			
			if humanoidRootPart then
				local nearby = workspace:FindPartBoundsInRadius(humanoidRootPart.Position, 20)
				for _, part in ipairs(nearby) do
					if part.Name:match("NPC") or part.Name:match("Interactable") then
						print("Interactuando con: " .. part.Name)
						-- Aquí se podría abrir un diálogo
					end
				end
			end
		end
	end)
end

-- Recibir actualizaciones de temporizador
RoundTimerEvent.OnClientEvent:Connect(function(seconds)
	UpdateTimerDisplay(seconds)
end)

-- Recibir actualizaciones de misiones
MissionEvent.OnClientEvent:Connect(function(action, data)
	if action == "UPDATE" then
		UpdateMissionsDisplay(data)
	elseif action == "COMPLETE" then
		UpdateStatusDisplay("¡Misión completada!")
	end
end)

-- Recibir actualizaciones de datos
DataUpdateEvent.OnClientEvent:Connect(function(data)
	playerData = data
	UpdateCoinsDisplay()
end)

-- Recibir eventos de logro
AchievementEvent.OnClientEvent:Connect(function(achievementId)
	UpdateStatusDisplay("¡Logro desbloqueado!")
	print("Logro " .. achievementId .. " desbloqueado")
end)

-- Recibir evento de reinicio
ResetEvent.OnClientEvent:Connect(function()
	print("Mundo reiniciándose...")
	gameState = "RESETTING"
	UpdateStatusDisplay("El mundo se reinicia...")
	wait(GameConfig.RESET_FADE_TIME)
	gameState = "LOBBY"
end)

-- Inicializar detecciones
SetupCoinDetection()
SetupLocationDetection()
SetupInputHandling()

print("[ClientController] Sistema del cliente listo")