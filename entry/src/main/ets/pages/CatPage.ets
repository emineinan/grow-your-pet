import { Cat } from '../components/Cat';
import { startPurrVibration } from '../PermissionUtils';

@Entry
@Component
export struct CatPage {
  @StorageLink('wash') clean: number = 0;
  @StorageLink('hungry') hungry: number = 0;
  @StorageLink('love') loveStatus: number = 0;

  love() {
    if (this.loveStatus <= 90) {
      this.loveStatus = this.loveStatus + 10;
    } else {
      this.loveStatus = 100;
    }
    startPurrVibration();
  }

  wash() {
    if (this.clean <= 90) {
      this.clean = this.clean + 10;
    } else {
      this.clean = 100;
    }
  }

  feed() {
    if (this.hungry <= 90) {
      this.hungry = this.hungry + 10;
    } else {
      this.hungry = 100;
    }
  }

  build() {
    Stack() {
      // Background Cat
      Cat()
        .width('100%')
        .height('100%')

      // Controls - positioned for circular watch faces
      Column() {
        Row() {
          Button() {
            Image($r('app.media.soap'))
              .width(30)
              .height(30)
          }
          .type(ButtonType.Circle)
          .backgroundColor('#80000000') // Semi-transparent black
          .width(48)
          .height(48)
          .onClick(() => this.wash())

          Blank().width('40%')

          Button() {
            Image($r('app.media.heart'))
              .width(30)
              .height(30)
          }
          .type(ButtonType.Circle)
          .backgroundColor('#80000000')
          .width(48)
          .height(48)
          .onClick(() => this.love())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Blank().height('50%')

        Button() {
          Image($r('app.media.fish'))
            .width(30)
            .height(30)
        }
        .type(ButtonType.Circle)
        .backgroundColor('#80000000')
        .width(48)
        .height(48)
        .onClick(() => this.feed())
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
