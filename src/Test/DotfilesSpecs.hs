module Test.DotfilesSpecs (dotfilesSpecs) where

import Test.Hspec
import Test.QuickCheck
import System.Directory
import System.IO
import System.FilePath (joinPath)
import Control.Exception (finally, catch, SomeException)
import Data.Set (Set)
import qualified Data.Set as Set

import Rcm.Private.Patterns (exclPat)
import Rcm.Private.Dotfiles (getDotfiles, Dotfile(..))
import Rcm.Private.Data

dotfilesSpecs = describe "Rcm.Private.Dotfiles" $ do
  context "getDotfiles" $ do
    context "normal dotfiles" $ do
      around setupNormalDotfiles $ do
        it "produces dotfiles from the given directories" $
          let config = mkConfig {
               dotfilesDirs = [tmpDotfileDir], homeDir = tmpHomeDir }
              mkD = mkDotfile tmpHomeDir tmpDotfileDir
              expected = [mkD (Just "gnupg") (Just "gnupg") "gpg.conf"
                         ,mkD (Just "cabal") (Just "cabal") "config"
                         ,mkD Nothing Nothing "zshrc"
                         ,mkD Nothing Nothing "vimrc"]
          in getDotfiles config [] `shouldReturnWithSet` expected

    context "tagged dotfiles" $ do
      around setupTaggedDotfiles $ do
        it "produces no tagged dotfiles by default" $
          let config = mkConfig {
               dotfilesDirs = [tmpDotfileDir], homeDir = tmpHomeDir }
              mkD = mkDotfile tmpHomeDir tmpDotfileDir
              expected = [mkD (Just "gnupg") (Just "gnupg") "gpg.conf"
                         ,mkD (Just "cabal") (Just "cabal") "config"
                         ,mkD Nothing Nothing "zshrc"
                         ,mkD Nothing Nothing "vimrc"]
          in getDotfiles config [] `shouldReturnWithSet` expected

        it "produces dotfiles matching the tag when asked" $
          let config = mkConfig {
               dotfilesDirs = [tmpDotfileDir], homeDir = tmpHomeDir,
               tags = ["ruby", "go"] }
              mkD = mkDotfile tmpHomeDir tmpDotfileDir
              rubyDotfile = Dotfile {
                 dotfileTarget = DotfileTarget {
                   dtBase = tmpDotfileDir
                  ,dtPath = Nothing
                  ,dtFile = "irbrc"
                  ,dtTag = Just "ruby"
                  ,dtHost = Nothing }
                ,dotfileSource = joinPath [tmpHomeDir, ".irbrc"] }
              expected = [mkD (Just "gnupg") (Just "gnupg") "gpg.conf"
                         ,mkD (Just "cabal") (Just "cabal") "config"
                         ,rubyDotfile
                         ,mkD Nothing Nothing "zshrc"
                         ,mkD Nothing Nothing "vimrc"]
          in getDotfiles config [] `shouldReturnWithSet` expected

    context "host-specific dotfiles" $ do
      around (setupHostnameDotfiles "gibson") $ do
        it "produces host-specific dotfiles by default" $
          let config = mkConfig {
               dotfilesDirs = [tmpDotfileDir], homeDir = tmpHomeDir,
               hostname = "gibson" }
              mkD = mkDotfile tmpHomeDir tmpDotfileDir
              hostDotfile = Dotfile {
                 dotfileTarget = DotfileTarget {
                   dtBase = tmpDotfileDir
                  ,dtPath = Nothing
                  ,dtFile = "rcrc"
                  ,dtTag = Nothing
                  ,dtHost = Just "gibson" }
                ,dotfileSource = joinPath [tmpHomeDir, ".rcrc"] }
              expected = [mkD (Just "gnupg") (Just "gnupg") "gpg.conf"
                         ,mkD (Just "cabal") (Just "cabal") "config"
                         ,hostDotfile
                         ,mkD Nothing Nothing "zshrc"
                         ,mkD Nothing Nothing "vimrc"]
          in getDotfiles config [] `shouldReturnWithSet` expected

  context "excluded files" $ do
    around setupMultipleDotfiles $ do
      it "ignores the excluded files" $
          let config = mkConfig {
               dotfilesDirs = [tmpDotfileDir, otherDotfileDir],
               homeDir = tmpHomeDir,
               excludes = [exclPat "gnupg/gpg.conf",
                           exclPat "/tmp/rcm-other-dotfile-dir:cabal/config"]
               }
              mkD = mkDotfile tmpHomeDir tmpDotfileDir
              hostDotfile = Dotfile {
                 dotfileTarget = DotfileTarget {
                   dtBase = tmpDotfileDir
                  ,dtPath = Nothing
                  ,dtFile = "rcrc"
                  ,dtTag = Nothing
                  ,dtHost = Just "gibson" }
                ,dotfileSource = joinPath [tmpHomeDir, ".rcrc"] }
              expected = [mkD (Just "cabal") (Just "cabal") "config"
                         ,mkD Nothing Nothing "zshrc"
                         ,mkD Nothing Nothing "vimrc"
                         ,mkDotfile tmpHomeDir otherDotfileDir Nothing Nothing "mkshrc"
                         ,mkDotfile tmpHomeDir otherDotfileDir Nothing Nothing "xmodmap"]
          in getDotfiles config [] `shouldReturnWithSet` expected
        

mkConfig = Config {
  showSigils = False
 ,showHelp = False
 ,includes = []
 ,tags = []
 ,verbosity = 0
 ,dotfilesDirs = []
 ,showVersion = False
 ,excludes = []
 ,symlinkDirs = []
 ,homeDir = "/home/foo"
 ,hostname = "cyberdelia"
}

tmpDotfileDir = "/tmp/rcm-tmp-dotfile-dir"
otherDotfileDir = "/tmp/rcm-other-dotfile-dir"
tmpHomeDir = "/tmp/rcm-tmp-home-dir"

setupNormalDotfiles :: IO () -> IO ()
setupNormalDotfiles test =
  (createNormalDotfiles >> test) `finally` removeDotfiles

setupTaggedDotfiles :: IO () -> IO ()
setupTaggedDotfiles test =
  (createNormalDotfiles >> createTaggedDotfiles >> test)
    `finally` removeDotfiles

setupHostnameDotfiles hostname test =
  (createNormalDotfiles >> createHostnameDotfiles hostname >> test)
    `finally` removeDotfiles

setupMultipleDotfiles test =
  (createNormalDotfiles >> createOtherDotfiles >> test) `finally` removeDotfiles

createNormalDotfiles = do
  ensureDirectory tmpDotfileDir
  ensureDirectory (joinPath [tmpDotfileDir, "gnupg"])
  ensureDirectory (joinPath [tmpDotfileDir, "cabal"])
  touchFile (joinPath [tmpDotfileDir, "gnupg", "gpg.conf"])
  touchFile (joinPath [tmpDotfileDir, "cabal", "config"])
  touchFile (joinPath [tmpDotfileDir, "zshrc"])
  touchFile (joinPath [tmpDotfileDir, "vimrc"])

createTaggedDotfiles = do
  ensureDirectory tmpDotfileDir
  ensureDirectory (joinPath [tmpDotfileDir, "tag-ruby"])
  ensureDirectory (joinPath [tmpDotfileDir, "tag-ssh"])
  touchFile (joinPath [tmpDotfileDir, "tag-ruby", "irbrc"])
  touchFile (joinPath [tmpDotfileDir, "tag-ssh", "ssh_config"])

createHostnameDotfiles hostname = do
  ensureDirectory tmpDotfileDir
  ensureDirectory (joinPath [tmpDotfileDir, "host-" ++ hostname])
  ensureDirectory (joinPath [tmpDotfileDir, "host-" ++ hostname ++ "-aux"])
  touchFile (joinPath [tmpDotfileDir, "host-" ++ hostname, "rcrc"])
  touchFile (joinPath [tmpDotfileDir, "host-" ++ hostname ++ "-aux", "rcrc"])

createOtherDotfiles = do
  ensureDirectory otherDotfileDir
  ensureDirectory (joinPath [otherDotfileDir, "cabal"])
  touchFile (joinPath [otherDotfileDir, "cabal", "config"])
  touchFile (joinPath [otherDotfileDir, "xmodmap"])

removeDotfiles =
  (removeDirectoryRecursive tmpDotfileDir) `orException` return ()

mkDotfile homeDir baseDir targetPath sourcePath file = Dotfile {
    dotfileTarget = DotfileTarget {
      dtBase = baseDir
     ,dtPath = targetPath
     ,dtFile = file
     ,dtTag  = Nothing
     ,dtHost = Nothing
     }
   ,dotfileSource = joinPath [homeDir, "." ++ pathAndFile]
  }
  where pathAndFile = maybe file (\p -> joinPath [p, file]) sourcePath

shouldReturnWithSet :: (Show a, Ord a) => IO [a] -> [a] -> Expectation
shouldReturnWithSet action expected =
  (action `orException` return []) >>= \actual ->
    shouldBe (Set.fromList actual) (Set.fromList expected)

ensureDirectory path = (createDirectory path) `orException` return ()
touchFile path = writeFile path ""

orException io orResult = io `catch` f
  where f x = let y = x :: SomeException in orResult
