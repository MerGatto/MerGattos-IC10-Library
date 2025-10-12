#Input sensor is only needed when the AC -
#got a passive vent on the waste port.

const @IsCooling = true
const @TemperatureLimit = 0
const @PressureLimit = 4500
#this will automaticly balance pressure, disable
#if you only want max effiency and minimum flow
#(leave it on if you are unsure)
const @MaxPumpSetting = 30
const ACUnit = "StructureAirConditioner"
const VolumePump = "StructureVolumePump"

array aCList[6]
aCList[0] = "0"
aCList[1] = "1"
aCList[2] = "2"
aCList[3] = "3"
aCList[4] = "4"
aCList[5] = "5"

Main:
    yield()
    if @IsCooling then
        IC.Device[ACUnit].Setting = -270C
    else
        IC.Device[ACUnit].Setting = 999C
    endif
    IC.Device[ACUnit].On = true
    var minTemp = min(IC.Device[ACUnit].TemperatureOutput2.Min, IC.Device[ACUnit].TemperatureOutput.Min)
    minTemp = max(minTemp, 1)
    
    foreach namePair in aClist
        alias currentAc = IC.Device[ACUnit].Name[namePair]
        alias currentPump = IC.Device[VolumePump].Name[namePair]
        var validAc = currentAc.PrefabHash.Sum == ACUnit
        var validPump = currentPump.PrefabHash.Sum == VolumePump
        if validAc && validPump then
            var presIn = currentAc.PressureOutput2
            var presOut = currentAc.PressureOutput
            var x = 11145.75
            var volume = x / presIn
            
            var activate = (volume < @MaxPumpSetting) && ((minTemp > @TemperatureLimit) || (presOut < 100)) && (not(@IsCooling) || (presOut < @PressureLimit))
            IC.Device[ACUnit].Name[namePair].Mode = activate
            IC.Device[VolumePump].Name[namePair].On = activate
            IC.Device[VolumePump].Name[namePair].Setting = volume
        endif        
    next    
    goto Main
    