# FlutterCon USA 2026

A companion app for [FlutterCon USA 2026](https://www.flutterconusa.dev) (OCCC West Concourse, Orlando, FL), built with Flutter.

This app is not affiliated with or endorsed by FlutterCon.

## Features

- **Sessions** — browse the full agenda by day, filter by track, and search by session title or speaker name.
- **Schedule** — bookmark sessions to build your personal conference schedule, persisted locally on device.
- **Speakers** — an overview of all speakers with bios, session listings, and social links.

## Getting started

```bash
flutter pub get
flutter run
```

## Conference data

The app ships with a local snapshot of the [Sessionize](https://sessionize.com) data behind the official [FlutterCon agenda](https://www.flutterconusa.dev/fluttercon-agenda):

| File | Contents | Sessionize view |
| --- | --- | --- |
| `assets/data/sessions.json` | Agenda grouped by day and room | `GridSmart` |
| `assets/data/speakers.json` | Speaker profiles, links, and Q&A | `Speakers` |

The data is loaded and parsed at startup by `lib/_utils/data/conference_data.dart`.

### Updating the dataset

The event's Sessionize API ID is `qed220fq`. To refresh the snapshot, fetch the two views and overwrite the asset files:

```bash
curl https://sessionize.com/api/v2/qed220fq/view/GridSmart -o assets/data/sessions.json
curl https://sessionize.com/api/v2/qed220fq/view/Speakers -o assets/data/speakers.json
```

Then do a full restart of the app (the data is only parsed once at launch).
