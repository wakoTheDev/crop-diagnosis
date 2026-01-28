# AI Service Setup Guide

## OpenRouter Integration

This app uses OpenRouter to access powerful AI models for crop diagnosis and farming assistance.

### Setup Instructions

1. **Get an API Key**
   - Visit [https://openrouter.ai/keys](https://openrouter.ai/keys)
   - Sign up or log in
   - Create a new API key
   - Copy your API key

2. **Configure the App**
   - Open `lib/core/services/ai_service.dart`
   - Replace `YOUR_OPENROUTER_API_KEY` with your actual API key:
   ```dart
   static const String _apiKey = 'sk-or-v1-xxxxxxxxxxxxx';
   ```

3. **Choose Your Model** (Optional)
   - Default: `anthropic/claude-3.5-sonnet` (Best for vision + farming)
   - Alternatives in `ai_service.dart`:
     - `google/gemini-pro-vision`
     - `openai/gpt-4-vision-preview`

### Features

✅ **Multimodal Analysis**: Processes both text and images  
✅ **Conversation History**: Maintains context across messages  
✅ **Location-Aware**: Provides region-specific recommendations  
✅ **Organic First**: Prioritizes natural solutions  
✅ **Verified Sources**: Evidence-based agricultural advice  
✅ **Error Handling**: Graceful fallbacks for network issues  

### Usage

1. **Text Only**: Ask farming questions
2. **Image + Text**: Upload crop/pest photos with description
3. **Image Only**: Send photos for automatic analysis
4. **Location**: App automatically includes location for regional advice

### Cost Management

- OpenRouter charges per token used
- Average cost: $0.001 - $0.01 per message
- Monitor usage at [https://openrouter.ai/activity](https://openrouter.ai/activity)
- Set spending limits in your OpenRouter account

### Privacy & Security

- API key is stored locally in the app code
- For production, move to environment variables
- Never commit API keys to version control
- Add `.env` to `.gitignore`

### Troubleshooting

**"Authentication error"**
- Check if API key is correct
- Verify key has credits/is active

**"Connection timeout"**
- Check internet connection
- Try again in a few moments

**"Too many requests"**
- You've hit rate limits
- Wait 1 minute and try again

### Support

- OpenRouter Docs: [https://openrouter.ai/docs](https://openrouter.ai/docs)
- Community: [https://discord.gg/openrouter](https://discord.gg/openrouter)
