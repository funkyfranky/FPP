-------------------------
-- FPP Practice Script --
-------------------------

-- Switches if you want to include a rescue helo and/or a recovery tanker.
local Stennis=false
local A2AD=false
local Range=true
local Warehouse=true
local Fox=true

-- No MOOSE settings menu.
_SETTINGS:SetPlayerMenuOff()

-- Active clients.
--local ClientSet = SET_CLIENT:New():FilterActive():FilterStart()

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zones
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local zone={}

zone.awacs=ZONE:New("Zone AWACS")  --Core.Zone#ZONE
zone.kutaisirange=ZONE_POLYGON:NewFromGroupName("Kutaisi Range Zone")  --Core.Zone#ZONE_POLYGON
zone.kobuletiXrange=ZONE:New("Zone Bombing Range Kobuleti X")  --Core.Zone#ZONE
zone.kobuletiXbombtarget=ZONE:New("Zone Bomb Target Kobuleti X")  --Core.Zone#ZONE
zone.SAMKrim=ZONE:New("Zone SAM Krim") --Core.Zone#ZONE
zone.SAMKrymsk=ZONE:New("Zone SAM Krymsk")  --Core.Zone#ZONE
zone.Maykop=ZONE:New("Zone Drone Maykop")   --Core.Zone#ZONE

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Practice Ranges
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Range then

  local range={}
  
  range.Kutaisi=RANGE:New("Kutaisi")  --Functional.Range#RANGE
  range.Kutaisi:SetRangeZone(zone.kutaisirange)
  range.Kutaisi:AddBombingTargetGroup(GROUP:FindByName("Kutaisi Unarmed Targets"), 50, true)
  --Range.Kutaisi:AddBombingTargets({"loco"})
  range.Kutaisi:Start()
  
  range.KobuletiX=RANGE:New("Kobuleti X")  --Functional.Range#RANGE
  range.KobuletiX:SetRangeZone(zone.kobuletiXrange)
  range.KobuletiX:AddBombingTargetCoordinate(zone.kobuletiXbombtarget:GetCoordinate(), "Kobuleti X Bombing Target", 50)
  range.KobuletiX:Start()

end

--[[

local KutaisiGroup=GROUP:FindByName("Kutaisi Unarmed Targets")
KutaisiGroup:HandleEvent(EVENTS.Dead)

local coord=KutaisiGroup:GetCoordinate()

--KutaisiGroup:GetUnit(1):Explode(5000, 60)

local loco=STATIC:FindByName("loco")
loco:GetCoordinate():Explosion(5000,60)

function KutaisiGroup:OnEventDead(EventData)
  env.info(string.format("FF Unit count = %d", self:CountAliveUnits()))
  
  local nalive=self:CountAliveUnits()
  
  if nalive==0 then
    self:InitCoordinate(coord)
    self:Respawn()
    self:PatrolZones({Range.Kutaisi.rangezone}, self:GetSpeedMax()*0.1)
  else
    local u=self:GetFirstUnitAlive()
    if u and u:IsAlive() then
      --u:Explode(5000, 60)
    end
  end
end
]]
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Warehouses
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Warehouse then

  local warehouse={}
  
  warehouse.kutaisi  = WAREHOUSE:New(STATIC:FindByName("Warehouse Kutaisi"))  --Functional.Warehouse#WAREHOUSE
  warehouse.kobuleti = WAREHOUSE:New(STATIC:FindByName("Warehouse Kobuleti")) --Functional.Warehouse#WAREHOUSE
  warehouse.tbilisi  = WAREHOUSE:New(STATIC:FindByName("Warehouse Tbilisi"))  --Functional.Warehouse#WAREHOUSE
  warehouse.maykop   = WAREHOUSE:New(STATIC:FindByName("Warehouse Maykop"))   --Functional.Warehouse#WAREHOUSE
  warehouse.skala    = WAREHOUSE:New(STATIC:FindByName("Skala Command Post")) --Functional.Warehouse#WAREHOUSE
  
  -- Start warehouses.
  for _,_warehouse in pairs(warehouse) do
    _warehouse:Start()
  end
  
  -------------
  -- Tbilisi --
  -------------
  
  warehouse.tbilisi:AddAsset("C-130", 99)
  warehouse.tbilisi:AddRequest(warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "C-130", 1, nil, nil, nil, "Transport")
  
  function warehouse.tbilisi:OnAfterAssetSpawned(From,Event,To,group,asset)
    self:__AddRequest(10*60,warehouse.kobuleti,WAREHOUSE.Descriptor.GROUPNAME, "C-130", 1, nil, nil, nil, "Transport")
  end

  --------------
  -- Kobuleti --
  --------------
  
  warehouse.kobuleti:AddAsset("E-3A Group", 2)
  warehouse.kobuleti:AddRequest(warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "E-3A Group", 1, nil, nil, nil, "AWACS")
  
  function warehouse.kobuleti:OnAfterSelfRequest(From,Event,To,groupset,request)
    
    local assignment=self:GetAssignment(request)
    
    if assignment=="AWACS" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        local speed=UTILS.KnotsToMps(300)
        local altitude=UTILS.FeetToMeters(20000)
        
        local c1=zone.awacs:GetCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE
        local c2=c1:Translate(UTILS.NMToMeters(50), 310):SetAltitude(altitude)
        
        local taskAWACS=group:EnRouteTaskAWACS()
        local taskOrbit=group:TaskOrbit(c1, altitude, speed,c2)
        
        local wp={}
        wp[1]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
        wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed),{taskAWACS, taskOrbit}, "AWACS")
        
        group:StartUncontrolled()
        group:CommandEPLRS(true, 1)
        group:OptionROTNoReaction()
        group:Route(wp)
      end
    end
  end
  
  ------------
  -- Maykop --
  ------------
  
  warehouse.maykop:AddAsset("MiG-21 Group", 50)
  warehouse.maykop:AddAsset("MiG-19 Group", 50)
  
  for i=1,10 do
    warehouse.maykop:__AddRequest((i-1)*30, warehouse.maykop, WAREHOUSE.Descriptor.GROUPNAME, "MiG-21 Group", 1, nil, nil, nil, "Drone")
  end
  
  function warehouse.maykop:OnAfterSelfRequest(From,Event,To,groupset,request)
    
    local assignment=self:GetAssignment(request)
    
    if assignment=="Drone" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        local speed=UTILS.KnotsToMps(300)
        local altitude=UTILS.FeetToMeters(10000)
        
        local c1=zone.Maykop:GetRandomCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE
        local c2=c1:Translate(UTILS.NMToMeters(10), 180):SetAltitude(altitude)
                
        local taskOrbit=group:TaskOrbit(c1, altitude, speed,c2)
        
        local wp={}
        wp[1]=warehouse.maykop:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
        wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed),{taskOrbit}, "Orbit")
        
        group:StartUncontrolled()
        group:OptionROEHoldFire()
        group:OptionROTNoReaction()
        group:Route(wp)
      end
    end
  end
  
  
  --- Function called when all assets of a request were delivered.
  function warehouse.maykop:OnAfterDelivered(From,Event,To,request)
    local assignment=self:GetAssignment(request)
    
    -- Spawn new drone if one returned, e.g. because out of fuel.
    if assignment=="Drone" then
      warehouse.maykop:AddRequest(warehouse.maykop, WAREHOUSE.Descriptor.GROUPNAME, asset.templatename, 1, nil, nil, nil, "Drone")
    end
  
  end
  
  --- Function called when an asset group is dead.
  function warehouse.maykop:OnAfterAssetDead(From,Event,To,_asset,_request)
    local asset=_asset     --Functional.Warehouse#WAREHOUSE.Assetitem
    local request=_request --Functional.Warehouse#WAREHOUSE.Queueitem
    
    -- Spawn new drone if one was shot down.
    if request.assignment=="Drone" then
      warehouse.maykop:AddRequest(warehouse.maykop, WAREHOUSE.Descriptor.GROUPNAME, asset.templatename, 1, nil, nil, nil, "Drone")
    end
  end
  
  function warehouse.maykop:OnAfterAssetSpawned(From,Event,To,_group,_asset)
    local group=_group --Wrapper.Group#GROUP
    group:GetUnit(1):Explode(500, 5*60)
  end
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Missile Trainer
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Fox missile trainer.
if Fox then
  fox=FOX:New()
  fox:AddSafeZone(zone.SAMKrim)
  fox:AddSafeZone(zone.SAMKrymsk)
  fox:Start()
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Airboss USS Stennis
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Stennis then

  -- Set mission menu.
  AIRBOSS.MenuF10Root=MENU_MISSION:New("Airboss").MenuPath
  
  -- S-3B Recovery Tanker spawning in air.
  local tanker=RECOVERYTANKER:New("USS Stennis", "S-3B Tanker Group")
  tanker:SetTakeoffAir()
  tanker:SetRadio(250)
  tanker:SetModex(511)
  tanker:SetTACAN(1, "TKR")
  tanker:Start()
  
  -- E-2D AWACS spawning in air
  local awacs=RECOVERYTANKER:New("USS Stennis", "E-2D Group")
  awacs:SetAWACS()
  awacs:SetRadio(260)
  awacs:SetAltitude(20000)
  awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
  awacs:SetRacetrackDistances(30, 15)
  awacs:SetModex(611)
  awacs:SetTACAN(2, "WIZ")
  awacs:__Start(1)
  
  -- Rescue Helo spawned in air with home base USS Perry.
  -- Has to be a global object!
  rescuehelo=RESCUEHELO:New("USS Stennis", "Rescue Helo Group")
  rescuehelo:SetHomeBase(AIRBASE:FindByName("USS Ford"))
  rescuehelo:SetTakeoffAir()
  rescuehelo:SetModex(42)
  rescuehelo:Start()
    
  -- Create AIRBOSS object.
  local AirbossStennis=AIRBOSS:New("USS Stennis")
  
  -- Add recovery windows:
  -- Case I from 9 to 10 am.
  local window1=AirbossStennis:AddRecoveryWindow( "6:35", "10:00", 1, nil, true, 25)
  -- Case II with +15 degrees holding offset from 15:00 for 60 min.
  local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  15, true, 23)
  -- Case III with +30 degrees holding offset from 2100 to 2200.
  local window3=AirbossStennis:AddRecoveryWindow("21:00", "22:00", 3,  30, true, 21)
  
  -- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
  AirbossStennis:Load()
  
  -- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
  AirbossStennis:SetAutoSave()
  
  AirbossStennis:SetRadioRelayLSO(rescuehelo:GetUnitName())
  AirbossStennis:SetRadioRelayMarshal("Huey Radio Relay")
  
  -- Set folder of airboss sound files within miz file.
  AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
  
  -- AI groups explicitly excluded from handling by the Airboss
  local CarrierExcludeSet=SET_GROUP:New():FilterPrefixes("E-2D Group"):FilterStart()
  AirbossStennis:SetExcludeAI(CarrierExcludeSet)
  
  -- Enable trap sheet.
  AirbossStennis:SetTrapSheet()
   
  -- Single carrier menu optimization.
  AirbossStennis:SetMenuSingleCarrier()
  
  -- Remove landed AI planes from flight deck.
  AirbossStennis:SetDespawnOnEngineShutdown()
  
    -- Set recovery tanker.
  AirbossStennis:SetRecoveryTanker(tanker)
  
  -- Start airboss class.
  AirbossStennis:Start()
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A2A Dispatcher
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if A2AD then

  -- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
  -- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
  DetectionSetGroup=SET_GROUP:New()
  DetectionSetGroup:FilterPrefixes({"DF CCCP AWACS", "DF CCCP EWR"})
  DetectionSetGroup:FilterStart()
  
  Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )
  
  -- Setup the A2A dispatcher, and initialize it.
  A2ADispatcher=AI_A2A_DISPATCHER:New(Detection)
  
  -- Enable the tactical display panel.
  A2ADispatcher:SetTacticalDisplay(false)
  
  -- Initialize the dispatcher, setting up a border zone. This is a polygon, 
  -- which takes the waypoints of a late activated group with the name CCCP Border as the boundaries of the border area.
  -- Any enemy crossing this border will be engaged.
  CCCPBorderZone = ZONE_POLYGON:New("CCCP Border", GROUP:FindByName("CCCP Border"))
  A2ADispatcher:SetBorderZone(CCCPBorderZone)
  
  -- Initialize the dispatcher, setting up a radius of 100km where any airborne friendly without an assignment within 100km radius from a detected target, will engage that target.
  A2ADispatcher:SetEngageRadius(120000)
  
  -- Setup the squadrons.
  A2ADispatcher:SetSquadron("Mineralnye", AIRBASE.Caucasus.Mineralnye_Vody, {"SQ CCCP SU-27", "SQ CCCP SU-33", "SQ CCCP MIG-23MLD", "SQ CCCP MIG-25PD" }, 16)
  A2ADispatcher:SetSquadron("Mozdok", AIRBASE.Caucasus.Mozdok, {"SQ CCCP MIG-31"}, 16)
  
  -- Setup the overhead
  A2ADispatcher:SetSquadronOverhead("Mineralnye", 1.2)
  A2ADispatcher:SetSquadronOverhead("Mozdok", 1)
  
  -- Setup the Grouping
  A2ADispatcher:SetSquadronGrouping("Mineralnye", 2)
  A2ADispatcher:SetSquadronGrouping("Mozdok", 2)
  
  -- Setup the Takeoff methods
  A2ADispatcher:SetSquadronTakeoff("Mineralnye", AI_A2A_DISPATCHER.Takeoff.Hot)
  A2ADispatcher:SetSquadronTakeoffFromRunway("Mozdok")
  
  -- Setup the Landing methods
  A2ADispatcher:SetSquadronLandingAtRunway("Mineralnye")
  A2ADispatcher:SetSquadronLandingAtEngineShutdown("Mozdok")
  
  -- CAP Squadron execution.
  CAPZoneEast = ZONE_POLYGON:New("CAP Zone East", GROUP:FindByName( "CAP Zone East" ))
  A2ADispatcher:SetSquadronCap("Mineralnye", CAPZoneEast, 6000, 12000, 500, 600, 800, 1100, "BARO")
  A2ADispatcher:SetSquadronCapInterval("Mineralnye", 3, 180, 360, 1)
  
  CAPZoneWest = ZONE_POLYGON:New("CAP Zone West", GROUP:FindByName("CAP Zone West"))
  A2ADispatcher:SetSquadronCap("Mozdok", CAPZoneWest, 6000, 12000, 600, 800, 800, 1200, "BARO")
  A2ADispatcher:SetSquadronCapInterval("Mozdok", 3, 180, 360, 1)
  
  -- GCI Squadron execution.
  A2ADispatcher:SetSquadronGci("Mineralnye", 900, 1200)
  A2ADispatcher:SetSquadronGci("Mozdok", 900, 1200)
  
  -- Set the squadrons visible before startup.
  --A2ADispatcher:SetSquadronVisible("Mineralnye")
  --A2ADispatcher:SetSquadronVisible("Mozdok")

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- General event handler.
local eventhandler=EVENTHANDLER:New()

-- Dead events.
eventhandler:HandleEvent(EVENTS.Dead)


function eventhandler:OnEventDead(EventData)
  EventData=EventData --Core.Event#EVENTDATA
  
  env.info(string.format("FF Event dead for %s", tostring(EventData.IniUnitName)))
  if EventData.IniUnitName=="loco" then
    loco:ReSpawn(nil, 60)
  end
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------