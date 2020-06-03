module Lib
    ( someFunc
    ) where

import System.Environment

someFunc :: IO ()
someFunc = do
  databaseUrl <- getEnv "DATABASE_URL"
  putStrLn databaseUrl

