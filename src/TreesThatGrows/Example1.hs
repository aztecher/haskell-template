{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
module TreesThatGrows.Example1 where

-- https://mizunashi-mana.github.io/blog/posts/2019/11/trees-that-grow/

import Data.Kind
import Data.Void

data Ast p
  = Add (Ast p) (Ast p)
  | Num Integer
  | XAst (XAst p)

type family XAst (p :: Type) :: Type

class EvalXAst p where
  evalXAst :: (Ast p -> Integer) -> XAst p -> Integer


eval :: forall p. EvalXAst p => Ast p -> Integer
eval = go
  where
    goXAst = evalXAst @p go
    go (Add x y) = go x + go y
    go (Num i)   = i
    go (XAst x)  = goXAst x

data OldAst
type instance XAst OldAst = Void

instance EvalXAst OldAst where
  evalXAst _ = absurd

data WithMul p = Mul (Ast p) (Ast p)

data NewAst
type instance XAst NewAst = WithMul NewAst

instance EvalXAst NewAst where
  evalXAst go (Mul x y) = go x * go y

example1 :: IO ()
example1 = putStrLn "hello, trees that grows"
