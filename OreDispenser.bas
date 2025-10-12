##Meta: AddMipsWrapper = clr,0

ALIAS oreSelectionDial Pin0
ALIAS dialQuantity Pin1
ALIAS activateLever Pin2
AlIAS displaySelection Pin3
ALIAS displayCount Pin4
#ALIAS passoverDish Pin1

ARRAY hashArray[10]
hashArray[0] = "ItemIronOre"
hashArray[1] = "ItemCoalOre"
hashArray[2] = "ItemCharcoal"
hashArray[3] = "ItemSiliconOre"
hashArray[4] = "ItemCopperOre"
hashArray[5] = "ItemGoldOre"
hashArray[6] = "ItemSilverOre"
hashArray[7] = "ItemNickelOre"
hashArray[8] = "ItemLeadOre"
hashArray[9] = "ItemCobaltOre"



Main:
    yield()
    displayCount.Setting = dialQuantity.Setting
    displayCount.Color = Green
    var selectedItem = hashArray[oreSelectionDial.Setting]
    displaySelection.Setting = IC.Device[StructureSDBSilo].Name[selectedItem].Quantity
    dialQuantity.Mode = IC.Device[StructureSDBSilo].Name[selectedItem].Quantity
    
    IC.Device[StructureChuteDigitalFlipFlopSplitterRight].On = 1
    IC.Device[StructureChuteDigitalFlipFlopSplitterLeft].On = 1
    IC.Device[StructureChuteDigitalFlipFlopSplitterRight].Setting = 0
    IC.Device[StructureChuteDigitalFlipFlopSplitterLeft].Setting = 0
    IC.Device[StructureChuteDigitalFlipFlopSplitterRight].SettingOutput = 0
    IC.Device[StructureChuteDigitalFlipFlopSplitterLeft].SettingOutput = 0
    
    FOR i = 0 TO 11
        var item = hashArray[i]
        IC.Device[StructureChuteDigitalFlipFlopSplitterRight].Name[item].Mode = (item != selectedItem)
        IC.Device[StructureChuteDigitalFlipFlopSplitterLeft].Name[item].Mode = (item != selectedItem)        
    NEXT
    IC.Setting = selectedItem
    
    IF activateLever.Open THEN
        IC.Device[StructureSDBSilo].ClearMemory = 1
        var requestedCount = dialQuantity.Setting
        var count = requestedCount
        WHILE count != 0            
            yield()
            IC.Device[StructureSDBSilo].Name[selectedItem].Open = 1
            count = requestedCount - IC.Device[StructureSDBSilo].Name[selectedItem].ExportCount            
            displaySelection.Setting = IC.Device[StructureSDBSilo].Name[selectedItem].Quantity
            displayCount.Setting = count
            displayCount.Color = Yellow
        ENDWHILE
        IC.Device[StructureSDBSilo].Name[selectedItem].Open = 0
        activateLever.Open = 0
    ENDIF
    yield()
    goto Main