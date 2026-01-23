# About This Image

This Image contains a browser-accessible Ubuntu Jammy Desktop with Gemini CLI, Google's command-line interface for interacting with Gemini AI models directly from your terminal.

![Screenshot][Image_Screenshot]

[Image_Screenshot]: https://5856039.fs1.hubspotusercontent-na1.net/hubfs/5856039/dockerhub/image-screenshots/gemini-cli.png "Image Screenshot"

# Environment Variables

## Gemini CLI Configuration

* `GEMINI_API_KEY` - Your Google Gemini API key (starts with `AIza`). This is required for Gemini CLI to authenticate with the Google AI API. If you don't want to use an API key, you can use browser login flow to login to your Gemini account.

You can pass this environment variable to your Gemini CLI Workspace with **Docker Run Config Override (JSON)** in your Workspace settings.

Alternatively, you can use the **Launch Form** to input your API key when starting the workspace. The Launch Form allows you to:
- Enable API key authentication
- Input your Google Gemini API key securely
- Save your preferences for future launches

The workspace will automatically configure Gemini CLI to use your API key.