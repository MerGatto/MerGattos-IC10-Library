##Meta:AddMipsWrapper = sdns,2
##Meta:AddMipsWrapper = clr,0
const Display = "StructureConsoleLED5"
const Silo = "StructureSDBSilo"

array list[11]
list[0] = "SiloIron"
list[1] = "SiloCopper"
list[2] = "SiloCoal"
list[3] = "SiloCharcoal"
list[4] = "SiloSilicon"
list[5] = "SiloGold"
list[6] = "SiloSilver"
list[7] = "SiloCobalt"
list[8] = "SiloNickel"
list[9] = "SiloLead"
list[10] = "SiloBiomass"

Main:
    yield()    
    foreach namePair in list
        alias currentSilo = IC.Device[Silo].Name[namePair]
        alias currentDisplay = IC.Device[Display].Name[namePair]
        currentDisplay.Setting = currentSilo.Quantity
    next    
    goto Main
    