# FF

**Finally, a fully fledged, frickin' fast Flutter framework!**

Forever free. Fantastically fabulous. Feature-first.

---

## Features

- **Feature-focused architecture** — FF facilitates a feature-first folder structure for Flutter apps
- **Frictionless state management** — Forget about boilerplate, FF fabricates state files for you
- **Fine-grained reactivity** — FF furnishes field-level watching, so frames refresh only for fields that flip
- **Flexible feature flavors** — From `FFReusableFeature` to `FFSimpleFeature`, find the fit for your flow

---

## Foundations: First-Time Setup

### 1. Fetch the FF Package

First, furnish your `pubspec.yaml` file with the ff framework:

```yaml
dependencies:
  ff:
    git:
      url: "https://github.com/HannesGitH/ff"
```

### 2. Fasten the ffeature Brick

FF features a Mason brick for fast feature scaffolding. First, form a `mason.yaml` file (if absent) and fill it with the following:

```yaml
bricks:
  ffeature:
    git:
      url: "https://github.com/HannesGitH/ff"
      path: bricks/ffeature
```

### 3. Fire Up the FF State Watcher

FF's file watcher fabricates state files for you. For VS Code folks, furnish your `.vscode/tasks.json` file with:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start ff generation",
      "type": "shell",
      "command": "nix run github:HannesGitH/ff -- --directory .",
      "presentation": {
        "reveal": "never",
        "panel": "new"
      },
      "isBackground": true,
      "runOptions": {
        "runOn": "folderOpen"
      }
    }
  ]
}
```

For folks favoring manual firing, just flash this in your terminal:

```bash
nix run github:HannesGitH/ff -- --directory .
```

---

## Forging Features

### Fabricate a Fresh Feature

Following the setup, fashioning a feature is frighteningly fast. Fire off Mason:

```bash
mason make ffeature --name YourFeatureName
```

FF forges the following folder formation:

```
your_feature_name/
├── controller.dart    # Feature controller for business flow
├── feature.dart       # Feature entry points and factory functions
├── model.dart         # ViewModel for formatting state for the frontend
├── state.dart         # State definition (ff-state flagged)
├── types.dart         # Type definitions for the feature
├── views/
│   └── main.dart      # Primary view for the feature
└── widgets/
    └── example.dart   # Fragment widgets for the feature
```

### Flag Your State for Generation

For FF to fabricate state files, flag your state class with the `ff-state` token:

```dart
import 'package:ff/ff.dart';
import 'package:flutter/widgets.dart';

part 'state.ff.dart';

// ff-state
class $YourFeatureState {
  const $YourFeatureState({
    required String firstName,
    required bool favoriteSelected,
  });

  static YourFeatureState initial() =>
      YourFeatureState.loading(firstName: '', favoriteSelected: false);
}
```

FF finds files flagged with `ff-state` and forges a `*.state.ff.dart` file featuring:

- `YourFeatureState` — Full state class with field metadata
- `YourFeatureStateWatched` — For fine-grained field-level reactivity
- `YourFeatureStateUnwatched` — For fast, full-state access
- Feature typedefs for `FFWidget`, `FFView`, `FFPresenter`, and more

---

## Fundamentals: How FF Functions

### Feature Architecture

FF follows a feature-first philosophy. Features form self-contained folders featuring:

1. **State** — Fields forming the feature's data
2. **Controller** — Functions for feature flow and firing state changes
3. **ViewModel** — Formats state for frontend friendliness
4. **Views** — Flutter widgets forming the feature's face

### Fine-Grained Field Watching

FF's foremost forte is fine-grained field-level watching. Features function as follows:

1. Fields in state are flagged with `FFPropWithMetadata`, furnishing both value and loading flags
2. Views fetch fields via the watched state (`state.watched(context).fieldName`)
3. FF's `InheritedModel` framework filters rebuilds — only widgets fetching a flipped field refresh
4. Fields flagged as "loading" furnish shimmer functionality for free

### FF State Watcher (Filesystem Watcher)

FF features a Rust-forged filesystem watcher for fabricating state files:

1. **File Monitoring** — Faithfully follows `.dart` files for fluctuations
2. **Flag Finding** — Finds the `ff-state` flag in file contents
3. **Fabrication** — Forges `*.ff.dart` files from Handlebars templates
4. **Fast Feedback** — File changes fire fresh generation in a flash

### Feature Flavors

FF furnishes four feature flavors for flexibility:

| Flavor | Function |
|--------|----------|
| `FFReusableFeature` | For features with one controller, forever reused |
| `FFReusableMultiFeature` | For features with controllers filed by parameter (e.g., `userId`) |
| `FFSimpleFeature` | For features forging fresh controllers for each entry |
| `FFFeature` | Foundation interface for all feature flavors |

---

## File Flow: From State to Screen

```
┌─────────────────┐
│   state.dart    │  ← Flag with ff-state
│  $FeatureState  │
└────────┬────────┘
         │ FF fabricates
         ▼
┌─────────────────┐
│ state.ff.dart   │  ← Full state with watching
│  FeatureState   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│   Controller    │ ←─► │    ViewModel    │
│  emit(state)    │     │ formats fields  │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     ▼
┌─────────────────────────────────┐
│            FFView               │
│  view.state.fieldName           │
│  (fine-grained field watching)  │
└─────────────────────────────────┘
```

---

## Frequently Found Fixes

### FF State File Fails to Form?

1. First, verify the `ff-state` flag features in your file
2. Firmly check the ff-watcher is functioning (`nix run github:HannesGitH/ff -- --directory .`)
3. Fret not about formatting — fix syntax, and FF will forge fresh files

### Fields Failing to Fire Rebuilds?

1. Fetch fields from `view.state` (the watched flavor), not `controller.state`
2. Forgetting `view.state.fieldName` means Flutter fails to flag field dependencies

---

## Further Findings

- **Forever Free** — FF follows the MIT license
- **Feedback Favored** — File issues for feature requests or fixes
- **Future Features** — FF is flourishing fast, follow for forthcoming functionality

---

*Fashioned with fervor for Flutter fanatics.* 🦋
