alias boiler Pin0
alias fuelpump Pin1
alias heatpump Pin2
alias heattank Pin3

const FuelPressure = 2MPa
const MaxHeatPressure = 40MPa
const MaxBoilerPressure = 40MPa

Main:
    yield()
    boiler.On = 1
    var boilerPressure = boiler.Pressure
    var heatPressure = heattank.Pressure
    var boilerTemperature = boiler.Temperature
    
    # turn off when presure max is reached
    if (heatPressure >= MaxHeatPressure) then
        if boilerPressure > MaxBoilerPressure then
            goto ExtractHeat
        endif
        goto Off
    endif
    
    # check for heat extraction
    if (boiler.Combustion || (boilerTemperature > 500C)) && (boilerPressure > 100kPa) then
        goto ExtractHeat
    endif
    
    # pump fuel or ignite
    if boilerPressure < FuelPressure then
      goto PumpFuel
    else
        goto Ignite
    endif
    goto Off

ExtractHeat:
    fuelpump.On = 0
    heatpump.On = 1
    heatpump.Setting = 100
    heatpump.Mode = 0 #check if mode correct
    goto Main

PumpFuel:
    fuelPump.Setting = 2000
    fuelpump.On = 1
    heatpump.On = 0
    goto Main
    
Ignite:
    fuelpump.On = 0
    heatpump.On = 1
    heatpump.Setting = 100
    heatpump.Mode = 1 #check if mode correct
    goto Main
    
Off:
    fuelpump.On = 0
    heatpump.On = 0
    goto Main