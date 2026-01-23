# About This Image

This Image contains a browser-accessible Ubuntu Jammy Desktop with Claude Code CLI, Anthropic's command-line interface for interacting with Claude AI models directly from your terminal.

![Screenshot][Image_Screenshot]

[Image_Screenshot]: https://5856039.fs1.hubspotusercontent-na1.net/hubfs/5856039/dockerhub/image-screenshots/claude-code.png "Image Screenshot"

# Environment Variables

## Claude Code CLI Configuration

* `ANTHROPIC_API_KEY` - Your Anthropic API key (starts with `sk-ant-`). This is required for Claude Code CLI to authenticate with the Anthropic API. If you don't want to use an API key, you can use browser login flow to login to your Anthropic account.

You can pass this environment variable to your Claude Code Workspace with **Docker Run Config Override (JSON)** in your Workspace settings.

Alternatively, you can use the **Launch Form** to input your API key when starting the workspace. The Launch Form allows you to:
- Enable API key authentication
- Input your Anthropic API key securely
- Save your preferences for future launches

The workspace will automatically configure Claude Code CLI to use your API key, bypassing the browser login flow.
