# Crop Diagnostic AI Chat - Features & Usage

## 🌾 Overview
An intelligent farming assistant powered by Claude 3.5 Sonnet via OpenRouter API. Specializes in crop disease diagnosis, pest identification, and organic farming solutions.

## ✨ Key Features

### 1. **Multimodal Analysis**
- Send text descriptions
- Upload crop/pest photos
- Combine text + images for detailed analysis
- Automatic image analysis when no text provided

### 2. **Conversation Memory**
- Maintains last 10 messages for context
- Understands follow-up questions
- References previous diagnoses
- Builds on earlier recommendations

### 3. **Location-Aware Advice**
- Auto-detects your location (with permission)
- Provides region-specific recommendations
- Considers local climate and pests
- Suggests seasonally appropriate solutions

### 4. **Organic-First Approach**
Every response prioritizes:
1. **Natural remedies** (neem oil, garlic spray, beneficial insects)
2. **Cultural practices** (crop rotation, spacing, mulching)
3. **Biological controls**
4. **Chemical alternatives** (only when necessary, with safety info)

### 5. **Evidence-Based Recommendations**
- Backed by agricultural research
- Verified information from trusted sources
- Specific actionable steps
- Expected results and timeframes

## 📱 How to Use

### Basic Text Query
```
"My tomato leaves are turning yellow and curling"
```

### Image Analysis
1. Tap camera icon
2. Take photo or choose from gallery
3. Optionally add description
4. Click send

### Image + Text (Best Results)
1. Attach crop/pest photo
2. Add details: "Maize leaves with brown spots, noticed after rain"
3. Send for comprehensive analysis

### Follow-Up Questions
```
User: "My tomatoes have white spots"
AI: [Provides diagnosis]
User: "Can I use this on peppers too?"
AI: [Remembers context about white spots]
```

## 🎯 What You Can Ask

### Disease Diagnosis
- "What's wrong with my crop?" + photo
- "Identify this plant disease"
- "Why are leaves turning brown?"

### Pest Identification
- "What pest is this?" + photo
- "How to control aphids organically?"
- "Natural ways to handle fruit flies"

### Plant Health
- "Is my plant healthy?" + photo
- "Nutrient deficiency symptoms"
- "Why is growth stunted?"

### Prevention
- "How to prevent tomato blight?"
- "Crop rotation strategy for maize"
- "Best companion plants for vegetables"

### Treatment
- "Organic fungicide for powdery mildew"
- "Natural pest control for cabbage"
- "Safe chemical alternative if organic fails"

## 🔧 Setup Required

1. **Get OpenRouter API Key**
   - Visit: https://openrouter.ai/keys
   - Create free account
   - Generate API key

2. **Add Key to App**
   - Open: `lib/core/services/ai_service.dart`
   - Replace: `YOUR_OPENROUTER_API_KEY`
   - With: Your actual key

3. **Test**
   - Run app
   - Send message: "Hello"
   - Should get AI response

## 💡 Pro Tips

### Best Photo Quality
- ✅ Clear focus on affected area
- ✅ Good lighting (natural light best)
- ✅ Close-up of symptoms
- ✅ Include whole plant context if possible
- ❌ Avoid blurry images
- ❌ Don't send dark/shadowy photos

### Better Descriptions
**Instead of**: "My plant is sick"  
**Try**: "Tomato plant, brown spots on lower leaves, appears after watering"

**Include**:
- Crop type
- Symptoms (color, texture, location)
- When noticed
- Recent weather/care changes
- Affected area percentage

### Multiple Images
- Can attach several photos
- Different angles
- Close-up + wide shot
- Progression photos

## ⚠️ Important Notes

### What AI CAN Do
- ✅ Identify common diseases/pests
- ✅ Suggest organic treatments
- ✅ Provide preventive measures
- ✅ Recommend chemical alternatives
- ✅ Give region-specific advice

### What AI CANNOT Do
- ❌ Replace professional diagnosis for rare diseases
- ❌ Guarantee 100% accuracy
- ❌ Provide instant lab results
- ❌ Test soil/water samples
- ❌ Make legal/regulatory decisions

### When to Seek Human Expert
- Unknown/rare disease
- Large-scale outbreak
- Regulatory compliance questions
- Soil/water testing needed
- Suspected chemical contamination

## 💰 Cost Information

- **OpenRouter**: Pay per use
- **Average**: $0.001 - $0.01 per message
- **Image analysis**: Slightly higher
- **Monitor**: https://openrouter.ai/activity
- **Tip**: Set spending limits in account

## 🔒 Privacy

- Messages processed by OpenRouter/Claude
- No data stored permanently
- Location optional (can deny permission)
- Images sent for analysis only
- Conversation history local only

## 📞 Support

**Technical Issues**:
- Check AI_SETUP.md
- Verify API key is active
- Test internet connection

**Farming Questions**:
- Ask the AI directly
- Consult local agricultural extension
- Contact farming cooperatives

## 🚀 Future Enhancements

Coming soon:
- [ ] Voice input for questions
- [ ] Multi-language support
- [ ] Offline disease database
- [ ] Weather integration
- [ ] Farming calendar
- [ ] Community shared diagnoses

---

**Remember**: The AI provides guidance based on general agricultural knowledge. For critical decisions, always consult local agricultural experts and test recommendations on small areas first.
