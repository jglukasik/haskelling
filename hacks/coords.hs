-- Reads a CSV full of McDonald's latitude and longitudes in the USA, and prints out the ones furthest north,south,east,west
import Text.CSV
import Data.Maybe
import System.Environment(getArgs)

main :: IO ()
main = do
  args <- getArgs
  let fileName = case args of
       (a:_) -> a
       _ -> "mcdonalds.csv"
  input <- readFile fileName
  let csv = parseCSV fileName input
  putStrLn "Furthest north, south, east, west"
  either handleError doWork csv

-- Error handling is CSV cannot be parsed
handleError :: t -> IO ()
handleError csv = putStrLn "error parsing"

-- Print out the maxima (latitude, longitude) for the data set
doWork :: [[Field]] -> IO ()
doWork x = (print.allStats.cleanCoords.map getCoords) x

-- Grab the latitude and longitudes from the data set
getCoords :: [Field] -> Maybe (Float, Float)
getCoords [] = Nothing
getCoords [x] = Nothing
getCoords (x:y:_) = Just (lat,long)
  where lat = read y :: Float
        long = read x :: Float

-- Clean up the coordinates, getting rid of any possible errors (Nothings)
cleanCoords ::(Eq a) => [Maybe a] -> [a]
cleanCoords (x:xs)
  | x == Nothing = cleanCoords xs
  | otherwise = fromJust x:cleanCoords xs
cleanCoords [] = []

-- Find all maxima in one function
allStats :: [(Float, Float)] -> [(Float, Float)]
allStats coords = map ($ coords) [maxLat, minLat, maxLong, minLong]

-- Find the maxima of the coordinate sets
maxLat :: (Num a, Ord a) => [(a, a)] -> (a, a)
maxLat = foldl1 (\acc x -> if fst x > fst acc then x else acc)

minLat :: (Num a, Ord a) => [(a, a)] -> (a, a)
minLat = foldl1 (\acc x -> if fst x < fst acc then x else acc)

maxLong :: (Num a, Ord a) => [(a, a)] -> (a, a)
maxLong = foldl1 (\acc x -> if snd x > snd acc then x else acc)

minLong :: (Num a, Ord a) => [(a, a)] -> (a, a)
minLong = foldl1 (\acc x -> if snd x < snd acc then x else acc)

