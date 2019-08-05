---------------------------
-- FPP Practice Script   --
-- v0.9.6 by funkyfranky --
---------------------------

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

-- Restart after 4h.
local restart=4*60*60
local restarttimes={}
restarttimes["20 minutes"]=restart-20*60
restarttimes["10 minutes"]=restart-10*60
restarttimes["5 minutes"]=restart-5*60
restarttimes["1 minute"]=restart-1*60

local function RestartMessage(minutes)
  local text=string.format("Server is restarting in %s.", minutes)
  MESSAGE:New(text, 30, "INFO"):ToAll()
end

for minutes,rt in pairs(restarttimes) do
  BASE:ScheduleOnce(rt, RestartMessage, minutes)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zones
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Zone table.
local zone={}

zone.awacs=ZONE:New("Zone AWACS") --Core.Zone#ZONE
zone.tanker=ZONE:New("Zone Tanker") --Core.Zone#ZONE

-- Kobuleti range zones.
zone.KobuletiRange=ZONE:New("Zone Range Kobuleti") --Core.Zone#ZONE

zone.KobuletiRangeTargetX=ZONE:New("Zone Range Kobuleti Target X") --Core.Zone#ZONE
zone.KobuletiRangeTechCombine=ZONE:New("Zone Range Kobuleti Tech Combine") --Core.Zone#ZONE
zone.KobuletiRangeAmmoDepot=ZONE:New("Zone Range Kobuleti Ammo Depot") --Core.Zone#ZONE
zone.KobuletiRangeTrain=ZONE:New("Zone Range Kobuleti Train") --Core.Zone#ZONE

-- SAM zones.
zone.SAMKrim=ZONE:New("Zone SAM Krim") --Core.Zone#ZONE
zone.SAMKrymsk=ZONE:New("Zone SAM Krymsk") --Core.Zone#ZONE

-- A2A zone around Maykop
zone.Maykop=ZONE:New("Zone Drone Maykop") --Core.Zone#ZONE

-- FARP Skala.
zone.Skala=ZONE:New("Zone Skala FARP") --Core.Zone#ZONE
zone.SkalaSpawn=ZONE:New("Skala Spawn Zone") --Core.Zone#ZONE_POLYGON

-- Red capture zones.
zone.Mozdok=ZONE:New("Zone Mozdok")         --Core.Zone#ZONE
zone.Nalchik=ZONE:New("Zone Nalchik")       --Core.Zone#ZONE
zone.Beslan=ZONE:New("Zone Beslan")         --Core.Zone#ZONE
zone.Mineralnye=ZONE:New("Zone Mineralnye") --Core.Zone#ZONE

-- Red border and CAP zones.
zone.CAPwest    = ZONE_POLYGON:New("CAP Zone West",    GROUP:FindByName("CAP Zone West"))    --Core.Zone#ZONE_POLYGON
zone.CAPeast    = ZONE_POLYGON:New("CAP Zone East",    GROUP:FindByName("CAP Zone East"))    --Core.Zone#ZONE_POLYGON
zone.CAPbeslan  = ZONE_POLYGON:New("CAP Zone Beslan",  GROUP:FindByName("CAP Zone Beslan"))  --Core.Zone#ZONE_POLYGON
zone.CAPnalchik = ZONE_POLYGON:New("CAP Zone Nalchik", GROUP:FindByName("CAP Zone Nalchik")) --Core.Zone#ZONE_POLYGON
zone.CAPmozdok  = ZONE_POLYGON:New("CAP Zone Mozdok",  GROUP:FindByName("CAP Zone Mozdok"))  --Core.Zone#ZONE_POLYGON
zone.CCCPboarder= ZONE_POLYGON:New("CCCP Border",      GROUP:FindByName("CCCP Border"))      --Core.Zone#ZONE_POLYGON


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RADIO COMMS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Instructor radio frequency 305.00 MHz.
local instructorfreq=305

-- Kobuleti and Kutaisi range control radio frequencies.
local rangecontrolfreq={}
rangecontrolfreq.Kobuleti=254
rangecontrolfreq.Krymsk=256

-- Path in the miz where the sound files are located. Mind the "/" at the end!
local path="Range Soundfiles/"

if RadioComms then
  
  -- Instructor radio on 305 MHz (AM is the default modulation but could be set via radio.modulation.FM as second parameter).
  InstructorRadio=RADIOQUEUE:New(instructorfreq)
  
  -- Transmission are broadcasted from bombing range location.
  InstructorRadio:SetSenderCoordinate(zone.KobuletiRange:GetCoordinate())
  
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
  
  -- Range control.
  RangeControl={}
  
  -- Set frequency
  RangeControl.Kobuleti = RADIOQUEUE:New(rangecontrolfreq.Kobuleti) --Core.Beacon#RADIOQUEUE
  RangeControl.Krymsk   = RADIOQUEUE:New(rangecontrolfreq.Krymsk)   --Core.Beacon#RADIOQUEUE
  
  -- Tranmission or broadcasted from bombing range location.
  RangeControl.Kobuleti:SetSenderCoordinate(zone.KobuletiRange:GetCoordinate())
  RangeControl.Krymsk:SetSenderCoordinate(zone.SAMKrymsk:GetCoordinate())
  
  -- Set parameters of numbers.
  for _,_rangecontrol in pairs(RangeControl) do
    local rangecontrol=_rangecontrol --Core.Beacon#RADIOQUEUE
    rangecontrol:SetDigit("0", "BR-N0.ogg", 0.40, path)
    rangecontrol:SetDigit("1", "BR-N1.ogg", 0.25, path)
    rangecontrol:SetDigit("2", "BR-N2.ogg", 0.37, path)
    rangecontrol:SetDigit("3", "BR-N3.ogg", 0.37, path)
    rangecontrol:SetDigit("4", "BR-N4.ogg", 0.39, path)
    rangecontrol:SetDigit("5", "BR-N5.ogg", 0.39, path)
    rangecontrol:SetDigit("6", "BR-N6.ogg", 0.40, path)
    rangecontrol:SetDigit("7", "BR-N7.ogg", 0.40, path)
    rangecontrol:SetDigit("8", "BR-N8.ogg", 0.37, path)
    rangecontrol:SetDigit("9", "BR-N9.ogg", 0.40, path)
    
    -- Start Radio queue.
    rangecontrol:Start()
  end  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Practice Ranges
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Range Table.
range={}

-- Arty Table.
arty={}

if Range then
  
  range.Kobuleti=RANGE:New("Kobuleti")  --Functional.Range#RANGE
  range.Kobuleti:SetRangeZone(zone.KobuletiRange)
  range.Kobuleti:AddBombingTargetCoordinate(zone.KobuletiRangeTargetX:GetCoordinate(), "Target X", 50)
  range.Kobuleti:AddBombingTargetCoordinate(zone.KobuletiRangeTrain:GetCoordinate(), "Train", 50)
  range.Kobuleti:AddBombingTargetGroup(GROUP:FindByName("Kutaisi Unarmed Targets"), 50, true)
  range.Kobuleti:AddBombingTargetCoordinate(zone.KobuletiRangeTechCombine:GetCoordinate(), "Tech Combine", 50)
  range.Kobuleti:AddBombingTargetCoordinate(zone.KobuletiRangeAmmoDepot:GetCoordinate(), "Ammo Depot", 50)
  range.Kobuleti:AddBombingTargetGroup(GROUP:FindByName("Kobuleti Range Msta Group"), 50, false)

  range.Krymsk=RANGE:New("Krymsk")  --Functional.Range#RANGE
  range.Krymsk:SetRangeZone(zone.SAMKrymsk)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Range Krymsk Bunker #001"):GetCoordinate(), "Bunker #01", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Range Krymsk Bunker #002"):GetCoordinate(), "Bunker #02", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Krymsk Range Tu-22 #001"):GetCoordinate(), "Tu-22 #01", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Krymsk Range Tu-22 #002"):GetCoordinate(), "Tu-22 #02", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Krymsk Range Tu-22 #003"):GetCoordinate(), "Tu-22 #03", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Range Krymsk Locomotive #001"):GetCoordinate(), "Train", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Range Krymsk Tech Combine #001"):GetCoordinate(), "Tech Combine", 50)
  range.Krymsk:AddBombingTargetCoordinate(STATIC:FindByName("Range Krymsk Road Outpost #001"):GetCoordinate(), "Road Outpost", 50)
  
  
  -- Start ranges.
  for _,_myrange in pairs(range) do
    local myrange=_myrange --Functional.Range#RANGE
    myrange:SetDefaultPlayerSmokeBomb(false)
    myrange:SetAutosaveOn()
    myrange:Start()    
  end
  
  --- Init arty
  local group=GROUP:FindByName("Kobuleti Range Msta Group")
  local coord=group:GetCoordinate()
  
  arty.MstaKobuleti=ARTY:New(group) --Functional.Artillery#ARTY
  
  arty.MstaKobuleti:SetRespawnOnDeath(10*60)
  
  arty.MstaKobuleti:SetReportOFF()
  
  arty.MstaKobuleti:Start()
  
  local clock=UTILS.SecondsToClock(timer.getAbsTime()+60)
  
  -- Target coordinate 10 km south.
  local target=coord:Translate(10*1000, 180)
    
  arty.MstaKobuleti:AssignTargetCoord(target, 50, 5, 10, 1, clock)

  function arty.MstaKobuleti:OnAfterCeaseFire(Controllable,From,Event,To,Target)
    --local target=Target --Functional.Artillery#ARTY.Target
    local clock=UTILS.SecondsToClock(timer.getAbsTime()+5*60)
    arty.MstaKobuleti:AssignTargetCoord(target, 50, 500, 10, 1, clock)
  end
    
  
  for rangename,_myrange in pairs(range) do
    local myrange=_myrange  --Functional.Range#RANGE

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
      --MESSAGE:New(text, 10):ToClient(player.client)
      
      -- Radio message.
      if RadioComms then
        RangeControl[rangename]:NewTransmission("BR-Impact.ogg", 0.60, path)                  -- Duration of voice over is 0.60 sec.
        RangeControl[rangename]:Number2Transmission(string.format("%03d", radial), nil, 0.2)  -- 0.2 sec interval to prev transmission.
        RangeControl[rangename]:NewTransmission("BR-Degrees.ogg", 0.60, path)
        RangeControl[rangename]:NewTransmission("BR-For.ogg", 0.75, path)
        RangeControl[rangename]:Number2Transmission(string.format("%d", distance), nil, 0.2)  -- 0.2 sec interval to prev transmission.
        RangeControl[rangename]:NewTransmission("BR-Feet.ogg", 0.35, path)
      end
      
    end
    
    --- Function called each time a player enters the bombing range zone.
    function myrange:OnAfterEnterRange(From, Event, To, _player)
      local player=_player --Functional.Range#RANGE.PlayerData
    
      -- Debug text message.
      local text=string.format("You should now hear a radio message on %.2f MHz that you entered the bombing range and switch to %.2f MHz.", rangecontrolfreq[rangename], rangecontrolfreq[rangename])
      --MESSAGE:New(text, 15, "Debug", false):ToClient(player.client)
        
      -- Range control radio frequency split.
      local RF=UTILS.Split(string.format("%.2f", rangecontrolfreq[rangename]), ".")
      
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
      local text=string.format("You should now hear a radio message on %.2f MHz that you left the bombing range.", rangecontrolfreq[rangename])
      --MESSAGE:New(text, 15, "Debug", false):ToClient(player.client)
      
      -- Radio message player left.
      if RadioComms then
        RangeControl[rangename]:NewTransmission("BR-Exit.ogg", 2.80, path)
      end
    
    end  
  
  end  

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- "JTAC" Units lasing range targets
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local JTAC={}

JTAC.KobuletiRangeTrain=GROUP:FindByName("Kobuleti Range JTAC Train Group") --Wrapper.Group#GROUP

JTAC.KobuletiRangeTrain:LaseCoordinate(STATIC:FindByName("Kobuleti Range Loco Target"):GetCoordinate(), 1688)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Warehouses
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Warehouse table.
local warehouse={}

if Warehouse then
  
  warehouse.kutaisi     = WAREHOUSE:New(STATIC:FindByName("Warehouse Kutaisi"))        --Functional.Warehouse#WAREHOUSE
  warehouse.kobuleti    = WAREHOUSE:New(STATIC:FindByName("Warehouse Kobuleti"))       --Functional.Warehouse#WAREHOUSE
  warehouse.tbilisi     = WAREHOUSE:New(STATIC:FindByName("Warehouse Tbilisi"))        --Functional.Warehouse#WAREHOUSE
  warehouse.maykop      = WAREHOUSE:New(STATIC:FindByName("Warehouse Maykop"))         --Functional.Warehouse#WAREHOUSE
  warehouse.beslan      = WAREHOUSE:New(STATIC:FindByName("Warehouse Beslan"))         --Functional.Warehouse#WAREHOUSE
  warehouse.nalchik     = WAREHOUSE:New(STATIC:FindByName("Warehouse Nalchik"))        --Functional.Warehouse#WAREHOUSE
  warehouse.mozdok      = WAREHOUSE:New(STATIC:FindByName("Warehouse Mozdok"))         --Functional.Warehouse#WAREHOUSE
  warehouse.mineralnye  = WAREHOUSE:New(STATIC:FindByName("Warehouse Mineralnye"))     --Functional.Warehouse#WAREHOUSE
  warehouse.krymsk      = WAREHOUSE:New(STATIC:FindByName("Warehouse Krymsk"))         --Functional.Warehouse#WAREHOUSE
  warehouse.skala       = WAREHOUSE:New(STATIC:FindByName("Skala Command Post"))       --Functional.Warehouse#WAREHOUSE
  
  -- Start warehouses.
  for _,_warehouse in pairs(warehouse) do
    local wh=_warehouse --Functional.Warehouse#WAREHOUSE
    wh:SetReportOff()
    --wh:SetRespawnAfterDestroyed(60)
    wh:Start()
    --wh:GetCoordinate():Explosion(50000, math.random(10,30))
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
    
    -- Set speed and altitude.
    local speed=UTILS.KnotsToMps(420)
    local altitude=UTILS.FeetToMeters(25000)
    
    -- Race-track orbit of 50 NM length.
    local c1=zone.tanker:GetCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE
    local c2=c1:Translate(UTILS.NMToMeters(50), 270):SetAltitude(altitude)
    
    -- Set TACAN and callsign.
    local tacanch=3
    local tacanmorse="SHL"
    local callsign=CALLSIGN.Tanker.Shell
    local tankerRTB="Shell RTB"
    if arco then
      tacanch=2
      tacanmorse="ACO"
      callsign=CALLSIGN.Tanker.Arco
      tankerRTB="Arco RTB"
      ArcoRTB:Set(1)
      env.info("FPP shift arco")
    else
      ShellRTB:Set(1)
      env.info("FPP shift shell")
    end
    
    -- Orbit in race track pattern.
    local TaskOrbit=group:TaskOrbit(c1, altitude, speed,c2)
    
    -- Orbit until flag=2.
    --local TaskCondition=group:TaskCondition(nil, tankerRTB, 2, nil, nil, nil)
    local TaskCondition=group:TaskCondition(nil, tankerRTB, nil, nil, 5*60, nil)
    
    -- Controlled Task: orbit until flag value is 2.
    local TaskControlled=group:TaskControlled(TaskOrbit, TaskCondition)
    
    -- Define waypoints.
    local wp={}
    wp[1]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
    --wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed), {TaskControlled}, "Tanker")
    wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed), {TaskOrbit}, "Tanker")
    wp[3]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirLanding(UTILS.MpsToKmph(speed), warehouse.kobuleti:GetAirbase(), {}, "Landing Kobuleti")
    
    group:StartUncontrolled()
            
    -- Task route.
    local TaskRoute=group:TaskRoute(wp)

    -- Enroute task tanker and route.
    local TaskTanker=group:EnRouteTaskTanker()
    local TaskCombo=group:TaskCombo({TaskTanker, TaskRoute})
    
    -- Create a new beacon and activate TACAN.
    local unit=group:GetUnit(1)
        
    -- Activate TACAN.
    local beacon=BEACON:New(unit)
    beacon:ActivateTACAN(tacanch, "Y", tacanmorse, true)
    group:CommandSetCallsign(callsign, 1, 1)
    group:OptionROTNoReaction()
    
    group:SetTask(TaskCombo, 1)
    
    -- Invert switch.
    arco=not arco    
  end

  --- AWACS setup.
  local function StartAWACS(_group)
    local group=_group --Wrapper.Group#GROUP
    
    -- Set speed and altitude.
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
    
    -- Set callsign, ROE and data link.
    group:CommandSetCallsign(CALLSIGN.AWACS.Magic, 1, 1)
    group:OptionROTNoReaction()
    group:CommandEPLRS(true, 2)
    
    group:SetTask(TaskCombo, 1)
  end
  
  --- Function to make a group lase a coordinate.
  function LaseReaper(_group)
    local group=_group --Wrapper.Group#GROUP
    local reaper=group:GetUnit(1)
    
    local coord=zone.KobuletiRangeTechCombine:GetCoordinate()
    
    env.info("FPP: Reaper starts to lase!")
    
    MESSAGE:New("Reaper on station. Lasing target at Kobuleti Range on laser code 1704.", 20):ToBlue()
    
    reaper:LaseCoordinate(coord, 1704)
  end
  
  --- Reaper setup.
  local function StartReaper(_group)
    local group=_group --Wrapper.Group#GROUP
    
    -- Set speed and altitude.
    local speed=UTILS.KnotsToMps(300)
    local altitude=UTILS.FeetToMeters(15000)
    
    -- Race-track orbit of 50 NM length.
    local c1=zone.KobuletiRange:GetCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE

    -- Orbit in race track pattern.
    local TaskOrbit=group:TaskOrbit(c1, altitude, speed)
    
    local TaskFuncLase=group:TaskFunction("LaseReaper")
    
    local wp={}
    wp[1]=warehouse.kobuleti:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
    wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed),{TaskFuncLase, TaskOrbit}, "Reaper")
        
    group:StartUncontrolled()
            
    local TaskRoute=group:TaskRoute(wp)
    local TaskCombo=group:TaskCombo({TaskRoute})
    
    -- Set callsign, ROE and data link.
    group:OptionROTNoReaction()
        
    group:SetTask(TaskCombo, 1)    
  end
  
  -- Add assets.
  warehouse.kobuleti:AddAsset("E-3A Group", 2)
  warehouse.kobuleti:AddAsset("KC-135 Group", 2)
  warehouse.kobuleti:AddAsset("Reaper Group", 2)
  
  -- Set low fuel to 10%.
  warehouse.kobuleti:SetLowFuelThreshold(0.10)

  
  -- Self request AWACS.
  warehouse.kobuleti:__AddRequest(10, warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "E-3A Group", 1, nil, nil, nil, "AWACS")
  
  -- Self request tanker.
  warehouse.kobuleti:__AddRequest(20, warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "KC-135 Group", 1, nil, nil, nil, "Tanker")

  -- Self request reaper.
  warehouse.kobuleti:__AddRequest(20, warehouse.kobuleti, WAREHOUSE.Descriptor.GROUPNAME, "Reaper Group", 1, nil, nil, nil, "Reaper")

  
  --- Function called after self requests.
  function warehouse.kobuleti:OnAfterSelfRequest(From,Event,To,groupset,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem    
    local assignment=self:GetAssignment(request)
    
    -- Init AWACS.
    if assignment=="AWACS" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        StartAWACS(group)
      end
    end
    
    -- Init tanker.
    if assignment=="Tanker" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        StartTanker(group)
      end
    end

    -- Init tanker.
    if assignment=="Reaper" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        StartReaper(group)
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
          env.info("FPP Sending Arco home due to low fuel.")
          ArcoRTB:Set(2)
        else
          -- Send Shell home.
          env.info("FPP Sending Shell home due to low fuel.")
          ShellRTB:Set(2)
        end
      end
    
      -- Send new Tanker or AWACS.
      warehouse.kobuleti:AddRequest(warehouse.kobuleti, request.assetdesc, request.assetdescval, 1, nil, nil, nil, assignment)
    end
    
  end

  ------------
  -- Krymsk --
  ------------
    
  -- Add IL-76 assets.
  warehouse.krymsk:AddAsset("IL-76 Group", 5)
  
  -- Transfer IL-76 to Mozdok.
  warehouse.krymsk:__AddRequest(40, warehouse.mozdok, WAREHOUSE.Descriptor.GROUPNAME, "IL-76 Group", 1, nil, nil, nil, "Transport Flight")
  
  
  function warehouse.krymsk:OnAfterAssetSpawned(From,Event,To,group,_asset,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem
    
    -- Spawn a transport flight every 30 min.
    if request.assignment=="Transport Flight" then
      self:__AddRequest(30*60, warehouse.mozdok, request.assetdesc, request.assetdescval, 1, nil, nil, nil, request.assignment)
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

  -- Safe parking at on (TO_AC parameter in getParking function).
  warehouse.maykop:SetSafeParkingOn()

  -- RTB when fuel <= 25%.
  warehouse.maykop:SetLowFuelThreshold(0.25)
  
  -- Template group names table.
  local drones={"MiG-21 Group", "MiG-23 Group", "MiG-25 Group"}
  
  -- Add 50 aircraft of random type.
  for _,drone in pairs(drones) do
    warehouse.maykop:AddAsset(drone, 50)
  end
  
  -- Launch six drones.
  for i=1,6 do
    local r=math.random(#drones)
    local drone=drones[r]
    warehouse.maykop:__AddRequest(i*3*60, warehouse.maykop, WAREHOUSE.Descriptor.GROUPNAME, drone, 1, nil, nil, nil, "Drone")
  end
  
  --- Function called after spawning a drone.
  function warehouse.maykop:OnAfterSelfRequest(From,Event,To,groupset,request)
    
    -- Get assignment.
    local assignment=self:GetAssignment(request)
    
    if assignment=="Drone" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        
        -- Random altitude between angels 10 and 15.
        local angels=math.random(10,15)
        
        local speed=UTILS.KnotsToMps(300)
        local altitude=UTILS.FeetToMeters(angels*1000)
        
        local c1=zone.Maykop:GetRandomCoordinate():SetAltitude(altitude) --Core.Point#COORDINATE
        local c2=c1:Translate(UTILS.NMToMeters(10), 180):SetAltitude(altitude)
                
        -- Enroute task to engage aircraft in Maykop zone.
        local taskEngageInZone=group:EnRouteTaskEngageTargetsInZone(zone.Maykop:GetVec2(), zone.Maykop:GetRadius(), {"Air"}, 0)
        local taskOrbit=group:TaskOrbit(c1, altitude, speed,c2)
        
        local flagname=group:GetName().."_RTB"
        local userflag=USERFLAG:New(flagname)
        userflag:Set(100)
        
        local taskCond=group:TaskCondition(nil,flagname, 666, nil, nil, nil)
        local taskCont=group:TaskControlled(taskOrbit, taskCond)
        
        local wp={}
        wp[1]=warehouse.maykop:GetAirbase():GetCoordinate():WaypointAirTakeOffParking(nil, 300)
        wp[2]=c1:WaypointAirTurningPoint(nil, UTILS.MpsToKmph(speed), {taskEngageInZone, taskCont}, "Orbit")
        wp[3]=warehouse.maykop:GetAirbase():GetCoordinate():WaypointAirLanding(400, warehouse.maykop:GetAirbase(), {}, "Landing")
        
        group:StartUncontrolled()
        
        -- Drone: Hold fire and dont react to threats!
        --group:OptionROEHoldFire()
        --group:OptionROTNoReaction()
        
        group:Route(wp)
      end
    end
  end
  
  
  --- Function called when all assets of a request were delivered.
  function warehouse.maykop:OnAfterDelivered(From,Event,To,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem
    local assignment=self:GetAssignment(request)
    
    env.info(string.format("FPP Maykop delivered asset with assignment %s", assignment))
    
    -- Spawn new drone if one returned, e.g. because out of fuel.
    if assignment=="Drone" then
      warehouse.maykop:__AddRequest(30, warehouse.maykop, request.assetdesc, request.assetdescval, 1, nil, nil, nil, assignment)
    end
  
  end
  
  --- Function called when an asset runs low on fuel, i.e. < 15 %.
  function warehouse.maykop:OnAfterAssetLowFuel(From,Event,To,_asset,_request)
    local request=_request --Functional.Warehouse#WAREHOUSE.Pendingitem
    local asset=_asset --Functional.Warehouse#WAREHOUSE.Assetitem
    local assignment=self:GetAssignment(request)
    
    -- TODO Bit clumsy here. Need to introduce a function for the class.
    local groupname=self:_alias(asset.unittype, self.uid, asset.uid, request.uid)
    
    -- Spawn new drone if one returned, e.g. because out of fuel.
    if assignment=="Drone" then
      
      local flagname=groupname.."_RTB"
      env.info(string.format("FPP Maykop group %s out of fuel ==> RTB", groupname))
      local userflag=USERFLAG:New(flagname)
      userflag:Set(666)
    end
  
  end
  
  --- Function called when an asset group is dead.
  function warehouse.maykop:OnAfterAssetDead(From,Event,To,_asset,_request)
    local asset=_asset     --Functional.Warehouse#WAREHOUSE.Assetitem
    local request=_request --Functional.Warehouse#WAREHOUSE.Queueitem    
    
    local groupname=self:_alias(asset.unittype, self.uid, asset.uid, request.uid)
    
    env.info(string.format("FPP Maykop group %s dead! Assignment %s", groupname, request.assignment))
    
    -- Spawn new drone if one was shot down.
    if request.assignment=="Drone" then
      --warehouse.maykop:AddRequest(warehouse.maykop, request.assetdesc, request.assetdescval, 1, nil, nil, nil, request.assignment)
    end
  end
  
  ----------------
  -- FARP Skala --
  ----------------
  
  -- Add assets.
  warehouse.skala:AddAsset("Infantry Rus Group 5", 20)
  warehouse.skala:AddAsset("SA-18 Manpad Group", 20)
  
  -- Set spawn zone.
  warehouse.skala:SetSpawnZone(zone.SkalaSpawn)
  
  -- Spawn some infantry and manpads.
  warehouse.skala:AddRequest(warehouse.skala, WAREHOUSE.Descriptor.GROUPNAME, "Infantry Rus Group 5", 3, nil, nil, nil, "Patrol")
  warehouse.skala:AddRequest(warehouse.skala, WAREHOUSE.Descriptor.GROUPNAME, "SA-18 Manpad Group", 3, nil, nil, nil, "Patrol")
  
  -- Big smoke.
  zone.Skala:GetRandomCoordinate():BigSmokeLarge(0.1)
    
  function warehouse.skala:OnAfterSelfRequest(From,Event,To,groupset,request)
    
    local assignment=self:GetAssignment(request)
    
    if assignment=="Patrol" then
      for _,_group in pairs(groupset:GetSet()) do
        local group=_group --Wrapper.Group#GROUP
        local speed=group:GetSpeedMax()*0.5
        group:PatrolZones({zone.Skala}, speed, "Custom")
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
  fox:AddSafeZone(zone.Maykop)
    
  -- Add launch zones.
  fox:AddLaunchZone(zone.SAMKrim)
  fox:AddLaunchZone(zone.SAMKrymsk)
  fox:AddLaunchZone(zone.Maykop)

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
  AIRBOSS.MenuF10Root=MENU_MISSION:New("CVN-74 Stennis").MenuPath
  
  -- Path is in DCS log directory.
  local savepath=nil 
  if lfs then
    savepath=lfs.writedir()..[[Logs]]
  end
  
  -- S-3B Recovery Tanker spawning in air.
  local tanker=RECOVERYTANKER:New("USS Stennis", "S-3B Tanker Group")
  tanker:SetTakeoffAir()
  tanker:SetRadio(250)
  tanker:SetModex(501)
  tanker:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
  tanker:SetTACAN(1, "TEX")
  tanker:Start()
  
  -- E-2D AWACS spawning in air.
  local awacs=RECOVERYTANKER:New("USS Stennis", "E-2D Group")
  awacs:SetTakeoffAir()
  awacs:SetAWACS()
  awacs:SetRadio(257)
  awacs:SetAltitude(20000)
  awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
  awacs:SetRacetrackDistances(30, 15)
  awacs:SetModex(601)
  awacs:SetTACANoff()
  awacs:__Start(1)
  
  -- Rescue Helo spawned in air with home base USS Ford. Has to be a global object!
  rescuehelo=RESCUEHELO:New("USS Stennis", "Rescue Helo Group")
  rescuehelo:SetHomeBase(AIRBASE:FindByName("USS Ford"))
  rescuehelo:SetTakeoffAir()
  rescuehelo:SetModex(42)
  rescuehelo:Start()
    
  -- Create AIRBOSS object.
  local AirbossStennis=AIRBOSS:New("USS Stennis")
  
  -- Add recovery windows:
  local window1=AirbossStennis:AddRecoveryWindow(  "6:30",  "8:30", 1, nil, true, 25, true)
  local window2=AirbossStennis:AddRecoveryWindow(  "9:30", "10:30", 1, nil, true, 25, true)
  local window3=AirbossStennis:AddRecoveryWindow( "11:30", "12:30", 1, nil, true, 25, true)
  local window4=AirbossStennis:AddRecoveryWindow( "13:30", "14:30", 1, nil, true, 25, true)
  local window5=AirbossStennis:AddRecoveryWindow( "15:30", "16:30", 1, nil, true, 25, true)
  local window6=AirbossStennis:AddRecoveryWindow( "17:30", "18:30", 1, nil, true, 25, true)
  local window7=AirbossStennis:AddRecoveryWindow( "19:30", "20:30", 1, nil, true, 25, true)
  -- Case III with +30 degrees holding offset from 21:30 to 7:30 next day.
  local window8=AirbossStennis:AddRecoveryWindow("21:30", "7:30:00+1", 3, 30, true, 25, true)
  
  -- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
  AirbossStennis:Load(savepath, "FPP-Greenieboard.csv")
  
  -- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
  AirbossStennis:SetAutoSave(savepath, "FPP-Greenieboard.csv")
  
  AirbossStennis:SetRadioRelayLSO(rescuehelo:GetUnitName())
  AirbossStennis:SetRadioRelayMarshal("Huey Radio Relay")
  
  -- Set folder of airboss sound files within miz file.
  AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")
  
  -- AI groups explicitly excluded from handling by the Airboss
  local CarrierExcludeSet=SET_GROUP:New():FilterPrefixes("E-2D Group"):FilterStart()
  AirbossStennis:SetExcludeAI(CarrierExcludeSet)
  
  -- Enable trap sheet.
  --AirbossStennis:SetTrapSheet(savepath, "FPP-Trapsheet")
   
  -- Single carrier menu optimization.
  AirbossStennis:SetMenuSingleCarrier()
  
  -- Enable skipper menu.
  AirbossStennis:SetMenuRecovery(15, 30, true)
  
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
  DetectionSetGroup:FilterPrefixes({"CCCP EWR"})
  DetectionSetGroup:FilterStart()
  
  Detection = DETECTION_AREAS:New(DetectionSetGroup, 30000)
  
  -- Setup the A2A dispatcher, and initialize it.
  A2ADispatcher=AI_A2A_DISPATCHER:New(Detection)
  
  -- Enable the tactical display panel.
  A2ADispatcher:SetTacticalDisplay(false)
  
  -- Despawn on landing to keep airbase clean.
  A2ADispatcher:SetDefaultLanding(AI_A2A_DISPATCHER.Landing.AtRunway)
  
  -- Initialize the dispatcher, setting up a border zone. Any enemy crossing this border will be engaged.  
  A2ADispatcher:SetBorderZone(zone.CCCPboarder)
  
  -- Initialize the dispatcher, setting up a radius of 120 km where any airborne friendly without an assignment within 120 km radius from a detected target, will engage that target.
  A2ADispatcher:SetEngageRadius(120000)
  
  -- Setup the squadrons.
  A2ADispatcher:SetSquadron("Mineralnye", AIRBASE.Caucasus.Mineralnye_Vody, {"SQ CCCP SU-27"},    6)
  A2ADispatcher:SetSquadron("Nalchik",    AIRBASE.Caucasus.Nalchik,         {"SQ CCCP MIG-25PD"}, 6)
  A2ADispatcher:SetSquadron("Beslan",     AIRBASE.Caucasus.Beslan,          {"SQ CCCP MIG-25PD"}, 4)
  A2ADispatcher:SetSquadron("Mozdok",     AIRBASE.Caucasus.Mozdok,          {"SQ CCCP MIG-31"},   10)
  
  local Squadrons={"Mineralnye", "Mozdok", "Beslan", "Nalchik"}
  
  -- CAP zones.
  A2ADispatcher:SetSquadronCap("Mineralnye", zone.CAPwest,    UTILS.FeetToMeters(10000), UTILS.FeetToMeters(20000), UTILS.KnotsToKmph(350), UTILS.KnotsToKmph(400), 800, 1100, "BARO")
  A2ADispatcher:SetSquadronCap("Mozdok",     zone.CAPmozdok,  UTILS.FeetToMeters(10000), UTILS.FeetToMeters(20000), UTILS.KnotsToKmph(350), UTILS.KnotsToKmph(400), 800, 1100, "BARO")
  A2ADispatcher:SetSquadronCap("Nalchik",    zone.CAPnalchik, UTILS.FeetToMeters(10000), UTILS.FeetToMeters(20000), UTILS.KnotsToKmph(350), UTILS.KnotsToKmph(400), 800, 1100, "BARO")
  A2ADispatcher:SetSquadronCap("Beslan",     zone.CAPbeslan,  UTILS.FeetToMeters(10000), UTILS.FeetToMeters(20000), UTILS.KnotsToKmph(350), UTILS.KnotsToKmph(400), 800, 1100, "BARO")
  
  -- CAP race track pattern.
  A2ADispatcher:SetSquadronCapRacetrack("Mineralnye", nil, nil, 90, 270, 20*60, 30*60)
  A2ADispatcher:SetSquadronCapRacetrack("Mozdok",     nil, nil, 90, 270, 20*60, 30*60)
  A2ADispatcher:SetSquadronCapRacetrack("Nalchik",    nil, nil, 90, 180, 20*60, 30*60)
  A2ADispatcher:SetSquadronCapRacetrack("Beslan",     nil, nil, 90, 180, 20*60, 30*60)
  
  for _,squadron in pairs(Squadrons) do
    A2ADispatcher:SetSquadronOverhead(squadron, 1.0)
    A2ADispatcher:SetSquadronGrouping(squadron, 2)
    --A2ADispatcher:SetSquadronTakeoff(squadron, AI_A2A_DISPATCHER.Takeoff.Hot)
    A2ADispatcher:SetSquadronTakeoffFromParkingHot(squadron)
    --A2ADispatcher:SetSquadronLanding(squadron, AI_A2A_DISPATCHER.Landing.AtRunway)
    A2ADispatcher:SetSquadronLandingAtEngineShutdown(squadron)
    A2ADispatcher:SetSquadronCapInterval(squadron, 1, 180, 360, 1)
    A2ADispatcher:SetSquadronGci(squadron, 900, 1200)
  end
  
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Scoring
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Scoring then

  -- Scoring object.
  local scoring=SCORING:New("FPP", "FPP-Scoring.csv")
  
  -- Stay silent!
  scoring:SetMessagesDestroy(false)
  scoring:SetMessagesHit(false)
  scoring:SetMessagesZone(false)
  
  
  scoring:AddZoneScore(zone.Skala, 10)
  --scoring:AddStaticScore(ScoreStatic,Score)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zone Capturing
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local beslanEmpty=false
local beslanCaptured=false

local nalchikEmpty=false
local nalchikCaptured=false

local mozdokEmpty=false
local mozdokCaptured=false

local mineralnyeEmpty=false
local mineralnyeCaptured=false

local function zoneScan(_zone)
  local zone=_zone --Core.Zone#ZONE_RADIUS

  -- Scan zone
  local _,_,_,units,statics=zone:GetCoordinate():ScanObjects(zone.Radius, true, true, false)
  
  local nred=0 ; local nblue=0
  for _,_unit in pairs(units) do
    local unit=_unit --Wrapper.Unit#UNIT
    local _coalition=unit:GetCoalition()
    local category=unit:GetGroup():GetCategory()
    
    if category==Group.Category.GROUND then
      if _coalition==coalition.side.RED then
        nred=nred+1
      elseif _coalition==coalition.side.BLUE then
        nblue=nblue+1
      end
    end
  end

  return nred,nblue
end

local function CheckZones()

  -- Count units in capture zones.
  local nRedMozdok,nBlueMozdok=zoneScan(zone.Mozdok)
  local nRedNalchik,nBlueNalchik=zoneScan(zone.Nalchik)
  local nRedBeslan,nBlueBeslan=zoneScan(zone.Beslan)
  local nRedMineralnye,nBlueMineralnye=zoneScan(zone.Mineralnye)
  
  -- Debug info.
  env.info(string.format("FPP Units Beslan: nRed=%d nBlue=%d", nRedBeslan, nBlueBeslan))
  env.info(string.format("FPP Units Nalchik: nRed=%d nBlue=%d", nRedNalchik, nBlueNalchik))
  env.info(string.format("FPP Units Mineralnye: nRed=%d nBlue=%d", nRedMineralnye, nBlueMineralnye))
  env.info(string.format("FPP Units Mozdok: nRed=%d nBlue=%d", nRedMozdok, nBlueMozdok))
  
  local text=""
  
  -- Check if Beslan is empty.
  if nRedBeslan<=0 and not beslanEmpty then
  
    -- Inform coalition.
    text=text..string.format("Red forces at airbase Beslan eliminated! Ground troops are on their way to capture the base.")

    -- Send blue ground to capture airbase.
    local spawn=SPAWN:New("Capture Beslan Blue")
    local group=spawn:Spawn()

    -- Make sure this is not done again.
    beslanEmpty=true
  end

  -- Check if Nalchik is empty.
  if nRedNalchik<=0 and not nalchikEmpty then
  
    -- Inform coalition.
    text=text..string.format("Red forces at airbase Nalchik eliminated! Ground troops are on their way to capture the base.")

    -- Send blue ground to capture airbase.
    local spawn=SPAWN:New("Capture Nalchik Blue")
    local group=spawn:Spawn()

    -- Make sure this is not done again.
    nalchikEmpty=true
  end

  -- Check if Mineralnye is empty.
  if nRedMineralnye<=0 and not mineralnyeEmpty then
  
    -- Inform coalition.
    text=text..string.format("Red forces at airbase Mineralnye Vody eliminated! Ground troops are on their way to capture the base.")

    -- Send blue ground to capture airbase.
    local spawn=SPAWN:New("Capture Mineralnye Blue")
    local group=spawn:Spawn()

    -- Make sure this is not done again.
    mineralnyeEmpty=true
  end

  -- Check if Mozdok is empty.
  if nRedMozdok<=0 and not mozdokEmpty then
  
    -- Inform coalition.
    text=text..string.format("Red forces at airbase Mozdok eliminated! Ground troops are on their way to capture the base.")
    
    -- Send blue ground to capture airbase.
    local spawn=SPAWN:New("Capture Mozdok Blue")
    local group=spawn:Spawn()

    -- Make sure this is not done again.
    mozdokEmpty=true
  end
  
  if text~="" then
    env.info("FPP "..text)
    MESSAGE:New(text, 30, nil, true):ToBlue()
  end
  
end

-- Check zones every 30 sec.
local zoneCheck,zoneCheckID=SCHEDULER:New(nil, CheckZones, {}, 30, 30)

local function CheckCapturedRedZones()
  
  local n=0
  if mozdokCaptured then
    n=n+1
  end
  if beslanCaptured then
    n=n+1
  end
  if mineralnyeCaptured then
    n=n+1
  end
  if nalchikCaptured then
    n=n+1
  end

  if n==4 then
    local text=string.format("*** VICTORY ***\nAll four red airbases are now in our hand. Well done, blue team!\nRTB and have a beer.")
    MESSAGE:New(text, 60, nil, true):ToBlue()
    
    for _,_wh in pairs(warehouse) do
      local wh=_wh --Functional.Warehouse#WAREHOUSE
      wh:_Fireworks()
    end
  end
  
  return n
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

if false then

  local SetRedGround=SET_GROUP:New():FilterCategoryGround():FilterCoalitions("red"):FilterOnce()
  
  local function DebugDestroyGroup(_group)
    local group=_group --Wrapper.Group#GROUP
    group:SmokeBlue()
    group:Destroy(true, 10)
  end
  
  SetRedGround:ForEachGroup(DebugDestroyGroup)

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- General event handler.
eventhandler=EVENTHANDLER:New()

-- Dead events.
eventhandler:HandleEvent(EVENTS.Dead)
eventhandler:HandleEvent(EVENTS.BaseCaptured)

function eventhandler:OnEventBaseCaptured(_EventData)
  local EventData=_EventData --Core.Event#EVENTDATA
  

  if EventData and EventData.Place then

    -- Place is the airbase that was captured.
    local airbase=EventData.Place --Wrapper.Airbase#AIRBASE
    
    local name=airbase:GetName()
    
    local newcoalition=airbase:GetCoalition()
    local newcoalitionname=airbase:GetCoalitionName()
    
    env.info(string.format("FPP: airbase %s captured", name))
    
    if name==AIRBASE.Caucasus.Nalchik or name==AIRBASE.Caucasus.Beslan or name==AIRBASE.Caucasus.Mozdok or name==AIRBASE.Caucasus.Mineralnye_Vody then
      if newcoalition==coalition.side.BLUE then        
        
        if name==AIRBASE.Caucasus.Nalchik then
          nalchikCaptured=true
        elseif name==AIRBASE.Caucasus.Beslan then
          beslanCaptured=true
        elseif name==AIRBASE.Caucasus.Mozdok then
          mozdokCaptured=true
        elseif AIRBASE.Caucasus.Mineralnye_Vody then
          mineralnyeCaptured=true
        end
        
        local n=CheckCapturedRedZones()
        
        if n<4 then
          local text=string.format("Blue forces captured airbase %s. Well done!\n%d red bases remaining.", name, 4-n)
          MESSAGE:New(text, 30, nil, true):ToCoalition(newcoalition)        
        end
        
      end
    end
    
  end
  
end

function eventhandler:OnEventDead(_EventData)
  local EventData=_EventData --Core.Event#EVENTDATA
  
  -- Name of the dead unit.
  local unitname=EventData.IniUnitName
  
  -- Name of the group.
  local groupname=EventData.IniGroupName
  
  
  -- Debug
  env.info(string.format("FPP Event dead of unit %s", tostring(unitname)))
  
  -- Try to find a static by this name.
  local static=STATIC:FindByName(unitname, false)
  
  -- Check wheter a static or unit is dead.
  if static then
  
    -- Respawn all statics after 10 min. Warehouses are not respawned.
    if not unitname:match("Warehouse") then
      static:ReSpawn(nil, 600)
    end
        
  else
  
    if EventData.IniGroup then
  
      -- Number of units in group still alive.    
      local nalive=EventData.IniGroup:CountAliveUnits()
      
      -- Debug.
      env.info(string.format("FPP Units still alive %d", nalive))
    
      -- Respawn Fuel truck on Kobuleti Range after 5 min.
      if unitname=="Kobuleti X Range Fuel Truck" then
        BASE:ScheduleOnce(5*60, GROUP.Respawn, EventData.IniGroup)
      end
      
      -- Respawn SA-10 site after 15 min if one unit is dead.
      if groupname=="SA-10" then
        BASE:ScheduleOnce(15*60, GROUP.Respawn, EventData.IniGroup)
      end
      
      -- Respawn air defences of Range Krymsk after 30 min.
      if groupname:match("SA-15 Krymsk") or groupname:match("SA-8 Krymsk") or groupname:match("Range Krymsk SA-18") or groupname:match("SA-11 Krymsk") or groupname:match("SA-6 Krymsk") then
        BASE:ScheduleOnce(30*60, GROUP.Respawn, EventData.IniGroup)
      end        
      
      -- Respawn AAA at FARP Skala after 30 min.
      if groupname:match("Skala ZU-23 Group") then
        BASE:ScheduleOnce(30*60, GROUP.Respawn, EventData.IniGroup)
      end
            
    end
    
  end    
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------