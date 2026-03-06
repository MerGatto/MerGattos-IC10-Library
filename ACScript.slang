device self = "db";
device liquidSwitch = "d0";

const ProduceLiquids = false;
const HasLiquidSwitch = true;
const TemperatureLimit = -140c;
const MaxTempDelta = 100;
const ACHash = hash("StructureAirConditioner");


const layer0Name = hash("0");
const layer1Name = hash("1");
const layer2Name = hash("2");

let i = -1;
let currentLayerName = layer0Name;

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
    if (i > 2) {
      i = 0;
      currentLayerName = layer0Name;
    }

    if (i == 1) { currentLayerName = layer1Name;}
    if (i == 2) { currentLayerName = layer2Name;}

    let validAc =
      lbn(ACHash, currentLayerName, "PrefabHash", "Minimum") == ACHash;
    sbn(ACHash, currentLayerName, "On", true);
    let tempCoolside =
      lbn(ACHash, currentLayerName, "TemperatureOutput2", "Maximum");
    let temp2 =
      lbn(ACHash, currentLayerName, "TemperatureOutput", "Maximum");
    let tempDelta = abs(tempCoolside - temp2);
    let liquidOut =
      lbn(ACHash, currentLayerName, "RatioLiquidVolatilesOutput2", "Maximum")
      + lbn(ACHash, currentLayerName, "RatioLiquidNitrogenOutput2", "Maximum");

    if (IsCooling) { 
      tempCoolside = temp2;
      liquidOut =
        lbn(ACHash, currentLayerName, "RatioLiquidVolatilesOutput", "Maximum")
        + lbn(ACHash, currentLayerName, "RatioLiquidNitrogenOutput", "Maximum");
    }
    let tempOk = tempCoolside > TemperatureLimit && tempDelta <= MaxTempDelta;
    let pressureOk = true;
    let liquidOk = (produceLiquids && (liquidOut < 0.05)) || (liquidOut == 0);
    let activate = tempOk && pressureOk && liquidOk;
    sbn(ACHash, currentLayerName, "Mode", activate);
}
