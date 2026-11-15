# VISA RUN — Concrete × Glass × Graffiti

An original, minimal **Flutter Web** visa-run demo. The design combines a quiet **Kindle-like warm concrete surface**, large black stencil lettering, a crisp vector coach-bus mural, and an **always-open** Liquid Glass calendar.

## Design

- **Real vector bus:** `lib/bus_mural.dart` contains approximately 91 scalable even-odd contours traced from the user's reference bus image. The outlines, windows, wheels, door, overspray and subtle drips remain crisp on high-DPI desktop and mobile screens. No raster bus is downloaded or stretched.
- **Quiet cast-concrete background (Option A):** `shaders/concrete.frag` produces very soft mineral variation, fine grain and rare pores using just one noise octave plus a grain sample. `lib/concrete_scene.dart` draws a single uninterrupted matte warm-gray surface (`#C9C6C1`), a nearly invisible daylight falloff and only **one vertical and one horizontal hairline seam**. There is **no floor, perspective, strong spotlight, shadow beam, or separate pore-drawing loop**. Its static painter remains in a `RepaintBoundary` with a flat fallback if the shader cannot load.
- **Stenciled typography:** `StencilText` draws faded, chipped black spray lettering; the title receives a few black paint drips.
- **Glass controls:** `lib/liquid_glass.dart` implements bounded `BackdropFilter` and glossy edges for just the calendar and three small top controls. The calendar now uses explicit top/bottom white-gradient opacities of **78% / 69%**; localized blur is kept low so the bus lines remain visible. WhatsApp, Telegram and EN/RU retain their own glass settings. The glass is an approximation of Apple's optical material, not an Apple-native implementation.
- **One direct booking interaction:** **the calendar is open by default** after the language is chosen. Selecting a date is immediately possible; its internal Continue button displays a demo acknowledgement. **There is no extra Book/open-calendar button and no close-to-open modal.**
- **Responsive:** desktop extends the bus graffiti underneath the calendar on the right; the calendar paints on top. On phones and tablets, the vector bus is layered *behind* the immediately usable calendar rather than placed in a separate section. It scales proportionally to the available padded viewport width (never exceeds the screen), including 320px screens. Both stay together while scrolling.

## Languages and prototype limitations

The first visit displays only ENGLISH and РУССКИЙ on the concrete. A choice is stored locally using `shared_preferences` under `visa_run_language`; subsequent visits show the calendar immediately. The header language switch can change it at any time.

The date picker supports current/future dates through 12 months ahead and is **not connected to availability, booking, payment, or message delivery**. WhatsApp and Telegram controls show honest not-configured notices until the business's real links are provided.

No continuous animation, heavy wallpaper bitmap, or full-screen blur. The concrete fragment shader now uses **5 hash evaluations per pixel**, down from 9 in the previous revision (one subdued mineral octave plus one fine-grain sample), and no time uniforms. The painter no longer draws architectural beams, floor gradients, or hundreds of individual pore circles. The non-overlapping WhatsApp/Telegram capsules share an efficient backdrop capture; the glass calendar remains independently blurred so the bus graffiti still appears through it. Redundant old graffiti controls and their code have been removed. The vector is an original trace of the user-provided bus illustration, avoiding recognizable third-party graffiti art.

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

The separate Cloudflare Worker is `visa-run-test` with target **`visa-run-test.evils.space`**; the existing production Evil Space Worker is not altered. The CI workflow builds/tests once on each push to main, reports bundle size and uploads the release output. On a successful main push, the deployment workflow reuses that exact verified output without recompiling. Manual deployments still build locally within the manual job. Set `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` in this repository's GitHub Actions secrets before deployment; successful Flutter checks do not automatically mean the site was published.
