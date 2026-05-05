# FaceFollow

**FaceFollow** is an iOS app I built when I was 18 to help people become more aware of their own emotions.  
It combines facial expression tracking, emoji‑based challenges, and emotion logging to create a playful yet introspective experience.

> Your face, your rules. Every emotion is valid.

---

> 🎥 **Watch the Demo video:** [YouTube Link](https://youtube.com/shorts/fnmfWX5HIUY)


## 📱 Overview

FaceFollow lets you:

1. **Record how you feel** – adjust sliders for Passion, Energy, and Positivity.
2. **Pick an emoji mask** – try to match the expression (smile, pout, wide eyes, raised or furrowed brows).
3. **Let the camera analyse your face** – the app shows real‑time tracking and gives a similarity score.
4. **Save your session** – add a comment and store the record.
5. **Review your history** – a calendar view shows past entries, and a scoreboard displays trends, streaks, and insights.

The goal is not to judge or “fix” your expressions, but to gently nudge you toward recognising your inner emotional state.

---

## ✨ Features

- **Face Landmark Tracking** (Vision framework) – detects eyes, eyebrows, lips, and face contour.
- **5 Emoji Challenges** – 😃 (smile), 😲 (raised brows), 😠 (furrowed brows), 😗 (pout), 😳 (wide eyes).
- **Real‑time similarity score** – calibrated to your own face during the first few seconds.
- **Emotion visualisation** – a colour‑coded circle changes with your slider values.
- **Calendar view** – see which emojis you picked on any day.
- **Scoreboard** – recent logs, 7‑day trends, emoji frequency, and average scores per mask.
- **Insights** – personalised messages based on your recording patterns (e.g., inner positivity vs. chosen mask).
- **Dark / Light mode** – respects system or manual preference.
- **Developer mode** – hidden feature (tap the version number 5 times) to clear data or generate random test data.

---

## 🧠 How It Works (Technical)

- **SwiftUI** for the entire user interface.
- **SwiftData** for local persistence of `EmotionRecord` objects.
- **AVFoundation** + **Vision** – real‑time face detection and landmark extraction.
- **UICalendarView** (wrapped as `UIViewRepresentable`) for the history calendar with emoji decorations.
- **Charts** (Swift Charts) – trend lines, bar charts for emoji frequency, and average scores.
- **Camera** – uses front‑facing camera, portrait orientation, mirrored preview for a natural “mirror” feel.

The face‑matching logic calculates a percentage score based on the chosen feature (e.g., mouth width for smile, eye height for wide eyes, brow‑to‑eye distance for brows). During the first ~30 frames, the app calibrates the user’s neutral range to make the score personalised rather than absolute.

---

## 🛠 Requirements

- iOS 16.0+ (the app uses SwiftUI APIs that require iOS 16, some features are marked `@available(iOS 17.0, *)` but the base target is 16).
- Xcode 14+ (Swift 5.7+)
- A real device with a front camera (the simulator cannot provide video frames for face detection).

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/FaceFollow.git
   cd FaceFollow
   ```
2. Open `FaceFollow.xcodeproj` (or the `.xcodeproj` generated from the Swift package).
3. Select your team and bundle identifier in Signing & Capabilities.
4. Build and run on a physical iPhone or iPad.

> **Note**: The app requests camera permission. Allow it to use the front camera.

---

## 📁 Project Structure (Main Files)

- `FaceFollowApp.swift` – app entry point, sets up SwiftData container.
- `ContentView.swift` – main tab view (Scoreboard, Calendar, Record, Insights, Settings).
- `RecordView.swift` – sliders for Passion/Energy/Positivity.
- `EmojiPickerView.swift` – grid of emoji challenges.
- `FaceSimulationView.swift` – camera + face tracking + real‑time score overlay.
- `SummaryView.swift` – save record with optional comment.
- `CalendarView.swift` – native calendar with emoji decorations.
- `ScoreboardView.swift` – charts, streak, recent logs.
- `InsightsView.swift` – dynamic textual insights based on recorded data.
- `SettingView.swift` – dark mode toggle, hidden developer mode.
- `EmotionRecord.swift` – SwiftData model.
- `EmotionCalculator.swift` – helper to map sliders to emotion word and colour.
- `EmojiChallenge.swift` – defines the five challenges and which facial feature to track.
- `CameraFaceOverlayView.swift` / `CameraVisionManager` – core face detection and landmark drawing.

---

## 🧪 Developer Mode

To access developer tools:

1. Go to the **Settings** tab.
2. Tap the version number (“Face Follow – V2.1.3”) five times.
3. A new “Developer” section appears.
   - **Clear All Data** – deletes all `EmotionRecord` entries.
   - **Generate Random Month Data** – populates the last 30 days with random test data (useful for testing charts and insights).

---

## 🙏 Acknowledgements

- Apple’s **Vision** framework for face landmark detection.
- **SwiftUI** and **SwiftData** for making data‑driven UI so smooth.
- The open‑source community for endless inspiration.

---

## 📝 Note from the Author

I built FaceFollow when I was 18 as a way to explore both iOS development and emotional awareness. It’s not meant to be a clinical tool – just a gentle, sometimes silly, reminder that **there’s no wrong way to express how you feel**.  
If this app helps you pause for a second and check in with yourself, it has done its job.

**Made with ❤️ and a front‑facing camera.**
