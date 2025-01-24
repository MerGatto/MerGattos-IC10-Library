##Meta: AddMipsWrapper = clr,0
##Meta:UsePutGetStackCommands=true
ALIAS trackingDish Pin0
ALIAS passoverDish Pin1

Main:
    yield()    
    if (trackingDish.SignalStrength > 0)
        && (trackingDish.SignalStrength < 15)
        && (trackingDish.WattsReachingContact < trackingDish.MinimumWattsToContact)
        && (trackingDish.InterrogationProgress == 0) THEN
        passoverDish.On = true
        passoverDish.Setting = 50000
        passoverDish.Vertical = trackingDish.Vertical
        passoverDish.Horizontal = trackingDish.Horizontal
        passoverDish.BestContactFilter = trackingDish.BestContactFilter
        WaitForSignalStart:
        yield()
        IF NOT(trackingDish.Idle) THEN
            GOTO WaitForSignalStart
        ENDIF 
        if passoverDish.WattsReachingContact < passoverDish.MinimumWattsToContact then goto Main endif
        passoverDish.Activate = false
        wait(1)
        while (passoverDish.InterrogationProgress < 1) && (passoverDish.InterrogationProgress >= 0)
            passoverDish.Activate = true
            yield()
        endwhile
        passoverDish.BestContactFilter = -1
        passoverDish.Vertical = 45
        passoverDish.Horizontal = 180
    ENDIF
GOTO Main