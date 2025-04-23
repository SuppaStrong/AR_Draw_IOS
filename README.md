# ar_draw

## Links
- **GitHub Repository**: [GitHub Repo URL](https://github.com/stackappdevs/CC-AR_Draw.git)
- **Figma Design**: [Figma Link](https://www.figma.com/design/MTJygBlrMOgU7TCHz4SEom/QuickTrade-App?node-id=0-1&p=f&t=Nh3Fo3aj5Hcmrljw-0)
- **Jira Issue Tracker**: [Jira Link](https://stackappsolution-1734066239229.atlassian.net/jira/software/projects/CCO/boards/1)

## Development Setup

### Prerequisites
- Flutter SDK: `v3.29.2`
- Dart Version: `3.7.2`

Make sure you have Flutter and Dart set up on your machine before you proceed with the setup. You can install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).

### Run the Project

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/stackappdevs/CC-AR_Draw.git
    cd CC-AR_Draw
    ```

2. **Install Dependencies**:
   Run the following command to get all the dependencies required by the project:
    ```bash
    flutter pub get
    ```

3. **Generate Code for JSON Serialization**:
   Since this project uses JSON serialization (via `json_serializable` package), you need to run the `build_runner` command to generate code for your models.

   Run this command to generate the necessary code:
    ```bash
    dart run build_runner build
    ```

   If you are making changes to your models and want to regenerate the code, use this command:
    ```bash
    dart run build_runner watch
    ```

4. **Run the App**:
   To run the app on an emulator or connected device:
    ```bash
    flutter run
    ```

### Build the App

1. **Build for Android**:
   To build the app for an Android release:
    ```bash
    flutter build apk --release --no-tree-shake-icons
    ```

2. **Build for iOS**:
   To build the app for iOS:
    ```bash
    flutter build ios --release
    ```

## Notes
- Ensure that you have the appropriate development environment set up for Android or iOS.
- For further instructions on how to configure your device or emulator, refer to [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).
- If you encounter issues with code generation (e.g., errors with `build_runner`), try clearing any generated files by running the following:
    ```bash
    dart run build_runner clean
    ```
