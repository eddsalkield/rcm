  $ . "$TESTDIR/helper.sh"

The default dotfiles directory to bless files into should be the first existing of:
$XDG_DATA_HOME/rcm/dotfiles, the respective $XDG_DATA_DIRS directories, and
finally $HOME/.dotfiles.
If no such directory exists, the default is $XDG_DATA_HOME/rcm/dotfiles
$RCRC should not be set
$XDG_CONFIG_HOME has not been set, so should default to $HOME/.local/share

  $ unset XDG_DATA_HOME
  $ unset RCRC
  $ export XDG_DATA_HOME_2="$HOME/.local/share"

  $ touch .example
  $ mkdir -p $XDG_DATA_HOME_2/rcm/dotfiles
  $ mkdir -p $HOME/.data1/rcm/dotfiles
  $ mkdir -p $HOME/.data2/rcm/dotfiles

  $ export XDG_DATA_DIRS="$HOME/.data1 $HOME/.data2"

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.local/share/rcm/dotfiles/example' (glob)
  Linking...
  '*/.local/share/rcm/dotfiles/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.local/share/rcm/dotfiles/example"

  $ rm -r $XDG_DATA_HOME_2/rcm/dotfiles
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.data1/rcm/dotfiles/example' (glob)
  Linking...
  '*/.data1/rcm/dotfiles/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.data1/rcm/dotfiles/example"
  $ rm -r $HOME/.data1
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.data2/rcm/dotfiles/example' (glob)
  Linking...
  '*/.data2/rcm/dotfiles/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.data2/rcm/dotfiles/example"
  $ rm -r $HOME/.data2
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.dotfiles/example' (glob)
  Linking...
  '*/.dotfiles/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.dotfiles/example"
  $ rm -r $HOME/.dotfiles
  $ rm .example
  > touch .example

  $ mkrc -v .example
  Moving...
  '*/.example' -> '*/.local/share/rcm/dotfiles/example' (glob)
  Linking...
  '*/.local/share/rcm/dotfiles/example' -> '*/.example' (glob)

  $ assert_linked "$HOME/.example" "$HOME/.local/share/rcm/dotfiles/example"
