import { ArcList, ArcListItem, LengthMetrics, ComponentContent } from '@kit.ArkUI';

@Builder
function buildText() {
  Column() {
    Text($r('app.string.cat_name'))
      .fontSize('44px')
      .fontWeight(FontWeight.Bolder)
      .fontStyle(FontStyle.Italic)
      .fontColor($r('app.color.primary_pink'))
    Text($r('app.string.wash_her_love_her'))
      .fontSize('24px')
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.primary_pink'))
      .textAlign(TextAlign.Center)
  }
  .width('100%')
  .padding({ bottom: 10 })
}

interface StatusItem {
  id: string;
  label: Resource;
  value: number;
  color: Resource;
}

@Entry
@Component
export struct StatusPage {
  @StorageLink('love') loveStatus: number = 5;
  @StorageLink('hungry') hungryStatus: number = 5;
  @StorageLink('wash') cleanStatus: number = 5;
  context: UIContext = this.getUIContext();
  tabBar1: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildText));

  getStatuses(): StatusItem[] {
    return [
      { id: 'wash', label: $r('app.string.cleaning_status', this.cleanStatus), value: this.cleanStatus, color: $r('app.color.clean_blue') },
      { id: 'love', label: $r('app.string.love_status', this.loveStatus), value: this.loveStatus, color: $r('app.color.primary_pink') },
      { id: 'hungry', label: $r('app.string.hungry_status', this.hungryStatus), value: this.hungryStatus, color: $r('app.color.hungry_orange') }
    ];
  }

  build() {
    Stack() {
      ArcList({ header: this.tabBar1, initialIndex: 0 }) {
        ForEach(this.getStatuses(), (item: StatusItem) => {
          ArcListItem() {
            Column() {
              Text(item.label)
                .fontColor($r('app.color.text_main'))
                .fontSize(14)
                .margin({ bottom: 5 })

              Gauge({ value: item.value, min: 0, max: 100 })
                .startAngle(210)
                .endAngle(150)
                .colors([[item.color, 1]])
                .strokeWidth(10)
                .width(120)
                .height(120)
                .description(null)
                .indicator(null)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }.key(item.id)
        }, (item: StatusItem) => item.id)
      }
      .space(LengthMetrics.px(20))
      .height('100%')
      .width('100%')
    }
    .backgroundColor($r('app.color.page_background'))
  }
}
