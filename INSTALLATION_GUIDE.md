# 📖 Guía Completa de Instalación

## Paso 1: Preparar Roblox Studio

1. Abre **Roblox Studio**
2. Haz clic en **Archivo → Nuevo**
3. Selecciona **Baseplate** o **Blankplate**
4. Guarda el juego con el nombre "El Mundo se Reinicia"

## Paso 2: Crear la Estructura de Carpetas

### En ReplicatedStorage:

1. Haz clic derecho en **ReplicatedStorage** → **Insertar Objeto** → **Carpeta**
   - Nombre: `Remotes`
2. Dentro de Remotes, crea:
   - RemoteEvent: `RoundTimer`
   - RemoteEvent: `MissionEvent`
   - RemoteEvent: `CoinEvent`
   - RemoteEvent: `ResetEvent`
   - RemoteEvent: `DataUpdateEvent`
   - RemoteEvent: `AchievementEvent`
   - RemoteEvent: `ChatEvent`

3. Crea otra carpeta: `Modules`
4. Dentro de Modules, crea ModuleScripts para cada archivo de módulo

### En ServerScriptService:

1. Crea Scripts para:
   - GameManager
   - WorldReset
   - MissionManager
   - CoinManager
   - DataManager
   - NPCManager
   - AchievementManager
   - ShopManager
   - AntiExploit

### En StarterGui:

1. Crea un ScreenGui: `MainGui`
2. Dentro, crea Frames y componentes según la estructura

### En StarterPlayer → StarterCharacterScripts:

1. Crea un LocalScript: `ClientController`

## Paso 3: Copiar los Scripts

Para cada archivo en este repositorio:

1. Copia el contenido del archivo Luau
2. Pega en el script correspondiente en Roblox Studio
3. Verifica que el nombre coincida con el archivo

## Paso 4: Crear Objetos en Workspace

### Crear Lobby:

1. En Workspace, crea una carpeta: `Lobby`
2. Dentro, crea Partes para:
   - Spawn point (tamaño 6x1x6)
   - Piso del lobby (tamaño 50x1x50)

### Crear Main Map:

1. Crea una carpeta: `MainMap`
2. Dentro, crea subcarpetas:
   - Buildings
   - Obstacles
   - CoinsSpawner
   - MissionLocations
   - SecretArea
   - FinalArea

### Crear Terrain:

1. Usa el Terrain Editor para crear el mapa
2. Añade pasto, agua, montañas, etc.

## Paso 5: Configurar NPCs

1. Descarga o crea un modelo humanoide
2. Colócalo en Workspace bajo `NPCSpawner`
3. Dale un nombre descriptivo (ej: "GuardianNPC")
4. Asegúrate que tenga un Humanoid

## Paso 6: Probar el Juego

1. Haz clic en **Jugar** (Play)
2. El juego debe:
   - Mostrar el lobby
   - Dejar entrar jugadores
   - Iniciar la ronda automáticamente
   - Mostrar el temporizador
   - Permitir completar misiones
   - Reiniciar después de 5 minutos

## Paso 7: Publicar el Juego

1. Haz clic en **Archivo → Publicar en Roblox**
2. Completa la información del juego
3. Elige si es privado o público
4. ¡Publicado!

## 🔧 Configuración Avanzada

### Cambiar Duración de Ronda

En GameConfig, modifica:
```lua
Round_DURATION = 300  -- 300 segundos = 5 minutos
```

### Cambiar Cantidad de Jugadores

En GameConfig:
```lua
MIN_PLAYERS = 1
MAX_PLAYERS = 20
```

### Ajustar Recompensas

En GameConfig:
```lua
COIN_PER_MISSION = 100
XP_PER_MISSION = 50
```

## 🐛 Solucionar Problemas

### El juego no inicia
- Verifica que todos los scripts estén en sus ubicaciones correctas
- Abre la Consola (Archivo → Herramientas del Desarrollador → Consola)
- Busca errores rojos

### Los jugadores no pueden unirse
- Verifica que haya al menos 1 espacio de spawn en Lobby/Spawn
- Asegúrate que SpawnLocation esté bien posicionado

### Las misiones no aparecen
- Verifica que MissionManager esté correctamente copiado
- Revisa la consola del servidor para errores

### DataStore no funciona
- En Studio, habilita DataStore: Archivo → Configuración de Lugar → Opciones → Enable Studio Access to API Services
- Marca la casilla de DataStore

## ✅ Checklist de Instalación

- [ ] ReplicatedStorage/Remotes creado con todas las RemoteEvents
- [ ] ReplicatedStorage/Modules creado con todos los ModuleScripts
- [ ] ServerScriptService tiene todos los Scripts
- [ ] StarterGui/MainGui creado con la UI
- [ ] StarterPlayer/StarterCharacterScripts/ClientController creado
- [ ] Workspace/Lobby creado con SpawnLocation
- [ ] Workspace/MainMap creado con estructura básica
- [ ] Todos los scripts copiados sin errores
- [ ] Prueba el juego en modo Play
- [ ] Verifica que aparezca el lobby

## 🎓 Próximos Pasos

1. **Personalización**: Modifica colores, fuentes y estilos en la UI
2. **Mapas**: Diseña mapas más complejos con Terrain
3. **Misiones**: Añade más tipos de misiones en MissionGenerator
4. **NPCs**: Crea más personajes con diálogos únicos
5. **Eventos**: Implementa eventos especiales semanales

---

**¿Necesitas ayuda?** Revisa el código comentado o consulta la documentación de Roblox en develop.roblox.com
