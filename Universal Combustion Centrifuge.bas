const @STRESSTHRESHOLD = 30
const @TIMEOUT = 2

var latestRpm = IC.Rpm
var latestStress = IC.Stress
var currentRpm = IC.Rpm
var currentStress = IC.Stress

#GOTO WaitForReset

Main:
    yield()    
    # check for error or max capacity
    if (IC.Reagents >= 3000) || (IC.Error == 1) || (IC.Open == 1) then
        goto EmptyCentrifuge
    endif
    
    latestRpm = currentRpm
    latestStress = currentStress
    currentRpm = IC.Rpm
    currentStress = IC.Stress
    
    var rpmDelta = currentRpm - latestRpm
    var stressDelta = currentStress - latestStress
    
    if (currentRpm == 0) THEN
        WaitForReset:
        IF (IC.Stress > 0) then
            yield()
            IC.Throttle = 0
            IC.CombustionLimiter = 0
            goto WaitForReset
        ENDIF        
        IC.Open = 0
        latestRpm = IC.Rpm
        latestStress = IC.Stress
        currentRpm = IC.Rpm
        currentStress = IC.Stress
        AdjustSetting(10)
    endif
    
    if (rpmDelta > 0) && (stressDelta > 0) && (currentStress > @STRESSTHRESHOLD) THEN
        AdjustSetting(-10)
    ENDIF
    
    if (rpmDelta <= 0) THEN
        AdjustSetting(10)
    ENDIF
    
    IF (stressDelta <= 0) && (currentStress < @STRESSTHRESHOLD) THEN
        AdjustSetting(10)
    ENDIF
    
    goto Main

FUNCTION AdjustSetting(delta)
    if (IC.Throttle == 0) && (delta == 10) && (IC.Temperature > 1000) && ((IC.Temperature / IC.Rpm) > 25) THEN
        IF (IC.Stress > 30) THEN goto Main ENDIF
        IC.Throttle = 10
        IC.CombustionLimiter = 0
        wait(1)
        IC.Throttle = 0
        wait(4)
        goto Main  
    endif
    var currentSetting = IC.Throttle + delta
    IC.Throttle = currentSetting
    IC.CombustionLimiter = currentSetting
    wait(@TIMEOUT)
    goto Main  
ENDFUNCTION

EmptyCentrifuge:
    yield()
    IC.Throttle = 0
    IC.CombustionLimiter = 0
    IC.Open = 1
    if (IC.Reagents < 1) then
        goto WaitForReset
    endif
    goto EmptyCentrifuge
    