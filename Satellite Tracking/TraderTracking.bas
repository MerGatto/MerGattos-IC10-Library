##Meta: AddMipsWrapper = clr,0
##Meta:UsePutGetStackCommands=true
clr()
ALIAS trackingDish Pin0
#ALIAS passoverDish Pin1

ARRAY knownTraders[8]

var maxStrength
var stackPointer
var maxH 
var maxV
var trackDirection
var currentH = trackingDish.Horizontal
var currentV
var currentStrength
var currentSignal
var currentProgress
var startV = 60


Main:
    trackingDish.BestContactFilter = -1
    RepositionDish(currentH, startV, 0)
    IF currentProgress == 1 THEN
        GOTO KnownTrader
    ENDIF
    FOREACH trader IN knownTraders
        IF trader == currentSignal THEN
            GOTO KnownTrader
        ENDIF
    NEXT
    #UnknownTrader
        trackingDish.BestContactFilter = currentSignal
        GOTO TrackTrader
    KnownTrader:
        currentH = currentH + 5
        goto Main

TrackTrader:
    #GetDirectionH
    maxStrength = -1
    RepositionDish(currentH, currentV, 60)
    if maxStrength == -1 then
        currentH = currentH + 27
        GOTO TrackTrader
    endif
    # GetDirectionH
    trackDirection = 3
    currentH = currentH + 1
    RepositionDish(currentH, currentV, 60)
    TrackH:
    currentH = currentH + trackDirection
    RepositionDish(currentH, currentV, 60)
    if (currentStrength >= maxStrength) THEN
        goto TrackH
     endif
     # MaxHFound
    GetDirectionV:
    trackDirection = 3
    currentV = currentV + 1
    RepositionDish(maxH, currentV, 30)
    TrackV:
    currentV = currentV + trackDirection
    RepositionDish(currentH, currentV, 30)
    if (currentStrength >= maxStrength) THEN
        goto TrackV
    endif
    MaxVFound:
    RepositionDish(maxH, maxV, 30)
    knownTraders[stackPointer] = currentSignal
    stackPointer++
    stackPointer = mod(stackPointer, 10)
    if currentStrength < trackingDish.MinimumWattsToContact then goto Main endif
    trackingDish.Activate = false
    wait(1)
    while (currentProgress < 1) && (currentProgress >= 0)
        trackingDish.Activate = true
        currentProgress = trackingDish.InterrogationProgress
        yield()
    endwhile
goto Main

FUNCTION RepositionDish(targetH, targetV, yieldTime)
    trackingDish.Vertical = targetV
    trackingDish.Horizontal = targetH
    WaitForSignalStart:
      yield()
      IF NOT(trackingDish.Idle) THEN
        GOTO WaitForSignalStart
      ENDIF
    currentH = trackingDish.Horizontal
    currentV = trackingDish.Vertical
    currentSignal = trackingDish.SignalID
    currentProgress = trackingDish.InterrogationProgress
    FOR j = 0 TO yieldTime
        if currentSignal == -1 then
            goto Main
        endif
        IC.Setting = j
        currentStrength = trackingDish.WattsReachingContact
        if currentStrength > 0 then            
            IF currentStrength >= maxStrength THEN
                maxStrength = currentStrength
                maxH = currentH
                maxV = currentV
            ELSE
                trackDirection = trackDirection * -1
            ENDIF
            RETURN j
        else
            trackDirection = trackDirection * -1
        ENDIF
        yield()
    NEXT
    RETURN j
ENDFUNCTION