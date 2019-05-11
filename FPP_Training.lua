-------------------------
-- FPP Practice Script --
-------------------------

-- Switches if you want to include a rescue helo and/or a recovery tanker.
local Traffic=false
local Stennis=false

-- No MOOSE settings menu.
_SETTINGS:SetPlayerMenuOff()

-- Active clients.
local ClientSet = SET_CLIENT:New():FilterActive():FilterStart()

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Practice Ranges
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Range={}

Range.Kutaisi=RANGE:New("Kutaisi")  --Functional.Range#RANGE
Range.Kutaisi:SetRangeZone(ZONE_POLYGON:NewFromGroupName("Kutaisi Range Zone"))
Range.Kutaisi:AddBombingTargetGroup(GROUP:FindByName("Kutaisi Unarmed Targets"), 50, true)
Range.Kutaisi:AddBombingTargets({"loco"})
Range.Kutaisi:Start()

local KutaisiGroup=GROUP:FindByName("Kutaisi Unarmed Targets")
KutaisiGroup:HandleEvent(EVENTS.Dead)

local coord=KutaisiGroup:GetCoordinate()

--KutaisiGroup:GetUnit(1):Explode(5000, 60)

local loco=STATIC:FindByName("loco")
loco:GetCoordinate():Explosion(5000,60)


local eventhandler=EVENTHANDLER:New()
eventhandler:HandleEvent(EVENTS.Dead)
function eventhandler:OnEventDead(EventData)
  EventData=EventData --Core.Event#EVENTDATA
  env.info(string.format("FF Event dead for %s", tostring(EventData.IniUnitName)))
  if EventData.IniUnitName=="loco" then
    loco:ReSpawn(nil, 60)
  end
end

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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zones
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local zone={}

zone.awacs=ZONE:New("Zone AWACS")  --Core.Zone#ZONE

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Warehouses
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local warehouse={}

warehouse.kutaisi=WAREHOUSE:New(STATIC:FindByName("Warehouse Kutaisi")) --Functional.Warehouse#WAREHOUSE
warehouse.kobuleti=WAREHOUSE:New(STATIC:FindByName("Warehouse Kobuleti")) --Functional.Warehouse#WAREHOUSE

for _,_warehouse in pairs(warehouse) do
  _warehouse:Start()
end


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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Missile Trainer
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Fox2 missile trainer.
local fox2=FOX2:New()
fox2:Start()

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
  
  --- Function called when recovery starts.
  function AirbossStennis:OnAfterRecoveryStart(Event, From, To, Case, Offset)
    env.info(string.format("Starting Recovery Case %d ops.", Case))
  end
  
end

-- Spawn some AI flights as additional traffic.
if Traffic then
  local F181=SPAWN:New("FA-18C Group 1"):InitModex(111) -- Coming in from NW after  ~6 min
  local F182=SPAWN:New("FA-18C Group 2"):InitModex(112) -- Coming in from NW after ~20 min
  local F183=SPAWN:New("FA-18C Group 3"):InitModex(113) -- Coming in from W  after ~18 min
  local F14=SPAWN:New("F-14B 2ship"):InitModex(211)   -- Coming in from SW after  ~4 min
  local E2D=SPAWN:New("E-2D Group"):InitModex(311)    -- Coming in from NE after ~10 min
  local S3B=SPAWN:New("S-3B Group"):InitModex(411)    -- Coming in from S  after ~16 min
  
  -- Spawn always 9 min before the recovery window opens.
  local spawntimes={"8:51", "14:51", "20:51"}
  for _,spawntime in pairs(spawntimes) do
    local _time=UTILS.ClockToSeconds(spawntime)-timer.getAbsTime()
    if _time>0 then
      SCHEDULER:New(nil, F181.Spawn, {F181}, _time)
      SCHEDULER:New(nil, F182.Spawn, {F182}, _time)
      SCHEDULER:New(nil, F183.Spawn, {F183}, _time)
      SCHEDULER:New(nil, F14.Spawn,  {F14},  _time)
      SCHEDULER:New(nil, E2D.Spawn,  {E2D},  _time)
      SCHEDULER:New(nil, S3B.Spawn,  {S3B},  _time)
    end
  end  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A2A Dispatcher
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
