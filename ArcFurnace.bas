ALIAS ArcFurnace IC.Device[StructureArcFurnace]
ALIAS AC IC.Device[StructureActiveVent]
ALIAS RoomSensor IC.Device[StructureGasSensor]

Main:
    yield()
    IF (ArcFurnace.Idle == 1) THEN
        IF (ArcFurnace[Import].Occupied) THEN
            ArcFurnace.On = 1
            ArcFurnace.Activate = 1
        ELSE
            ArcFurnace.On = 0
        ENDIF
    ENDIF
    AC.On = (RoomSensor.Pressure > 0)
    goto Main
