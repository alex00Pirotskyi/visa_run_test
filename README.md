# VISA RUN — Street Art × Liquid Glass (Flutter Web)

A minimal, premium **Flutter Web** prototype built around a still concrete mural and its single red heart balloon.

## Material design

The graffiti and concrete remain part of one completely static artwork. UI is limited to three compact optical-glass capsules: **Book Visa Run**, **WhatsApp** and **Telegram**. A small glass **EN / RU** control is at the top right. All UI ink is black/white; **the balloon is the only red accent**.

- First visit: only language choice (ENGLISH / РУССКИЙ). The choice is persisted in local browser `shared_preferences` as `visa_run_language`
- Returning visitors: only mural, small top identity, tiny language control and three actions
- Tap **Book Visa Run** to reveal a compact frosted-glass calendar; select a future date then Continue. This prototype has **no booking backend**, so it shows demo feedback
- WhatsApp and Telegram actions explicitly show a not-configured message instead of opening fake contact links
- Calendar and controls are interactive and keyboard/focus accessible
- Desktop: booking capsule bottom-right; contacts bottom-left; calendar opens immediately above the booking control
- Phone: artwork displayed as a centered portrait crop with feathered edges, controls near the bottom, and the calendar as a bounded translucent panel above the controls

## Performance

- **No animated background**, no shader, no WebGL surface simulation, and no constantly repainted noise layer
- **One locally bundled WebP mural asset** from a 1000×562 source image. The initial bundled image is heavily compressed; the design is compatible with replacing it in place with the higher-quality WebP export without code changes
- Only glass controls and the opened date picker use localized clipped `BackdropFilter`, never the full screen
- Reduced-motion devices receive no backdrop blur and no scale animation
- All parts of the page, including the mural, share the same scroll coordinates

Project structure: `lib/main.dart` responsive composition, `lib/liquid_glass.dart` glass materials and controls, `lib/glass_calendar.dart` interactive calendar, `lib/graffiti_widgets.dart` stencil font treatment.

## Run

Flutter 3.47.2+:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter run -d chrome
```

## Deploy

Isolated Cloudflare Worker: `visa-run-test`, intended domain `https://visa-run-test.evils.space`. Evil Space production remains untouched.

GitHub Actions needs `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as secrets for **this repo**; a passed Flutter build is not a published site. The workflow runs on `main`.

## Artwork rights

The supplied image depicts recognizable Banksy art; permission for public/commercial use must be cleared, or the mural replaced with an original licensed artwork. The current site is a visual demo, not a commercial booking service.
