device O2Vent = "d0";
device CO2Vent = "d1";
device NVent = "d2";
device OutVent = "d3";
device RoomSensor = "d4";

loop {
  yield();
  O2Vent.Mode = 0;
  CO2Vent.Mode = 0;
  NVent.Mode = 0;
  OutVent.Mode = 1;
  OutVent.On = RoomSensor.Pressure > 95;
  
  OutVent.PressureExternal = 0;
  O2Vent.PressureExternal = 50_000;
  CO2Vent.PressureExternal = 50_000;
  NVent.PressureExternal = 50_000;
  
  OutVent.PressureInternal = 45_000;
  O2Vent.PressureInternal = 10_000;
  CO2Vent.PressureExternal = 10_000;
  NVent.PressureInternal = 10_000;

  let partialPressureOxygen =
    RoomSensor.Pressure * RoomSensor.RatioOxygen;
  let partialPressureCarbon =
    RoomSensor.Pressure * RoomSensor.RatioCarbonDioxide;
  let partialPressureNitrogen =
    RoomSensor.Pressure * RoomSensor.RatioNitrogen;

  if (RoomSensor.Temperature > 45c || RoomSensor.Pressure > 100) {
    O2Vent.On = 0;
    CO2Vent.On = 0;
    NVent.On = 0;
    continue;
  }

  O2Vent.On = partialPressureOxygen < 25;
  CO2Vent.On = partialPressureCarbon < 5;
  NVent.On = partialPressureNitrogen < 65;
}
