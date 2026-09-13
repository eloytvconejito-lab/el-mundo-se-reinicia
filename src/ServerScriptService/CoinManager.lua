--[[
	CoinManager.lua
	🎮 UBICACIÓN EN ROBLOX: ServerScriptService > CoinManager
	Gestiona la recolección de monedas con validación
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local RewardCalculator = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("RewardCalculator"))
local DataManager = require(game:GetService("ServerScriptService"):WaitForChild("DataManager"))

local CoinManager = {}
local coinCollectionStats = {} -- Rastrear monedas recolectadas

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local CoinEvent = Remotes:WaitForChild("CoinEvent")

-- Estructura de rastreo
local function InitCoinStats(userId)
	if not coinCollectionStats[userId] then
		coinCollectionStats[userId] = {
			coinsCollectedThisRound = 0,
			lastCollectionTime = 0,
			collectionEvents = 0,
		}
	end
end

-- Recolectar moneda con validación
function CoinManager.CollectCoin(player, coinAmount)
	if not player or not player.Parent then
		return false
	end
	
	local userId = player.UserId
	InitCoinStats(userId)
	
	-- Validación 1: Cantidad positiva
	if not coinAmount or coinAmount <= 0 then
		print("[EXPLOIT] Intento de recolectar monedas negativas: " .. tostring(coinAmount))
		return false
	end
	
	-- Validación 2: Límite por recolección individual
	if coinAmount > GameConfig.COIN_PER_COLLECTION * 10 then
		print("[EXPLOIT] Monedas excesivas en una recolección: " .. tostring(coinAmount))
		return false
	end
	
	-- Validación 3: Límite por ronda
	local stats = coinCollectionStats[userId]
	if stats.coinsCollectedThisRound + coinAmount > GameConfig.MAX_COINS_PER_ROUND then
		print("[EXPLOIT] Intento de superar límite de monedas de " .. player.Name)
		return false
	end
	
	-- Validación 4: No recolectar demasiado rápido (throttling)
	local currentTime = os.time()
	if currentTime - stats.lastCollectionTime < 0.5 and stats.collectionEvents > 5 then
		print("[THROTTLE] Demasiadas recolecciones rápidas de " .. player.Name)
		return false
	end
	
	-- Agregar monedas validadas
	stats.coinsCollectedThisRound = stats.coinsCollectedThisRound + coinAmount
	stats.lastCollectionTime = currentTime
	stats.collectionEvents = stats.collectionEvents + 1
	
	-- Guardar en DataStore
	DataManager.AddCoins(userId, coinAmount)
	
	print("[CoinManager] " .. player.Name .. " recolectó " .. coinAmount .. " monedas")
	return true
end

-- Limpiar estadísticas cuando sale el jugador
game:GetService("Players").PlayerRemoving:Connect(function(player)
	coinCollectionStats[player.UserId] = nil
end)

-- Evento de recolección desde el cliente
CoinEvent.OnServerEvent:Connect(function(player, amount)
	CoinManager.CollectCoin(player, amount or GameConfig.COIN_PER_COLLECTION)
end)

print("[CoinManager] Sistema listo")

return CoinManager