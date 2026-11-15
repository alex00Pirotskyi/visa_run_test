# VISA RUN — image-first graffiti wall

Lightweight, minimal Flutter Web demo for a visa-run company. Built for the user's reference image: a black stencil girl and one red heart balloon on pale concrete. The background is shipped as a **small local WebP asset**, not an approximation drawn from an animated shader.

## Visual architecture

- `assets/images/banksy_wall.webp`: compressed 840px-wide copy of the user's uploaded image (about 10 KB); packaged locally with Flutter
- `lib/main.dart`: clean, single image-overlay composition on desktop; mobile preserves the picture's proportions and shows a complete girl + heart composition beneath the calendar
- `lib/graffiti_calendar.dart`: a real selectable date grid, slightly rotated, with no filled card or opaque panel
- `lib/transparent_stencil_button.dart`: reusable outline-only stencil graffiti actions for booking, WhatsApp and Telegram
- `lib/graffiti_widgets.dart`: reusable weathered stencil lettering
- Small `EN / RU` language switch with saved choice via `shared_preferences`, first visit shows only English/Russian selector

No GPU wall shader, parallax, JS library, external CDN, looping animation, or full-screen blur is used. Both the picture and the controls scroll as one wall.

## Demo behavior

The calendar can select dates, but no live availability or booking backend exists. Booking and contact taps show clear demo notices rather than opening nonexistent services. No form data is transmitted. Set your friend's official WhatsApp and Telegram links and booking endpoint before production use.

## Develop

Flutter 3.47.2+:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter run -d chrome
```

## Deploy

Dedicated Cloudflare Worker `visa-run-test`, custom domain `visa-run-test.evils.space`. The existing Evil Space Worker is unaffected.

Set GitHub Actions secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` on the new repository, then rerun `Deploy demo to Cloudflare`. A successful Flutter build alone does not mean the website is live.

## Rights

The image is from the user's uploaded reference, depicting a recognizable work by Banksy. Keep the demo private for review until rights for public/commercial use are clarified, or commission a distinct original mural.
