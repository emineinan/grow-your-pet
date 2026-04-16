import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DbHelper } from '../utils/DbHelper';
import { SensorHelper } from '../utils/SensorHelper';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // Initialize with default values first to avoid race conditions in UI
    if (AppStorage.get<number>('love') === undefined) {
      AppStorage.setOrCreate('love', 50);
      AppStorage.setOrCreate('hungry', 50);
      AppStorage.setOrCreate('wash', 50);
    }

    // Trigger async loading of data
    this.loadData();
  }

  private async loadData() {
    await DbHelper.getInstance().init(this.context);
    const status = await DbHelper.getInstance().getStatus();
    if (status) {
      AppStorage.setOrCreate('love', status.love);
      AppStorage.setOrCreate('hungry', status.hungry);
      AppStorage.setOrCreate('wash', status.wash);
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    SensorHelper.getInstance().startPedometer();
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    SensorHelper.getInstance().stopPedometer();
    const love = AppStorage.get<number>('love') || 0;
    const hungry = AppStorage.get<number>('hungry') || 0;
    const wash = AppStorage.get<number>('wash') || 0;
    DbHelper.getInstance().updateStatus({ id: 1, love, hungry, wash });
  }
}
