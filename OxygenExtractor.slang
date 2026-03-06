device self = "db";
device roomVent = "d0";
device roomSensor = "d1";

loop {
  yield();
  roomVent.Mode = 1;
  let partOxyPressure = roomSensor.Pressure * roomSensor.RatioOxygen;
  roomVent.On = (partOxyPressure > 25)
    && (roomSensor.Pressure > 95)
    && (self.PressureInput < 40_000);
  self.Mode = (self.PressureOutput < 40_000)
           && (self.PressureInput > 0);
}
