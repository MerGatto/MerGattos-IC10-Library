##Meta: AddMipsWrapper = clr,0
##Meta:UsePutGetStackCommands=true
ALIAS RoomVent d0
ALIAS RoomSensor d1

Main:
    yield()
    RoomVent.Mode = 1
    
    var partialPressureOxygen = RoomSensor.Pressure * RoomSensor.RatioOxygen
    
    RoomVent.On = (partialPressureOxygen > 25) && (RoomSensor.Pressure > 95) && (this.PressureInput < 40MPa)
    this.Mode = (this.PressureOutput < 40MPa) && (this.PressureInput > 0)
    goto Main