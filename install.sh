# Installation script for setting up my development environment
# snowcra5h@icloud.com
# https//github.com/snowcra5h

#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

## Banner
echo -e "\n- ${CYAN}snowcra5h's development environment setup${NC} -"
echo -e "- ${CYAN}snowcra5h@icloud.com${NC} -"
echo -e "- ${CYAN}https//github.com/snowcra5h${NC} -\n"
read -p "Press enter to continue: "

## The dotfiles 
echo -e "\n ${GREEN} [+] - ${YELLOW} Installing the Dotfiles\n ${NC}"
mv ~/.vimrc ~/.vimrc.old 2>/dev/null
mv ~/.clang-format ~/.clang-format.old 2>/dev/null
mv ~/.vimspector.json ~/.vimspector.json.old 2>/dev/null
mv ~/.tmux.conf ~/.tmux.conf.old 2>/dev/null

cp .tmux.conf ~/.tmux.conf
cp .vimrc ~/.vimrc
cp .clang-format ~/.clang-format
cp .vimspector.json ~/.vimspector.json

## Required Packages
echo -e "\n ${GREEN} [+] - ${YELLOW} Updating the System and Installing the Required Packages\n ${NC}"
sudo apt update && sudo apt upgrade -y && sudo apt install -y git curl wget vim build-essential cmake vim-nox python3-dev mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm tmux exuberant-ctags

## YouCompleteMe
echo -e "\n ${GREEN} [+] - ${YELLOW} Installing YouCompleteMe\n ${NC}"
git clone https://github.com/ycm-core/YouCompleteMe ~/.vim/plugged/YouCompleteMe
cd ~/.vim/plugged/YouCompleteMe
git submodule update --init --recursive
python3 install.py --all

## Vundle
echo -e "\n ${GREEN} [+] - ${YELLOW} Installing Vundle\n ${NC}"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/plugged/Vundle.vim

## Powerline
echo -e "\n ${GREEN} [+] - ${YELLOW} Installing Powerline and Powerline Fonts\n ${NC}"
sudo apt install python3-pip fonts-powerline && pip3 install powerline-status
git clone https://github.com/powerline/fonts.git --depth=1; cd fonts; ./install.sh; cd ..; rm -rf fonts
powerline_path=$(pip show powerline-status | grep Location)
powerline_path=${powerline_path#Location: }
powerline_path=${powerline_path% }
echo "powerline-daemon -q" >> ~/.bashrc
echo "POWERLINE_BASH_CONTINUATION=1" >> ~/.bashrc
echo "POWERLINE_BASH_SELECT=1" >> ~/.bashrc
echo ". ${powerline_path}/powerline/bindings/bash/powerline.sh" >> ~/.bashrc

## Solarized
echo -e "\n ${GREEN} [+] - ${YELLOW} Installing Solarized for The Terminal\n ${NC}"
profiles=$(dconf list /org/gnome/terminal/legacy/profiles:/)
counter=1
for profile in $profiles; do
    if [[ $profile == :* ]]; then
        echo -e "  ${BLUE}[$counter] - $profile ${NC}"
        counter=$((counter+1))
    fi
done

while true; do
    read -p "Please enter the number of the profile you would like to use: " profile_number
    if [[ $profile_number -gt 0 && $profile_number -lt $counter ]]; then
        break
    else
        echo -e " ${RED} [!] - ${YELLOW} Please enter a valid number ${NC}"
    fi
done

profile=$(echo $profiles | cut -d ' ' -f $profile_number)
profile=${profile:1}
profile=${profile%?}

cd ~
git clone https://github.com/aruhier/gnome-terminal-colors-solarized.git 
cd gnome-terminal-colors-solarized; ./install.sh -s dark --install-dircolors --profile $profile
dircolors_path=$(find ~/.dir_colors -name dircolors)

if [[ ! -f $dircolors_path ]]; then
    echo -e " ${RED} [!] - ${YELLOW} The path to the dircolors file does not exist\n ${NC}"
    exit 1
fi
echo eval \`dircolors $dircolors_path\` >> ~/.bashrc

## Install Vim Plugins
source ~/.bashrc
echo -e " ${GREEN} [+] - ${YELLOW} Installing Vim Plugins\n ${NC}"
vim +PluginInstall +qall

echo -e " ${GREEN} [+] - ${YELLOW} Type ${RED}source ~/.bashrc ${YELLOW}to refresh the current shell session\n ${NC}"
