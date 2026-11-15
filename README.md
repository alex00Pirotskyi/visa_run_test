# VISA RUN — Balloon Mural Demo

Flutter Web, minimalist concrete-and-graffiti single-screen concept. The background is a **static procedural concrete shader** and a lightweight, faithful **vector reconstruction of the user-provided girl-and-balloon reference** (a few hundred contour points, with no PNG/JPEG downloads).

## Design

- Pale grainy concrete wall with tiny marks, no floor, shadow shafts or distracting seams
- Black stencil silhouette of a girl reaching towards a single **red heart balloon**
- Angled **VISA RUN** calendar near the upper-left corner, with selectable future days (current month and up to 12 months ahead)
- One `BOOK VISA RUN` graffiti-style button; pressing it shows a demo-only notice because booking is not configured
- Two separate black graffiti buttons: **WhatsApp** and **Telegram**. They display an honest not-configured notice until official contact links are supplied
- Tiny EN / RU language switch in the corner; on a first visit only the language picker appears
- Works on desktop and narrow phones: desktop mural occupies the background, mobile layout places the calendar above the artwork and contacts to the girl's left
- No large image assets, external fonts, looping animations, parallax, tracking, or backend

## Structure

- `lib/main.dart`: minimalist responsive scene, locale persistence with `shared_preferences`, demo notices
- `lib/balloon_mural.dart`: cached vector contour paths for the reference artwork, painting black and red
- `lib/graffiti_calendar.dart`: a real locally interactive monthly date picker in a roughly painted frame
- `lib/graffiti_widgets.dart`: existing reusable custom graffiti-style buttons and text components
- `shaders/concrete.frag`: fast static mineral-grain shader
- `lib/concrete_wall.dart`: subtle wall speckles and staining

## Local development

Flutter 3.47.2+:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter run -d chrome
```

## Demo limitations and rights

**Booking and contact details are not connected.** No requests, dates, or personal information are transmitted. The calendar only stores the selected date in widget state.

The girl's silhouette is an adaptation of artwork in a user-provided image. Check appropriate permissions before using that artwork in a public commercial site; a commissioned original is preferable for production.

## Deployment

GitHub repository: `alex00Pirotskyi/visa_run_test`.
Dedicated Cloudflare Worker: `visa-run-test`, separate from the production Evil Space Worker.
Intended domain: `https://visa-run-test.evils.space`.

To deploy from GitHub Actions, configure `CLOUDFLARE_API_TOKEN` and
`CLOUDFLARE_ACCOUNT_ID` as Actions secrets in **this** repository and run
`Deploy demo to Cloudflare`. A successful Flutter build does not by itself
mean the domain is live.
