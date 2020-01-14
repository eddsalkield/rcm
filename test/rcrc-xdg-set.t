  $ . "$TESTDIR/helper.sh"

Information should be read from $XDG_CONFIG_HOME/rcm/rcrc with the highest priority,
then the respective $XDG_CONFIG_DIRS directories, and finally $HOME/.rcrc
$RCRC should not be set
$XDG_CONFIG_HOME has been set

  $ unset RCRC

  $ touch .example
  > mkdir .other-dotfiles-xdg-config-home
  > mkdir .other-dotfiles-xdg-config-dirs-1
  > mkdir .other-dotfiles-xdg-config-dirs-2
  > mkdir .other-dotfiles

  $ mkdir -p $XDG_CONFIG_HOME/rcm
  > mkdir -p .config1/rcm
  > mkdir -p .config2/rcm
  > export XDG_CONFIG_DIRS="$HOME/.config1 $HOME/.config2"

  $ mkdir -p $XDG_CONFIG_HOME/rcm
  $ mkdir -p $HOME/.config1/rcm
  $ mkdir -p $HOME/.config2/rcm

  $ echo 'DOTFILES_DIRS="$HOME/.other-dotfiles-xdg-config-home"' > $XDG_CONFIG_HOME/rcm/rcrc
  $ echo 'DOTFILES_DIRS="$HOME/.other-dotfiles-xdg-config-dirs-1"' > $HOME/.config1/rcm/rcrc
  $ echo 'DOTFILES_DIRS="$HOME/.other-dotfiles-xdg-config-dirs-2"' > $HOME/.config2/rcm/rcrc
  $ echo 'DOTFILES_DIRS="$HOME/.other-dotfiles"' > $HOME/.rcrc

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.other-dotfiles-xdg-config-home/example' (glob)
  Linking...
  '*/.other-dotfiles-xdg-config-home/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.other-dotfiles-xdg-config-home/example"
  $ rm $XDG_CONFIG_HOME/rcm/rcrc
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.other-dotfiles-xdg-config-dirs-1/example' (glob)
  Linking...
  '*/.other-dotfiles-xdg-config-dirs-1/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.other-dotfiles-xdg-config-dirs-1/example"
  $ rm $HOME/.config1/rcm/rcrc
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.other-dotfiles-xdg-config-dirs-2/example' (glob)
  Linking...
  '*/.other-dotfiles-xdg-config-dirs-2/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.other-dotfiles-xdg-config-dirs-2/example"
  $ rm $HOME/.config2/rcm/rcrc
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.other-dotfiles/example' (glob)
  Linking...
  '*/.other-dotfiles/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.other-dotfiles/example"
