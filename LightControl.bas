ALIAS lightSensor Pin0
ALIAS HYDRO_STATION IC.Device[1441767298]
ALIAS GROW_LIGHT IC.Device[-1758710260]

Main:
    yield()
    var h = lightSensor.Horizontal
    h = mod(h,360)
    IC.Setting = h
    
    if (h > 90) && (h < 300) then
        HYDRO_STATION.On = true
        GROW_LIGHT.On = true
    else
        HYDRO_STATION.On = false
        GROW_LIGHT.On = false    
    endif
    goto Main