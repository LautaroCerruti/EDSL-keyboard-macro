module MonadKM (
  KM,
  runKM,
  failKM,
  addDef,
  lookupDef,
  MonadKM,
  module Control.Monad.Except,
  module Control.Monad.State)
 where

import Common
import Error ( Error(..) )
import Control.Monad.State
import Control.Monad.Except

class (MonadIO m, MonadState GlEnv m, MonadError Error m) => MonadKM m where
addDef :: MonadKM m => Stmt Tm -> m ()
addDef d = modify (\s -> s { glb = d : glb s})

lookupDef :: MonadKM m => Name -> m (Maybe Tm)
lookupDef name = do
     s <- get
     case filter (hasName name) (glb s) of
       (Def _ e):_ -> return (Just e)
       (Macro _ e):_ -> return (Just e)
       _ -> return Nothing
   where hasName :: Name -> Stmt a -> Bool
         hasName nm (Def nm' _) = nm == nm'
         hasName nm (Macro nm' _) = nm == nm'

failKM :: MonadKM m => String -> m a
failKM s = throwError (Error s)

type KM = StateT GlEnv (ExceptT Error IO)

instance MonadKM KM

runKM' :: KM a -> IO (Either Error (a, GlEnv))
runKM' c =  runExceptT $ runStateT c initialEnv

runKM :: KM a -> IO (Either Error a)
runKM c = fmap fst <$> runKM' c