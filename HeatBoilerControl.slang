device self = "db";
device fuelPump = "d0";
device extractorPump = "d1";
device igniter = "d2";
device tankAnalyzer = "d3";
device boilerAnalyzer = "d4";

// Pressures are in kPa (40 MPa = 40_000 kPa).
const TANK_TARGET_PRESSURE = 40_000;
const BOILER_PRESSURE_LIMIT = 30_000;
const BOILER_EMPTY_PRESSURE = 500;
const MAX_OXIDIZER_RATIO = 0.01;
const MAX_FUEL_OXIDIZER_RATIO = 0.10;
let extractorLatched = 0;

loop {
  yield();

  let tankNeedsHeat = tankAnalyzer.Pressure < TANK_TARGET_PRESSURE;
  let boilerPressure = boilerAnalyzer.Pressure;
  let boilerLowPressure = boilerPressure < BOILER_PRESSURE_LIMIT;
  let boilerHighPressure = boilerPressure > BOILER_PRESSURE_LIMIT;
  let boilerEmpty = boilerPressure <= BOILER_EMPTY_PRESSURE;

  // "All oxidizers"
  // also treat hydrazine as oxidizer for the purpose of this script
  let oxidizerRatio = boilerAnalyzer.RatioOxygen
                    + boilerAnalyzer.RatioNitrousOxide
                    + boilerAnalyzer.RatioOzone
                    + boilerAnalyzer.RatioHydrazine;
  let oxidizersLowEnough = oxidizerRatio < MAX_OXIDIZER_RATIO;
  let fuelOxidizersLowEnough = oxidizerRatio < MAX_FUEL_OXIDIZER_RATIO;

  let canExtractNow = tankNeedsHeat && oxidizersLowEnough;
  if (!canExtractNow || boilerEmpty) {
    extractorLatched = 0;
  } else if (boilerHighPressure) {
    extractorLatched = 1;
  }

  // Starts only above BOILER_PRESSURE_LIMIT, then keeps running until boiler is empty.
  let extractorOn = canExtractNow && (extractorLatched == 1);

  // Interlock: fuel pump must never run while extractor runs.
  fuelPump.On = tankNeedsHeat
             && boilerLowPressure
             && fuelOxidizersLowEnough
             && !extractorOn;
  extractorPump.On = extractorOn;

  // Keep ignition active when combustion is out and we still need heat gas.
  igniter.Activate = tankNeedsHeat && (boilerAnalyzer.Combustion == 0);
}
