# App Icon Setup Instructions

## Step 1: Create/Download Your Wallet Icon

### Option A: Download Free Icons
Visit these sites for free wallet/card icons:
- [Flaticon](https://www.flaticon.com/search?word=wallet%20card) - Search "wallet card"
- [Icons8](https://icons8.com/icons/set/wallet) - Wallet icons
- [IconFinder](https://www.iconfinder.com/search?q=wallet+card&price=free) - Free wallet icons

### Option B: Generate with AI
Use these free AI tools:
- [Bing Image Creator](https://www.bing.com/create) - Prompt: "minimalist wallet and credit card app icon, flat design, indigo and blue colors"
- [Leonardo.ai](https://leonardo.ai/) - Free tier available

### Recommended Design:
- Simple wallet with a credit card partially visible
- Use your app colors: Indigo (#3F51B5) and Light Blue (#03A9F4)
- White or transparent background
- Size: 1024x1024 pixels

## Step 2: Prepare Icon Files

Save your icon as:
1. `app_icon.png` - Main icon (1024x1024 px)
2. `app_icon_foreground.png` - For Android adaptive icon (optional)

Place files in: `assets/icon/`

## Step 3: Generate All Icon Sizes

Run these commands in the terminal:

```bash
# Get dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons
```

## Step 4: Verify Icons

The command will generate:
- Android icons in: `android/app/src/main/res/mipmap-*/`
- iOS icons in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Step 5: Test

Run your app to see the new icon:
```bash
flutter run
```

## Icon Requirements:
- PNG format
- Minimum 512x512, recommended 1024x1024
- No transparency for iOS (add background)
- Android adaptive icons work best with foreground/background separation

## Quick Icon Ideas:
1. 💳 Wallet with visible credit card
2. 👛 Open wallet showing cards and cash
3. 💰 Wallet with dollar sign
4. 📊 Wallet with chart/graph overlay (expense tracking)