--[[
	WorldReset.lua
	🎮 UBICACIÓN EN ROBLOX: ServerScriptService > WorldReset
	Gestiona el reinicio del mundo cada ronda
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local MapGenerator = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("MapGenerator"))

local currentMapSeed = 0
local spawnedCoins = {}
local lastResetTime = 0

-- Generar monedas en el mapa
local function SpawnCoins()
	-- Limpiar monedas antiguas
	for _, coin in ipairs(spawnedCoins) do
		if coin and coin.Parent then
			coin:Destroy()
		end
	end
	spawnedCoins = {}
	
	-- Generar nueva semilla
	local roundNumber = (os.time() - game.CreatedTime) / GameConfig.ROUND_DURATION
	currentMapSeed = MapGenerator.GenerateMapSeed(math.floor(roundNumber))
	
	-- Obtener posiciones para monedas
	local coinPositions = MapGenerator.GetCoinSpawnPositions(currentMapSeed, GameConfig.TOTAL_COINS_PER_ROUND)
	
	local mainMap = workspace:FindFirstChild("MainMap")
	if not mainMap then
		print("[WorldReset] MainMap no encontrado")
		return
	end
	
	-- Crear monedas
	for i, position in ipairs(coinPositions) do
		local coin = Instance.new("Part")
		coin.Name = "Coin_" .. i
		coin.Shape = Enum.PartType.Ball
		coin.Size = Vector3.new(0.5, 0.5, 0.5)
		coin.Color = Color3.fromRGB(255, 215, 0)
		coin.Material = Enum.Material.Neon
		coin.CanCollide = false
		coin.Position = position
		coin.Parent = mainMap
		
		-- Hacer que rote
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = coin
		
		-- Detección de contacto
		local touchConnection
		touchConnection = coin.Touched:Connect(function(hit)
			local humanoid = hit.Parent:FindFirstChild("Humanoid")
			if humanoid then
				local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
				if player then
					local CoinEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CoinEvent")
					CoinEvent:FireServer(GameConfig.COIN_PER_COLLECTION)
					
					coin:Destroy()
					touchConnection:Disconnect()
			end
		end
	end)
	
	-- Efecto visual
	local bodyVelocity = coin:FindFirstChild("BodyVelocity")
	if bodyVelocity then
		local rotationSpeed = math.random(1, 3) * (math.random(0, 1) == 0 and -1 or 1)
		spawn(function()
			while coin.Parent do
				coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(rotationSpeed), 0)
				wait(0.05)
			end
		end)
	end
	
	table.insert(spawnedCoins, coin)
	end
	
	print("[WorldReset] Generadas " .. #spawnedCoins .. " monedas")
end

-- Reiniciar objetos del mapa
local function ResetWorldObjects()
	print("[WorldReset] Reiniciando objetos del mundo")
	
	-- Restaurar obstáculos destruidos
	local obstacles = workspace:FindFirstChild("MainMap"):FindFirstChild("Obstacles")
	if obstacles then
		for _, obstacle in ipairs(obstacles:GetChildren()) do
			if obstacle:IsA("Model") or obstacle:IsA("Part") then
				-- Restaurar posición original si existe
				if obstacle:FindFirstChild("OriginalPosition") then
					obstacle:MoveTo(obstacle:FindFirstChild("OriginalPosition").Value)
			end
		end
	end
	end
	
	-- Variar condiciones del mapa
	local mapEvents = MapGenerator.GetMapEvents(currentMapSeed)
	if mapEvents and #mapEvents > 0 then
		local event = mapEvents[1]
		print("[WorldReset] Evento del mapa: " .. event.type)
		
		-- Aquí se podrían aplicar cambios visuales según el evento
		local lighting = game:GetService("Lighting")
		
		if event.type == "noche" then
			lighting.Brightness = 0.3
		elseif event.type == "lluvia" then
			lighting.Brightness = 0.5
		else
			lighting.Brightness = 2
		end
	end
end

-- Respawnear jugadores
local function RespawnPlayers()
	print("[WorldReset] Respawneando jugadores")
	
	local lobbySpawn = workspace:FindFirstChild("Lobby"):FindFirstChild("Spawn")
	if not lobbySpawn then
		print("[WorldReset] No se encontró Spawn point")
		return
	end
	
	local players = game:GetService("Players"):GetPlayers()
	for _, player in ipairs(players) do
		if player.Character then
			local spawnPos = lobbySpawn.Position + Vector3.new(math.random(-5, 5), 3, math.random(-5, 5))
			player.Character:MoveTo(spawnPos)
		end
	end
end

-- Función principal de reinicio
local function PerformWorldReset()
	lastResetTime = os.time()
	
	print("[WorldReset] Reinicio del mundo iniciado")
	
	-- Ejecutar tareas de reinicio
	ResetWorldObjects()
	RespawnPlayers()
	SpawnCoins()
	
	print("[WorldReset] Reinicio completado")
end

-- Conectar a evento de reinicio
local ResetEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ResetEvent")
ResetEvent.Event:Connect(function()
	PerformWorldReset()
end)

-- Generar monedas iniciales
spawn(function()
	wait(2)
	SpawnCoins()
end)

print("[WorldReset] Sistema listo")