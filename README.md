# PinWinTop

A lightweight macOS menubar utility that adds a floating "Pin" button next to standard window controls. It allows you to keep any application window always on top of other windows.

Built with Swift and AppKit, PinWinTop uses macOS Accessibility APIs to track and manipulate windows, ensuring no code injection into third-party applications.

## Features

- **Always on Top:** Pin any window to keep it visible above everything else.
- **Floating Pin Button:** Seamlessly places a pin icon to the left of the active window's standard controls (traffic lights).
- **Menubar App:** Runs quietly in the menubar without cluttering your dock.
- **Safe & Native:** Uses macOS native Accessibility APIs.

## Installation

1. Go to the [Releases](https://github.com/OWNER/REPO/releases) page for this repository. (Note: Ensure you download the pre-compiled binary).
2. Download the latest `PinWinTop.app.zip`.
3. Double-click the downloaded `.zip` file to extract the `PinWinTop.app`.
4. Drag and drop `PinWinTop.app` into your `/Applications` folder.
5. Open your `/Applications` folder and double-click `PinWinTop.app` to launch it.

## Permissions & Usage

### 1. Grant Accessibility Permissions (First Launch)
PinWinTop requires Accessibility permissions to read window positions and apply the "always on top" state.

On your first launch, the app will automatically prompt you that these permissions are required:
1. Click **Open System Settings** in the prompt provided by the app.
2. Navigate to **Privacy & Security** -> **Accessibility**.
3. Toggle the switch next to **PinWinTop** to ON.
4. Restart the PinWinTop app.

### 2. Using the App
Once running, PinWinTop lives in your menubar as a simple 📌 icon.
- Focus on any application window.
- You will see a small, floating 📌 button appear to the left of that window's close/minimize/maximize buttons.
- Click the floating pin button to toggle "Always on Top" for that specific window.

## Building from Source (Optional)

If you'd like to build the project yourself using Swift Package Manager:

```bash
git clone https://github.com/OWNER/REPO.git
cd PinWinTop
swift build -c release
```

This project does not use Storyboards or Interface Builder, making it lightweight and entirely programmatic.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
