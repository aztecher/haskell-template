module Main where

import TreesThatGrows.Example1 as TTGEx1
import TypeFamily.Example1 as TFEx1

main :: IO ()
main = do
  TTGEx1.example1
  -- TFEx1.example2
  -- TFEx1.battleExample
  -- TFEx1.pickByTypeClass
  -- TFEx1.battleByTypeClass
  -- TFEx1.pickByTCTF
  -- TFEx1.battleByTCTF
  TFEx1.finalExample
