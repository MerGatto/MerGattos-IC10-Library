device self = "db";
device larre = "d0";
device bin = "d1";

let step = 1;
let incrementLocation = false;
larre.Setting = 999;
let maxLocation = larre.Setting;
larre.Setting = -999;
let minLocation = larre.Setting;

let binLocation = -999;

fn waitLarre() {
  yield();
  let i = 0;
  while (larre.Idle == 0 && i < 60) {
    yield();
    i = i+1;
  }
}

loop {
  if (incrementLocation) {
    let counter = larre.PositionX + step;
    if (counter < minLocation || counter > maxLocation) {
      step = -step;
      counter = counter + step;
    }

    larre.Setting = counter;
    self.Setting = counter;
  }
  incrementLocation = false;

  waitLarre();

  bin.On = 1;
  bin.Open = (loadSlot(bin, 0, "Occupied") == 0);

  if (larre.TargetSlotIndex < 0) {
    incrementLocation = true;
    continue;
  }


  let maturingState = loadSlot(larre, 255, "Mature");
  //let seedingState = loadSlot(larre, 255, "Seeding");
  //let isPlantOccupied = loadSlot(larre, 255, "Occupied");
  let isArmOccupied = loadSlot(larre, 0, "Occupied");
  let isHopperOccupied = loadSlot(larre, 1, "Occupied");

  if (larre.TargetPrefabHash == bin.PrefabHash && binLocation == -999) {
    binLocation = larre.PositionX;
  }

  if (larre.PositionX == binLocation && isArmOccupied) {
    if (larre.TargetPrefabHash != bin.PrefabHash) {
      binLocation = -999;
      continue;
    }
    larre.Activate = 1;
    continue;
  }

  // does not account for reseed yet
  if (isArmOccupied) {
    if (
      (larre.TargetPrefabHash == hash("StructureHydroponicsTrayData")
      || larre.TargetPrefabHash == hash("StructureHydroponicsTray"))
      && !loadSlot(larre, 255, "Occupied")) {
      larre.Activate = 1;
      continue;
    }
    if (isHopperOccupied) {
      if (binLocation == -999) {      
        incrementLocation = true;
      }
      else {
        larre.Setting = binLocation;
        waitLarre();
      }
      continue;
    }
  }


  // we got something, check it
  // if is Plant
  if (loadSlot(larre, 255, "Class") == 11) {
    if (maturingState ) {
      larre.Activate = 1;
      continue;
    }
  }
  incrementLocation = true;
}
