import { StatusPage } from './StatusPage';
import { CatPage } from './CatPage';

@Entry
@Component
struct Index {

  build() {
    Swiper() {
      StatusPage()
      CatPage()
    }
    .backgroundColor($r('app.color.page_background'))
    .indicator(DotIndicator.dot().color($r('app.color.indicator_color')).selectedColor($r('app.color.primary_pink')))
    .autoPlay(false)
    .height('100%')
    .width('100%')
  }
}
