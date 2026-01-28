# 🚀 Quick Start Checklist

## Before First Run

### 1. ✅ Install Dependencies
```bash
flutter pub get
```

### 2. 🔑 Get OpenRouter API Key
- [ ] Visit https://openrouter.ai/keys
- [ ] Create account (free)
- [ ] Generate new API key
- [ ] Copy the key (starts with `sk-or-v1-...`)

### 3. ⚙️ Configure AI Service
- [ ] Open `lib/core/services/ai_service.dart`
- [ ] Find line 12: `static const String _apiKey = 'YOUR_OPENROUTER_API_KEY';`
- [ ] Replace with your actual key
- [ ] Save file

### 4. 📍 Location Permissions (Optional)
**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide region-specific farming advice</string>
```

### 5. 📸 Camera Permissions
**Android** (already in manifest):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

**iOS** (already in Info.plist):
```xml
<key>NSCameraUsageDescription</key>
<string>Take photos of your crops for diagnosis</string>
```

### 6. 🧪 Test the Setup
```bash
# Run on Chrome (fastest for testing)
flutter run -d chrome

# Or on your device
flutter run
```

### 7. ✨ First Test Message
1. Open the app
2. Go to Chat screen
3. Type: "Hello, can you help me with my crops?"
4. Wait for AI response
5. If you get a response → ✅ Setup complete!
6. If error → Check troubleshooting below

## 🔍 Troubleshooting

### Error: "Authentication error"
- ❌ API key is incorrect
- ✅ Copy key again from OpenRouter
- ✅ Make sure no extra spaces
- ✅ Should start with `sk-or-v1-`

### Error: "Connection timeout"
- ❌ No internet connection
- ✅ Check your network
- ✅ Try again

### Error: "Image.file not supported on web"
- ❌ Running on web with file-based image
- ✅ Already fixed in latest code
- ✅ Make sure you pulled latest changes

### No AI response
- Check console for errors
- Verify API key has credits
- Test API key at https://openrouter.ai/playground

## 💡 Quick Test Scenarios

### Test 1: Text Only
```
Message: "What causes yellow leaves in tomatoes?"
Expected: Detailed response about nutrient deficiency, diseases, etc.
```

### Test 2: Image + Text
```
1. Attach any plant photo
2. Message: "What do you see in this image?"
Expected: Description of plant/symptoms visible
```

### Test 3: Location
```
Message: "What crops grow well in my area?"
Expected: Response considering your location (if permission granted)
```

## 📊 Cost Estimates

For typical farming questions:
- **Text only**: ~$0.001 - $0.002 per message
- **Image + text**: ~$0.005 - $0.01 per message
- **100 messages**: ~$0.50 - $1.00
- **1000 messages**: ~$5 - $10

💡 Tip: Start with $5 credit - should last weeks of testing

## 🎯 Next Steps

Once working:
1. [ ] Read CHAT_GUIDE.md for usage tips
2. [ ] Test with real crop photos
3. [ ] Try conversation memory (follow-up questions)
4. [ ] Explore Market feature
5. [ ] Join Community groups
6. [ ] Set up Profile

## 📚 Documentation

- **AI Setup**: AI_SETUP.md
- **Chat Guide**: CHAT_GUIDE.md
- **General Setup**: SETUP_GUIDE.md
- **Roadmap**: ROADMAP.md

## 🆘 Need Help?

1. Check error messages carefully
2. Read AI_SETUP.md for detailed troubleshooting
3. Verify API key status at OpenRouter
4. Check OpenRouter Discord for support

---

**You're all set!** 🎉 Start chatting with your AI farming assistant!
