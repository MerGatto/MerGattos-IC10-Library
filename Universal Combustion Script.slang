// EXPERIMENTAL, doesnt quite work yet
device self = "db";

const REAGENT_CAPACITY = 2990;
const TIMEOUT = 2;
const RPM_TEMP_RATIO = 0.04;
const EMPTY_TIMEOUT = 10;
const RPMPS = 2;
const centrifugeHash = hash("StructureCombustionCentrifuge");

let isCentrifuge = self.PrefabHash == centrifugeHash;
let latestRpm = self.Rpm;
let latestStress = self.Stress;

loop {
    sleep(1);
    let currentRpm = self.Rpm;
    let currentStress = self.Stress;

    let rpmDelta = currentRpm - latestRpm;
    let stressDelta = currentStress - latestStress;
    latestRpm = currentRpm;
    latestStress = currentStress;

    if (isCentrifuge
      && (self.Reagents >= REAGENT_CAPACITY
          || self.Error == 1
          || self.Open == 1))
    {
        let previousReagents = self.Reagents;
        let timeout = 0;
        self.Throttle = 0;
        self.CombustionLimiter = 0;
        self.Open = 1;
        while (self.Reagents > 1 && timeout <= EMPTY_TIMEOUT) {
            sleep(2);
            if (previousReagents == self.Reagents) {
                timeout = timeout + 1;
            }
            previousReagents = self.Reagents;
        }
        self.Open = 0;
        continue;
    }

    if (currentRpm < 10 && currentStress > 30) {
        while (self.Stress > 0) {
            self.Throttle = 0;
            self.CombustionLimiter = 0;
            yield();
        }
        continue;
    }

    let desiredDelta = 0;
    if (rpmDelta <= 0) {
        desiredDelta = 10;
    } else if (rpmDelta > RPMPS && currentStress > 5) {
        if (stressDelta > 0) {
            desiredDelta = -10;
        }
    } else if (stressDelta <= 0) {
        desiredDelta = 10;
    }

    let currentSetting = self.Throttle + desiredDelta;
    if (desiredDelta <= 0) {
        self.Throttle = currentSetting;
        self.CombustionLimiter = 0;
    } else {
        // too hot?
        if ((currentRpm / self.Temperature) < RPM_TEMP_RATIO) {
            if (currentStress > 5) {
                continue;
            }
            self.Throttle = currentSetting;
            self.CombustionLimiter = 30;
            sleep(1);
            self.Throttle = 0;
            self.CombustionLimiter = 0;
        } else {
            self.Throttle = currentSetting;
            self.CombustionLimiter = currentSetting;
            if (rpmDelta <= 0) {
                self.CombustionLimiter = currentSetting / 2;
            }
        }
    }

    sleep(TIMEOUT);
}
