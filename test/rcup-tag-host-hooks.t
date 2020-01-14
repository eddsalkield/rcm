  $ . "$TESTDIR/helper.sh"

Pre-up and post-up hooks should run for hostname and selected tags by default

  $ mkdir -p .dotfiles/host-myhostname/hooks
  > touch .dotfiles/host-myhostname/hooks/pre-up .dotfiles/host-myhostname/hooks/post-up
  > chmod +x .dotfiles/host-myhostname/hooks/pre-up .dotfiles/host-myhostname/hooks/post-up

  $ echo 'echo "host-example" > /tmp/test3' > .dotfiles/host-myhostname/hooks/pre-up
  > echo 'cat /tmp/test3; rm /tmp/test3' > .dotfiles/host-myhostname/hooks/post-up

  $ mkdir -p .dotfiles/tag-test/hooks
  > touch .dotfiles/tag-test/hooks/pre-up .dotfiles/tag-test/hooks/post-up
  > chmod +x .dotfiles/tag-test/hooks/pre-up .dotfiles/tag-test/hooks/post-up

  $ echo 'echo "tag-example" > /tmp/test' > .dotfiles/tag-test/hooks/pre-up
  > echo 'cat /tmp/test; rm /tmp/test' > .dotfiles/tag-test/hooks/post-up

  $ mkdir -p .dotfiles/tag-test2/hooks
  > touch .dotfiles/tag-test2/hooks/pre-up .dotfiles/tag-test2/hooks/post-up
  > chmod +x .dotfiles/tag-test2/hooks/pre-up .dotfiles/tag-test2/hooks/post-up

  $ echo 'echo "impossible" > /tmp/test2' > .dotfiles/tag-test2/hooks/pre-up
  > echo 'cat /tmp/test2; rm /tmp/test2' > .dotfiles/tag-test2/hooks/post-up

  $ rcup -B "myhostname" -t "test"
  host-example
  tag-example

Ensure that hooks run when output of lsrc is non-empty
  $ touch .dotfiles/testrc
  > rcup -B "myhostname" -t "test"
  host-example
  tag-example
