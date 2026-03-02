const @REAGENT_CAPACITY = 2990

const @TIMEOUT = 2
const @RPM_TEMP_RATIO = 0.04
const @EMPTY_TIMEOUT = 10
const @RPMPS = 2

var latestRpm = IC.Rpm
var latestStress = IC.Stress
var currentRpm = IC.Rpm
var currentStress = IC.Stress
var desiredDelta

Main:
    # cache IC reads for this iteration
    var icTemp = IC.Temperature
    if (icTemp < 1) then icTemp = 1 endif # avoid divide by zero
    var icThrottle = IC.Throttle
    var icError = IC.Error

    latestRpm = IC.Rpm
    latestStress = IC.Stress
    wait(1)
    currentRpm = IC.Rpm
    currentStress = IC.Stress    

    # check for error or max capacity
    if (IC.PrefabHash == "StructureCombustionCentrifuge") THEN
      IF (IC.Reagents >= @REAGENT_CAPACITY) || (icError == 1) || (IC.Open == 1) THEN
        goto EmptyCentrifuge
      ENDIF
    endif

    if ((currentRpm < 10) && (currentStress > 30)) THEN
        WHILE (IC.Stress > 0)
            IC.Throttle = 0
            IC.CombustionLimiter = 0
            yield()
        ENDWHILE
        goto Main
    endif

    var rpmDelta = currentRpm - latestRpm
    var stressDelta = currentStress - latestStress
    var isTooFast = ((rpmDelta > @RPMPS) && (currentStress > 5))

    desiredDelta = 0
    if (rpmDelta <= 0) THEN
        desiredDelta = 10
    ELSEIF (isTooFast) THEN # fast acceleration
      IF (stressDelta > 0) THEN
        desiredDelta = -10
      ENDIF
    ELSEIF (stressDelta <= 0) THEN
        desiredDelta = 10
    ENDIF
    
    ## adjust setting
    var currentSetting = icThrottle + desiredDelta
    if (desiredDelta <= 0) THEN
        IC.Throttle = currentSetting
        IC.CombustionLimiter = 0
    ELSE
        var tooHot = ((currentRpm / icTemp) < @RPM_TEMP_RATIO)
        
        if ((tooHot && (currentStress > 5))) THEN goto Main ENDIF
        IC.Throttle = currentSetting
        IC.CombustionLimiter = currentSetting
        if (tooHot) THEN
            IC.CombustionLimiter = 30
            wait(1)
            IC.Throttle = 0
            IC.CombustionLimiter = 0
        elseif (rpmDelta <= 0) then
         IC.CombustionLimiter = (currentSetting / 2)
        endif
    ENDIF
    wait(@TIMEOUT)
    goto Main

EmptyCentrifuge:
    yield()
    var reagentDelta = 0
    var previousReagents = IC.Reagents
    var timeout = 0
    IC.Throttle = 0
    IC.CombustionLimiter = 0
    IC.Open = 1
    while (IC.Reagents > 1)
        wait(2)
        reagentDelta = previousReagents - IC.Reagents
        previousReagents = IC.Reagents
        if (reagentDelta == 0) then
            timeout = timeout + 1
        endif
        if (timeout > @EMPTY_TIMEOUT) then
            BREAK
        endif
    endwhile
    IC.Open = 0
    goto Main