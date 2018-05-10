#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +%s);
dotfilespath="$HOME/dotfiles"
dotrepo="https://github.com/iamtchelo/dotfiles"

if [ ! -d "$dotfilespath" ]; then
    printf "Fetching dotfiles...\n"
    git clone --recursive "$dotrepo" "$dotfilespath"
fi;

sh $dotfilespath/osx/install.sh
sh $dotfilespath/debian/install.sh

echo "Installing Oh My Zsh"
curl -L http://install.ohmyz.sh | bash

find $dotfilespath -mindepth 2 -name 'install.sh'|grep -v -E "(osx|debian)"| while read FILE; do
    echo "Running: $FILE"
    sh $FILE
done

echo "Configuring .dotfiles"
find $dotfilespath/* -maxdepth 0 -type f -not -name "install.sh" -not -name "LICENSE" -not -name "README.md" | while read FILE; do
	rm -f "$HOME/.${FILE##*/}"
	ln -s "$FILE" "$HOME/.${FILE##*/}"
done

if [ -d "$HOME/.ssh" ]; then
    if [ -L $HOME/.ssh ]; then
        rm -rf "$HOME/.ssh"
    else
        mv "$HOME/.ssh" "$HOME/ssh-bkp-$TIMESTAMP"
    fi
fi

rm -rf "$HOME/.backup"
rm -rf "$HOME/.bin"
rm -rf "$HOME/.pgpass"
rm -rf "$HOME/.aws"
rm -rf "$HOME/.npmrc"

mkdir "$HOME/.backup"
ln -s "$HOME/dotfiles/bin" "$HOME/.bin"
ln -s "$HOME/dotfiles/ssh" "$HOME/.ssh"
ln -s "$HOME/dotfiles/ssh/pgpass" "$HOME/.pgpass"
ln -s "$HOME/dotfiles/ssh/aws" "$HOME/.aws"
ln -s "$HOME/dotfiles/ssh/npmrc" "$HOME/.npmrc"

chsh -s /bin/zsh
echo "Finish!!!"
