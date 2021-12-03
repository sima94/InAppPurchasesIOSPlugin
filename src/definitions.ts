export interface InAppPurchasesPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
