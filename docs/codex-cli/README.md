# About This Image

This Image contains a browser-accessible Ubuntu Jammy Desktop with Codex CLI, OpenAI's command-line interface for code generation and completion using GPT models directly from your terminal.

![Screenshot][Image_Screenshot]

[Image_Screenshot]: https://5856039.fs1.hubspotusercontent-na1.net/hubfs/5856039/dockerhub/image-screenshots/codex-cli.png "Image Screenshot"

# Environment Variables

## Codex CLI Configuration

* `OPENAI_API_KEY` - Your OpenAI API key (starts with `sk-`). This is required for Codex CLI to authenticate with the OpenAI API. If you don't want to use an API key, you can use browser login flow to login to your OpenAI account.

You can pass this environment variable to your Codex CLI Workspace with **Docker Run Config Override (JSON)** in your Workspace settings.

Alternatively, you can use the **Launch Form** to input your API key when starting the workspace. The Launch Form allows you to:
- Enable API key authentication
- Input your OpenAI API key securely
- Save your preferences for future launches

The workspace will automatically configure Codex CLI to use your API key.