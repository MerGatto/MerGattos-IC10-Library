##Meta:AddMipsWrapper = sdns,2
##Meta:AddMipsWrapper = clr,0

#Input sensor is only needed when the AC -
#got a passive vent on the waste port.



const @IsCooling = true
const @ProduceLiquids = false
const @HasLiquidSwitch = true
const @TemperatureLimit = 90
const @PressureLimit = 3000
const ACUnit = "StructureAirConditioner"
const VolumePump = "StructureVolumePump"
var IsHeating = not(@IsCooling)

alias liquidSwitch d0

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
    var turnOff = IC.Open

    var produceLiquids = @ProduceLiquids
    if (@HasLiquidSwitch) then
        produceLiquids = liquidSwitch.Setting
    endif
    
    foreach namePair in aClist
        alias currentAc = IC.Device[ACUnit].Name[namePair]
        alias currentPump = IC.Device[VolumePump].Name[namePair]
        var validAc = currentAc.PrefabHash.Sum == ACUnit
        var validPump = currentPump.PrefabHash.Sum == VolumePump
        if validAc && validPump then
            if turnOff then
              currentAc.Mode = 0
              currentPump.On = 0
            else
                var tempOut = currentAc.TemperatureOutput2
                var tempIn = currentAc.TemperatureInput
                var liquidOut = currentAc.RatioLiquidVolatilesOutput2 + currentAc.RatioLiquidNitrogenOutput2
                var presIn = currentAc.PressureOutput2
                var presOut = currentAc.PressureOutput
                var x = 11145.75           
                var volumeSetting = x / presIn
                if @IsCooling then
                    liquidOut = currentAc.RatioLiquidVolatilesOutput + currentAc.RatioLiquidNitrogenOutput
                    tempOut = currentAc.TemperatureOutput
                    tempIn = currentAc.TemperatureOutput2
                    var volumeSetting2 = x / max(presOut, @PressureLimit)
                    volumeSetting = max(volumeSetting, volumeSetting2)
                endif
                tempOut = max(tempOut, 1)
    
                var tempCheck = (tempOut > @TemperatureLimit)
                var pressureCheck = (presOut < 100)
                var pressureInHeatingLimit = ((presIn > (@PressureLimit-50)) || (presIn > presOut))
                var pressureInCheck = (pressureInHeatingLimit || @IsCooling)
                var pressureOutCheck = (IsHeating || (tempOut > tempIn) || (presOut < @PressureLimit))
                var pressureLimitCheck = pressureOutCheck && pressureInCheck
                var liquidCheck = (produceLiquids && (liquidOut < 0.05)) || (liquidOut == 0)
                
                var activate = (tempCheck || pressureCheck) && pressureLimitCheck && liquidCheck
                IC.Device[ACUnit].Name[namePair].Mode = activate || (currentAc.PressureInput > 0)
                IC.Device[VolumePump].Name[namePair].On = activate
                IC.Device[VolumePump].Name[namePair].Setting = volumeSetting
            endif
        endif       
    next    
    goto Main
    