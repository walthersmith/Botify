#!/bin/bash

show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -p, --project    Create a new project"
  echo "  -c, --cog        Create a new cog"
}

display_logo() {
  echo "  ____        _   _  __       _ "
  echo " | __ )  ___ | |_(_)/ _|_   _| |"
  echo " |  _ \ / _ \| __| | |_| | | | |"
  echo " | |_) | (_) | |_| |  _| |_| |_|"
  echo " |____/ \___/ \__|_|_|  \__, (_)"
  echo "                        |___/   "
  echo "Welcome to Botify! script for creating Discord bots."
}


# Function to create a new project
newproject() {
  display_logo
  # Check if the project name has been passed as an argument
  if [ -z "$1" ]; then
    echo "Please enter the project name."
    exit 1
  fi

  # Si el directorio es ".", se usa el directorio actual
  if [ "$1" = "." ]; then
    project_dir="."
  else
    project_dir="$1"
    mkdir $project_dir
  fi


  # Create the project directory and enter it 
  cd "$1" || exit

  check_python_version
  create_env_file
  create_readme_file
  generate_gitignore
  create_main_file
  create_cogs_directory
  initialize_git_repository
  create_virtualenv  
}

# Function to create the .env file
create_env_file() {
  # Create the .env file with the bot key
  echo "KEY=<your-key-here>" > .env
}

# Function to create the README.md file
create_readme_file() {
  # Create the README.md file with the project description
  cat > README.md << EOF
# $1

This is a Discord.py project that uses the commands extension.

## Requirements

- Python >=3.8
- Discord.py  
- Python-dotenv (to load the bot key from the .env file) 

# Optional Packages
- [PyNaCl](https://pypi.org/project/PyNaCl/) (for voice support)
- libffi-dev (or libffi-devel on some systems)
- python-dev (e.g. python3.8-dev for Python 3.8)


## Structure

The project has the following files and directories:

- .env: contains the bot key. It should not be shared publicly.
- main.py: contains the main code of the bot, which creates the bot object, defines an event for when it is ready and runs the bot with the key.
- cogs: contains the Python modules that define the cogs of the bot, which are classes that group related commands and events.
- README.md: contains this description of the project.
- Discord.py documentation [here](https://discordpy.readthedocs.io/en/latest/index.html)

## Usage

To run the bot, you need to do the following:

- Create a bot on the Discord developer portal and obtain its key. [Discord Applications](https://discord.com/developers/applications)
- Paste the key in the .env file where it says KEY=<your-key-here>.
- Install requirements with pip install -r requirements.txt (if you created a virtualenv, activate it first).
- Run main.py file with python main.py (or python3 main.py depending on system).
EOF
}

# Function to create the main.py file
create_main_file() {
  # Create the main.py file with the basic code of the bot
  cat > main.py << EOF
import os
import discord
from discord.ext import commands
from dotenv import load_dotenv

# Load the bot key from the .env file
load_dotenv()
TOKEN = os.getenv('KEY')

# Create the bot object with the desired command prefix
bot = commands.Bot(command_prefix='!')

# Define an event for when the bot is ready
@bot.event
async def on_ready():
    print(f'{bot.user.name} has connected to Discord!')

# Run the bot with the key
bot.run(TOKEN) 
EOF
}

# Function to generate the .gitignore file
generate_gitignore() {
  cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class

# Virtual environment
venv/

# Environment variables
.env

# Discord.py voice support
voice_bot.py

# Jupyter Notebook
.ipynb_checkpoints/

# System and IDE files
.DS_Store
.idea/
.vscode/

# Log files
*.log
EOF

  echo "✅ The .gitignore file has been successfully generated."
}

# Function to generate the requirements.txt file
generate_requirements_file() {
  # Check if the virtualenv is activated
  if [[ -z "${VIRTUAL_ENV}" ]]; then
    echo "❌ Virtualenv is not activated. Please activate the virtualenv before generating the requirements file."
    exit 1
  fi

  # Generate the requirements.txt file using pip freeze
  pip freeze > requirements.txt

  echo "✅ requirements.txt file has been successfully generated."
}

# Function to create the cogs directory
create_cogs_directory() {
  # Create the cogs directory and enter it
  mkdir cogs
  cd cogs || exit

  # Create the empty __init__.py file
  touch __init__.py

  # Return to the project directory
  cd ..
}

# Function to check Python version and warn if it is not >= 3.8
check_python_version() {
  python_version=$(python --version | cut -d ' ' -f 2)
  if [[ $(printf "%s\\n" "$python_version" "3.8" | sort -V | head -n1) != "3.8" ]]; then
    echo "⚠️ Warning: Python version is $python_version, a version greater than or equal to 3.8 is required for Discord.py"
    exit 1  
  fi
}

# Function to create a virtualenv
create_virtualenv() {
  # Ask if you want to create a virtualenv
  read -r -p "Do you want to create a virtualenv? [Y/n] " answer
  case "$answer" in 
    [yY][eE][sS]|[yY]|'')
      # Create the virtualenv with the name venv and activate it
      python -m venv venv
      source venv/bin/activate

      install_discordpy_with_voice_support
      install_python_dotenv
      generate_requirements_file

      echo "🎉 🎉 🎉 The project $1 has been successfully created.🎉🎉🎉"
      exit 0
      ;;
    [nN][oO]|[nN])
      echo "No virtualenv is created."
      exit 0
      ;;
    *)
      echo "❌ Invalid answer."
      exit 1
      ;;
  esac
}

# Function to install discord.py with or without voice support
install_discordpy_with_voice_support() {
  # Ask if you want to install discord.py with voice support or without it
  read -r -p "Do you want to install discord.py with voice support? [Y/n] " answer2
  case "$answer2" in 
    [yY][eE][sS]|[yY]|'')
      install_discordpy_with_voice
      ;;
    [nN][oO]|[nN])
      install_discordpy_without_voice
      ;;
    *)
      echo "❌ Invalid answer."
      exit 1
      ;;
  esac
}

# Function to install discord.py with voice support
install_discordpy_with_voice() {
  #Installing required packages: libffi-dev, python3.8-dev
  install_required_packages

  # Install discord.py with voice support in the virtualenv
  pip install -q "discord.py[voice]"
  echo -e "✅ Discord.py with voice support has been successfully installed "

  # Check if PyNaCl is already installed in the system
  if ! python -c "import nacl" &> /dev/null; then
    # Ask if you want to install PyNaCl for voice support
    read -r -p "Do you want to install PyNaCl for voice support? [Y/n] " answer3
    case "$answer3" in
      [yY][eE][sS]|[yY]|'')
        # Install PyNaCl in the virtualenv
        python -m pip install -q -U PyNaCl
        echo -e "✅ PyNaCl has been successfully installed "
        ;;
      [nN][oO]|[nN])
        # Show a message that PyNaCl won't be installed
        echo "PyNaCl won't be installed."
        ;;
      *)
        # Show an error message and exit
        echo "❌ Invalid answer."
        exit 1
        ;;
    esac
  else
    echo "✅ PyNaCl is already installed."
  fi

  echo -e "✅ Discord.py with voice support has been successfully installed in the virtualenv."
}

# Function to install discord.py without voice support
install_discordpy_without_voice() {
  # Install discord.py without voice support in the virtualenv
  pip install -q discord.py

  echo "Discord.py without voice support has been successfully installed in the virtualenv."
}


# Function to install required packages
install_required_packages() {
  if [[ "$(uname)" == "Linux" ]]; then
    if command -v apt-get >/dev/null 2>&1; then
      echo "Ubuntu-based system. Using apt-get."
      echo "Installing required packages: libffi-dev, python3-dev"
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update > /dev/null
      sudo apt-get install -yq libffi-dev python3-dev > /dev/null      
      # verify that the packages have been installed
      check_package_installed apt libffi-dev
      check_package_installed apt python3-dev
    elif command -v dnf >/dev/null 2>&1; then
      echo "Fedora-based system. Using DNF."
      echo "Installing required packages: libffi-devel, python3.8-devel"
      sudo dnf update > /dev/null
      sudo dnf install -y libffi-devel python3-dev > /dev/null
      # verify that the packages have been installed
      check_package_installed dnf libffi-devel
      check_package_installed dnf python3-devel
    elif command -v pacman >/dev/null 2>&1; then
      echo "Arch-based system. Using Pacman."
      echo "Installing required packages: libffi, python38"
      sudo pacman -Syu > /dev/null
      sudo pacman -S --noconfirm libffi python38 > /dev/null
      # verify that the packages have been installed
      check_package_installed pacman libffi
      check_package_installed pacman python38
    else
      echo "❌ Unsupported operating system or unrecognized package manager."
      exit 1
    fi


  else
    echo "❌ This script is only compatible with Linux operating systems."
    exit 1
  fi
}

# Function to check if a package is installed
check_package_installed() {
  package_manager=$1
  package_name=$2

  case $package_manager in
    apt)
      if dpkg -s "$package_name" &> /dev/null; then
        echo "✅ Package $package_name is installed."
      else
        echo "❌ Package $package_name is not installed."
      fi
      ;;
    dnf)
      if rpm -q "$package_name" &> /dev/null; then
        echo "✅ Package $package_name is installed."
      else
        echo "❌ Package $package_name is not installed."
      fi
      ;;
    pacman)
      if pacman -Qs "$package_name" &> /dev/null; then
        echo "✅ Package $package_name is installed."
      else
        echo "❌ Package $package_name is not installed."
      fi
      ;;
    *)
      echo "❌ Unsupported package manager: $package_manager"
      ;;
  esac
}

# Function to install python-dotenv
install_python_dotenv() {
  # Install python-dotenv in the virtualenv
  pip install -q python-dotenv
}

# Function to create a new cog
newcog() {
  # Check if cog name has been passed as an argument
  if [ -z "$1" ]; then
    echo "Please enter cog name."
    exit 1
  fi

  # Check if cogs directory exists and enter it
  if [ -d "cogs" ]; then
    cd cogs || exit
  else
    echo "❌ Cogs directory not found, make sure you are in the project directory."
    exit 1
  fi

  create_cog_file "$1"

  # Return to project directory
  cd ..

  echo "The cog $1 has been successfully created."
}

# Function to create the .py file with cog code
create_cog_file() {
  cat > "$1".py << EOF
import discord
from discord.ext import commands

# Create cog class with desired name
class $1(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    # Define cog commands and events here

# Add cog to bot when module is loaded
def setup(bot):
    bot.add_cog($1(bot))
EOF
}

# Function to initialize a Git repository
initialize_git_repository() {
  # Check if Git is installed
  if ! command -v git >/dev/null 2>&1; then
    echo "❌ Git is not installed. Please install Git before initializing a repository."
    exit 1
  fi

  # Initialize the Git repository
  git init

  # Add all files to the initial commit
  git add .

  # Commit the initial files
  git commit -m "Initial commit"

  echo "🎉 Git repository has been successfully initialized."
}


# Verificar si se pasa la opción -h o --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  display_logo
  show_help
  exit 0
fi

# Verificar el comando pasado como primer argumento y ejecutar la función correspondiente
case "$1" in
  -p|--project)
    newproject "$2"
    ;;
  -c|--cog)
    newcog "$2"
    ;;
  *)
    echo "❌ Invalid command. Available commands are: -p, --project, -c, --cog"
    exit 1
    ;;
esac
