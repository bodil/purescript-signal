module Test.TestUtils 
   ( Test
   , timeout
   , success
   ) where

import Prelude

import Control.Alternative ((<|>))
import Data.Either (either)
import Data.Int (toNumber)
import Effect.Aff (Aff, Milliseconds(..), attempt, delay, error, parallel, sequential, throwError)

type Test = Aff Unit

-- | Set a test to fail after a given number of milliseconds.
timeout :: Int -> Test -> Test
timeout time t = do
  r <- sequential $ parallel (attempt $ makeTimeout time) <|> parallel (attempt t)
  either throwError (const success) r

makeTimeout :: forall a. Int -> Aff a
makeTimeout time = do
  delay $ Milliseconds $ toNumber time
  throwError $ error $ "test timed out after " <> show time <> "ms"


-- | The basic value for a succeeding test.
success :: Test
success = pure unit
