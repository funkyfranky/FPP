-------------------------
-- FPP Practice Script --
-- v0.6 by funkyfranky --
-------------------------

-- Enable/disable modules.
local Stennis=true
local A2AD=true
local Range=true
local Warehouse=true
local Fox=true
local RadioComms=true
local Scoring=false

-- No MOOSE settings menu.
_SETTINGS:SetPlayerMenuOff()

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zones
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local zone={}

zone.awacs=ZONE:New("Zone AWACS") --Core.Zone#ZONE
zone.tanker=ZONE:New("Zone Tanker") --Core.Zone#ZONE
zone.kutaisirange=ZONE_POLYGON:NewFromGroupName("Kutaisi Range Zone") --Core.Zone#ZONE_POLYGON
zone.kutaisiTechCombine=ZONE:New("Zone Kutaisi Range Tech Combine") --Core.Zone#ZONE
zone.kobuletiXrange=ZONE:New("Zone Bombing Range Kobuleti X") --Core.Zone#ZONE
zone.kobuletiXbombtarget=ZONE:New("Zone Bomb Target Kobuleti X") --Core.Zone#ZONE
zone.SAMKrim=ZONE:New("Zone SAM Krim") --Core.Zone#ZONE
zone.SAMKrymsk=ZONE:New("Zone SAM Krymsk") --Core.Zone#ZONE
zone.Maykop=ZONE:New("Zone Drone Maykop") --Core.Zone#ZONE
zone.Skala=ZONE:New("Zone Skala FARP") --Core.Zone#ZONE
zone.CAPwest=ZONE_POLYGON:New("CAP Zone West", GROUP:FindByName("CAP Zone West")) --Core.Zone#ZONE_POLYGON
zone.CAPeast=ZONE_POLYGON:New("CAP Zone East", GROUP:FindByName("CAP Zone East")) --Core.Zone#ZONE_POLYGON
zone.CCCPboarder=ZONE_POLYGON:New("CCCP Border", GROUP:FindByName("CCCP Border")) --Core.Zone#ZONE_POLYGON

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RADIO COMMS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Instructor radio frequency 305.00 MHz.
local instructorfreq=305

-- Range control radio frequency 264.00 MHz.
local rangecontrolfreq=264

-- Path in the miz where the sound files are located. Mind the "/" at the end!
local path="Range Soundfiles/"

if RadioComms then
  
  -- Instructor radio on 305 MHz (AM is the default modulation but could be set via radio.modulation.FM as second parameter).
  InstructorRadio=RADIOQUEUE:New(instructorfreq)
  
  -- Transmission are broadcasted from bombing range location.
  InstructorRadio:SetSenderCoordinate(zone.kobuletiXrange:GetCoordinate())
  
  -- Set parameters of numbers.
  InstructorRadio:SetDigit("0", "BR-N0.ogg", 0.40, path)
  InstructorRadio:SetDigit("1", "BR-N1.ogg", 0.25, path)
  InstructorRadio:SetDigit("2", "BR-N2.ogg", 0.37, path)
  InstructorRadio:SetDigit("3", "BR-N3.ogg", 0.37, path)
  InstructorRadio:SetDigit("4", "BR-N4.ogg", 0.39, path)
  InstructorRadio:SetDigit("5", "BR-N5.ogg", 0.39, path)
  InstructorRadio:SetDigit("6", "BR-N6.ogg", 0.40, path)
  InstructorRadio:SetDigit("7", "BR-N7.ogg", 0.40, path)
  InstructorRadio:SetDigit("8", "BR-N8.ogg", 0.37, path)
  InstructorRadio:SetDigit("9", "BR-N9.ogg", 0.40, path)
  
  -- Start radio queue.
  InstructorRadio:Start()
  
  
  -- Range control on 264 MHz.
  RangeControl=RADIOQUEUE:New(rangecontrolfreq)
  
  -- Tranmission or broadcasted from bombing range location.
  RangeControl:SetSenderCoordinate(zone.kobuletiXrange:GetCoordinate())
  
  -- Set parameters of numbers.
  RangeControl:SetDigit("0", "BR-N0.ogg", 0.40, path)
  RangeControl:SetDigit("1", "BR-N1.ogg", 0.25, path)
  RangeControl:SetDigit("2", "BR-N2.ogg", 0.37, path)
  RangeControl:SetDigit("3", "BR-N3.ogg", 0.37, path)
  RangeControl:SetDigit("4", "BR-N4.ogg", 0.39, path)
  RangeControl:SetDigit("5", "BR-N5.ogg", 0.39, path)
  RangeControl:SetDigit("6", "BR-N6.ogg", 0.40, path)
  RangeControl:SetDigit("7", "BR-N7.ogg", 0.40, path)
  RangeControl:SetDigit("8", "BR-N8.ogg", 0.37, path)
  RangeControl:SetDigit("9", "BR-N9.ogg", 0.40, path)
  
  -- Start Radio queue.
  RangeControl:Start()
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Practice Ranges
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Range then

  -- Range Table.
  range={}
  
  range.Kutaisi=RANGE:New("Kutaisi")  --Functional.Range#RANGE
  range.Kutaisi:SetRangeZone(zone.kutaisirange)
  range.Kutaisi:AddBombingTargetGroup(GROUP:FindByName("Kutaisi Unarmed Targets"), 50, true)
  range.Kutaisi:AddBombingTargetCoordinate(zone.kutaisiTechCombine:GetCoordinate(), "Kutaisi Tech Combine", 50)
  range.Kutaisi:Start()
  
  range.KobuletiX=RANGE:New("Kobuleti X")  --Functional.Range#RANGE
  range.KobuletiX:SetRangeZone(zone.kobuletiXrange)
  range.KobuletiX:AddBombingTargetCoordinate(zone.kobuletiXbombtarget:GetCoordinate(), "Kobuleti X Bombing Target", 50)
  range.KobuletiX:Start()
  
  for _,_myrange in pairs(range) do
    local myrange=_myrange

    --- Function called on each bomb impact.
    function myrange:OnAfterImpact(From,Event,To,_result,_player)
      local result=_result --Functional.Range#RANGE.BombResult
      local player=_player --Functional.Range#RANGE.PlayerData
    
      -- Distance in feet.
      local distance=UTILS.MetersToFeet(result.distance)
      
      -- Radial in degrees.
      local radial=result.radial
      
      -- Text message to player only.
      local text=string.format("Impact %03d° for %d ft.", radial, distance)
      MESSAGE:New(text, 10):ToClient(player.client)
      
      -- Radio message.
      if RadioComms then
        RangeControl:NewTransmission("BR-Impact.ogg", 0.60, path)                  -- Duration of voice over is 0.60 sec.
        RangeControl:Number2Transmission(string.format("%03d", radial), nil, 0.2)  -- 0.2 sec interval to prev transmission.
        RangeControl:NewTransmission("BR-Degrees.ogg", 0.60, path)
        RangeControl:NewTransmission("BR-For.ogg", 0.75, path)
        RangeControl:Number2Transmission(string.format("%d", distance), nil, 0.2)  -- 0.2 sec interval to prev transmission.
        RangeControl:NewTransmission("BR-Feet.ogg", 0.35, path)
      end
      
    end
    
    --- Function called each time a player enters the bombing range zone.
    function myrange:OnAfterEnterRange(From, Event, To, _player)
      local player=_player --Functional.Range#RANGE.PlayerData
    
      -- Debug text message.
      local text=string.format("You should now hear a radio message on %.2f MHz that you entered the bombing range and switch to %.2f MHz.", instructorfreq, rangecontrolfreq)
      MESSAGE:New(text, 15, "Debug", false):ToClient(player.client)
        
      -- Range control radio frequency split.
      local RF=UTILS.Split(string.format("%.2f", rangecontrolfreq), ".")
      
      -- Radio message that player entered the range
      if RadioComms then
        InstructorRadio:NewTransmission("BR-Enter.ogg", 4.60, path)
        InstructorRadio:Number2Transmission(RF[1])
        InstructorRadio:NewTransmission("BR-Point.ogg", 0.33, path)
        InstructorRadio:Number2Transmission(RF[2])
      end
      
    end
    
    --- Function called each time a player exists the bombing range zone.
    function myrange:OnAfterExitRange(From, Event, To, _player)
      local player=_player --Functional.Range#RANGE.PlayerData
    
      -- Debug text message.
      local text=string.format("You should now hear a radio message on %.2f MHz that you left the bombing range.", rangecontrolfreq)
      MESSAGE:New(text, 15, "Debug", false):ToClient(player.client)
      
      -- Radio message player left.
      if RadioComms then
        RangeControl:NewTransmission("BR-Exit.ogg", 2.80, path)
      end
    
    end  
  
  end  

end

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
  warehouse.beslan   = WAREHOUSE:New(STATIC:FindByName("Warehouse Beslan"))   --Functional.Warehouse#WAREHOUSE
  warehouse.nalchik  = WAREHOUSE:New(STATIC:FindByName("Warehouse Nalchik"))  --Functional.Warehouse#WAREHOUSE
  
  -- Start warehouses.
  for _,_warehouse in pairs(warehouse) do
    local wh=_warehouse --Functional.Warehouse#WAREHOUSE
    wh:SetReportOff()
    wh:Start()    
  end
  
  -------------
  -- Tbilisi --
  -------------
  
  warehouse.tbilisi:AddAsset("C-130", 99)
  
  warehouse.tbilisi:AddRequest(warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "C-130", 1, nil, nil, nil, "Transport")
  
  function warehouse.tbilisi:OnAfterAssetSpawned(From,Event,To,group,asset)
    self:__AddRequest(30*60,warehouse.kobuleti,WAREHOUSE.Descriptor.GROUPNAME, "C-130", 1, nil, nil, nil, "Transport")
  end

  --------------
  -- Kobuleti --
  --------------

  -- Is it Arco's turn? If not, we use Shell.
  local arco=true
  
  local ArcoRTB=USERFLAG:New("Arco RTB")
  local ShellRTB=USERFLAG:New("Shell RTB")
  ArcoRTB:Set(1)
  ShellRTB:Set(1)

  --- Tanker setup.
  local function StartTanker(_group)
    local group=_group --Wrapper.Group#GROUP
    local speed=UTILS.KnotsToMps(350)
    local altitude=UTILS.FeetToMeters(25000)
    
    local c1=zone.tanker:GetCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE
    local c2=c1:Translate(UTILS.NMToMeters(50), 270):SetAltitude(altitude)
    
    -- 
    local tacanch=3
    local tacanmorse="SHL"
    local callsign=CALLSIGN.Tanker.Shell
    local tankerRTB="Shell RTB"
    if arco then
      tacanch=4
      tacanmorse="ACO"
      callsign=CALLSIGN.Tanker.Arco
      tankerRTB="Arco RTB"
      ArcoRTB:Set(1)
    else
      ShellRTB:Set(1)
    end
    
    -- Orbit in race track pattern.
    local TaskOrbit=group:TaskOrbit(c1, altitude, speed,c2)
    
    -- Orbit until flag=2
    local TaskCondition=group:TaskCondition(nil, tankerRTB, 2, nil, nil, nil)
    
    -- Controlled Task.
    local TaskControlled=group:TaskControlled(TaskOrbit, TaskCondition)
    
    -- Define waypoints.
    local wp={}
    wp[1]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
    wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed), {TaskControlled}, "Tanker")
    wp[3]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirLanding(UTILS.MpsToKmph(speed), warehouse.kobuleti:GetAirbase(),{}, "Landing Kobuleti")
    
    group:StartUncontrolled()
            
    local TaskRoute=group:TaskRoute(wp)
    local TaskTanker=group:EnRouteTaskTanker()
    local TaskCombo=group:TaskCombo({TaskTanker, TaskRoute})
    
    -- Create a new beacon and activate TACAN.
    local unit=group:GetUnit(1)
        
    -- Activate TACAN.
    local beacon=BEACON:New(unit)
    beacon:ActivateTACAN(tacanch, "Y", tacanmorse, true)
    group:CommandSetCallsign(callsign, 1, 1)
    
    -- Invert switch.
    arco=not arco
    
    group:OptionROTNoReaction()
    
    group:SetTask(TaskCombo, 1)
  end

  --- AWACS setup.
  local function StartAWACS(_group)
    local group=_group --Wrapper.Group#GROUP
    
    local speed=UTILS.KnotsToMps(300)
    local altitude=UTILS.FeetToMeters(20000)
    
    local c1=zone.awacs:GetCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE
    local c2=c1:Translate(UTILS.NMToMeters(50), 310):SetAltitude(altitude)
    
    -- Orbit in race track pattern.
    local TaskOrbit=group:TaskOrbit(c1, altitude, speed,c2)
    
    local wp={}
    wp[1]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
    wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed),{TaskOrbit}, "AWACS")
    
    group:StartUncontrolled()
            
    local TaskRoute=group:TaskRoute(wp)
    local TaskAWACS=group:EnRouteTaskAWACS()
    local TaskCombo=group:TaskCombo({TaskAWACS, TaskRoute})
    
    group:CommandSetCallsign(CALLSIGN.AWACS.Magic, 1, 1)
    group:OptionROTNoReaction()
    group:CommandEPLRS(true, 1)
    
    group:SetTask(TaskCombo, 1)  
  end
  
  -- Add assets.
  warehouse.kobuleti:AddAsset("E-3A Group", 2)
  warehouse.kobuleti:AddAsset("KC-135 Group", 2)
  
  -- Debug testing.
  --warehouse.kobuleti:SetLowFuelThreshold(0.95)

  
  -- Self request AWACS.
  warehouse.kobuleti:__AddRequest(10, warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "E-3A Group", 1, nil, nil, nil, "AWACS")
  
  -- Self request tanker.
  warehouse.kobuleti:__AddRequest(20, warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "KC-135 Group", 1, nil, nil, nil, "Tanker")
  
  --- Function called after self requests.
  function warehouse.kobuleti:OnAfterSelfRequest(From,Event,To,groupset,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem    
    local assignment=self:GetAssignment(request)
    
    if assignment=="AWACS" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        StartAWACS(group)
      end
    end
    
    if assignment=="Tanker" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        StartTanker(group)
      end
    end    
    
  end
  
  --- Function called when a group runs out of fuel.
  function warehouse.kobuleti:OnAfterAssetLowFuel(From,Event,To,asset,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem    
    local assignment=self:GetAssignment(request)
    
    -- Send a new tanker or AWACS once the other runs out of fuel.
    if assignment=="AWACS" or assignment=="Tanker" then
    
      if assignment=="AWACS" then
      
      elseif assignment=="Tanker" then
        if arco then
          -- Send Arco home.
          ArcoRTB:Set(2)
        else
          -- Send Shell home.
          ShellRTB:Set(2)
        end
      end
    
      -- Send new tanker.
      warehouse.kobuleti:AddRequest(warehouse.kobuleti, request.assetdesc, request.assetdescval, 1, nil, nil, nil, assignment)
    end
    
  end
    
  ------------
  -- Beslan --
  ------------
  
  warehouse.beslan:AddAsset("Mi-8 Group", 50)
  
  warehouse.beslan:__AddRequest(60, warehouse.skala, WAREHOUSE.Descriptor.GROUPNAME, "Mi-8 Group", 1, nil, nil, nil, "Ferry Flight")


  --- Function called when all assets of a request were delivered.
  function warehouse.beslan:OnAfterDelivered(From,Event,To,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem
    local assignment=self:GetAssignment(request)
    
    -- Spawn new drone if one returned, e.g. because out of fuel.
    if assignment=="Ferry Flight" then
      self:AddRequest(warehouse.skala, request.assetdesc, request.assetdescval, 1, nil, nil, nil, assignment)
    end
  end
  
  -------------
  -- Nalchik --
  -------------
  
  warehouse.nalchik:AddAsset("UAZ-469 Group", 50)
  
  warehouse.nalchik:__AddRequest(10, warehouse.skala, WAREHOUSE.Descriptor.GROUPNAME, "UAZ-469 Group", 1, nil, nil, nil, "Traffic")


  --- Function called when all assets of a request were delivered.
  function warehouse.nalchik:OnAfterDelivered(From,Event,To,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem
    local assignment=self:GetAssignment(request)
    
    -- Spawn new drone if one returned, e.g. because out of fuel.
    if assignment=="Traffic" then
      self:AddRequest(warehouse.skala, request.assetdesc, request.assetdescval, 1, nil, nil, nil, assignment)
    end
  end    
  
  ------------
  -- Maykop --
  ------------
  
  local drones={"MiG-21 Group", "MiG-19 Group"}
  
  for _,drone in pairs(drones) do
    warehouse.maykop:AddAsset(drone, 50)
  end
  
  
  for i=1,10 do
    local r=math.random(2)
    local drone=drones[r]
    warehouse.maykop:__AddRequest((i-1)*30, warehouse.maykop, WAREHOUSE.Descriptor.GROUPNAME, drone, 1, nil, nil, nil, "Drone")
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
        wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed), {taskOrbit}, "Orbit")
        
        group:StartUncontrolled()
        
        -- Drone: Hold fire and dont react to threats!
        group:OptionROEHoldFire()
        group:OptionROTNoReaction()
        
        group:Route(wp)
      end
    end
  end
  
  
  --- Function called when all assets of a request were delivered.
  function warehouse.maykop:OnAfterDelivered(From,Event,To,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem
    local assignment=self:GetAssignment(request)
    
    -- Spawn new drone if one returned, e.g. because out of fuel.
    if assignment=="Drone" then
      warehouse.maykop:AddRequest(warehouse.maykop, request.assetdesc, request.assetdescval, 1, nil, nil, nil, assignment)
    end
  
  end
  
  --- Function called when an asset group is dead.
  function warehouse.maykop:OnAfterAssetDead(From,Event,To,_asset,_request)
    local asset=_asset     --Functional.Warehouse#WAREHOUSE.Assetitem
    local request=_request --Functional.Warehouse#WAREHOUSE.Queueitem
    
    -- Spawn new drone if one was shot down.
    if request.assignment=="Drone" then
      warehouse.maykop:AddRequest(warehouse.maykop, request.assetdesc, request.assetdescval, 1, nil, nil, nil, request.assignment)
    end
  end
  
  function warehouse.maykop:OnAfterAssetSpawned(From,Event,To,_group,_asset)
    local group=_group --Wrapper.Group#GROUP
    --group:GetUnit(1):Explode(500, 5*60)
  end
  
  ----------------
  -- FARP Skala --
  ----------------
  
  -- Add assets.
  warehouse.skala:AddAsset("Infantry Rus Group 5", 20)
  warehouse.skala:AddAsset("SA-18 Manpad Group", 20)
  
  -- Spawn some infantry and manpads.
  warehouse.skala:AddRequest(warehouse.skala, WAREHOUSE.Descriptor.GROUPNAME, "Infantry Rus Group 5", 3, nil, nil, nil, "Patrol")
  warehouse.skala:AddRequest(warehouse.skala, WAREHOUSE.Descriptor.GROUPNAME, "SA-18 Manpad Group", 3, nil, nil, nil, "Patrol")
  
  
  function warehouse.skala:OnAfterSelfRequest(From,Event,To,groupset,request)
    
    local assignment=self:GetAssignment(request)
    
    if assignment=="Patrol" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        group:PatrolZones({zone.Skala}, group:GetSpeedMax()*0.5, "Custom")
      end
    end
  end  
  
  --local gaz66=STATIC:FindByName("Skala GAZ-66")
  --gaz66:GetCoordinate():Explosion(40, 10)
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Missile Trainer
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Fox missile trainer.
if Fox then
  -- Constructor. Better to make this global so that the garbage collector does not deallocate it.
  fox=FOX:New()
  
  -- Add training zones.
  fox:AddSafeZone(zone.SAMKrim)
  fox:AddSafeZone(zone.SAMKrymsk)
  
  -- Add launch zones.
  fox:AddLaunchZone(zone.SAMKrim)
  fox:AddLaunchZone(zone.SAMKrymsk)
  
  fox:AddProtectedGroup(GROUP:FindByName("A-10 Target"))
  
  -- Start trainer.
  fox:Start()
  
  function fox:OnAfterEnterSafeZone(From,Event,To,_player)
    local player=_player --Functional.Fox2#FOX.PlayerData
    MESSAGE:New("You just entered a missile training zone."):ToClient(player.client)
  end

  function fox:OnAfterExitSafeZone(From,Event,To,_player)
    local player=_player --Functional.Fox2#FOX.PlayerData
    MESSAGE:New("You just left a missile training zone."):ToClient(player.client)
  end
  
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
  tanker:SetModex(501)
  tanker:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
  tanker:SetTACAN(1, "TEX")
  tanker:Start()
  
  -- E-2D AWACS spawning in air
  local awacs=RECOVERYTANKER:New("USS Stennis", "E-2D Group")
  awacs:SetAWACS()
  awacs:SetRadio(260)
  awacs:SetAltitude(20000)
  awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
  awacs:SetRacetrackDistances(30, 15)
  awacs:SetModex(601)
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
  local window1=AirbossStennis:AddRecoveryWindow(  "7:30",  "8:30", 1, nil, true, 25)
  local window2=AirbossStennis:AddRecoveryWindow(  "9:30", "10:30", 1, nil, true, 25)
  local window3=AirbossStennis:AddRecoveryWindow( "11:30", "12:30", 1, nil, true, 25)
  local window3=AirbossStennis:AddRecoveryWindow( "13:30", "14:30", 1, nil, true, 25)
  local window3=AirbossStennis:AddRecoveryWindow( "15:30", "16:30", 1, nil, true, 25)
  local window3=AirbossStennis:AddRecoveryWindow( "17:30", "18:30", 1, nil, true, 25)
  local window3=AirbossStennis:AddRecoveryWindow( "19:30", "20:30", 1, nil, true, 25)
  -- Case III with +30 degrees holding offset from 21:30 to 7:30 next day.
  local window3=AirbossStennis:AddRecoveryWindow("21:30", "7:30:00+1", 3, 30, true, 25)
  
  -- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
  AirbossStennis:Load(nil, "FPP-Greenieboard.csv")
  
  -- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
  AirbossStennis:SetAutoSave(nil, "FPP-Greenieboard.csv")
  
  AirbossStennis:SetRadioRelayLSO(rescuehelo:GetUnitName())
  AirbossStennis:SetRadioRelayMarshal("Huey Radio Relay")
  
  -- Set folder of airboss sound files within miz file.
  AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
  
  -- AI groups explicitly excluded from handling by the Airboss
  local CarrierExcludeSet=SET_GROUP:New():FilterPrefixes("E-2D Group"):FilterStart()
  AirbossStennis:SetExcludeAI(CarrierExcludeSet)
  
  -- Enable trap sheet.
  AirbossStennis:SetTrapSheet(nil, "FPP-Trapsheet")
   
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
  
  Detection = DETECTION_AREAS:New(DetectionSetGroup, 30000)
  
  -- Setup the A2A dispatcher, and initialize it.
  A2ADispatcher=AI_A2A_DISPATCHER:New(Detection)
  
  -- Enable the tactical display panel.
  A2ADispatcher:SetTacticalDisplay(false)
  
  -- Initialize the dispatcher, setting up a border zone. Any enemy crossing this border will be engaged.  
  A2ADispatcher:SetBorderZone(zone.CCCPboarder)
  
  -- Initialize the dispatcher, setting up a radius of 120 km where any airborne friendly without an assignment within 120 km radius from a detected target, will engage that target.
  A2ADispatcher:SetEngageRadius(120000)
  
  -- Setup the squadrons.
  --A2ADispatcher:SetSquadron("Mineralnye", AIRBASE.Caucasus.Mineralnye_Vody, {"SQ CCCP SU-27", "SQ CCCP MIG-23MLD", "SQ CCCP MIG-25PD" }, 16)
  A2ADispatcher:SetSquadron("Mineralnye", AIRBASE.Caucasus.Mineralnye_Vody, {"SQ CCCP SU-27"},  32)
  A2ADispatcher:SetSquadron("Mozdok",     AIRBASE.Caucasus.Mozdok,          {"SQ CCCP MIG-31"}, 32)
  
  -- Setup the overhead
  A2ADispatcher:SetSquadronOverhead("Mineralnye", 1.0)
  A2ADispatcher:SetSquadronOverhead("Mozdok", 1.0)
  
  -- Setup the Grouping.
  A2ADispatcher:SetSquadronGrouping("Mineralnye", 2)
  A2ADispatcher:SetSquadronGrouping("Mozdok", 2)
  
  -- Setup the Takeoff methods.
  A2ADispatcher:SetSquadronTakeoff("Mineralnye", AI_A2A_DISPATCHER.Takeoff.Hot)
  A2ADispatcher:SetSquadronTakeoff("Mozdok",     AI_A2A_DISPATCHER.Takeoff.Hot)
  
  -- Setup the Landing methods.
  A2ADispatcher:SetSquadronLandingAtEngineShutdown("Mineralnye")
  A2ADispatcher:SetSquadronLandingAtEngineShutdown("Mozdok")
  
  -- CAP: Two groups patrolling zone CAP west.
  A2ADispatcher:SetSquadronCap("Mineralnye", zone.CAPwest, 6000, 12000, 500, 600, 800, 1100, "BARO")
  A2ADispatcher:SetSquadronCapInterval("Mineralnye", 2, 180, 360, 1)
  
  
  -- CAP: Two groups patrolling zone CAP east.
  A2ADispatcher:SetSquadronCap("Mozdok", zone.CAPeast, 6000, 12000, 600, 800, 800, 1200, "BARO")
  A2ADispatcher:SetSquadronCapInterval("Mozdok", 2, 180, 360, 1)
  
  -- GCI Squadron execution.
  A2ADispatcher:SetSquadronGci("Mineralnye", 900, 1200)
  A2ADispatcher:SetSquadronGci("Mozdok", 900, 1200)
  
  -- Set the squadrons visible before startup.
  --A2ADispatcher:SetSquadronVisible("Mineralnye")
  --A2ADispatcher:SetSquadronVisible("Mozdok")

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Scoring
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Scoring then

  local scoring=SCORING:New("FPP", "FPP-Scoring.csv")
  scoring:SetMessagesDestroy(false)
  scoring:SetMessagesHit(false)
  scoring:SetMessagesZone(false)
  
  --scoring:AddZoneScore(zone.kobuletiXrange, 100)
  --scoring:AddStaticScore(ScoreStatic,Score)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- General event handler.
eventhandler=EVENTHANDLER:New()

-- Dead events.
eventhandler:HandleEvent(EVENTS.Dead)

function eventhandler:OnEventDead(_EventData)
  local EventData=_EventData --Core.Event#EVENTDATA
  
  -- Name of the dead unit.
  local unitname=EventData.IniUnitName
  
  
  -- Debug
  env.info(string.format("FPP Event dead for %s", tostring(unitname)))
  
  -- Try to find a static by this name.
  local static=STATIC:FindByName(unitname, false)
  
  -- Check wheter a static or unit is dead.
  if static then
  
    -- Respawn all statics after 10 min. 
    static:ReSpawn(nil, 600)
        
  else
  
    -- Number of units in group still alive.
    local nalive=EventData.IniGroup:CountAliveUnits()
    
    -- Debug.
    env.info(string.format("FPP Units still alive %d", nalive))
  
    -- Respawn Fuel truck on Kobuleti Range after 5 min.
    if unitname=="Kobuleti X Range Fuel Truck" then
      BASE:ScheduleOnce(5*60, GROUP.Respawn, EventData.IniGroup)
    end
    
    -- Respawn SA-10 site after 10 min if one unit is dead.
    if EventData.IniGroupName=="SA-10" then
      BASE:ScheduleOnce(10*60, GROUP.Respawn, EventData.IniGroup)
    end
  
  end
    
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------