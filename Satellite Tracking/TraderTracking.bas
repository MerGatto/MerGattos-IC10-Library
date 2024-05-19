##Meta: AddMipsWrapper = clr,0
##Meta:UsePutGetStackCommands=true

clr()
ALIAS trackingDish Pin0
#ALIAS passoverDish Pin1

ARRAY knownTraders[8]

var searchHDirection
var maxStrength
var stackPointer
var maxH 
var maxV
var vDirection
var currentH = trackingDish.Horizontal
var currentV
var currentStrength
var currentSignal
vaR waited



Main:
    trackingDish.BestContactFilter = -1
    WaitForSignal(currentH, 75, 0)
    IF trackingDish.InterrogationProgress == 1 THEN    
        GOTO KnownTrader
    ENDIF
    FOR i = 0 TO 7
        IF knownTraders[i] == currentSignal THEN
            GOTO KnownTrader
        ENDIF
    NEXT
    #UnknownTrader
        trackingDish.BestContactFilter = currentSignal
        maxH = currentH
        GOTO TrackTrader
    KnownTrader:
        currentH = currentH + 10
        goto Main

TrackTrader:
    #GetDirectionH
    WaitForSignal(currentH, currentV, 60)
    maxStrength = currentStrength
    if maxStrength == -1 then
        currentH = currentH + 54
        GOTO TrackTrader
    endif
    currentH = currentH + 2
    WaitForSignal(currentH, currentV, waited)
    searchHDirection = -5
    if currentStrength > maxStrength then
        searchHDirection = 5
        maxStrength = currentStrength
        maxH = currentH
    endif
    WaitH:
    currentH = currentH + searchHDirection
    WaitForSignal(currentH, currentV, 60)
    if (currentStrength > maxStrength) THEN
        maxStrength = currentStrength
        maxH = currentH
        goto WaitH
     endif
     # MaxHFound
    GetDirectionV:
    WaitForSignal(maxH, 77, 30)
    maxV = currentV
    IF currentStrength > maxStrength THEN
        vDirection = 5
        maxStrength = currentStrength
        maxV = currentV
    ELSE
        vDirection = -5
    ENDIF
    TrackV:
    currentV = currentV + vDirection
    WaitForSignal(currentH, currentV, 30)
    if (currentStrength > maxStrength) THEN
        maxStrength = currentStrength
        maxV = currentV
        goto TrackV
    endif
    MaxVFound:
    WaitForSignal(maxH, maxV, true)
    knownTraders[stackPointer] = currentSignal
    stackPointer++
    stackPointer = mod(stackPointer, 10)
    trackingDish.Activate = false
    wait(1)
    while trackingDish.InterrogationProgress < 1
        trackingDish.Activate = true
        wait(1)
    endwhile
goto Main

FUNCTION WaitForSignal(targetH, targetV, yieldTime)
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
    FOR j = 0 TO yieldTime
        IC.Setting = j
        currentStrength = trackingDish.WattsReachingContact
        if currentStrength > 0 then
            break
        ENDIF 
        yield()
    NEXT
    RETURN j
ENDFUNCTION