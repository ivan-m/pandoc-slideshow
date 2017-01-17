#!/usr/bin/env runhaskell

{- |
   Module      : Main
   Description : Run pandoc with pandoc-mode args
   Copyright   : (c) Ivan Lazar Miljenovic
   License     : BSD-style (see the file LICENSE)
   Maintainer  : Ivan.Miljenovic@gmail.com



 -}
module Main where

import Data.Char
import Data.List
import Data.Maybe         (fromMaybe, mapMaybe)
import System.Environment (getArgs)
import System.Process
import Text.Read          (readMaybe)

-- -----------------------------------------------------------------------------

main :: IO ()
main = do [fn, out] <- getArgs
          let pmSettingsFile = '.' : fn ++ ".default.pandoc"
          pmSettings <- readFile pmSettingsFile
          let rawArgs = mapMaybe parseArgLine (lines pmSettings)
              outArg = PArg "output" (Just [out])
              wantedArgs = outArg : filter keepArg rawArgs
              cmd = unwords ( "pandoc"
                              : map printArg wantedArgs
                              ++ [fn]
                            )
          runCommand cmd >>= waitForProcess >> return ()

data PArg = PArg { arg   :: String
                 , value :: Maybe [String]
                 }
            deriving (Eq, Ord, Show, Read)

-- Each line is either:
-- * A comment (ignore)
-- * blank (ignore)
-- * Consists of an empty setting such as "(foo)" (ignore)
-- * An argument we want to keep: the first one starts with "(("; the rest with " (".
--
-- Arguments of the form "(key . t)" we just keep the key.
--
-- In general, this doesn't distinguish between "(key . value)" and
-- "(key value)" (the latter used for a list of values).
parseArgLine :: String -> Maybe PArg
parseArgLine ln = case ln of
                    '(':'(':argln -> prs argln
                    ' ':'(':argln -> prs argln
                    _             -> Nothing
  where
    prs argln
      = case break isSpace argln of
          -- A setting we don't care about
          (_,[]) -> Nothing
          (ra,rv) ->
            let a = dropWhileEnd isSpace ra
                mv = -- remove initial ". "; hope there's no ')' in a setting
                     case takeWhile (/=')') (dropWhile (\c -> c == '.' || isSpace c) rv) of
                       "t" -> Nothing
                       vs  -> Just (map valueList (words vs))
            in Just PArg { arg = a, value = mv }
    valueList v = fromMaybe v $ readMaybe v -- Check if it's an escaped String

printArg :: PArg -> String
printArg (PArg a vs) = maybe prA (unwords . map ((prA++) . ('=':))) vs
  where
    prA = "--" ++ a

keepArg :: PArg -> Bool
keepArg pa = case arg pa of
               "output"      -> False
               "master-file" -> False
               _             -> True
