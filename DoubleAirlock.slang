device self = "db";
device doorExtRoom1 = "d0";
device doorExtRoom2 = "d1";
device doorIntRoom1 = "d2";
device doorIntRoom2 = "d3";
device sensorRoom1 = "d4";
device sensorRoom2 = "d5";
const earlyOpenMultiplier = 0.8;
const BigPoweredVentHash = hash("StructurePoweredVentLarge");
const MedPoweredVentHash = hash("StructurePoweredVent");
const GasSensorHash = hash("StructureGasSensor");
const PipeAnalyzerHash = hash("StructurePipeAnalysizer");
const flashingLights = hash("StructureFlashingLight");
const leds = hash("StructureDiode");

let latestPressure1 = 0;
let latestPressure2 = 0;
let openSide = 0;

doorExtRoom1.Open = 0;
doorExtRoom2.Open = 0;

doorExtRoom1.Mode = 1;
doorExtRoom2.Mode = 1;
doorIntRoom1.Mode = 1;
doorIntRoom2.Mode = 1;

doorExtRoom1.Setting = 0;
doorIntRoom1.Setting = 0;
doorExtRoom2.Setting = 0;
doorIntRoom2.Setting = 0;

sb(BigPoweredVentHash, "On", 0);
sb(MedPoweredVentHash, "On", 0);
sb(flashingLights, "On", 0);
sb(leds, "On", 1);

sb(BigPoweredVentHash, "Lock", 1);
sb(MedPoweredVentHash, "Lock", 1);

doorExtRoom1.Lock = 0;
doorIntRoom1.Lock = 0;
doorExtRoom2.Lock = 0;
doorIntRoom2.Lock = 0;

yield();

// Default to room 1 unless int room 2 was the first request.
if (doorIntRoom2.Open > 0) {
  doorExtRoom1.Open = 1;
  doorExtRoom1.Setting = 1;
  doorIntRoom2.Open = 1;
  doorIntRoom2.Setting = 1;
  openSide = 0;
} else {
  doorExtRoom2.Open = 1;
  doorExtRoom2.Setting = 1;
  doorIntRoom1.Open = 1;
  doorIntRoom1.Setting = 1;
  openSide = 1;
}

loop {
  yield();
  sb(MedPoweredVentHash, "PressureExternal", 60_000);
  sb(flashingLights, "On", 0);
  sb(leds, "Color", 2);
  doorExtRoom1.Lock = 0;
  doorIntRoom1.Lock = 0;
  doorExtRoom2.Lock = 0;
  doorIntRoom2.Lock = 0;

  while ((doorExtRoom1.Setting == doorExtRoom1.Open)
      && (doorExtRoom2.Setting == doorExtRoom2.Open)
      && (doorIntRoom1.Setting == doorIntRoom1.Open)
      && (doorIntRoom2.Setting == doorIntRoom2.Open)) {
    yield();
  }

  self.Setting = 2;
  doorExtRoom1.Open = 0;
  doorIntRoom1.Open = 0;
  doorExtRoom2.Open = 0;
  doorIntRoom2.Open = 0;

  doorExtRoom1.Lock = 1;
  doorIntRoom1.Lock = 1;
  doorExtRoom2.Lock = 1;
  doorIntRoom2.Lock = 1;

  // Snapshot both connected room pressures before cycling.
  latestPressure1 = sensorRoom1.Pressure;
  latestPressure2 = sensorRoom2.Pressure;
  sb(MedPoweredVentHash, "On", 0);
  sb(BigPoweredVentHash, "On", 1);
  sb(BigPoweredVentHash, "Mode", 1);
  sb(flashingLights, "On", 1);
  sb(leds, "Color", 3);

  // Inhale
  while (lb(GasSensorHash, "Temperature", "Maximum") > 0) {
    yield();
  }

  self.Setting = 3;
  sleep(1);
  sb(BigPoweredVentHash, "On", 0);
  sb(MedPoweredVentHash, "On", 1);
  sb(MedPoweredVentHash, "Mode", 0);

  // Each door can open early as soon as its own room reaches its prior pressure threshold.
  while (lb(PipeAnalyzerHash, "Temperature", "Maximum") > 0) {
    if (sensorRoom1.Pressure >= (latestPressure2 * earlyOpenMultiplier)) {
      sb(leds, "Color", 5);
      if (openSide == 1) {
        doorExtRoom1.Open = 1;
      }
      else {          
        doorIntRoom1.Open = 1;
      }
    }
    if (sensorRoom2.Pressure >= (latestPressure1 * earlyOpenMultiplier)) {
      sb(leds, "Color", 5);
      if (openSide == 1) {
        doorIntRoom2.Open = 1;
      }
      else {
        doorExtRoom2.Open = 1;
      }
    }
    yield();
  }

  sleep(1);
  sb(MedPoweredVentHash, "On", 0);

  if (openSide == 1) {
    doorExtRoom1.Open = 1;
    doorIntRoom2.Open = 1;
    openSide = 0;
  } else {
    doorExtRoom2.Open = 1;
    doorIntRoom1.Open = 1;
    openSide = 1;
  }
}
