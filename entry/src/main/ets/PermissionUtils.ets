import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { vibrator } from '@kit.SensorServiceKit';

const TAG: string = '[PublishOperation]';
const DOMAIN_NUMBER: number = 0xFF00;

export default async function getPermission(context: common.UIAbilityContext): Promise<void> {
  notificationManager.isNotificationEnabled().then((data: boolean) => {
    if (!data) {
      notificationManager.requestEnableNotification(context).then(() => {
        hilog.info(DOMAIN_NUMBER, TAG, '[ANS] requestEnableNotification success');
      }).catch((err : BusinessError) => {
        if (1600004 === err.code) {
          hilog.error(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
        } else {
          hilog.error(DOMAIN_NUMBER, TAG, `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
        }
      });
    }
  }).catch((err : BusinessError) => {
    hilog.error(DOMAIN_NUMBER, TAG, `isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
  });
}

export function sendReminder() {
  let targetReminderAgent: reminderAgentManager.ReminderRequestTimer = {
    reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
    triggerTimeInSeconds: 10,
    actionButton: [
      {
        title: 'close',
        type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
      }
    ],
    wantAgent: {
      pkgName: 'com.hmosdemos.wearable.grow_your_pet',
      abilityName: 'EntryAbility'
    },
    title: 'Isabella',
    content: 'I need you!!',
    expiredContent: 'Isabella needed you..',
    notificationId: 100,
    slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
  };
  reminderAgentManager.publishReminder(targetReminderAgent).then((res: number) => {
    startVibration('alarm', 1000);
    console.info('Succeeded in publishing reminder. ');
  }).catch((err: BusinessError) => {
    console.error(`Failed to publish reminder. Code: ${err.code}, message: ${err.message}`);
  });
}

export function startVibration(usage: string, duration: number) {
  try {
    vibrator.startVibration({
      type: 'time',
      duration: duration
    }, {
      id: 0,
      usage: usage
    }, (error: BusinessError) => {
      if (error) {
        console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.info('Succeed in starting vibration');
    });
  } catch (err) {
    let e: BusinessError = err as BusinessError;
    console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
  }
}

let isPurring = false;
/**
 * Simulates a cat purring using multiple short vibrations
 */
export function startPurrVibration() {
  if (isPurring) return;
  isPurring = true;
  const purrCount = 3;
  let count = 0;
  const interval = setInterval(() => {
    startVibration('notification', 200);
    count++;
    if (count >= purrCount) {
      clearInterval(interval);
      isPurring = false;
    }
  }, 400);
}
