import { registerPlugin } from '@capacitor/core';

import type { InAppPurchasesPlugin } from './definitions';

const InAppPurchases = registerPlugin<InAppPurchasesPlugin>('InAppPurchases', {
  web: () => import('./web').then(m => new m.InAppPurchasesWeb()),
});

export * from './definitions';
export { InAppPurchases };
