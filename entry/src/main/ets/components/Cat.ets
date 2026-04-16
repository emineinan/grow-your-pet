import getPermission, { sendReminder } from '../PermissionUtils';
import { common } from '@kit.AbilityKit';
import { DbHelper } from '../utils/DbHelper';

@Component
export struct Cat {
  @StorageLink('love') @Watch('checkCatStatus') loveStatus: number = 0;
  @StorageLink('hungry') @Watch('checkCatStatus') hungryStatus: number = 0;
  @StorageLink('wash') @Watch('checkCatStatus') cleanStatus: number = 0;
  @State cat: string = 'app.media.cat';
  @State textMessage: Resource = $r('app.string.im_happy');
  private intervalId: number = 0;
  private reminderSent: boolean = false;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private reduceValues() {
    if (this.intervalId !== 0) {
      return;
    }

    this.intervalId = setInterval(() => {
      if (this.cleanStatus > 5) {
        this.cleanStatus -= 5;
      }
      if (this.hungryStatus > 5) {
        this.hungryStatus -= 5;
      }
      if (this.loveStatus > 5) {
        this.loveStatus -= 5;
      }

      this.checkCatStatus();
      this.saveToDb();

      if (!this.reminderSent &&
        (this.cleanStatus <= 20 || this.hungryStatus <= 20 || this.loveStatus <= 20)) {
        sendReminder();
        this.reminderSent = true;
      }

    }, 30000); // Reduce every 30 seconds for better playability
  }

  private saveToDb() {
    DbHelper.getInstance().updateStatus({
      id: 1,
      love: this.loveStatus,
      hungry: this.hungryStatus,
      wash: this.cleanStatus
    });
  }

  checkCatStatus() {
    if (this.cleanStatus <= 40) {
      this.cat = 'app.media.dirty';
      this.textMessage = $r('app.string.wash_me');
    } else if (this.hungryStatus <= 40) {
      this.cat = 'app.media.hungry';
      this.textMessage = $r('app.string.feed_me');
    } else if (this.loveStatus <= 40) {
      this.cat = 'app.media.sad';
      this.textMessage = $r('app.string.love_me');
    } else {
      this.cat = 'app.media.happy';
      this.textMessage = $r('app.string.im_happy');
      this.reduceValues();
    }
  }

  aboutToAppear(): void {
    getPermission(this.context);
    this.checkCatStatus();
  }

  build() {
    Column() {
      Text(this.textMessage)
        .fontColor($r('app.color.text_sub'))
        .fontSize(24)
      Image($r(this.cat))
        .height('100%')
        .width('100%')
    }
  }
}
