##Meta: AddMipsWrapper = clr,0
##Meta:UsePutGetStackCommands=true
ALIAS NitrogenVent Pin0
ALIAS CarbonVent Pin1
ALIAS OxygenVent Pin2
ALIAS OutVent Pin3
ALIAS RoomSensor Pin4

Main:
    yield()
    NitrogenVent.Mode = 0
    CarbonVent.Mode = 0
    OxygenVent.Mode = 0
    OutVent.Mode = 1
    
    OutVent.PressureExternal = 95
    OutVent.On = 1
    
    CarbonVent.PressureExternal = 50MPa
    NitrogenVent.PressureExternal = 50MPa
    OxygenVent.PressureExternal = 50MPa
    
    CarbonVent.PressureInternal = 1MPa
    NitrogenVent.PressureInternal = 1MPa
    OxygenVent.PressureInternal = 1MPa
    
    var partialPressureOxygen = RoomSensor.Pressure * RoomSensor.RatioOxygen
    var partialPressureCarbon = RoomSensor.Pressure * RoomSensor.RatioCarbonDioxide
    var partialPressureNitrogen = RoomSensor.Pressure * RoomSensor.RatioNitrogen
    
    IF RoomSensor.Temperature > 45C THEN
        OxygenVent.On = false
        CarbonVent.On = false
        NitrogenVent.On = false
        goto Main
    ENDIF
    
    OxygenVent.On = partialPressureOxygen < 30
    CarbonVent.On = partialPressureCarbon < 10
    NitrogenVent.On = partialPressureNitrogen < 60
    goto Main