export const money = (value: number) => `${Math.round(value).toLocaleString('fr-FR')} DJF`;
export type Locale = 'fr' | 'en' | 'ar';
export function localized(row: Record<string, any>, field: string, locale: Locale) {
  return row[`${field}_${locale}`] || row[`${field}_fr`] || row[field] || '';
}
export function whatsappNumber(value: string) { return value.replace(/[^\d]/g, ''); }
