--[[
	GameManager.lua
	🎮 UBICACIÓN EN ROBLOX: ServerScriptService > GameManager
	Gestiona el ciclo principal del juego, rondas y lobby
]]

local GameManager = {}
local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local MissionGenerator = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("MissionGenerator"))
local DataManager = require(game:GetService("ServerScriptService"):WaitForChild("DataManager"))
local AchievementManager = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("AchievementManager"))

local playersInGame = {}
local gameState = "LOBBY" -- LOBBY, PLAYING, RESETTING
local currentRound = 0
local roundStartTime = 0
local playerMissions = {} -- {userId = {misiones}}
local playerCoins = {} -- {userId = totalMonedas}

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local RoundTimerEvent = Remotes:WaitForChild("RoundTimer")
local MissionEvent = Remotes:WaitForChild("MissionEvent")
local ResetEvent = Remotes:WaitForChild("ResetEvent")
local DataUpdateEvent = Remotes:WaitForChild("DataUpdateEvent")
local AchievementEvent = Remotes:WaitForChild("AchievementEvent")

-- Actualizar lista de jugadores
local function UpdatePlayerList()
	local players = game:GetService("Players"):GetPlayers()
	playersInGame = {}
	
	for _, player in ipairs(players) do
		if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			table.insert(playersInGame, player)
		end
	end
	
	return #playersInGame
end

-- Iniciar ronda
local function StartRound()
	gameState = "PLAYING"
	currentRound = currentRound + 1
	roundStartTime = os.time()
	
	print("[GameManager] Iniciando ronda " .. currentRound)
	
	-- Generar misiones para cada jugador
	for _, player in ipairs(playersInGame) do
		local missions = MissionGenerator.GenerateMissions(#playersInGame)
		playerMissions[player.UserId] = missions
		playerCoins[player.UserId] = 0
		
		-- Enviar misiones al cliente
		if player:FindFirstChildOfClass("PlayerGui") then
			MissionEvent:FireClient(player, "UPDATE", missions)
		end
	end
	
	-- Iniciar temporizador de ronda
	spawn(function()
		local timeRemaining = GameConfig.ROUND_DURATION
		
		while timeRemaining > 0 and gameState == "PLAYING" do
			wait(1)
			timeRemaining = gameState == "PLAYING" and (GameConfig.ROUND_DURATION - (os.time() - roundStartTime)) or 0
			
			if timeRemaining <= 0 then
				break
			end
			
			-- Enviar actualización de temporizador a todos
			for _, player in ipairs(playersInGame) do
				if player and player.Parent then
					RoundTimerEvent:FireClient(player, math.ceil(timeRemaining))
				end
			end
		end
		
		-- Terminar ronda
		if gameState == "PLAYING" then
			EndRound()
		end
	end)
end

-- Terminar ronda
function EndRound()
	gameState = "RESETTING"
	
	print("[GameManager] Terminando ronda " .. currentRound)
	
	-- Procesar recompensas
	for _, player in ipairs(playersInGame) do
		local userId = player.UserId
		local playerData = DataManager.GetPlayerData(userId)
		
		if playerData then
			-- Agregar monedas recolectadas
			local coinsEarned = playerCoins[userId] or 0
			DataManager.AddCoins(userId, coinsEarned)
			
			-- Procesar misiones completadas
			local completedMissions = 0
			if playerMissions[userId] then
				for _, mission in ipairs(playerMissions[userId]) do
					if mission.completed then
						DataManager.AddCoins(userId, mission.reward)
						DataManager.AddXP(userId, GameConfig.XP_PER_MISSION)
						DataManager.CompleteMission(userId)
						completedMissions = completedMissions + 1
					end
				end
			end
			
			-- Actualizar datos de ronda
			DataManager.ResetRoundStats(userId)
			
			-- Verificar logros
			local newAchievements = AchievementManager.CheckAchievements(playerData)
			for _, achievementId in ipairs(newAchievements) do
				DataManager.AddAchievement(userId, achievementId)
				AchievementEvent:FireClient(player, achievementId)
		end
		end
	end
	
	-- Enviar evento de reinicio a todos
	ResetEvent:FireAllClients()
	
	-- Esperar a que se complete la transición
	wait(GameConfig.RESET_FADE_TIME)
	
	-- Limpiar datos de ronda
	playerMissions = {}
	playerCoins = {}
	gameState = "LOBBY"
	
	-- Esperar y reiniciar
	wait(2)
	if UpdatePlayerList() >= GameConfig.MIN_PLAYERS then
		StartRound()
	end
end

-- Manejar entrada de jugador
game:GetService("Players").PlayerAdded:Connect(function(player)
	print("[GameManager] Jugador entrado: " .. player.Name)
	
	-- Cargar datos
	local playerData = DataManager.GetPlayerData(player.UserId)
	if playerData then
		DataUpdateEvent:FireClient(player, playerData)
	end
end)

-- Manejar salida de jugador
game:GetService("Players").PlayerRemoving:Connect(function(player)
	print("[GameManager] Jugador salido: " .. player.Name)
	playerMissions[player.UserId] = nil
	playerCoins[player.UserId] = nil
end)

-- Recibir monedas recolectadas
local CoinEvent = Remotes:WaitForChild("CoinEvent")
CoinEvent.OnServerEvent:Connect(function(player, coinsAmount)
	if gameState ~= "PLAYING" then return end
	
	local userId = player.UserId
	playerCoins[userId] = (playerCoins[userId] or 0) + coinsAmount
end)

-- Recibir actualización de progreso de misión
MissionEvent.OnServerEvent:Connect(function(player, missionId, newProgress)
	if gameState ~= "PLAYING" then return end
	
	local userId = player.UserId
	if not playerMissions[userId] then return end
	
	for _, mission in ipairs(playerMissions[userId]) do
		if mission.id == missionId then
			-- Validar progreso
			if MissionGenerator.ValidateMissionProgress(mission, newProgress) then
				mission.progress = newProgress
				
				-- Marcar como completada si alcanzó el objetivo
				if mission.progress >= mission.target and not mission.completed then
					mission.completed = true
					mission.completedTime = os.time()
					MissionEvent:FireClient(player, "COMPLETE", missionId)
				end
		end
		break
	end
end)

-- Iniciar juego cuando hay suficientes jugadores
spawn(function()
	while true do
		wait(2)
		
		local playerCount = UpdatePlayerList()
		
		if playerCount >= GameConfig.MIN_PLAYERS and gameState == "LOBBY" then
			StartRound()
		end
	end
end)

print("[GameManager] Sistema iniciado correctamente")