{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( someFunc
    ) where

import System.Environment
import Data.Time.Format
import Data.Time
import Data.Time.Clock
import Data.Maybe
import Database.PostgreSQL.Simple
import Data.ByteString.UTF8

nominalDay1 :: NominalDiffTime
nominalDay1 = 60 * 60 * 24 * 3 * (-1)

formatStr = "%Y-%m-%d %H:%M:%S%Q %Z"

dateStrToZonedTime :: String -> IO ZonedTime
dateStrToZonedTime dateStr = do
  utcTime         <- parseTimeM True defaultTimeLocale formatStr dateStr
  currentTimeZone <- getCurrentTimeZone
  return $ utcToZonedTime currentTimeZone utcTime

getConnection :: IO Connection
getConnection = do
  databaseUrl <- getEnv "DATABASE_URL"
  conn <- connectPostgreSQL $ fromString databaseUrl
  return conn

deleteData :: ZonedTime -> IO ()
deleteData openTime = do
  conn <- getConnection 
  withTransaction conn $
    (do
       execute conn "delete from klines where open_time < ?" (Only openTime :: Only ZonedTime)
       return ()
    )

createNowTime :: ZonedTime -> ZonedTime
createNowTime openTime2 = ZonedTime {
                            zonedTimeToLocalTime = _nowLocalTime,
                            zonedTimeZone = _timeZone
                          }
                          where
                            _localTime = (zonedTimeToLocalTime openTime2)
                            _timeZone  = (zonedTimeZone openTime2)
                            _localDay  = (localDay _localTime)
                            _localTimeOfDay = (localTimeOfDay _localTime)
                            _localTimeOfDay2 = TimeOfDay {
                                                todHour = 0,
                                                todMin = 0,
                                                todSec = 0
                                               }
                            _nowLocalTime = LocalTime {
                                              localDay = _localDay,
                                              localTimeOfDay = _localTimeOfDay2
                                            }

someFunc :: IO ()
someFunc = do
  myZonedTime <- createNowTime <$> getZonedTime
  let utcTime = zonedTimeToUTC myZonedTime  
  let t = addUTCTime nominalDay1 utcTime
  timeZone <- getCurrentTimeZone
  let t2 = utcToZonedTime timeZone t
  print t2
  print "a"
  deleteData t2
