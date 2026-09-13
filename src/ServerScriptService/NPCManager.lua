--[[
	NPCManager.lua
	🎮 UBICACIÓN EN ROBLOX: ServerScriptService > NPCManager
	Gestiona NPCs y sus diálogos
]]

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameConfig"))

local NPCManager = {}
local npcDialogues = {}

-- Diálogos disponibles
local DIALOGUES = {
	Guardian = {
		"Bienvenido al mundo. Debes explorar y encontrar monedas.",
		"Las misiones te darán recompensas valiosas.",
		"¡Prepárate! El mundo se reinicia en 5 minutos.",
		"Los secretos están escondidos en las sombras.",
	},
	Merchant = {
		"¡Hola! ¿Deseas comprar algo en mi tienda?",
		"Tengo cosmético exclusivo y poderosos efectos.",
		"La calidad tiene un precio, amigo.",
		"¿Has encontrado todas las monedas?",
	},
	Scholar = {
		"Te enseñaré los secretos de este mundo.",
		"El conocimiento es poder. Escúchame bien.",
		"He visto cosas increíbles en 100 rondas.",
		"¿Quieres saber dónde están las zonas secretas?",
	},
}

-- Obtener diálogo de NPC
function NPCManager.GetDialogue(npcName)
	if DIALOGUES[npcName] then
		local dialogues = DIALOGUES[npcName]
		return dialogues[math.random(1, #dialogues)]
	end
	return "..."
end

-- Crear NPC en el mundo
function NPCManager.SpawnNPC(name, position)
	local npcSpawner = workspace:FindFirstChild("NPCSpawner")
	if not npcSpawner then
		print("[NPCManager] NPCSpawner no encontrado")
		return nil
	end
	
	-- Crear modelo de NPC
	local npc = Instance.new("Model")
	npc.Name = name
	
	-- Crear humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = npc
	
	-- Crear rootpart
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Shape = Enum.PartType.Ball
	rootPart.Size = Vector3.new(2, 2, 2)
	rootPart.CanCollide = true
	rootPart.CFrame = CFrame.new(position)
	rootPart.Parent = npc
	
	-- Crear cabeza
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1, 1, 1)
	head.Color = Color3.fromRGB(255, 200, 150)
	head.Parent = npc
	
	-- Conectar cabeza al rootpart
	local neck = Instance.new("Motor6D")
	neck.Name = "Neck"
	neck.Part0 = rootPart
	neck.Part1 = head
	neck.C0 = CFrame.new(0, 1, 0)
	neck.Parent = head
	
	-- Crear humanoidrootpart connection
	humanoid.Parent = npc
	rootPart.TopSurface = Enum.SurfaceType.Smooth
	rootPart.BottomSurface = Enum.SurfaceType.Smooth
	
	npc.Parent = npcSpawner
	
	-- Agregar script de interacción
	local touchConnection
	touchConnection = rootPart.Touched:Connect(function(hit)
		local humanoidHit = hit.Parent:FindFirstChild("Humanoid")
		if humanoidHit then
			local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
			if player then
				local dialogue = NPCManager.GetDialogue(name)
				print("[NPC] " .. name .. " dice: " .. dialogue)
				
				-- Enviar diálogo al cliente
				local ChatEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("ChatEvent")
				if ChatEvent then
					ChatEvent:FireClient(player, name, dialogue)
				end
			end
		end
	end)
	
	npcDialogues[name] = {
		model = npc,
		position = position,
		connection = touchConnection,
	}
	
	return npc
end

-- Limpiar NPCs
function NPCManager.ClearNPCs()
	for name, npcData in pairs(npcDialogues) do
		if npcData.connection then
			npcData.connection:Disconnect()
		end
		if npcData.model and npcData.model.Parent then
			npcData.model:Destroy()
		end
	end
	npcDialogues = {}
end

print("[NPCManager] Sistema listo")

return NPCManager