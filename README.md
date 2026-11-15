# VISA RUN — Concrete / stencil demo

Original art-directed Flutter Web landing page. Purpose: **visual-only prototype** for a visa-run company. It does not process bookings, applications, payments, travel documents, or personal information.

## Visual language

- A **static GPU fragment shader** draws a quiet, gently porous concrete wall, with no vignette, strong mottling, or animation. The app provides a solid-colour fallback if shader initialization fails.
- A custom Flutter painter draws an original anonymous traveler, a spray-paint sun, motion marks and paint spatters. No third-party images or Banksy artworks are used.
- Black editorial stencil-like display, slightly translucent ink, limited distressed red, flat painted controls, editorial responsive composition.
- Buttons have pointer hover, keyboard focus and tap visual feedback, but intentionally **do nothing**.
- **The wall scrolls with the typography and painted art**, so there is no fixed background/parallax separation. Pigment flecks sit above the ink and move with it. The wall has a separate repaint boundary and no animation frames. No external fonts or packages.

## Development

Use Flutter 3.47.2+.

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
flutter build web --release
```

## Cloudflare Workers

This is a completely separate deployment from `evil-space`. Worker name: `visa-run-test`. Target HTTPS custom domain: **https://visa-run-test.evils.space**. The underscore version is not valid for a public HTTPS hostname.

The Worker uses static assets directly from `build/web`; there is **no database**, API, secret, or paid resource. It is intended to run on a Cloudflare Workers free account within its free usage limits.

Set the following GitHub Actions secrets **on this repository** (never commit their values): `CLOUDFLARE_API_TOKEN` (Workers Scripts Edit, appropriate zone rights) and `CLOUDFLARE_ACCOUNT_ID`. Enable Actions, then run **Deploy demo to Cloudflare** or push to `main`. Wrangler's `custom_domain = true` requests Cloudflare to associate the domain on deploy. The `evils.space` DNS zone must already be in the same Cloudflare account; conflicts or missing token permissions require a manual dashboard fix.

For local deployment with authenticated Wrangler:

```sh
flutter build web --release
npx wrangler@4 deploy
```

**Important:** The GitHub source is committed but deployment isn't complete until the workflow succeeds with credentials and the hostname resolves. Do not modify the `evil-space` Worker or its routes.
