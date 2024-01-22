module MonadKM (
  KM,
  runKM,
  failKM,
  addDef,
  lookupDef,
  printKM,
  MonadKM,
  module Control.Monad.Except,
  module Control.Monad.State)
 where

import Common
import Error ( Error(..) )
import Control.Monad.State
import Control.Monad.Except

class (MonadIO m, MonadState GlEnv m, MonadError Error m) => MonadKM m where
addDef :: MonadKM m => Def Tm -> m ()
addDef d = modify (\s -> s { glb = d : glb s})

lookupDef :: MonadKM m => Name -> m (Maybe (Def Tm))
lookupDef name = do
     s <- get
     case filter (hasName name) (glb s) of
       (Def n e):_ -> return (Just (Def n e))
       _ -> return Nothing
   where hasName :: Name -> Def a -> Bool
         hasName nm (Def nm' _) = nm == nm'

failKM :: MonadKM m => String -> m a
failKM s = throwError (Error s)

printKM :: MonadKM m => String -> m ()
printKM = liftIO . putStrLn

type KM = StateT GlEnv (ExceptT Error IO)

instance MonadKM KM

runKM' :: KM a -> IO (Either Error (a, GlEnv))
runKM' c =  runExceptT $ runStateT c initialEnv

runKM :: KM a -> IO (Either Error a)
runKM c = fmap fst <$> runKM' c