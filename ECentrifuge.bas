Main:
    yield()
    IC.Device[StructureCentrifuge].On = 1
    IC.Device[StructureCentrifuge].Open = 0
    # check for error or max capacity
    if (IC.Device[StructureCentrifuge].Reagents.Max >= 400) then
        goto EmptyCentrifuges
    endif
    goto Main

EmptyCentrifuges:
    yield()
    IC.Device[StructureCentrifuge].On = 0
    IC.Device[StructureCentrifuge].Open = 1
    if (IC.Device[StructureCentrifuge].Reagents.Max < 1) then
        goto Main
    endif
    goto EmptyCentrifuges
    