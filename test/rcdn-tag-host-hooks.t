  $ . "$TESTDIR/helper.sh"

Pre-down and post-down hooks should run for hostname and selected tags by default

  $ mkdir -p .dotfiles/host-myhostname/hooks
  > touch .dotfiles/host-myhostname/hooks/pre-down .dotfiles/host-myhostname/hooks/post-down
  > chmod +x .dotfiles/host-myhostname/hooks/pre-down .dotfiles/host-myhostname/hooks/post-down

  $ echo 'echo "host-example" > /tmp/test3' > .dotfiles/host-myhostname/hooks/pre-down
  > echo 'cat /tmp/test3; rm /tmp/test3' > .dotfiles/host-myhostname/hooks/post-down

  $ mkdir -p .dotfiles/tag-test/hooks
  > touch .dotfiles/tag-test/hooks/pre-down .dotfiles/tag-test/hooks/post-down
  > chmod +x .dotfiles/tag-test/hooks/pre-down .dotfiles/tag-test/hooks/post-down

  $ echo 'echo "tag-example" > /tmp/test' > .dotfiles/tag-test/hooks/pre-down
  > echo 'cat /tmp/test; rm /tmp/test' > .dotfiles/tag-test/hooks/post-down

  $ mkdir -p .dotfiles/tag-test2/hooks
  > touch .dotfiles/tag-test2/hooks/pre-down .dotfiles/tag-test2/hooks/post-down
  > chmod +x .dotfiles/tag-test2/hooks/pre-down .dotfiles/tag-test2/hooks/post-down

  $ echo 'echo "impossible" > /tmp/test2' > .dotfiles/tag-test2/hooks/pre-down
  > echo 'cat /tmp/test2; rm /tmp/test2' > .dotfiles/tag-test2/hooks/post-down

  $ rcdn -B "myhostname" -t "test"
  host-example
  tag-example

Ensure that hooks run when output of lsrc is non-empty
  $ touch .dotfiles/testrc
  > rcup -B "myhostname" -t "test"
  > rcdn -B "myhostname" -t "test"
  host-example
  tag-example
