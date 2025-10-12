##Meta: AddMipsWrapper = clr,0

ALIAS pump Pin0
ALIAS analyzer Pin1
#ALIAS passoverDish Pin1


Main:
    pump.On = (analyzer.Temperature < 150C)
    yield()
    goto Main
