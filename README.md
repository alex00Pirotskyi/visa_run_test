# VISA RUN — Painted-on-concrete Flutter prototype

An original black-stencil graffiti website concept for visa runs, built entirely in **Flutter Web**. This is a **design-only demo**: there are no working bookings, messages, application forms, or real visa services.

## Visual direction

The web UI is a mural painted onto a believable architectural concrete wall, not floating cards over a texture.

- **`shaders/concrete.frag`** — static low-frequency mineral clouding, concrete pores, grain and aggregate. No time uniform or animation loop
- **`lib/concrete_wall.dart`** — panel seams, form-tie holes, directional diagonal sunlight and hard-edged window shadows on a concrete floor; one stable `CustomPainter` pass
- **`lib/stencil_mural.dart`** — original vector stencil artwork featuring a walking backpacker, rolling suitcase, airport sign, plane and border-control icon
- **`lib/graffiti_widgets.dart`** — reusable weathered `StencilText`, `GraffitiButton`, `GraffitiTextField`; chipped ink, spray and drip details, all drawn by Flutter
- **`lib/main.dart`** — responsive composition; real text field can accept demo text but never transmits it. Stencil-themed language switch
- **`lib/visa_i18n.dart`** — English and Russian UI copy

**Lightweight by design:** no full-screen raster backgrounds, external font downloads, canvas animation, parallax, third-party image requests, or UI animation timers. The shader and paint layers are static and wrapped in repaint boundaries, scrolling as a single wall.

The design was informed by the user's approved black stencil travel-mural mockup; no existing Banksy artwork is reproduced.

## Languages

First visit displays **only** ENGLISH and РУССКИЙ on the wall. Once selected, the complete mural appears in the selected language; Flutter Web `shared_preferences` stores the code locally under `visa_run_language`. Returning visitors skip the picker. The `EN / RU` control allows switching later. Without browser storage, the session is still usable.

## Develop and test

Flutter 3.47.2 or newer:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter run -d chrome
```

The CI tests exercise first-visit language choice, both languages, persistence, responsive layouts, wall scrolling, and editing a demo field.

## Cloudflare deployment

The project is separate from Evil Space: standalone Worker `visa-run-test`, target URL **https://visa-run-test.evils.space**. Its Worker assets are the Flutter release build, no D1 or API required. A deployment job triggers on `main`.

To publish, add repository Actions secrets **`CLOUDFLARE_API_TOKEN`** and **`CLOUDFLARE_ACCOUNT_ID`**, scoped for the correct Cloudflare account and domain, and rerun **Deploy demo to Cloudflare**. The GitHub build may pass before the site is actually deployed.

Do not modify or reuse the existing production `evil-space` Worker.
