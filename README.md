# Amour Et Sincérité

A Flutter dating app — *rencontres* — with swipe matching, real-time chat and
location-based discovery, localised in French.

## Features

| Module | What it does |
|---|---|
| `discover` | Swipe deck of nearby profiles, with like / pass actions |
| `matches` | Mutual likes, shown as match cards |
| `messages` · `chat` | Real-time conversations over Socket.IO |
| `profile` · `edit_profile` · `profile_setup` | Photos, details and first-run onboarding |
| `plans` | Subscription plans |
| `auth` · `settings` · `splash` | Sign-in, preferences, launch |

## Stack

- **Flutter** (Dart SDK `^3.12`)
- **GetX** for state, routing and dependency injection; `get_storage` for local persistence
- **Socket.IO** client for live messaging
- **Geolocator** for location-based discovery
- **Image Picker** for profile photos
- **http** REST client against the backend API

## Structure

```
lib/app/
├── core/
│   ├── constants/      API endpoints, images, filter and settings options
│   ├── localization/   translations and keys
│   ├── theme/          colours and app theme
│   └── widgets/        swipe deck, swipe card, match card, avatar, shimmer
├── data/
│   ├── models/         user, match, message, plan, profile details
│   ├── providers/      API client
│   ├── repositories/   user, message, plan
│   └── services/       auth, socket
└── modules/            one folder per screen, listed above
```

Each module pairs a GetX controller with its view, so a screen's state lives
beside the widget that renders it.

## Running

```bash
flutter pub get
flutter run
```

The API base URL lives in `lib/app/core/constants/api_constants.dart`.
`lib/app/core/dev_flags.dart` holds development switches.
