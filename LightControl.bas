# LigthSensor faces 0, with data port on 180
ALIAS lightSensor Pin0
ALIAS HYDRO_STATION IC.Device[1441767298]
ALIAS GROW_LIGHT IC.Device[-1758710260]

const @sunriseDegree = 90
const @sunsetDegree = 300
const @clockwiseSun = true

Main:
    yield()
    var h = lightSensor.Horizontal
    h = mod(h,360)
    IC.Setting = h

    var isDay = false
    if (@clockwiseSun) then
        # Clockwise: day is from sunrise to sunset moving forward
        if (@sunriseDegree <= @sunsetDegree) then
            isDay = (h >= @sunriseDegree) && (h <= @sunsetDegree)
        else
            isDay = (h >= @sunriseDegree) || (h <= @sunsetDegree)
        endif
    else
        # Counterclockwise: day is from sunset to sunrise moving backward
        if (@sunsetDegree <= @sunriseDegree) then
            isDay = (h >= @sunsetDegree) && (h <= @sunriseDegree)
        else
            isDay = (h >= @sunsetDegree) || (h <= @sunriseDegree)
        endif
    endif

    
    HYDRO_STATION.On = isDay
    GROW_LIGHT.On = isDay
    goto Main