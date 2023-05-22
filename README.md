# Botify!

Is command-line utility for easily creating Discord bot projects using Discord.py.
It automates the creation of the basic project structure, including generating necessary files and directories. You can customize and expand the project according to your needs. For more details, refer to the "Usage" section below.

## Requirements

- Python >=3.8 
- Git

## Project Structure

The project has the following files and directories:

- .env: contains the bot key. It should not be shared publicly.
- main.py: contains the main code of the bot, which creates the bot object, defines an event for when it is ready, and runs the bot with the key.
- cogs: contains the Python modules that define the cogs of the bot, which are classes that group related commands and events.
- README.md: contains this description of the project.

## Usage
To use the script, follow these steps:
- Run the script with the desired options. For example, to create a new project, use: `./script.sh -p <project-name>`
- Follow the prompts and provide the necessary information.
- The script will create the project structure, generate files, and install dependencies.
- Refer to the generated README.md file inside the project directory for further instructions on running the bot.
- Discord.py documentation [here](https://discordpy.readthedocs.io/en/stable/)

## Authors
- [walthersmith](https://github.com/walthersmith)
