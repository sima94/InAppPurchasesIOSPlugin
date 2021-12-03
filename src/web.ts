import { WebPlugin } from '@capacitor/core';

import type { InAppPurchasesPlugin } from './definitions';

export class InAppPurchasesWeb
  extends WebPlugin
  implements InAppPurchasesPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
