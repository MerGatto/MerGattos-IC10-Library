device self = "db";
device liquidSwitch = "d0";

const ProduceLiquids = false;
const HasLiquidSwitch = false;
const TemperatureLimit = 0;
//const MaxTempDelta = 110;
const ACHash = hash("StructureAirConditioner");


const maxLayer = 3;
const layer0Name = hash("0");
const layer1Name = hash("1");
const layer2Name = hash("2");
const layer3Name = hash("3");

// for venus start 129c minimum setup
 // Hcl on Venus with 500kpa input pressure (20kw cooling with total 6 units)
const layer0TargetTemp = 100c;
 // Hcl on Venus with 500kpa input pressure (20kw cooling with total 6 units)
const layer1TargetTemp = 60c;
const layer2TargetTemp = -30c;
const layer3TargetTemp = 0;


let i = -1;
let currentLayerName = layer0Name;
let currentTempLimit = layer0TargetTemp;

loop {
    yield();
    let minSetting = lb(ACHash, "Setting", "Minimum");
    let maxSetting = lb(ACHash, "Setting", "Maximum");
    let IsCooling = true;
    if ((minSetting <= 20c && maxSetting >= -265c) || minSetting > 998c) {
      IsCooling = false;
    }

    if (IsCooling) {
        sb(ACHash, "Setting", -270c);
    } else {
        sb(ACHash, "Setting", 999c);
    }
    sb(ACHash, "On", true);
    //let turnOff = self.Open;

    let produceLiquids = ProduceLiquids;
    if (HasLiquidSwitch) {
      produceLiquids = liquidSwitch.Setting;
    }

    i = i+1;
    if (i > 3) {
      i = 0;
      currentLayerName = layer0Name;
      currentTempLimit = layer0TargetTemp;
    }

    if (i == 1) {
      currentLayerName = layer1Name;
      currentTempLimit = layer1TargetTemp;
      }
    if (i == 2) {
      currentLayerName = layer2Name;
      currentTempLimit = layer2TargetTemp;
      }
    if (i == 3) {
      currentLayerName = layer3Name;
      currentTempLimit = layer3TargetTemp;
      }

    let validAc =
      lbn(ACHash, currentLayerName, "PrefabHash", "Minimum") == ACHash;
    sbn(ACHash, currentLayerName, "On", true);
    let tempCoolside =
      lbn(ACHash, currentLayerName, "TemperatureOutput2", "Maximum");
    let temp2 =
      lbn(ACHash, currentLayerName, "TemperatureOutput", "Maximum");
    let tempDelta = abs(tempCoolside - temp2);
    let liquidOut =
      lbn(ACHash, currentLayerName, "RatioLiquidMethaneOutput2", "Maximum")
      + lbn(ACHash, currentLayerName, "RatioLiquidNitrogenOutput2", "Maximum");

    if (IsCooling) { 
      tempCoolside = temp2;
      liquidOut =
        lbn(ACHash, currentLayerName, "RatioLiquidMethaneOutput", "Maximum")
        + lbn(ACHash, currentLayerName, "RatioLiquidNitrogenOutput", "Maximum");
    }
    let tempOk = (tempCoolside > TemperatureLimit && tempCoolside > currentTempLimit)
                  || tempCoolside == 0;
    let pressureOk = true;
    let liquidOk = (produceLiquids && (liquidOut < 0.05)) || (liquidOut == 0);
    let activate = tempOk && pressureOk && liquidOk;
    sbn(ACHash, currentLayerName, "Mode", activate);
}
