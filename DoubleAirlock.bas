ALIAS doorExtRoom1 Pin0
ALIAS doorExtRoom2 Pin1
ALIAS doorIntRoom1 Pin2
ALIAS doorIntRoom2 Pin3

# at what percentage of room pressure the doors will open early
# eg with the default of 0.8, the doors will open when the airlock pressure is 80kp for a 100kp room
CONST @earlyOpenMultiplier = 0.8

ALIAS PoweredVents IC.Device[StructurePoweredVentLarge]
ALIAS MedPoweredVents IC.Device[StructurePoweredVent]
ALIAS ActiveVents IC.Device[StructureActiveVent]
ALIAS GasSensor IC.Device[StructureGasSensor]
ALIAS MotionSensor IC.Device[StructureMotionSensor]
ALIAS PipeAnalyzer IC.Device[StructurePipeAnalysizer]

var latestPressure = 0
var openSide = 0

Setup:
    openSide = doorIntRoom1.Open

    doorExtRoom1.Open = 0
    doorIntRoom1.Open = 0
    doorExtRoom2.Open = 0
    doorIntRoom2.Open = 0
    
    doorExtRoom1.Mode = 1
    doorExtRoom2.Mode = 1
    doorIntRoom1.Mode = 1
    doorIntRoom2.Mode = 1
    
    doorExtRoom1.Setting = 0
    doorIntRoom1.Setting = 0
    doorExtRoom2.Setting = 0
    doorIntRoom2.Setting = 0
    
    ActiveVents.PressureExternal = 60MPa
    MedPoweredVents.PressureExternal = 60MPa
    
    
    ActiveVents.Mode = 0
    MedPoweredVents.Mode = 0
    
    PoweredVents.On = 0
    ActiveVents.On = 0
    MedPoweredVents.On = 0
    
    PoweredVents.Lock = 1
    ActiveVents.Lock = 1
    MedPoweredVents.Lock = 1
    
    goto Main

Main:
    IC.Setting = 1
    yield()
    ActiveVents.PressureExternal = 60MPa
    MedPoweredVents.PressureExternal = 60MPa
    doorExtRoom1.Lock = 0
    doorIntRoom1.Lock = 0
    doorExtRoom2.Lock = 0
    doorIntRoom2.Lock = 0
    if (doorExtRoom1.Setting != doorExtRoom1.Open)
        || (doorExtRoom2.Setting != doorExtRoom2.Open)
        || (doorIntRoom1.Setting != doorIntRoom1.Open)
        || (doorIntRoom2.Setting != doorIntRoom2.Open) then
        goto Inhale
    endif
    goto Main

Inhale:
    IC.Setting = 2
    doorExtRoom1.Open = 0
    doorIntRoom1.Open = 0
    doorExtRoom2.Open = 0
    doorIntRoom2.Open = 0
    
    doorIntRoom2.Lock = 1
    doorExtRoom1.Lock = 1
    doorIntRoom1.Lock = 1
    doorExtRoom2.Lock = 1
    latestPressure = GasSensor.Pressure.Max
    ActiveVents.On = 0
    MedPoweredVents.On = 0
    while GasSensor.Temperature.Max > 0    
        PoweredVents.On = 1
        PoweredVents.Mode = 1
        yield()
    endwhile
    goto Exhale
Exhale:
    IC.Setting = 3
    wait(1)
    PoweredVents.On = 0
    ActiveVents.On = 1
    MedPoweredVents.On = 1
    ActiveVents.Mode = 0
    MedPoweredVents.Mode = 0
    while PipeAnalyzer.Temperature.Max > 0
        if GasSensor.Pressure.Max > (latestPressure * @earlyOpenMultiplier) then # open doors early        
            if openSide == 1 then
                doorExtRoom1.Open = 1
                doorIntRoom2.Open = 1 
            else
                doorExtRoom2.Open = 1
                doorIntRoom1.Open = 1
            endif
        endif
        yield()
    endwhile
    wait(1)
    ActiveVents.On = 0
    MedPoweredVents.On = 0
    if openSide == 1 then
        doorExtRoom1.Open = 1
        doorIntRoom2.Open = 1
        openSide = 0        
    else
        doorExtRoom2.Open = 1
        doorIntRoom1.Open = 1
        openSide = 1
    endif
    goto Main
    
    
    