# El Mundo se Reinicia - Roblox Game

## 📖 Descripción del Juego

**El Mundo se Reinicia** es un juego multijugador de supervivencia/aventura donde el mundo se reinicia cada 5 minutos. Los jugadores mantienen su conocimiento y progresión permanente entre reinicios.

### Características Principales

✅ **Sistema de Rondas**: Cada ronda dura 5 minutos exactamente
✅ **Lobby Dinámico**: Matchmaking automático entre jugadores
✅ **Misiones Aleatorias**: Diferentes objetivos cada ronda
✅ **Mapas Procedurales**: Entorno cambia en cada reinicio
✅ **Sistema de Inventario**: Persiste entre rondas
✅ **Recompensas Diarias**: Bonificaciones por jugar regularmente
✅ **Sistema de Logros**: 25+ logros desbloqueables
✅ **Sistema de Niveles**: Progresión permanente
✅ **Tienda de Cosméticos**: Personalización con monedas
✅ **Efectos Visuales y Sonidos**: Ambiente inmersivo
✅ **NPCs con Diálogos**: Personajes interactivos
✅ **Zonas Secretas**: Áreas ocultas con recompensas especiales
✅ **Misiones Ocultas**: Desafíos adicionales
✅ **Finales Múltiples**: Múltiples caminos a la victoria
✅ **Anti-Exploit**: Validación servidor-lado completa
✅ **Optimización Multidispositivo**: PC, celular y tablet
✅ **DataStore Seguro**: Guardado persistente de datos

## 🎮 Cómo Usar Este Proyecto

### Instalación Rápida

1. Abre **Roblox Studio**
2. Crea un nuevo lugar
3. Copia y pega CADA script en su ubicación correcta (ver abajo)
4. Ejecuta el juego en modo de prueba
5. ¡Listo para jugar!

### Estructura de Carpetas en Roblox Studio

```
Workspace/
├── Lobby/
│   ├── Spawn (Part)
│   └── WaitingArea (Part)
├── MainMap/
│   ├── Terrain/
│   ├── Buildings/
│   ├── Obstacles/
│   ├── CoinsSpawner/
│   ├── MissionLocations/
│   ├── SecretArea/
│   └── FinalArea/
└── NPCSpawner/
    └── NPC (Humanoid Model)

ReplicatedStorage/
├── Remotes/
│   ├── RoundTimer (RemoteEvent)
│   ├── MissionEvent (RemoteEvent)
│   ├── CoinEvent (RemoteEvent)
│   ├── ResetEvent (RemoteEvent)
│   └── DataUpdateEvent (RemoteEvent)
├── Modules/
│   ├── GameConfig (ModuleScript)
│   ├── MissionGenerator (ModuleScript)
│   ├── MapGenerator (ModuleScript)
│   ├── RewardCalculator (ModuleScript)
│   └── AchievementManager (ModuleScript)
└── Assets/
    ├── Sounds/
    └── Particles/

ServerScriptService/
├── GameManager (Script)
├── WorldReset (Script)
├── MissionManager (Script)
├── CoinManager (Script)
├── DataManager (Script)
├── NPCManager (Script)
├── AchievementManager (Script)
├── ShopManager (Script)
└── AntiExploit (Script)

StarterGui/
└── MainGui (ScreenGui)
    ├── Lobby Screen (Frame)
    │   ├── JoinButton (TextButton)
    │   ├── PlayersLabel (TextLabel)
    │   └── StatusLabel (TextLabel)
    ├── InGame Screen (Frame)
    │   ├── TimerLabel (TextLabel)
    │   ├── MissionPanel (Frame)
    │   │   ├── MissionTitle (TextLabel)
    │   │   ├── MissionDescription (TextLabel)
    │   │   └── MissionProgress (Frame)
    │   ├── CoinsLabel (TextLabel)
    │   ├── InventoryButton (ImageButton)
    │   ├── ShopButton (ImageButton)
    │   ├── AchievementsButton (ImageButton)
    │   └── MiniMap (ImageLabel)
    └── EndRound Screen (Frame)
        ├── ResultsLabel (TextLabel)
        ├── RewardLabel (TextLabel)
        ├── NextRoundButton (TextButton)
        └── LeaderboardFrame (Frame)

StarterPlayer/
└── StarterCharacterScripts/
    └── ClientController (LocalScript)
```

## 🔧 Configuración

Todos los valores personalizables están en **GameConfig**:

```lua
local GameConfig = {
    -- Tiempos
    ROUND_DURATION = 300,
    LOBBY_WAIT_TIME = 30,
    RESET_FADE_TIME = 3,
    
    -- Jugadores
    MIN_PLAYERS = 1,
    MAX_PLAYERS = 20,
    
    -- Monedas
    COIN_PER_MISSION = 100,
    COIN_PER_COLLECTION = 10,
    
    -- Niveles
    XP_PER_MISSION = 50,
    XP_PER_KILL = 25,
}
```

## 🎯 Guía de Características

### Sistema de Misiones
Cada ronda genera 3 misiones aleatorias para cada jugador:
- **Colecciona**: Encuentra X monedas
- **Explora**: Visita X ubicaciones
- **Sobrevive**: Permanece vivo X minutos
- **Secreto**: Descubre la zona secreta

### Sistema de Recompensas
- Monedas al completar misiones
- XP para subir de nivel
- Bonificaciones de recompensas diarias
- Recompensas por logros desbloqueados

### Finales Múltiples
1. **Final Normal**: Completar 10 rondas
2. **Final Secreto**: Encontrar todas las zonas secretas
3. **Final Desafiante**: Completar misiones ocultas
4. **Final Legendario**: Desbloquear todos los logros

## 🛡️ Seguridad

Todo está validado en el servidor:
- Verificación de monedas
- Validación de misiones completadas
- Anti-teleport
- Anti-farm
- Rate limiting en eventos

## 📱 Optimización Multidispositivo

- UI responsiva con UDim2
- Controles táctiles para celular
- Botones grandes para facilitar navegación en tablet
- Rendimiento optimizado en todos los dispositivos

## 📊 Logros Disponibles

- 🏆 Primer Paso (Completar 1 ronda)
- 🏆 Superviviente (Completar 5 rondas)
- 🏆 Leyenda (Completar 25 rondas)
- 🏆 Coleccionista (Recolectar 100 monedas)
- 🏆 Explorador (Visitar todas las zonas)
- 🏆 Y muchos más...

## 🐛 Reportar Errores

Si encuentras algún bug, por favor reporta un issue en GitHub.

## 📄 Licencia

MIT License - Libre para usar y modificar

---

**Versión**: 1.0.0
**Última actualización**: 2026-09-13
**Creador**: eloytvconejito-lab
