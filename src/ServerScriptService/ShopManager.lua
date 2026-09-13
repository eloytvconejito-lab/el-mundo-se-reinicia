--[[
	ShopManager.lua
	🎮 UBICACIÓN EN ROBLOX: ServerScriptService > ShopManager
	Gestiona compras de tienda y cosmético
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))
local DataManager = require(game:GetService("ServerScriptService"):WaitForChild("DataManager"))

local ShopManager = {}
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

-- Obtener todos los items de la tienda
function ShopManager.GetShopItems()
	return GameConfig.SHOP_ITEMS
end

-- Obtener item específico
function ShopManager.GetShopItem(itemId)
	for _, item in ipairs(GameConfig.SHOP_ITEMS) do
		if item.id == itemId then
			return item
		end
	end
	return nil
end

-- Comprar item de la tienda
function ShopManager.BuyItem(player, itemId)
	if not player or not player.Parent then
		return false
	end
	
	local item = ShopManager.GetShopItem(itemId)
	if not item then
		print("[ShopManager] Item no válido: " .. tostring(itemId))
		return false
	end
	
	local success = DataManager.BuyShopItem(player.UserId, itemId)
	
	if success then
		print("[ShopManager] " .. player.Name .. " compró: " .. item.name)
		
		-- Notificar al cliente
		local ShopEvent = Remotes:FindFirstChild("ShopEvent")
		if ShopEvent then
			ShopEvent:FireClient(player, "PURCHASE_SUCCESS", itemId)
		end
	
		return true
	else
		print("[ShopManager] Compra fallida para " .. player.Name .. " - Item: " .. item.name)
		
		local ShopEvent = Remotes:FindFirstChild("ShopEvent")
		if ShopEvent then
			ShopEvent:FireClient(player, "PURCHASE_FAILED", itemId)
		end
	
		return false
	end
end

-- Equipar item cosmético
function ShopManager.EquipItem(player, itemId, itemType)
	if not player or not player.Parent then
		return false
	end
	
	local playerData = DataManager.GetPlayerData(player.UserId)
	if not playerData then
		return false
	end
	
	-- Verificar que el jugador tiene el item
	if not playerData.shopItems[itemId] then
		return false
	end
	
	-- Equipar según tipo
	if itemType == "skin" then
		playerData.equippedSkin = itemId
	elseif itemType == "effect" then
		playerData.equippedEffect = itemId
	else
		return false
	end
	
	DataManager.SavePlayerData(player.UserId, playerData)
	print("[ShopManager] " .. player.Name .. " equipó item: " .. itemId)
	
	return true
end

print("[ShopManager] Sistema listo")

return ShopManager