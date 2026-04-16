import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class SensorHelper {
  private static instance: SensorHelper;
  private isListening: boolean = false;
  private lastStepCount: number = -1;

  private constructor() {}

  public static getInstance(): SensorHelper {
    if (!SensorHelper.instance) {
      SensorHelper.instance = new SensorHelper();
    }
    return SensorHelper.instance;
  }

  public startPedometer() {
    if (this.isListening) return;
    try {
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        console.info(`Pedometer data: ${data.steps}`);
        if (this.lastStepCount === -1) {
          this.lastStepCount = data.steps;
        } else {
          const delta = data.steps - this.lastStepCount;
          if (delta >= 10) {
            this.updatePetEnergy(delta);
            this.lastStepCount = data.steps;
          }
        }
      }, { interval: 100000000 }); // 100ms
      this.isListening = true;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(`Failed to start pedometer. Code: ${e.code}, message: ${e.message}`);
    }
  }

  public stopPedometer() {
    if (!this.isListening) return;
    try {
      sensor.off(sensor.SensorId.PEDOMETER);
      this.isListening = false;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(`Failed to stop pedometer. Code: ${e.code}, message: ${e.message}`);
    }
  }

  private updatePetEnergy(delta: number) {
    // Every 10 steps increases hunger/love/wash by 1
    const increment = Math.floor(delta / 10);
    if (increment > 0) {
      let love = AppStorage.get<number>('love') || 0;
      let hungry = AppStorage.get<number>('hungry') || 0;
      let wash = AppStorage.get<number>('wash') || 0;

      AppStorage.setOrCreate('love', Math.min(100, love + increment));
      AppStorage.setOrCreate('hungry', Math.min(100, hungry + increment));
      AppStorage.setOrCreate('wash', Math.min(100, wash + increment));
    }
  }
}
