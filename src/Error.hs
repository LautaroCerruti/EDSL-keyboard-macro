module Error where

data Error = Error String

instance Show Error where
  show (Error e) = show e