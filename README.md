# VISA RUN — Concrete × Glass × Graffiti

An original, minimal **Flutter Web** visa-run demo. The approved design concept combines a realistic static concrete wall, large black stencil lettering, a crisp vector coach-bus mural, and an **always-open** Liquid Glass calendar.

## Design

- **Real vector bus:** `lib/bus_mural.dart` contains approximately 91 scalable even-odd contours traced from the user's reference bus image. The outlines, windows, wheels, door, overspray and subtle drips remain crisp on high-DPI desktop and mobile screens. No raster bus is downloaded or stretched.
- **Architectural wall:** `shaders/concrete.frag` is a static, time-free Flutter fragment shader creating mineral/grain variation. `lib/concrete_scene.dart` adds cast-concrete panel seams, window daylight, tiny pores, and a concrete floor. It renders inside a `RepaintBoundary`, with a painter fallback if shaders cannot load.
- **Stenciled typography:** `StencilText` draws faded, chipped black spray lettering; the title receives a few black paint drips.
- **Glass controls:** `lib/liquid_glass.dart` implements bounded `BackdropFilter` and glossy edges for just the calendar and three small top controls—WhatsApp, Telegram, EN/RU. The glass is an approximation of Apple's optical material, not an Apple-native implementation.
- **One direct booking interaction:** **the calendar is open by default** after the language is chosen. Selecting a date is immediately possible; its internal Continue button displays a demo acknowledgement. **There is no extra Book/open-calendar button and no close-to-open modal.**
- **Responsive:** desktop places the large mural and title left, contact capsules top-right, calendar right. Phones and tablets lead with an immediately usable calendar and present the vector bus below it; there is no overlap or fixed parallax.

## Languages and prototype limitations

The first visit displays only ENGLISH and РУССКИЙ on the concrete. A choice is stored locally using `shared_preferences` under `visa_run_language`; subsequent visits show the calendar immediately. The header language switch can change it at any time.

The date picker supports current/future dates through 12 months ahead and is **not connected to availability, booking, payment, or message delivery**. WhatsApp and Telegram controls show honest not-configured notices until the business's real links are provided.

No continuous animation, heavy wallpaper bitmap, or full-screen blur. The vector is an original trace of the user-provided bus illustration, avoiding recognizable third-party graffiti art.

## Run

Flutter 3.47.2+:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter run -d chrome
```

## Deployment

The separate Cloudflare Worker is `visa-run-test` with target **`visa-run-test.evils.space`**; the existing production Evil Space Worker is not altered. Set `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` in this repository's GitHub Actions secrets and run the deploy workflow. Successful Flutter builds do not automatically mean the site was published.
