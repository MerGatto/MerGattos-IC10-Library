device controller = "d0"; // preferably occupancy sensor
const OccupancySensor = hash("StructureOccupancySensor");

const StructureConsoleMonitor = hash("StructureConsoleMonitor");
const StructureConsole = hash("StructureConsole");
const StructureConsoleDual = hash("StructureConsoleDual");
const StructureConsoleLED5 = hash("StructureConsoleLED5");
const StructureConsoleLED1x2 = hash("StructureConsoleLED1x2");
const StructureConsoleLED1x3 = hash("StructureConsoleLED1x3");
const StructureWallLight = hash("StructureWallLight");
const StructureDiode = hash("StructureDiode");
const StructureLightLong = hash("StructureLightLong");
const StructureLightLongAngled = hash("StructureLightLongAngled");
const StructureLightLongWide = hash("StructureLightLongWide");
const StructureDiodeSlide = hash("StructureDiodeSlide");
const StructureWallLightBattery = hash("StructureWallLightBattery");
const StructureLightRound = hash("StructureLightRound");
const StructureLightRoundAngled = hash("StructureLightRoundAngled");
const StructureLightRoundSmall = hash("StructureLightRoundSmall");

loop {
  yield();
  let turnOn = lb(OccupancySensor, "Activate", "Minimum");
  sb(StructureConsoleMonitor, "On", turnOn);
  sb(StructureConsole, "On", turnOn);
  sb(StructureConsoleDual, "On", turnOn);
  sb(StructureConsoleLED5, "On", turnOn);
  sb(StructureConsoleLED1x2, "On", turnOn);
  sb(StructureConsoleLED1x3, "On", turnOn);
  sb(StructureWallLight, "On", turnOn);
  //sb(StructureDiode, "On", turnOn);
  sb(StructureLightLong, "On", turnOn);
  sb(StructureLightLongAngled, "On", turnOn);
  sb(StructureLightLongWide, "On", turnOn);
  sb(StructureDiodeSlide, "On", turnOn);
  sb(StructureWallLightBattery, "On", turnOn);
  sb(StructureLightRound, "On", turnOn);
  sb(StructureLightRoundAngled, "On", turnOn);
  sb(StructureLightRoundSmall, "On", turnOn);
} 
