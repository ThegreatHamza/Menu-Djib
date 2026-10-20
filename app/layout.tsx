import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'Menu Djib — Menus & commandes QR', description: 'Menus digitaux et commandes WhatsApp pour les restaurants de Djibouti.' };
export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) { return <html lang="fr"><body>{children}</body></html>; }
