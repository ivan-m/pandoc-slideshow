#!/usr/bin/env runhaskell
{-# LANGUAGE OverloadedStrings #-}

{- |
   Module      : Main
   Description : Easily write speakers notes for pandoc + reveal.js
   Copyright   : (c) Ivan Lazar Miljenovic
   License     : BSD-style (see the file LICENSE)
   Maintainer  : Ivan.Miljenovic@gmail.com



 -}
module Main where

import Control.Arrow    (first)
import Data.List        (partition)
import Text.Pandoc.JSON

-- -----------------------------------------------------------------------------

main :: IO ()
main = toJSONFilter notify

-- -----------------------------------------------------------------------------

notify :: Maybe Format -> Block -> [Block]
notify mfmt dl@(DefinitionList dfs)
  = case getNotes dfs of
      ([],_)      -> [dl]
      (nts, dfs') -> let dl' = DefinitionList dfs'
                     in case mfmt of
                          Just "revealjs" -> RawBlock (Format "html") "<aside class=\"notes\">"
                                             : nts
                                             ++ [ RawBlock (Format "html") "</aside>"
                                                , dl'
                                                ]
                          Just "dzslides" -> [Div ("",[],[("role","note")]) nts, dl']
                          _               -> [dl']
notify _ bl = [bl]

type DefList = [([Inline], [[Block]])]

getNotes :: DefList -> ([Block], DefList)
getNotes = first merge . partition isNote
  where
    isNote ([Str "Notes"],_) = True
    isNote _                 = False

    merge = concat . concatMap snd
