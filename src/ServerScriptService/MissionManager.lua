--[[
	MissionManager.lua
	🎮 UBICACIÓN EN ROBLOX: ServerScriptService > MissionManager
	Gestiona todas las misiones de los jugadores
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local MissionGenerator = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("MissionGenerator"))
local DataManager = require(game:GetService("ServerScriptService"):WaitForChild("DataManager"))

local MissionManager = {}
local playerMissions = {}
local locationVisits = {} -- Rastrear ubicaciones visitadas

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local MissionEvent = Remotes:WaitForChild("MissionEvent")

-- Crear misión para un jugador
function MissionManager.CreatePlayerMissions(player)
	local userId = player.UserId
	local missions = MissionGenerator.GenerateMissions(1)
	
	playerMissions[userId] = missions
	locationVisits[userId] = {}
	
	return missions
end

-- Actualizar progreso de misión
function MissionManager.UpdateMissionProgress(player, missionType, amount)
	local userId = player.UserId
	if not playerMissions[userId] then return false end
	
	for _, mission in ipairs(playerMissions[userId]) do
		if mission.missionType == missionType then
			if MissionGenerator.ValidateMissionProgress(mission, amount) then
				mission.progress = math.min(amount, mission.target)
				
				-- Verificar completitud
				if mission.progress >= mission.target and not mission.completed then
					MissionManager.CompleteMission(player, mission.id)
				end
				
				return true
			end
		end
	end
	
	return false
end

-- Completar misión
function MissionManager.CompleteMission(player, missionId)
	local userId = player.UserId
	if not playerMissions[userId] then return end
	
	for _, mission in ipairs(playerMissions[userId]) do
		if mission.id == missionId then
			mission.completed = true
			mission.completedTime = os.time()
			
			-- Registrar en DataStore
			DataManager.CompleteMission(userId)
			
			-- Notificar cliente
			MissionEvent:FireClient(player, "COMPLETE", missionId)
			print("[MissionManager] Misión completada: " .. mission.name .. " - Jugador: " .. player.Name)
			break
		end
	end
end

-- Registrar ubicación visitada
function MissionManager.VisitLocation(player, locationName)
	local userId = player.UserId
	
	if not locationVisits[userId] then
		locationVisits[userId] = {}
	end
	
	if not locationVisits[userId][locationName] then
		locationVisits[userId][locationName] = true
		
		-- Actualizar misión de exploración
		local visitCount = 0
		for _ in pairs(locationVisits[userId]) do
			visitCount = visitCount + 1
		end
		
		MissionManager.UpdateMissionProgress(player, "explore_locations", visitCount)
		
		-- Registrar en datos
		local playerData = DataManager.GetPlayerData(userId)
		if playerData then
			playerData.locationsVisited = (playerData.locationsVisited or 0) + 1
			DataManager.SavePlayerData(userId, playerData)
		end
		
		print("[MissionManager] Ubicación visitada: " .. locationName .. " - Jugador: " .. player.Name)
		return true
	end
	
	return false
end

-- Obtener misiones del jugador
function MissionManager.GetPlayerMissions(userId)
	return playerMissions[userId] or {}
end

-- Limpiar datos cuando sale el jugador
game:GetService("Players").PlayerRemoving:Connect(function(player)
	playerMissions[player.UserId] = nil
	locationVisits[player.UserId] = nil
end)

print("[MissionManager] Sistema listo")

return MissionManager